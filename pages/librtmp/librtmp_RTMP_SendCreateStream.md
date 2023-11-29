# librtmp源码之RTMP_SendCreateStream

```c
// 发送创建流请求
int
RTMP_SendCreateStream(RTMP *r)
{
    RTMPPacket packet;
    char pbuf[256], *pend = pbuf + sizeof(pbuf);
    char *enc;
    
    packet.m_nChannel = 0x03; /* control channel (invoke) */
    packet.m_headerType = RTMP_PACKET_SIZE_MEDIUM;
    packet.m_packetType = RTMP_PACKET_TYPE_INVOKE;
    packet.m_nTimeStamp = 0;
    packet.m_nInfoField2 = 0;
    packet.m_hasAbsTimestamp = 0;
    packet.m_body = pbuf + RTMP_MAX_HEADER_SIZE;
    
    enc = packet.m_body;
    enc = AMF_EncodeString(enc, pend, &av_createStream);
    enc = AMF_EncodeNumber(enc, pend, ++r->m_numInvokes);
    *enc++ = AMF_NULL;    /* NULL */
    
    packet.m_nBodySize = enc - packet.m_body;
    
    return RTMP_SendPacket(r, &packet, TRUE);
}
```

内容和`SendReleaseStream`函数差不多，只不过命令改用了`av_createStream`。

>参考：

[librtmp源码分析之核心实现解读](https://www.jianshu.com/p/05b1e5d70c06)