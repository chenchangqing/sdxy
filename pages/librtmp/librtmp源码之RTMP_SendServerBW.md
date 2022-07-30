# librtmp源码之RTMP_SendServerBW

```c
// 设置缓冲大小
int
RTMP_SendServerBW(RTMP *r)
{
    RTMPPacket packet;
    char pbuf[256], *pend = pbuf + sizeof(pbuf);
    // Chunk Stream ID用来表示消息的级别
    // 2:low level
    // 块流ID，`..00 0010 = Chunk Stream ID: 2`中的11，第1个字节的低两位
    packet.m_nChannel = 0x02; /* control channel (invoke) */
    // Format为0的时候，RTMP Header的长度为12
    // 块类型ID，`01.. .... = Format: 1`中的01，第1个字节的高两位
    packet.m_headerType = RTMP_PACKET_SIZE_LARGE;
    // #define RTMP_PACKET_TYPE_SERVER_BW          0x05
    // 命令类型ID，`Type ID: AMF0 Command (0x14)`，第8个字节
    packet.m_packetType = RTMP_PACKET_TYPE_SERVER_BW;
    // 时间戳第2、3、4字节
    packet.m_nTimeStamp = 0;
    // 消息流ID，这里块类型ID为1，有12个字节，这里是没有消息流ID的
    packet.m_nInfoField2 = 0;
    // 是否是绝对时间戳(类型1时为true)
    packet.m_hasAbsTimestamp = 0;
    // 块body指针，前面18（RTMP_MAX_HEADER_SIZE）字节用来放块头，后面放body
    packet.m_body = pbuf + RTMP_MAX_HEADER_SIZE;
    // 块body大小，第5、6、7个字节
    packet.m_nBodySize = 4;
    // 压入4字节带宽
    AMF_EncodeInt32(packet.m_body, pend, r->m_nServerBW);
    return RTMP_SendPacket(r, &packet, FALSE);
}
```

>参考：

[librtmp源码分析之核心实现解读](https://www.jianshu.com/p/05b1e5d70c06)