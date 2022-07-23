# librtmp源码之SendConnectPacket

## 代码片段分析1

```c
RTMPPacket packet;
// pend：AMF_EncodeNamedString函数参数
// pbuf: packet.m_body = pbuf + RTMP_MAX_HEADER_SIZE;
char pbuf[4096], *pend = pbuf + sizeof(pbuf);
char *enc;

if (cp)
    // 不会走
    return RTMP_SendPacket(r, cp, TRUE);
```

## 代码片段分析2

```c
// chunk stream id(chunk basic header)字段
// 块流ID，消息头的第1个字节的后6位
packet.m_nChannel = 0x03;    /* control channel (invoke) */
// #define RTMP_PACKET_SIZE_LARGE    0 onMetaData流开始的绝对时间戳控制消息（如connect）
// #define RTMP_PACKET_SIZE_MEDIUM   1 大部分的rtmp header都是8字节的
// #define RTMP_PACKET_SIZE_SMALL    2 比较少见
// #define RTMP_PACKET_SIZE_MINIMUM  3 偶尔出现，低于8字节频率
// chunk type id (2bit)fmt 对应message head {0,3,7,11} + (6bit)chunk stream id
// 块类型ID，消息头的第1个字节的前2位，决定消息头长度
packet.m_headerType = RTMP_PACKET_SIZE_LARGE;
// 消息类型为20的用AMF0编码，这些消息用于在远端实现连接，创建流，发布，播放和暂停等操作
// #define RTMP_PACKET_TYPE_INVOKE             0x14
// Message type ID（1-7协议控制；8，9音视频；10以后为AMF编码消息）
// 消息类型ID，消息头的第8个字节，0x14表示以AMF0编码。另外还有如0x04表示用户控制消息，0x05表示Window Acknowledgement Size，0x06表示 Set Peer Bandwith等等。
packet.m_packetType = RTMP_PACKET_TYPE_INVOKE;
// 时间搓，消息头的第2-4个字节
packet.m_nTimeStamp = 0;
// Stream ID通常用以完成某些特定的工作，如使用ID为0的Stream来完成客户端和服务器的连接和控制，使用ID为1的Stream来完成视频流的控制和播放等工作。
// 流ID，消息头的第9-12个字节（末尾最后4个字节）
packet.m_nInfoField2 = 0;
// 是否含有Extend timeStamp字段
packet.m_hasAbsTimestamp = 0;
// #define RTMP_MAX_HEADER_SIZE 18
// 设置chunk body(data)的起始指针，前18个字节用来存储消息头，之后就用来存消息体
packet.m_body = pbuf + RTMP_MAX_HEADER_SIZE;
```

消息头的第5-7个字节是放的是body的长度，后面会设置。

## 代码片段分析3

