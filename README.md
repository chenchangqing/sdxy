# librtmp源码之RTMP_SendPacket

## 代码片段分析1

```c
// 取出对应块流ID上一次发送的报文
const RTMPPacket *prevPacket;
// 上一次相对时间戳
uint32_t last = 0;
// 表示块头初始大小
int nSize;
// hSize表示块头大小
// 块基本头是1-3字节，因此用变量cSize来表示剩下的0-2字节
int hSize, cSize;
// header头指针指向头部，hend块尾指针指向body头部
// hbuf表示头部最大18（3字节最大块基本头+11字节最大快消息头+4字节扩展时间戳）缓冲数组
// hptr指向header
// c = packet->m_headerType << 6;
char *header, *hptr, *hend, hbuf[RTMP_MAX_HEADER_SIZE], c;
// t = packet->m_nTimeStamp - last;
// 时间戳增量
uint32_t t;
// buffer 表示 data 的指针，tbuf 块初始指针，toff 块指针
char *buffer, *tbuf = NULL, *toff = NULL;
// Chunk大小，默认是128字节
int nChunkSize;
// tlen ?
int tlen;

// ?
if (packet->m_nChannel >= r->m_channelsAllocatedOut)
{
    RTMP_Log(RTMP_LOGDEBUG, "CCQ: %s if (packet->m_nChannel >= r->m_channelsAllocatedOut)", __FUNCTION__);
    int n = packet->m_nChannel + 10;
    RTMPPacket **packets = realloc(r->m_vecChannelsOut, sizeof(RTMPPacket*) * n);
    if (!packets) {
        free(r->m_vecChannelsOut);
        r->m_vecChannelsOut = NULL;
        r->m_channelsAllocatedOut = 0;
        return FALSE;
    }
    r->m_vecChannelsOut = packets;
    memset(r->m_vecChannelsOut + r->m_channelsAllocatedOut, 0, sizeof(RTMPPacket*) * (n - r->m_channelsAllocatedOut));
    r->m_channelsAllocatedOut = n;
}
```

## 代码片段分析2

```c
// 获取该通道，上一次的数据
prevPacket = r->m_vecChannelsOut[packet->m_nChannel];
// 尝试对非LARGE报文进行字段压缩
// 前一个packet存在且不是完整的ChunkMsgHeader，因此有可能需要调整块消息头的类型
// fmt字节
/* case 0:chunk msg header 长度为11
 * case 1:chunk msg header 长度为7
 * case 2:chunk msg header 长度为3
 * case 3:chunk msg header 长度为0
*/
if (prevPacket && packet->m_headerType != RTMP_PACKET_SIZE_LARGE)
{
    RTMP_Log(RTMP_LOGDEBUG, "CCQ: %s if (prevPacket && packet->m_headerType != RTMP_PACKET_SIZE_LARGE)", __FUNCTION__);
    /* compress a bit by using the prev packet's attributes */
    // 获取ChunkMsgHeader类型，前一个Chunk与当前Chunk比较
    // 如果前后两个块的大小、包类型及块头类型都相同，则将块头类型fmt设为2，
    // 即可省略消息长度、消息类型id、消息流id
    // 可以参考官方协议：流的分块 --- 6.1.2.3节
    if (prevPacket->m_nBodySize == packet->m_nBodySize
        && prevPacket->m_packetType == packet->m_packetType
        && packet->m_headerType == RTMP_PACKET_SIZE_MEDIUM)
        packet->m_headerType = RTMP_PACKET_SIZE_SMALL;
    // 前后两个块的时间戳相同，且块头类型fmt为2，则相应的时间戳也可省略，因此将块头类型置为3
    // 可以参考官方协议：流的分块 --- 6.1.2.4节
    if (prevPacket->m_nTimeStamp == packet->m_nTimeStamp
        && packet->m_headerType == RTMP_PACKET_SIZE_SMALL)
        packet->m_headerType = RTMP_PACKET_SIZE_MINIMUM;
        // 上一次相对时间戳
        last = prevPacket->m_nTimeStamp;
}
// 块头类型fmt取值0、1、2、3，超过3就表示出错(fmt占二个字节)
if (packet->m_headerType > 3) /* sanity */
{
    RTMP_Log(RTMP_LOGERROR, "sanity failed!! trying to send header of type: 0x%02x.",
             (unsigned char)packet->m_headerType);
    return FALSE;
}
// 块头初始大小 = 基本头(1字节) + 块消息头大小(11/7/3/0) = [12, 8, 4, 1]
// 块基本头是1-3字节，因此用变量cSize来表示剩下的0-2字节
// nSize 表示块头初始大小， hSize表示块头大小
nSize = packetSize[packet->m_headerType];
hSize = nSize; cSize = 0;
// 时间戳增量
t = packet->m_nTimeStamp - last;
```

