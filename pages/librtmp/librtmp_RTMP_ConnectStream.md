# librtmp源码之RTMP_ConnectStream

```c
// 建立流（NetStream）
int
RTMP_ConnectStream(RTMP *r, int seekTime)
{
    RTMPPacket packet = { 0 };

    /* seekTime was already set by SetupStream / SetupURL.
     * This is only needed by ReconnectStream.
     */
    if (seekTime > 0)
        r->Link.seekTime = seekTime;

    // 当前连接媒体使用的块流ID
    r->m_mediaChannel = 0;

    // 接收到的实际上是块(Chunk)，而不是消息(Message)，因为消息在网上传输的时候要分割成块.
    while (!r->m_bPlaying && RTMP_IsConnected(r) && RTMP_ReadPacket(r, &packet))
    {
        // 一个消息可能被封装成多个块(Chunk)，只有当所有块读取完才处理这个消息包
        if (RTMPPacket_IsReady(&packet))
        {
            if (!packet.m_nBodySize)
                continue;
            // 读取到flv数据包，则继续读取下一个包
            if ((packet.m_packetType == RTMP_PACKET_TYPE_AUDIO) ||
                (packet.m_packetType == RTMP_PACKET_TYPE_VIDEO) ||
                (packet.m_packetType == RTMP_PACKET_TYPE_INFO))
            {
                RTMP_Log(RTMP_LOGWARNING, "Received FLV packet before play()! Ignoring.");
                RTMPPacket_Free(&packet);
                continue;
            }
            // 处理收到的数据包
            RTMP_ClientPacket(r, &packet);
            // 处理完毕，清除数据
            RTMPPacket_Free(&packet);
        }
    }

    // 当前是否推流或连接中
    return r->m_bPlaying;
}
```

简单的一个逻辑判断，重点在while循环里。首先，必须要满足三个条件。其次，进入循环以后只有出错或者建立流（NetStream）完成后，才能退出循环。 

在RTMP_ConnectStream()处理交互准备的过程中，有两个重要函数：RTMP_ReadPacket()负责接收报文，RTMP_ClientPacket()负责逻辑的分派处理。

>参考：

[RTMPdump（libRTMP） 源代码分析 6： 建立一个流媒体连接 （NetStream部分 1）](https://blog.csdn.net/leixiaohua1020/article/details/12957877)

[RTMP推流及协议学习](https://blog.csdn.net/huangyimo/article/details/83858620)

[librtmp源码分析之核心实现解读](https://www.jianshu.com/p/05b1e5d70c06)

[【原】librtmp源码详解](https://www.cnblogs.com/Kingfans/p/7064902.html)