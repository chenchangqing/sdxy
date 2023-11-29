# librtmp源码之SendReleaseStream

```c
// 发送RealeaseStream命令
// Real Time Messaging Protocol (AMF0 Command releaseStream())
//    RTMP Header
//        01.. .... = Format: 1
//        ..00 0011 = Chunk Stream ID: 3
//        Timestamp delta: 0
//        Timestamp: 0 (calculated)
//        Body size: 39
//        Type ID: AMF0 Command (0x14)
//    RTMP Body
//        String 'releaseStream'
//        Number 2
//        Null
//        String 'livestream'
static int
SendReleaseStream(RTMP *r)
{
    RTMPPacket packet;
    char pbuf[1024], *pend = pbuf + sizeof(pbuf);
    char *enc;
    // 块流ID，`..00 0011 = Chunk Stream ID: 3`中的11，第1个字节的低两位
    packet.m_nChannel = 0x03;   /* control channel (invoke) */
    // 块类型ID，`01.. .... = Format: 1`中的01，第1个字节的高两位
    packet.m_headerType = RTMP_PACKET_SIZE_MEDIUM;
    // 命令类型ID，`Type ID: AMF0 Command (0x14)`，第8个字节
    packet.m_packetType = RTMP_PACKET_TYPE_INVOKE;
    // 时间戳第2、3、4字节
    packet.m_nTimeStamp = 0;
    // 消息流ID，这里块类型ID为1，只有8个字节，这里是没有消息流ID的
    packet.m_nInfoField2 = 0;
    // 是否是绝对时间戳(类型1时为true)
    packet.m_hasAbsTimestamp = 0;
    // 块body指针，前面18（RTMP_MAX_HEADER_SIZE）字节用来放块头，后面放body
    packet.m_body = pbuf + RTMP_MAX_HEADER_SIZE;
    // 设置body开始位置
    enc = packet.m_body;
    // 对“releaseStream”字符串进行AMF编码
    enc = AMF_EncodeString(enc, pend, &av_releaseStream);
    // 对传输ID（0）进行AMF编码，0x14命令远程过程调用计数
    enc = AMF_EncodeNumber(enc, pend, ++r->m_numInvokes);
    // 编码Null
    *enc++ = AMF_NULL;
    // 对播放路径字符串进行AMF编码，livestream
    enc = AMF_EncodeString(enc, pend, &r->Link.playpath);
    if (!enc)
        return FALSE;
    // 块body大小，第5、6、7个字节
    packet.m_nBodySize = enc - packet.m_body;
    
    return RTMP_SendPacket(r, &packet, FALSE);
}
```

>参考：

[librtmp源码分析之核心实现解读](https://www.jianshu.com/p/05b1e5d70c06)

[RTMPdump（libRTMP） 源代码分析 8： 发送消息（Message））](https://blog.csdn.net/leixiaohua1020/article/details/12958747)

[手撕rtmp协议细节（2）——rtmp Header](https://cloud.tencent.com/developer/article/1630595?from=article.detail.1630594)

[手撕Rtmp协议细节（3）——Rtmp Body](https://cloud.tencent.com/developer/article/1630594)