## 代码片段分析3

```c
if (packet->m_body)
{
    // 块头的首指针  向前平移了  基本头(1字节) + 块消息头大小(11/7/3/0)  字节
    header = packet->m_body - nSize;
    // 块头的尾指针
    hend = packet->m_body;
}
else
{
    header = hbuf + 6;
    hend = hbuf + sizeof(hbuf);
}
// 计算基本头的扩充大小
// 块基本头是1-3字节，因此用变量cSize来表示剩下的0-2字节
if (packet->m_nChannel > 319)
    // 块流id(cs id)大于319，则块基本头占3个字节
    cSize = 2;
else if (packet->m_nChannel > 63)
    // 块流id(cs id)在64与319之间，则块基本头占2个字节
    cSize = 1;
if (cSize)
{
    // 向前平移了 块基本头是1-3字节，因此用变量cSize来表示剩下的0-2字节 个字节
    header -= cSize;
    hSize += cSize;
    RTMP_Log(RTMP_LOGDEBUG, "CCQ: %s cSize:%d", __FUNCTION__, cSize);
}
// 根据时间戳计算是否需要扩充头大小
// 如果 t>0xffffff， 则需要使用 extended timestamp
if (t >= 0xffffff)
{
    // 向前平移了 extended timestamp
    header -= 4;
    hSize += 4;
    RTMP_Log(RTMP_LOGWARNING, "Larger timestamp than 24-bit: 0x%x", t);
}
// 确定好 Header 的位置后，就可以开始赋值了
// 向缓冲区压入基本头
hptr = header;
// 把ChunkBasicHeader的Fmt类型左移6位
// cSize 表示块基本头剩下的0-2字节
// 设置basic header的第一个字节值，前两位为fmt. 可以参考官方协议：流的分块 --- 6.1.1节
c = packet->m_headerType << 6;
switch (cSize)
{
case 0:// 把ChunkBasicHeader的低6位设置成ChunkStreamID( cs id
    c |= packet->m_nChannel;// chunk stream ID
    RTMP_Log(RTMP_LOGDEBUG, "CCQ: %s 把ChunkBasicHeader的低6位设置成ChunkStreamID", __FUNCTION__);
    break;
case 1:// 同理，但低6位设置成000000
    break;
case 2:// 同理，但低6位设置成000001
    c |= 1;
    break;
}
// 可以拆分成两句*hptr=c; hptr++，此时hptr指向第2个字节
*hptr++ = c;
// 设置basic header的第二(三)个字节值
if (cSize)
{
    // 将要放到第2字节的内容tmp
    int tmp = packet->m_nChannel - 64;
    // 获取低位存储与第2字节
    *hptr++ = tmp & 0xff;
    // ChunkBasicHeader是最大的3字节时,获取高位存储于最后1个字节（注意：排序使用大端序列，和主机相反）
    if (cSize == 2)
        *hptr++ = tmp >> 8;
}
// nSize 块头初始大小 = 基本头(1字节) + 块消息头大小(11/7/3/0) = [12, 8, 4, 1]
// 向缓冲区压入时间戳
if (nSize > 1)
{
    // 写入 timestamp 或 timestamp delta
    hptr = AMF_EncodeInt24(hptr, hend, t > 0xffffff ? 0xffffff : t);
}
// 向缓冲区压入负载大小和报文类型
if (nSize > 4)
{
    // 写入 message length
    hptr = AMF_EncodeInt24(hptr, hend, packet->m_nBodySize);
    // 写入 message type id
    *hptr++ = packet->m_packetType;
}
// 向缓冲区压入流ID
if (nSize > 8)
    // 写入 message stream id
    // 还原Chunk为Message的时候都是根据这个ID来辨识是否是同一个消息的Chunk的
    hptr += EncodeInt32LE(hptr, packet->m_nInfoField2);
// 向缓冲区压入扩展时间戳
if (t >= 0xffffff)
    // 写入 extended timestamp
    hptr = AMF_EncodeInt32(hptr, hend, t);
// 到此为止，已经将块头填写好了
// 此时nSize表示负载数据的长度, buffer是指向负载数据区的指针
nSize = packet->m_nBodySize;
buffer = packet->m_body;
// Chunk大小，默认是128字节
nChunkSize = r->m_outChunkSize;

RTMP_Log(RTMP_LOGDEBUG2, "%s: fd=%d, size=%d", __FUNCTION__, r->m_sb.sb_socket,
  nSize);
```

