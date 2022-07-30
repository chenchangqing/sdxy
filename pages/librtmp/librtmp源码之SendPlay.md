# librtmp源码之SendPlay

```c
// 发送命令“播放”
static int
SendPlay(RTMP *r)
{
    RTMPPacket packet;
    char pbuf[1024], *pend = pbuf + sizeof(pbuf);
    char *enc;
    
    // 8:control stream
    packet.m_nChannel = 0x08; /* we make 8 our stream channel */
    packet.m_headerType = RTMP_PACKET_SIZE_LARGE;
    packet.m_packetType = RTMP_PACKET_TYPE_INVOKE;
    packet.m_nTimeStamp = 0;
    // 指定流ID
    packet.m_nInfoField2 = r->m_stream_id;  /*0x01000000; */
    packet.m_hasAbsTimestamp = 0;
    packet.m_body = pbuf + RTMP_MAX_HEADER_SIZE;
    
    enc = packet.m_body;
    enc = AMF_EncodeString(enc, pend, &av_play);
    enc = AMF_EncodeNumber(enc, pend, ++r->m_numInvokes);
    *enc++ = AMF_NULL;
    
    RTMP_Log(RTMP_LOGDEBUG, "%s, seekTime=%d, stopTime=%d, sending play: %s",
             __FUNCTION__, r->Link.seekTime, r->Link.stopTime,
             r->Link.playpath.av_val);
    enc = AMF_EncodeString(enc, pend, &r->Link.playpath);
    if (!enc)
        return FALSE;
    
    // 指定开始时间
    /* Optional parameters start and len.
     *
     * start: -2, -1, 0, positive number
     *  -2: looks for a live stream, then a recorded stream,
     *      if not found any open a live stream
     *  -1: plays a live stream
     * >=0: plays a recorded streams from 'start' milliseconds
     */
    // #define RTMP_LF_LIVE    0x0002    /* stream is live */
    if (r->Link.lFlags & RTMP_LF_LIVE)
        enc = AMF_EncodeNumber(enc, pend, -1000.0);
    else
    {
        if (r->Link.seekTime > 0.0)
            enc = AMF_EncodeNumber(enc, pend, r->Link.seekTime);  /* resume from here */
        else
            enc = AMF_EncodeNumber(enc, pend, 0.0); /*-2000.0);*/ /* recorded as default, -2000.0 is not reliable since that freezes the player if the stream is not found */
    }
    if (!enc)
        return FALSE;
    
    // 指点播放时长
    /* len: -1, 0, positive number
     *  -1: plays live or recorded stream to the end (default)
     *   0: plays a frame 'start' ms away from the beginning
     *  >0: plays a live or recoded stream for 'len' milliseconds
     */
    /*enc += EncodeNumber(enc, -1.0); */ /* len */
    if (r->Link.stopTime)
    {
        enc = AMF_EncodeNumber(enc, pend, r->Link.stopTime - r->Link.seekTime);
        if (!enc)
            return FALSE;
    }
    
    packet.m_nBodySize = enc - packet.m_body;
    
    return RTMP_SendPacket(r, &packet, TRUE);
}
```

>参考：

[RTMP学习（十一）rtmpdump源码阅读（6）请求播放](https://blog.csdn.net/NB_vol_1/article/details/59109805)

[librtmp源码分析之核心实现解读](https://www.jianshu.com/p/05b1e5d70c06)
