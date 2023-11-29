# librtmp源码之RTMP_SendCtrl

```c
// 发送用戶控制消息
//Ping 是 RTMP 中最神秘的消息，直到现在我们还没有完全解释它。总之，Ping 消息用作客户端和服务器之间交换的特殊命令。此页面旨在记录所有已知的 Ping 消息。预计名单会增长。
//
//Ping 数据包的类型为 0x4，包含两个强制参数和两个可选参数。第一个参数是 Ping 的类型，简称整数。第二个参数是 ping 的目标。由于 Ping 始终在 Channel 2（控制通道）中发送，并且 RTMP 标头中的目标对象始终为 0，这意味着 Connection 对象，因此有必要放置一个额外的参数来指示 Ping 发送到的确切目标对象。第二个参数承担这个责任。该值与 RTMP 头中的目标对象字段含义相同。 （第二个值也可以做其他用途，比如RTT Ping/Pong。它用作时间戳。）第三个和第四个参数是可选的，可以看作是Ping包的参数。以下是 Ping 消息的无穷无尽的列表。
//
//    * 类型 0：清除流。没有第三个和第四个参数。第二个参数可以是 0。建立连接后，服务器会向客户端发送 Ping 0,0。该消息还将在 Play 开始时发送给客户端，并响应 Seek 或 Pause/Resume 请求。此 Ping 告诉客户端使用下一个数据包服务器发送的时间戳重新校准时钟。
//    * 类型 1：告诉流清除播放缓冲区。
//    * 类型 3：客户端的缓冲时间。第三个参数是以毫秒为单位的缓冲时间。
//    * 类型 4：重置流。在 VOD 的情况下与类型 0 一起使用。通常在类型 0 之前发送。
//    * 类型 6：从服务器 Ping 客户端。第二个参数是当前时间。
//    * 类型 7：来自客户的 Pong 回复。第二个参数是服务器发送他的 ping 请求的时间。
//    * 类型 26：SWFVerification 请求
//    * 类型 27：SWFVerification 响应
int
RTMP_SendCtrl(RTMP *r, short nType, unsigned int nObject, unsigned int nTime)
{
    RTMPPacket packet;
    char pbuf[256], *pend = pbuf + sizeof(pbuf);
    int nSize;
    char *buf;
    
    RTMP_Log(RTMP_LOGDEBUG, "sending ctrl. type: 0x%04x", (unsigned short)nType);
    
    packet.m_nChannel = 0x02; /* control channel (ping) */
    packet.m_headerType = RTMP_PACKET_SIZE_MEDIUM;
    // #define RTMP_PACKET_TYPE_CONTROL            0x04
    packet.m_packetType = RTMP_PACKET_TYPE_CONTROL;
    packet.m_nTimeStamp = 0;  /* RTMP_GetTime(); */
    packet.m_nInfoField2 = 0;
    packet.m_hasAbsTimestamp = 0;
    packet.m_body = pbuf + RTMP_MAX_HEADER_SIZE;
    
    switch(nType) {
        case 0x03: nSize = 10; break; /* buffer time */
        case 0x1A: nSize = 3; break;  /* SWF verify request */
        case 0x1B: nSize = 44; break; /* SWF verify response */
        default: nSize = 6; break;
    }
    
    packet.m_nBodySize = nSize;
    
    buf = packet.m_body;
    buf = AMF_EncodeInt16(buf, pend, nType);
    
    if (nType == 0x1B)
    {
#ifdef CRYPTO
        memcpy(buf, r->Link.SWFVerificationResponse, 42);
        RTMP_Log(RTMP_LOGDEBUG, "Sending SWFVerification response: ");
        RTMP_LogHex(RTMP_LOGDEBUG, (uint8_t *)packet.m_body, packet.m_nBodySize);
#endif
    }
    else if (nType == 0x1A)
    {
        *buf = nObject & 0xff;
    }
    else
    {
        if (nSize > 2)
            buf = AMF_EncodeInt32(buf, pend, nObject);
        
        if (nSize > 6)
            buf = AMF_EncodeInt32(buf, pend, nTime);
    }
    
    return RTMP_SendPacket(r, &packet, FALSE);
}
```

>参考：

[librtmp源码分析之核心实现解读](https://www.jianshu.com/p/05b1e5d70c06)