## 代码片段分析4

```c
/* send all chunks in one HTTP request */
if (r->Link.protocol & RTMP_FEATURE_HTTP)
{
    RTMP_Log(RTMP_LOGDEBUG, "CCQ: %s if (r->Link.protocol & RTMP_FEATURE_HTTP)", __FUNCTION__);
    // nSize:Message负载长度；nChunkSize：Chunk长度；
    // 例nSize：307，nChunkSize:128；
    // 可分为（307 + 128 - 1）/128 = 3个
    // 为什么加 nChunkSize - 1？因为除法会只取整数部分！
    int chunks = (nSize+nChunkSize-1) / nChunkSize;
    if (chunks > 1)
    {
        RTMP_Log(RTMP_LOGDEBUG, "CCQ: %s chunks > 1，chunks: %d", __FUNCTION__, chunks);
        // 注意：ChunkBasicHeader的长度 = cSize + 1
        // 消息分n块后总的开销：
        // n个ChunkBasicHeader，1个ChunkMsgHeader，1个Message负载
        // 实际上只有第一个Chunk是完整的，剩下的只有ChunkBasicHeader
        tlen = chunks * (cSize + 1) + nSize + hSize;
        tbuf = malloc(tlen);
        if (!tbuf)
            return FALSE;
        toff = tbuf;
    }
}
// 消息的负载 + 头
while (nSize + hSize)
{
    int wrote;
    
    // 消息负载大小 < Chunk大小（不用分块）
    if (nSize < nChunkSize)
        nChunkSize = nSize;

    RTMP_LogHexString(RTMP_LOGDEBUG2, (uint8_t *)header, hSize);
    RTMP_LogHexString(RTMP_LOGDEBUG2, (uint8_t *)buffer, nChunkSize);
    // 如果r->Link.protocol采用Http协议，则将RTMP包数据封装成多个Chunk，然后一次性发送。
    // 否则每封装成一个块，就立即发送出去
    if (tbuf)
    {
        // 将从Chunk头开始的nChunkSize + hSize个字节拷贝至toff中，
        // 这些拷贝的数据包括块头数据(hSize字节)和nChunkSize个负载数据
        memcpy(toff, header, nChunkSize + hSize);
        toff += nChunkSize + hSize;
        RTMP_Log(RTMP_LOGDEBUG, "CCQ: %s if (tbuf)", __FUNCTION__);
    }
    // 负载数据长度不超过设定的块大小，不需要分块，因此tbuf为NULL；或者r->Link.protocol不采用Http
    else
    {
        RTMP_Log(RTMP_LOGDEBUG, "CCQ: %s if !(tbuf)", __FUNCTION__);
        // 直接将负载数据和块头数据发送出去
        wrote = WriteN(r, header, nChunkSize + hSize);
        if (!wrote)
            return FALSE;
    }
    // 消息负载长度 - Chunk负载长度
    nSize -= nChunkSize;
    // buffer指针前移1个Chunk负载长度
    buffer += nChunkSize;
    // 重置块头大小为0，后续的块只需要有基本头(或加上扩展时间戳)即可
    hSize = 0;
    // 如果消息负载数据还没有发完，准备填充下一个块的块头数据
    // 若只有部分负载发送成功，则需继续构造块再次发送
    if (nSize > 0)
    {
        RTMP_Log(RTMP_LOGDEBUG, "CCQ: %s 继续构造块再次发送", __FUNCTION__);
        // 只需要构造3号类型的块头
        header = buffer - 1;
        // basic header 字节
        hSize = 1;
        if (cSize)
        {
            header -= cSize;
            hSize += cSize;
        }
        if (t >= 0xffffff)
        {
            header -= 4;
            hSize += 4;
        }
        // c 为 basic header 第一个字节
        *header = (0xc0 | c);
        if (cSize)
        {
            int tmp = packet->m_nChannel - 64;
            header[1] = tmp & 0xff;
            if (cSize == 2)
                header[2] = tmp >> 8;
        }
        if (t >= 0xffffff)
        {
            char* extendedTimestamp = header + 1 + cSize;
            AMF_EncodeInt32(extendedTimestamp, extendedTimestamp + 4, t);
        }
    }
}
```

