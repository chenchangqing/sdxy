# librtmp源码之SendPublish

```c
// 发送Publish命令
static int
SendPublish(RTMP *r)
{
    RTMPPacket packet;
    char pbuf[1024], *pend = pbuf + sizeof(pbuf);
    char *enc;
    // 块流ID，04: control stream
    packet.m_nChannel = 0x04; /* source channel (invoke) */
    packet.m_headerType = RTMP_PACKET_SIZE_LARGE;
    packet.m_packetType = RTMP_PACKET_TYPE_INVOKE;
    packet.m_nTimeStamp = 0;
    // 消息流ID，这个时候就有了流ID，因为这个方法是在收到服务器返回创建流的时候调用
    packet.m_nInfoField2 = r->m_stream_id;
    packet.m_hasAbsTimestamp = 0;
    packet.m_body = pbuf + RTMP_MAX_HEADER_SIZE;
    
    enc = packet.m_body;
    // 压入publish
    enc = AMF_EncodeString(enc, pend, &av_publish);
    enc = AMF_EncodeNumber(enc, pend, ++r->m_numInvokes);
    *enc++ = AMF_NULL;
    enc = AMF_EncodeString(enc, pend, &r->Link.playpath);
    if (!enc)
        return FALSE;
    
    /* FIXME: should we choose live based on Link.lFlags & RTMP_LF_LIVE? */
    enc = AMF_EncodeString(enc, pend, &av_live);
    if (!enc)
        return FALSE;
    
    packet.m_nBodySize = enc - packet.m_body;
    
    return RTMP_SendPacket(r, &packet, TRUE);
}
```

>参考：

[RTMPdump（libRTMP） 源代码分析 8： 发送消息（Message）](https://blog.csdn.net/leixiaohua1020/article/details/12958747)

[librtmp源码分析之核心实现解读](https://www.jianshu.com/p/05b1e5d70c06)