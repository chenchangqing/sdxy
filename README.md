# librtmp源码之RTMP_SendPacket

## RTMP_SendPacket

```c
int
RTMP_SendPacket(RTMP *r, RTMPPacket *packet, int queue)
{
  const RTMPPacket *prevPacket;
  uint32_t last = 0;
  int nSize;
  int hSize, cSize;
  char *header, *hptr, *hend, hbuf[RTMP_MAX_HEADER_SIZE], c;
  uint32_t t;
  char *buffer, *tbuf = NULL, *toff = NULL;
  int nChunkSize;
  int tlen;

  if (packet->m_nChannel >= r->m_channelsAllocatedOut)
    {
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

  prevPacket = r->m_vecChannelsOut[packet->m_nChannel];
  if (prevPacket && packet->m_headerType != RTMP_PACKET_SIZE_LARGE)
    {
      /* compress a bit by using the prev packet's attributes */
      if (prevPacket->m_nBodySize == packet->m_nBodySize
    && prevPacket->m_packetType == packet->m_packetType
    && packet->m_headerType == RTMP_PACKET_SIZE_MEDIUM)
  packet->m_headerType = RTMP_PACKET_SIZE_SMALL;

      if (prevPacket->m_nTimeStamp == packet->m_nTimeStamp
    && packet->m_headerType == RTMP_PACKET_SIZE_SMALL)
  packet->m_headerType = RTMP_PACKET_SIZE_MINIMUM;
      last = prevPacket->m_nTimeStamp;
    }

  if (packet->m_headerType > 3) /* sanity */
    {
      RTMP_Log(RTMP_LOGERROR, "sanity failed!! trying to send header of type: 0x%02x.",
    (unsigned char)packet->m_headerType);
      return FALSE;
    }

  nSize = packetSize[packet->m_headerType];
  hSize = nSize; cSize = 0;
  t = packet->m_nTimeStamp - last;

  if (packet->m_body)
    {
      header = packet->m_body - nSize;
      hend = packet->m_body;
    }
  else
    {
      header = hbuf + 6;
      hend = hbuf + sizeof(hbuf);
    }

  if (packet->m_nChannel > 319)
    cSize = 2;
  else if (packet->m_nChannel > 63)
    cSize = 1;
  if (cSize)
    {
      header -= cSize;
      hSize += cSize;
    }

  if (t >= 0xffffff)
    {
      header -= 4;
      hSize += 4;
      RTMP_Log(RTMP_LOGWARNING, "Larger timestamp than 24-bit: 0x%x", t);
    }

  hptr = header;
  c = packet->m_headerType << 6;
  switch (cSize)
    {
    case 0:
      c |= packet->m_nChannel;
      break;
    case 1:
      break;
    case 2:
      c |= 1;
      break;
    }
  *hptr++ = c;
  if (cSize)
    {
      int tmp = packet->m_nChannel - 64;
      *hptr++ = tmp & 0xff;
      if (cSize == 2)
  *hptr++ = tmp >> 8;
    }

  if (nSize > 1)
    {
      hptr = AMF_EncodeInt24(hptr, hend, t > 0xffffff ? 0xffffff : t);
    }

  if (nSize > 4)
    {
      hptr = AMF_EncodeInt24(hptr, hend, packet->m_nBodySize);
      *hptr++ = packet->m_packetType;
    }

  if (nSize > 8)
    hptr += EncodeInt32LE(hptr, packet->m_nInfoField2);

  if (t >= 0xffffff)
    hptr = AMF_EncodeInt32(hptr, hend, t);

  nSize = packet->m_nBodySize;
  buffer = packet->m_body;
  nChunkSize = r->m_outChunkSize;

  RTMP_Log(RTMP_LOGDEBUG2, "%s: fd=%d, size=%d", __FUNCTION__, r->m_sb.sb_socket,
      nSize);
  /* send all chunks in one HTTP request */
  if (r->Link.protocol & RTMP_FEATURE_HTTP)
    {
      int chunks = (nSize+nChunkSize-1) / nChunkSize;
      if (chunks > 1)
        {
    tlen = chunks * (cSize + 1) + nSize + hSize;
    tbuf = malloc(tlen);
    if (!tbuf)
      return FALSE;
    toff = tbuf;
  }
    }
  while (nSize + hSize)
    {
      int wrote;

      if (nSize < nChunkSize)
  nChunkSize = nSize;

      RTMP_LogHexString(RTMP_LOGDEBUG2, (uint8_t *)header, hSize);
      RTMP_LogHexString(RTMP_LOGDEBUG2, (uint8_t *)buffer, nChunkSize);
      if (tbuf)
        {
    memcpy(toff, header, nChunkSize + hSize);
    toff += nChunkSize + hSize;
  }
      else
        {
    wrote = WriteN(r, header, nChunkSize + hSize);
    if (!wrote)
      return FALSE;
  }
      nSize -= nChunkSize;
      buffer += nChunkSize;
      hSize = 0;

      if (nSize > 0)
  {
    header = buffer - 1;
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
  if (tbuf)
    {
      int wrote = WriteN(r, tbuf, toff-tbuf);
      free(tbuf);
      tbuf = NULL;
      if (!wrote)
        return FALSE;
    }

  /* we invoked a remote method */
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
      }
    }

  if (!r->m_vecChannelsOut[packet->m_nChannel])
    r->m_vecChannelsOut[packet->m_nChannel] = malloc(sizeof(RTMPPacket));
  memcpy(r->m_vecChannelsOut[packet->m_nChannel], packet, sizeof(RTMPPacket));
  return TRUE;
}
```

<div style="margin: 0px;">
    备案号：
    <a href="https://beian.miit.gov.cn/" target="_blank">
        <!-- <img src="https://api.azpay.cn/808/1.png" style="height: 20px;"> -->沪ICP备2022002183号-1
    </a >
</div>