## 代码片段分析5

```c
if (tbuf)
{
    RTMP_Log(RTMP_LOGDEBUG, "CCQ: %s if (tbuf)， write tbuf", __FUNCTION__);
    int wrote = WriteN(r, tbuf, toff-tbuf);
    free(tbuf);
    tbuf = NULL;
    if (!wrote)
        return FALSE;
}

/* we invoked a remote method */
// 如果是0x14远程调用，则需要解出调用名称，加入等待响应的队列中
if (packet->m_packetType == RTMP_PACKET_TYPE_INVOKE)
{
    AVal method;
    char *ptr;
    ptr = packet->m_body + 1;
    AMF_DecodeString(ptr, &method);
    RTMP_Log(RTMP_LOGDEBUG, "Invoking %s", method.av_val);
    /* keep it in call queue till result arrives */
    if (queue) {
        int txn;
        ptr += 3 + method.av_len;
        txn = (int)AMF_DecodeNumber(ptr);
        AV_queue(&r->m_methodCalls, &r->m_numCalls, &method, txn);
        RTMP_Log(RTMP_LOGDEBUG, "CCQ: %s 如果是0x14远程调用，则需要解出调用名称，加入等待响应的队列中", __FUNCTION__);
    }
}

// 记录这个块流ID刚刚发送的报文，但是应忽略负载
if (!r->m_vecChannelsOut[packet->m_nChannel])
    r->m_vecChannelsOut[packet->m_nChannel] = malloc(sizeof(RTMPPacket));
memcpy(r->m_vecChannelsOut[packet->m_nChannel], packet, sizeof(RTMPPacket));
return TRUE;
```

## 报文数据

```
DEBUG2:   0000:  03 00 00 00 00 00 55 14  00 00 00 00               ......U.....      
DEBUG2:   0000:  02 00 07 63 6f 6e 6e 65  63 74 00 3f f0 00 00 00   ...connect.?....  
DEBUG2:   0010:  00 00 00 03 00 03 61 70  70 02 00 04 6c 69 76 65   ......app...live  
DEBUG2:   0020:  00 04 74 79 70 65 02 00  0a 6e 6f 6e 70 72 69 76   ..type...nonpriv  
DEBUG2:   0030:  61 74 65 00 05 74 63 55  72 6c 02 00 15 72 74 6d   ate..tcUrl...rtm  
DEBUG2:   0040:  70 3a 2f 2f 31 32 32 31  2e 73 69 74 65 2f 6c 69   p://1221.site/li  
DEBUG2:   0050:  76 65 00 00 09                                     ve...   
```

>参考：

[librtmp源码分析之核心实现解读](https://www.jianshu.com/p/05b1e5d70c06)

[rtmp源码分析之RTMP_Write 和 RTMP_SendPacket](https://blog.csdn.net/dss875914213/article/details/123171825)

[librtmp协议分析---RTMP_SendPacket函数](https://blog.csdn.net/xwjazjx1314/article/details/54863428)

[librtmp 源码分析笔记 RTMP_SendPacket](https://www.codeleading.com/article/97093265842/)


<div style="margin: 0px;">
    备案号：
    <a href="https://beian.miit.gov.cn/" target="_blank">
        <!-- <img src="https://api.azpay.cn/808/1.png" style="height: 20px;"> -->沪ICP备2022002183号-1
    </a >
</div>

