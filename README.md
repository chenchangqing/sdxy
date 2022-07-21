# librtmp源码之SendConnectPacket

## SendConnectPacket

```c
/// 发起0x14命令connect远程调用
static int
SendConnectPacket(RTMP *r, RTMPPacket *cp)
{
  RTMPPacket packet;
  char pbuf[4096], *pend = pbuf + sizeof(pbuf);
  char *enc;

  if (cp)
    return RTMP_SendPacket(r, cp, TRUE);

  packet.m_nChannel = 0x03; /* control channel (invoke) */
  packet.m_headerType = RTMP_PACKET_SIZE_LARGE;
  packet.m_packetType = RTMP_PACKET_TYPE_INVOKE;
  packet.m_nTimeStamp = 0;
  packet.m_nInfoField2 = 0;
  packet.m_hasAbsTimestamp = 0;
  packet.m_body = pbuf + RTMP_MAX_HEADER_SIZE;

  enc = packet.m_body;
  enc = AMF_EncodeString(enc, pend, &av_connect);
  enc = AMF_EncodeNumber(enc, pend, ++r->m_numInvokes);
  *enc++ = AMF_OBJECT;

  enc = AMF_EncodeNamedString(enc, pend, &av_app, &r->Link.app);
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
  *enc++ = 0;
  *enc++ = 0;     /* end of object - 0x00 0x00 0x09 */
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
  packet.m_nBodySize = enc - packet.m_body;

  return RTMP_SendPacket(r, &packet, TRUE);
}
```

## 代码片段分析1

```c
RTMPPacket packet;
    // pend：AMF_EncodeNamedString函数参数
    // pbuf: packet.m_body = pbuf + RTMP_MAX_HEADER_SIZE;
  char pbuf[4096], *pend = pbuf + sizeof(pbuf);
  char *enc;
    
    RTMP_Log(RTMP_LOGDEBUG, "CCQ: %s cp2:%s", __FUNCTION__, cp);
    // DEBUG: CCQ: SendConnectPacket cp2:(null)
  if (cp)
    // 不会走
    return RTMP_SendPacket(r, cp, TRUE);
```

## 代码片段分析2

```c
// 填写块头字段
    //块流ID
  packet.m_nChannel = 0x03; /* control channel (invoke) */
    // chunk basic header（大部分情况是一个字节）
  packet.m_headerType = RTMP_PACKET_SIZE_LARGE;
    //消息类型为20的用AMF0编码，这些消息用于在远端实现连接，创建流，发布，播放和暂停等操作
//#define RTMP_PACKET_TYPE_INVOKE             0x14
    // Message type ID（1-7协议控制；8，9音视频；10以后为AMF编码消息）
  packet.m_packetType = RTMP_PACKET_TYPE_INVOKE;
  packet.m_nTimeStamp = 0;
    //流ID需要设置为0
  packet.m_nInfoField2 = 0;
    // 是否含有Extend timeStamp字段
  packet.m_hasAbsTimestamp = 0;
  packet.m_body = pbuf + RTMP_MAX_HEADER_SIZE;

  enc = packet.m_body;
    // 压入connect命令和操作流水号
    //connect使用##进行字符串化连接，此处编码connect字符串
  enc = AMF_EncodeString(enc, pend, &av_connect);
  enc = AMF_EncodeNumber(enc, pend, ++r->m_numInvokes);
  *enc++ = AMF_OBJECT;
    // 压入对象的各个属性
  enc = AMF_EncodeNamedString(enc, pend, &av_app, &r->Link.app);
```

## 代码片段分析3

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

## 代码片段分析4

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

内容来源于：

https://blog.csdn.net/bwangk/article/details/112802823

https://www.jianshu.com/p/05b1e5d70c06

<div style="margin: 0px;">
    备案号：
    <a href="https://beian.miit.gov.cn/" target="_blank">
        <!-- <img src="https://api.azpay.cn/808/1.png" style="height: 20px;"> -->沪ICP备2022002183号-1
    </a >
</div>

