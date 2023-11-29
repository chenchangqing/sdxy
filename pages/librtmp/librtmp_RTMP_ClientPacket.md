# librtmp源码之RTMP_ClientPacket

```c
// 处理消息（Message），并做出响应
int
RTMP_ClientPacket(RTMP *r, RTMPPacket *packet)
{
    // 返回值为1表示推拉流正在正作中，为2表示已经停止
    int bHasMediaPacket = 0;
    switch (packet->m_packetType)
    {
    // RTMP消息类型ID=1,设置块大小
    case RTMP_PACKET_TYPE_CHUNK_SIZE:
        /* chunk size */
        RTMP_Log(RTMP_LOGDEBUG, "CCQ: %s 处理消息 Set Chunk Size (typeID=1)", __FUNCTION__);
        // 更新接收处理时的块限制
        HandleChangeChunkSize(r, packet);
        break;
    // 对端反馈的已读大小
    // RTMP消息类型ID=3
    case RTMP_PACKET_TYPE_BYTES_READ_REPORT:
        /* bytes read report */
        RTMP_Log(RTMP_LOGDEBUG, "%s, received: bytes read report", __FUNCTION__);
        break;
    // RTMP消息类型ID=4，用户控制
    // 处理对端发送的控制报文
    case RTMP_PACKET_TYPE_CONTROL:
        /* ctrl */
        RTMP_Log(RTMP_LOGDEBUG, "CCQ: %s 处理消息 User Control (typeID=4)", __FUNCTION__);
        HandleCtrl(r, packet);
        break;
    // RTMP消息类型ID=5
    case RTMP_PACKET_TYPE_SERVER_BW:
        /* server bw */
        // 处理对端发送的应答窗口大小，这里由服务器发送，即告之客户端收到对应大小的数据后应发送反馈
        RTMP_Log(RTMP_LOGDEBUG, "CCQ: %s 处理消息 Window Acknowledgement Size (typeID=5)", __FUNCTION__);
        HandleServerBW(r, packet);
        break;
    // RTMP消息类型ID=6
    case RTMP_PACKET_TYPE_CLIENT_BW:
        /* client bw */
        // 处理对端发送的设置发送带宽大小，这里由服务器发送，即设置客户端的发送带宽
        RTMP_Log(RTMP_LOGDEBUG, "CCQ: %s 处理消息 Set Peer Bandwidth (typeID=6)", __FUNCTION__);
        HandleClientBW(r, packet);
        break;
    // RTMP消息类型ID=8，音频数据
    case RTMP_PACKET_TYPE_AUDIO:
        /* audio data */
        /*RTMP_Log(RTMP_LOGDEBUG, "%s, received: audio %lu bytes", __FUNCTION__, packet.m_nBodySize); */
        HandleAudio(r, packet);
        bHasMediaPacket = 1;
        if (!r->m_mediaChannel)
            r->m_mediaChannel = packet->m_nChannel;
        if (!r->m_pausing)
            r->m_mediaStamp = packet->m_nTimeStamp;
        break;
    // RTMP消息类型ID=9，视频数据
    case RTMP_PACKET_TYPE_VIDEO:
        /* video data */
        /*RTMP_Log(RTMP_LOGDEBUG, "%s, received: video %lu bytes", __FUNCTION__, packet.m_nBodySize); */
        HandleVideo(r, packet);
        bHasMediaPacket = 1;
        if (!r->m_mediaChannel)
            r->m_mediaChannel = packet->m_nChannel;
        if (!r->m_pausing)
            r->m_mediaStamp = packet->m_nTimeStamp;
        break;
    // RTMP消息类型ID=15，AMF3编码，忽略
    case RTMP_PACKET_TYPE_FLEX_STREAM_SEND:
        /* flex stream send */
        RTMP_Log(RTMP_LOGDEBUG,
                "%s, flex stream send, size %u bytes, not supported, ignoring",
                __FUNCTION__, packet->m_nBodySize);
        break;
    // RTMP消息类型ID=16，AMF3编码，忽略
    case RTMP_PACKET_TYPE_FLEX_SHARED_OBJECT:
        /* flex shared object */
        RTMP_Log(RTMP_LOGDEBUG,
                "%s, flex shared object, size %u bytes, not supported, ignoring",
                 __FUNCTION__, packet->m_nBodySize);
        break;
    // RTMP消息类型ID=17，AMF3编码，忽略
    case RTMP_PACKET_TYPE_FLEX_MESSAGE:
    /* flex message */
    {
        RTMP_Log(RTMP_LOGDEBUG,
                 "%s, flex message, size %u bytes, not fully supported",
                 __FUNCTION__, packet->m_nBodySize);
        /*RTMP_LogHex(packet.m_body, packet.m_nBodySize); */

        /* some DEBUG code */
#if 0
        RTMP_LIB_AMFObject obj;
        int nRes = obj.Decode(packet.m_body+1, packet.m_nBodySize-1);
        if(nRes < 0) {
           RTMP_Log(RTMP_LOGERROR, "%s, error decoding AMF3 packet", __FUNCTION__);
           /*return; */
        }

        obj.Dump();
#endif

        if (HandleInvoke(r, packet->m_body + 1, packet->m_nBodySize - 1) == 1)
            bHasMediaPacket = 2;
        break;
    }
    // RTMP消息类型ID=18，AMF0编码，数据消息
    case RTMP_PACKET_TYPE_INFO:
        /* metadata (notify) */
        RTMP_Log(RTMP_LOGDEBUG, "%s, received: notify %u bytes", __FUNCTION__,
                 packet->m_nBodySize);
        if (HandleMetadata(r, packet->m_body, packet->m_nBodySize))
            bHasMediaPacket = 1;
        break;
    // RTMP消息类型ID=19，AMF0编码，忽略
    case RTMP_PACKET_TYPE_SHARED_OBJECT:
        RTMP_Log(RTMP_LOGDEBUG, "%s, shared object, not supported, ignoring",
                 __FUNCTION__);
        break;
    // RTMP消息类型ID=20，AMF0编码，命令消息
    // 处理命令消息！
    case RTMP_PACKET_TYPE_INVOKE:
        /* invoke */
        RTMP_Log(RTMP_LOGDEBUG, "%s, received: invoke %u bytes", __FUNCTION__,
                 packet->m_nBodySize);
        RTMP_Log(RTMP_LOGDEBUG, "CCQ: %s 处理消息 (typeID=20，AMF0编码)", __FUNCTION__);
        /*RTMP_LogHex(packet.m_body, packet.m_nBodySize); */

        if (HandleInvoke(r, packet->m_body, packet->m_nBodySize) == 1)
            bHasMediaPacket = 2;
        break;
    // RTMP消息类型ID=22
    case RTMP_PACKET_TYPE_FLASH_VIDEO:
    {
        /* go through FLV packets and handle metadata packets */
        unsigned int pos = 0;
        uint32_t nTimeStamp = packet->m_nTimeStamp;
        
        while (pos + 11 < packet->m_nBodySize)
        {
            uint32_t dataSize = AMF_DecodeInt24(packet->m_body + pos + 1);  /* size without header (11) and prevTagSize (4) */
            
            if (pos + 11 + dataSize + 4 > packet->m_nBodySize)
            {
                RTMP_Log(RTMP_LOGWARNING, "Stream corrupt?!");
                break;
            }
            if (packet->m_body[pos] == 0x12)
            {
                HandleMetadata(r, packet->m_body + pos + 11, dataSize);
            }
            else if (packet->m_body[pos] == 8 || packet->m_body[pos] == 9)
            {
                nTimeStamp = AMF_DecodeInt24(packet->m_body + pos + 4);
                nTimeStamp |= (packet->m_body[pos + 7] << 24);
            }
            pos += (11 + dataSize + 4);
        }
        if (!r->m_pausing)
            r->m_mediaStamp = nTimeStamp;
        
        /* FLV tag(s) */
        /*RTMP_Log(RTMP_LOGDEBUG, "%s, received: FLV tag(s) %lu bytes", __FUNCTION__, packet.m_nBodySize); */
        bHasMediaPacket = 1;
        break;
    }
    default:
        RTMP_Log(RTMP_LOGDEBUG, "%s, unknown packet type received: 0x%02x", __FUNCTION__,
                 packet->m_packetType);
#ifdef _DEBUG
        RTMP_LogHex(RTMP_LOGDEBUG, packet->m_body, packet->m_nBodySize);
#endif
    }
    // 返回值为1表示推拉流正在正作中，为2表示已经停止
    return bHasMediaPacket;
}
```

>参考：

[RTMPdump（libRTMP） 源代码分析 7： 建立一个流媒体连接 （NetStream部分 2）](https://blog.csdn.net/leixiaohua1020/article/details/12958617)

[librtmp源码分析之核心实现解读](https://www.jianshu.com/p/05b1e5d70c06)