# librtmp源码之SendFCPublish

```c
// 发送准备推流点请求
// Real Time Messaging Protocol (AMF0 Command FCPublish())
//    RTMP Header
//        01.. .... = Format: 1
//        ..00 0011 = Chunk Stream ID: 3
//        Timestamp delta: 0
//        Timestamp: 0 (calculated)
//        Body size: 35
//        Type ID: AMF0 Command (0x14)
//    RTMP Body
//        String 'FCPublish'
//            AMF0 type: String (0x02)
//            String length: 9
//            String: FCPublish
//        Number 3
//            AMF0 type: Number (0x00)
//            Number: 3
//        Null
//            AMF0 type: Null (0x05)
//        String 'livestream'
//            AMF0 type: String (0x02)
//            String length: 10
//            String: livestream
static int
SendFCPublish(RTMP *r)
{
    RTMPPacket packet;
    char pbuf[1024], *pend = pbuf + sizeof(pbuf);
    char *enc;
    
    packet.m_nChannel = 0x03; /* control channel (invoke) */
    packet.m_headerType = RTMP_PACKET_SIZE_MEDIUM;
    packet.m_packetType = RTMP_PACKET_TYPE_INVOKE;
    packet.m_nTimeStamp = 0;
    packet.m_nInfoField2 = 0;
    packet.m_hasAbsTimestamp = 0;
    packet.m_body = pbuf + RTMP_MAX_HEADER_SIZE;
    
    enc = packet.m_body;
    // 对“FCPublish”字符串进行AMF编码
    enc = AMF_EncodeString(enc, pend, &av_FCPublish);
    enc = AMF_EncodeNumber(enc, pend, ++r->m_numInvokes);
    *enc++ = AMF_NULL;
    enc = AMF_EncodeString(enc, pend, &r->Link.playpath);
    if (!enc)
        return FALSE;
    
    packet.m_nBodySize = enc - packet.m_body;
    
    return RTMP_SendPacket(r, &packet, FALSE);
}
```

和`SendReleaseStream`函数类似，区别在与body的第一个字段是`FCPublish`。

>参考：

[librtmp源码分析之核心实现解读](https://www.jianshu.com/p/05b1e5d70c06)