```c
// 指针赋值，通过enc来设置消息体的内容
enc = packet.m_body;
// 压入connect命令和操作流水号
// connect使用##进行字符串化连接，此处编码connect字符串
enc = AMF_EncodeString(enc, pend, &av_connect);
// m_numInvokes：0x14命令远程过程调用计数
enc = AMF_EncodeNumber(enc, pend, ++r->m_numInvokes);
// 压入对象
*enc++ = AMF_OBJECT;
// 压入对象的“app”字符串，客户端连接到的服务器端应用的名字
enc = AMF_EncodeNamedString(enc, pend, &av_app, &r->Link.app);
if (!enc)
    return FALSE;
// 压入“type”，这里是“nonprivate”
if (r->Link.protocol & RTMP_FEATURE_WRITE)
{
    enc = AMF_EncodeNamedString(enc, pend, &av_type, &av_nonprivate);
    if (!enc)
        return FALSE;
}
// 压入“flashver”，Flash Player 版本号。和ApplicationScript getversion() 方法返回的是同一个字符串。FMSc/1.0
if (r->Link.flashVer.av_len)
{
    enc = AMF_EncodeNamedString(enc, pend, &av_flashVer, &r->Link.flashVer);
    if (!enc)
        return FALSE;
}
// 压入“swfUrl”，进行当前连接的 SWF 文件源地址。file://C:/FlvPlayer.swf
if (r->Link.swfUrl.av_len)
{
    enc = AMF_EncodeNamedString(enc, pend, &av_swfUrl, &r->Link.swfUrl);
    if (!enc)
        return FALSE;
}
// 压入“tcUrl”，服务器 URL。具有以下格式：protocol://servername:port/appName/appInstance，rtmp://localhost:1935/testapp/instance1
if (r->Link.tcUrl.av_len)
{
    enc = AMF_EncodeNamedString(enc, pend, &av_tcUrl, &r->Link.tcUrl);
    if (!enc)
        return FALSE;
}
if (!(r->Link.protocol & RTMP_FEATURE_WRITE))
{
    // 压入“fpad”，如果使用了代理就是 true。true 或者 false。
    enc = AMF_EncodeNamedBoolean(enc, pend, &av_fpad, FALSE);
    if (!enc)
        return FALSE;
    enc = AMF_EncodeNamedNumber(enc, pend, &av_capabilities, 15.0);
    if (!enc)
        return FALSE;
    // 压入“audioCodecs“，表明客户端所支持的音频编码。SUPPORT_SND_MP3
    enc = AMF_EncodeNamedNumber(enc, pend, &av_audioCodecs, r->m_fAudioCodecs);
    if (!enc)
        return FALSE;
    // 压入“videoCodecs”，表明支持的视频编码。SUPPORT_VID_SORENSON
    enc = AMF_EncodeNamedNumber(enc, pend, &av_videoCodecs, r->m_fVideoCodecs);
    if (!enc)
        return FALSE;
    // 压入“videoFunction”，表明所支持的特殊视频方法。SUPPORT_VID_CLIENT_SEEK
    enc = AMF_EncodeNamedNumber(enc, pend, &av_videoFunction, 1.0);
    if (!enc)
        return FALSE;
    if (r->Link.pageUrl.av_len)
    {
        // 压入“pageUrl“，SWF 文件所加载的网页 URL。http://somehost/sample.html
        enc = AMF_EncodeNamedString(enc, pend, &av_pageUrl, &r->Link.pageUrl);
        if (!enc)
            return FALSE;
    }
}
if (r->m_fEncoding != 0.0 || r->m_bSendEncoding)
{	/* AMF0, AMF3 not fully supported yet */
    enc = AMF_EncodeNamedNumber(enc, pend, &av_objectEncoding, r->m_fEncoding);
    if (!enc)
        return FALSE;
}
// 判断是否溢出
if (enc + 3 >= pend)
    return FALSE;
// 压入属性结束标记
*enc++ = 0;
*enc++ = 0;			/* end of object - 0x00 0x00 0x09 */
*enc++ = AMF_OBJECT_END;

/* add auth string */
if (r->Link.auth.av_len)
{
    enc = AMF_EncodeBoolean(enc, pend, r->Link.lFlags & RTMP_LF_AUTH);
    if (!enc)
        return FALSE;
    enc = AMF_EncodeString(enc, pend, &r->Link.auth);
    if (!enc)
        return FALSE;
}
if (r->Link.extras.o_num)
{
    int i;
    for (i = 0; i < r->Link.extras.o_num; i++)
    {
        enc = AMFProp_Encode(&r->Link.extras.o_props[i], enc, pend);
        if (!enc)
            return FALSE;
    }
}
```

## 代码片段分析4

