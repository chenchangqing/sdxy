# librttmp源码之RTMP_Connect

```c
int
RTMP_Connect(RTMP *r, RTMPPacket *cp)
{
  struct addrinfo *service;
  
  if (!r->Link.hostname.av_len)
    return FALSE;
    
  // 设置直接连接的服务器地址
  if (r->Link.socksport)
    {

      /* Connect via SOCKS */
      if (!add_addr_info(&service, &r->Link.sockshost, r->Link.socksport))
        return FALSE;
    }
  else
    {

      /* Connect directly */
      if (!add_addr_info(&service, &r->Link.hostname, r->Link.port))
        return FALSE;
    }
    
  if (!RTMP_Connect0(r, service))
    {
      freeaddrinfo(service);
      return FALSE;
    }

  freeaddrinfo(service);
  r->m_bSendCounter = TRUE;

  return RTMP_Connect1(r, cp);
}
```

## struct addrinfo

<netdb.h> 头应定义 addrinfo 结构，该结构应至少包括以下成员：