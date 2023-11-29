# librtmp源码之RTMP_ReadPacket

```c
/**
 * @brief 读取接收到的消息块(Chunk)，存放在packet中. 对接收到的消息不做任何处理。 块的格式为：
 *
 *   | basic header(1-3字节）| chunk msg header(0/3/7/11字节) | Extended Timestamp(0/4字节) | chunk data |
 *
 *   其中 basic header还可以分解为：| fmt(2位) | cs id (3 <= id <= 65599) |
 *   RTMP协议支持65597种流，ID从3-65599。ID 0、1、2作为保留。
 *      id = 0，表示ID的范围是64-319（第二个字节 + 64）；
 *      id = 1，表示ID范围是64-65599（第三个字节*256 + 第二个字节 + 64）；
 *      id = 2，表示低层协议消息。
 *   没有其他的字节来表示流ID。3 -- 63表示完整的流ID。
 *
 *    一个完整的chunk msg header 还可以分解为 ：
 *     | timestamp(3字节) | msg length(3字节) | msg type id(1字节，小端) | msg stream id(4字节) |
 */
int
RTMP_ReadPacket(RTMP *r, RTMPPacket *packet)
{
    // Chunk Header最大值18
    uint8_t hbuf[RTMP_MAX_HEADER_SIZE] = { 0 };
    // header 指向的是从Socket中收下来的数据
    char *header = (char *)hbuf;
    // nSize是块消息头长度，hSize是块头长度
    // nToRead 准备读取的数据大小 nChunk 分块大小
    int nSize, hSize, nToRead, nChunk;
    // 是否进行了分块初始化
    int didAlloc = FALSE;
    // 扩展时间戳
    int extendedTimestamp;

    RTMP_Log(RTMP_LOGDEBUG2, "%s: fd=%d", __FUNCTION__, r->m_sb.sb_socket);
    // 收下来的数据存入hbuf
    if (ReadN(r, (char *)hbuf, 1) == 0)
    {
        RTMP_Log(RTMP_LOGERROR, "%s, failed to read RTMP packet header", __FUNCTION__);
        return FALSE;
    }
    // 块类型fmt
    packet->m_headerType = (hbuf[0] & 0xc0) >> 6;
    // 块流ID（2-63）
    packet->m_nChannel = (hbuf[0] & 0x3f);
    header++;
    // 块流ID第一个字节为0，表示块流ID占2个字节，表示ID的范围是64-319（第二个字节 + 64）
    if (packet->m_nChannel == 0)
    {
        // 读取接下来的1个字节存放在hbuf[1]中
        if (ReadN(r, (char *)&hbuf[1], 1) != 1)
        {
            RTMP_Log(RTMP_LOGERROR, "%s, failed to read RTMP packet header 2nd byte", __FUNCTION__);
            return FALSE;
        }
        // 块流ID = 第二个字节 + 64 = hbuf[1] + 64
        packet->m_nChannel = hbuf[1];
        packet->m_nChannel += 64;
        header++;
    }
    // 块流ID第一个字节为1，表示块流ID占3个字节，表示ID范围是64 -- 65599（第三个字节*256 + 第二个字节 + 64）
    else if (packet->m_nChannel == 1)
    {
        int tmp;
        // 读取2个字节存放在hbuf[1]和hbuf[2]中
        if (ReadN(r, (char *)&hbuf[1], 2) != 2)
        {
            RTMP_Log(RTMP_LOGERROR, "%s, failed to read RTMP packet header 3nd byte", __FUNCTION__);
            return FALSE;
        }
        // 块流ID = 第三个字节*256 + 第二个字节 + 64
        tmp = (hbuf[2] << 8) + hbuf[1];
        packet->m_nChannel = tmp + 64;
        RTMP_Log(RTMP_LOGDEBUG, "%s, m_nChannel: %0x", __FUNCTION__, packet->m_nChannel);
        header += 2;
    }
    // 块消息头(ChunkMsgHeader)有四种类型，大小分别为11、7、3、0,每个值加1 就得到该数组的值
    // 块头 = BasicHeader(1-3字节) + ChunkMsgHeader + ExtendTimestamp(0或4字节)
    nSize = packetSize[packet->m_headerType];

    if (packet->m_nChannel >= r->m_channelsAllocatedIn)
    {
        int n = packet->m_nChannel + 10;
        int *timestamp = realloc(r->m_channelTimestamp, sizeof(int) * n);
        RTMPPacket **packets = realloc(r->m_vecChannelsIn, sizeof(RTMPPacket*) * n);
        if (!timestamp)
            free(r->m_channelTimestamp);
        if (!packets)
            free(r->m_vecChannelsIn);
        r->m_channelTimestamp = timestamp;
        r->m_vecChannelsIn = packets;
        if (!timestamp || !packets) {
            r->m_channelsAllocatedIn = 0;
            return FALSE;
        }
        memset(r->m_channelTimestamp + r->m_channelsAllocatedIn, 0, sizeof(int) * (n - r->m_channelsAllocatedIn));
        memset(r->m_vecChannelsIn + r->m_channelsAllocatedIn, 0, sizeof(RTMPPacket*) * (n - r->m_channelsAllocatedIn));
        r->m_channelsAllocatedIn = n;
    }
    // 块类型fmt为0的块，在一个块流的开始和时间戳返回的时候必须有这种块
    // 块类型fmt为1、2、3的块使用与先前块相同的数据
    // 关于块类型的定义，可参考官方协议：流的分块 --- 6.1.2节
    // 如果是标准大头，设置时间戳为绝对的
    if (nSize == RTMP_LARGE_HEADER_SIZE)    /* if we get a full header the timestamp is absolute */
        // 11个字节的完整ChunkMsgHeader的TimeStamp是绝对时间戳
        packet->m_hasAbsTimestamp = TRUE;
    // 如果非标准大头，首次尝试拷贝上一次的报头
    else if (nSize < RTMP_LARGE_HEADER_SIZE)
    {
        /* using values from the last message of this channel */
        // 这里的拷贝操作有可能取得上次的分块报文，然后继续后续块的接收合并工作
        if (r->m_vecChannelsIn[packet->m_nChannel])
            memcpy(packet, r->m_vecChannelsIn[packet->m_nChannel], sizeof(RTMPPacket));
    }
    // 真实的ChunkMsgHeader的大小，此处减1是因为前面获取包类型的时候多加了1
    nSize--;
    // 读取nSize个字节存入header
    if (nSize > 0 && ReadN(r, header, nSize) != nSize)
    {
        RTMP_Log(RTMP_LOGERROR, "%s, failed to read RTMP packet header. type: %x",
                 __FUNCTION__, (unsigned int)hbuf[0]);
        return FALSE;
    }
    // 目前已经读取的字节数 = chunk msg header + basic header
    // 计算基本块头+消息块头的大小
    hSize = nSize + (header - (char *)hbuf);
    // chunk msg header为11、7、3字节，fmt类型值为0、1、2
    if (nSize >= 3)
    {
        // TimeStamp(注意 BigEndian to SmallEndian)(11，7，3字节首部都有)
        // 首部前3个字节为timestamp
        packet->m_nTimeStamp = AMF_DecodeInt24(header);

        /*RTMP_Log(RTMP_LOGDEBUG, "%s, reading RTMP packet chunk on channel %x, headersz %i, timestamp %i, abs timestamp %i", __FUNCTION__, packet.m_nChannel, nSize, packet.m_nTimeStamp, packet.m_hasAbsTimestamp); */
        
        // chunk msg header为11或7字节，fmt类型值为0或1
        // 消息长度(11，7字节首部都有)
        if (nSize >= 6)
        {
            // 解析负载长度
            packet->m_nBodySize = AMF_DecodeInt24(header + 3);
            packet->m_nBytesRead = 0;
            //(11，7字节首部都有)
            if (nSize > 6)
            {
                // Msg type ID
                // 解析包类型
                packet->m_packetType = header[6];
                // Msg Stream ID
                // 解析流ID
                if (nSize == 11)
                    // msg stream id，小端字节序
                    packet->m_nInfoField2 = DecodeInt32LE(header + 7);
            }
        }
    }
    // 读取扩展时间戳并解析
    // Extend Tiemstamp,占4个字节
    extendedTimestamp = packet->m_nTimeStamp == 0xffffff;
    if (extendedTimestamp)
    {
        if (ReadN(r, header + nSize, 4) != 4)
        {
            RTMP_Log(RTMP_LOGERROR, "%s, failed to read extended timestamp",
                     __FUNCTION__);
            return FALSE;
        }
        packet->m_nTimeStamp = AMF_DecodeInt32(header + nSize);
        hSize += 4;
    }

    RTMP_LogHexString(RTMP_LOGDEBUG2, (uint8_t *)hbuf, hSize);
    // 负载非0，需要分配内存，或第一个分块的初使化工作
    if (packet->m_nBodySize > 0 && packet->m_body == NULL)
    {
        if (!RTMPPacket_Alloc(packet, packet->m_nBodySize))
        {
            RTMP_Log(RTMP_LOGDEBUG, "%s, failed to allocate packet", __FUNCTION__);
            return FALSE;
        }
        didAlloc = TRUE;
        packet->m_headerType = (hbuf[0] & 0xc0) >> 6;
    }
    // 剩下的消息数据长度如果比块尺寸大，则需要分块,否则块尺寸就等于剩下的消息数据长度
    // 准备读取的数据和块大小
    nToRead = packet->m_nBodySize - packet->m_nBytesRead;
    nChunk = r->m_inChunkSize;
    if (nToRead < nChunk)
        nChunk = nToRead;

    /* Does the caller want the raw chunk? */
    if (packet->m_chunk)
    {
        // 块头大小
        packet->m_chunk->c_headerSize = hSize;
        // 填充块头数据
        memcpy(packet->m_chunk->c_header, hbuf, hSize);
        // 块消息数据缓冲区指针
        packet->m_chunk->c_chunk = packet->m_body + packet->m_nBytesRead;
        // 块大小
        packet->m_chunk->c_chunkSize = nChunk;
    }
    // 读取负载到缓冲区中
    // 读取一个块大小的数据存入块消息数据缓冲区
    if (ReadN(r, packet->m_body + packet->m_nBytesRead, nChunk) != nChunk)
    {
        RTMP_Log(RTMP_LOGERROR, "%s, failed to read RTMP packet body. len: %u",
                 __FUNCTION__, packet->m_nBodySize);
        return FALSE;
    }

    RTMP_LogHexString(RTMP_LOGDEBUG2, (uint8_t *)packet->m_body + packet->m_nBytesRead, nChunk);
    // 更新已读数据字节个数
    packet->m_nBytesRead += nChunk;

    /* keep the packet as ref for other packets on this channel */
    // 将这个包作为通道中其他包的参考
    // 保存当前块流ID最新的报文，与RTMP_SendPacket()不同的是，负载部分也被保存了，以应对不完整的分块报文
    if (!r->m_vecChannelsIn[packet->m_nChannel])
        r->m_vecChannelsIn[packet->m_nChannel] = malloc(sizeof(RTMPPacket));
    memcpy(r->m_vecChannelsIn[packet->m_nChannel], packet, sizeof(RTMPPacket));
    // 设置扩展时间戳
    if (extendedTimestamp)
    {
        r->m_vecChannelsIn[packet->m_nChannel]->m_nTimeStamp = 0xffffff;
    }

    // 若报文负载接收完整
    if (RTMPPacket_IsReady(packet))
    {
        /* make packet's timestamp absolute */
        // 处理增量时间戳
        // 绝对时间戳 = 上一次绝对时间戳 + 时间戳增量
        if (!packet->m_hasAbsTimestamp)
            packet->m_nTimeStamp += r->m_channelTimestamp[packet->m_nChannel];  /* timestamps seem to be always relative!! */
        // 保存当前块流ID的时间戳
        // 当前绝对时间戳保存起来，供下一个包转换时间戳使用
        r->m_channelTimestamp[packet->m_nChannel] = packet->m_nTimeStamp;

        /* reset the data from the stored packet. we keep the header since we may use it later if a new packet for this channel */
        /* arrives and requests to re-use some info (small packet header) */
        // 清理上下文中当前块流ID最新的报文的负载信息
        // 重置保存的包。保留块头数据，因为通道中新到来的包(更短的块头)可能需要使用前面块头的信息.
        r->m_vecChannelsIn[packet->m_nChannel]->m_body = NULL;
        r->m_vecChannelsIn[packet->m_nChannel]->m_nBytesRead = 0;
        r->m_vecChannelsIn[packet->m_nChannel]->m_hasAbsTimestamp = FALSE;  /* can only be false if we reuse header */
    }
    else
    {
        packet->m_body = NULL;  /* so it won't be erased on free */
    }

    return TRUE;
}
```

>参考：

[RTMPdump（libRTMP） 源代码分析 6： 建立一个流媒体连接 （NetStream部分 1）](https://blog.csdn.net/leixiaohua1020/article/details/12957877)

[RTMP推流及协议学习](https://blog.csdn.net/huangyimo/article/details/83858620)

[librtmp源码分析之核心实现解读](https://www.jianshu.com/p/05b1e5d70c06)

[【原】librtmp源码详解](https://www.cnblogs.com/Kingfans/p/7064902.html)