```c
if (!enc)
    return FALSE;
  if (r->Link.protocol & RTMP_FEATURE_WRITE)
    {
      enc = AMF_EncodeNamedString(enc, pend, &av_type, &av_nonprivate);
      if (!enc)
  return FALSE;
    }
  if (r->Link.flashVer.av_len)
    {
      enc = AMF_EncodeNamedString(enc, pend, &av_flashVer, &r->Link.flashVer);
      if (!enc)
  return FALSE;
    }
  if (r->Link.swfUrl.av_len)
    {
      enc = AMF_EncodeNamedString(enc, pend, &av_swfUrl, &r->Link.swfUrl);
      if (!enc)
  return FALSE;
    }
  if (r->Link.tcUrl.av_len)
    {
      enc = AMF_EncodeNamedString(enc, pend, &av_tcUrl, &r->Link.tcUrl);
      if (!enc)
  return FALSE;
    }
  if (!(r->Link.protocol & RTMP_FEATURE_WRITE))
    {
      enc = AMF_EncodeNamedBoolean(enc, pend, &av_fpad, FALSE);
      if (!enc)
  return FALSE;
      enc = AMF_EncodeNamedNumber(enc, pend, &av_capabilities, 15.0);
      if (!enc)
  return FALSE;
      enc = AMF_EncodeNamedNumber(enc, pend, &av_audioCodecs, r->m_fAudioCodecs);
      if (!enc)
  return FALSE;
      enc = AMF_EncodeNamedNumber(enc, pend, &av_videoCodecs, r->m_fVideoCodecs);
      if (!enc)
  return FALSE;
      enc = AMF_EncodeNamedNumber(enc, pend, &av_videoFunction, 1.0);
      if (!enc)
  return FALSE;
      if (r->Link.pageUrl.av_len)
  {
    enc = AMF_EncodeNamedString(enc, pend, &av_pageUrl, &r->Link.pageUrl);
    if (!enc)
      return FALSE;
  }
    }
  if (r->m_fEncoding != 0.0 || r->m_bSendEncoding)
    { /* AMF0, AMF3 not fully supported yet */
      enc = AMF_EncodeNamedNumber(enc, pend, &av_objectEncoding, r->m_fEncoding);
      if (!enc)
  return FALSE;
    }
  if (enc + 3 >= pend)
    return FALSE;
    // 压入属性结束标记
  *enc++ = 0;
  *enc++ = 0;     /* end of object - 0x00 0x00 0x09 */
  *enc++ = AMF_OBJECT_END;
```

## 代码片段分析5

```c
/* add auth string */
if (r->Link.auth.av_len)
{
    enc = AMF_EncodeBoolean(enc, pend, r->Link.lFlags & RTMP_LF_AUTH);
    if (!enc)
        return FALSE;
    enc = AMF_EncodeString(enc, pend, &r->Link.auth);
    if (!enc)
        return FALSE;
}
if (r->Link.extras.o_num)
{
    int i;
    for (i = 0; i < r->Link.extras.o_num; i++)
    {
        enc = AMFProp_Encode(&r->Link.extras.o_props[i], enc, pend);
        if (!enc)
            return FALSE;
    }
}
// 经过AMF编码组包后，message的大小 (如果是音视频数据 即FLV格式一个Tag中Tag Data 大小)
// 消息体长度，消息头的第5-7个字节
packet.m_nBodySize = enc - packet.m_body;
// 发送报文，并记入应答队列
return RTMP_SendPacket(r, &packet, TRUE);
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

[RTMP 协议规范(中文版)](https://www.cnblogs.com/Kingfans/p/7083100.html)

[流媒体-RTMP协议-librtmp库学习（二）](https://blog.csdn.net/bwangk/article/details/112802823)

[librtmp源码分析之核心实现解读](https://www.jianshu.com/p/05b1e5d70c06)

[rtmp源码分析之RTMP_Write 和 RTMP_SendPacket](https://blog.csdn.net/dss875914213/article/details/123171825)

[ASCII对照表](https://tool.oschina.net/commons?type=4)

[RTMP协议详解及实例分析](https://blog.csdn.net/King_weng/article/details/108059686)

[手撕rtmp协议细节（2）——rtmp Header](https://cloud.tencent.com/developer/article/1630595)
