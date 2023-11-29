# librttmp源码之RTMP_Connect

## RTMP_Connect

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
    
    RTMP_Log(RTMP_LOGDEBUG, "CCQ: addrinfo->ai_flags:%d", service->ai_flags);
    RTMP_Log(RTMP_LOGDEBUG, "CCQ: addrinfo->ai_family:%d", service->ai_family);
    RTMP_Log(RTMP_LOGDEBUG, "CCQ: addrinfo->ai_socktype:%d", service->ai_socktype);
    RTMP_Log(RTMP_LOGDEBUG, "CCQ: addrinfo->ai_protocol:%d", service->ai_protocol);
    RTMP_Log(RTMP_LOGDEBUG, "CCQ: addrinfo->ai_addrlen:%d", service->ai_addrlen);
    RTMP_Log(RTMP_LOGDEBUG, "CCQ: addrinfo->ai_addr->sa_family:%d", service->ai_addr->sa_family);
    RTMP_Log(RTMP_LOGDEBUG, "CCQ: addrinfo->ai_addr->sa_data:%s", service->ai_addr->sa_data);
    RTMP_Log(RTMP_LOGDEBUG, "CCQ: addrinfo->ai_canonname:%s", service->ai_canonname);
    RTMP_Log(RTMP_LOGDEBUG, "CCQ: addrinfo->ai_next:%s", service->ai_next);
    
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
**代码片段分析1**
```c
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

RTMP_Log(RTMP_LOGDEBUG, "CCQ: addrinfo->ai_flags:%d", service->ai_flags);
RTMP_Log(RTMP_LOGDEBUG, "CCQ: addrinfo->ai_family:%d", service->ai_family);
RTMP_Log(RTMP_LOGDEBUG, "CCQ: addrinfo->ai_socktype:%d", service->ai_socktype);
RTMP_Log(RTMP_LOGDEBUG, "CCQ: addrinfo->ai_protocol:%d", service->ai_protocol);
RTMP_Log(RTMP_LOGDEBUG, "CCQ: addrinfo->ai_addrlen:%d", service->ai_addrlen);
RTMP_Log(RTMP_LOGDEBUG, "CCQ: addrinfo->ai_addr->sa_family:%d", service->ai_addr->sa_family);
RTMP_Log(RTMP_LOGDEBUG, "CCQ: addrinfo->ai_addr->sa_data:%s", service->ai_addr->sa_data);
RTMP_Log(RTMP_LOGDEBUG, "CCQ: addrinfo->ai_canonname:%s", service->ai_canonname);
RTMP_Log(RTMP_LOGDEBUG, "CCQ: addrinfo->ai_next:%s", service->ai_next);

// DEBUG: CCQ: addrinfo->ai_flags:0 /* 0代表没有设值，如果设值，取值范围见上`AI_PASSIVE`... */
// DEBUG: CCQ: addrinfo->ai_family:2 /* 2代表`AF_INET`，也就是`PF_INET`，取之范围见上`AF_UNSPEC`... */
// DEBUG: CCQ: addrinfo->ai_socktype:1 /* 1代表`SOCK_STREAM`，取值范围见上`__socket_type` */
// DEBUG: CCQ: addrinfo->ai_protocol:6 /* 6代表`IPPROTO_TCP`，取之范围见上`Ip Protocol` */
// DEBUG: CCQ: addrinfo->ai_addrlen:16 /* socket address 的长度 */
// DEBUG: CCQ: addrinfo->ai_addr->sa_family:2 /* 2代表`AF_INET`，也就是`PF_INET`，取之范围见上`AF_UNSPEC`... */
// DEBUG: CCQ: addrinfo->ai_addr->sa_data:\217\300\250
// DEBUG: CCQ: addrinfo->ai_canonname:(null) /* Canonical name of service location. */
// DEBUG: CCQ: addrinfo->ai_next:(null)
```

**代码片段分析2**
```c
if (!RTMP_Connect0(r, service))
{
  freeaddrinfo(service);
  return FALSE;
}

freeaddrinfo(service);
r->m_bSendCounter = TRUE;// 设置是否向服务器发送接收字节应答
return RTMP_Connect1(r, cp);
```

内容来源于：https://www.jianshu.com/p/05b1e5d70c06

开始调用`RTMP_Connect1`，继续执行SSL或HTTP协商，以及RTMP握手。

## add_addr_info

内容来源于：https://blog.csdn.net/weixin_37921201/article/details/90111641

填充struct addrinfo结构体用于之后的socket通信。

```c
/**
 填充struct addrinfo结构体用于之后的socket通信。
 service: addrinfo指针的指针
 host: 192.168.0.12:1935/zbcs/room
 port: 1935
 */
static int
add_addr_info(struct addrinfo **service, AVal *host, int port)
{
  struct addrinfo hints;
  char *hostname, portNo[32];
  int ret = TRUE;
    RTMP_Log(RTMP_LOGDEBUG, "CCQ: host->av_val：%s", host->av_val);
  if (host->av_val[host->av_len])
    {
      hostname = malloc(host->av_len+1);
      memcpy(hostname, host->av_val, host->av_len);
      hostname[host->av_len] = '\0';
        RTMP_Log(RTMP_LOGDEBUG, "CCQ: hostname：%s", hostname);
    }
  else
    {
      hostname = host->av_val;
        RTMP_Log(RTMP_LOGDEBUG, "CCQ: hostname2：%s", hostname);
    }

  sprintf(portNo, "%d", port);
    RTMP_Log(RTMP_LOGDEBUG, "CCQ: portNo：%s", portNo);
  
  memset(&hints, 0, sizeof(struct addrinfo));
  hints.ai_socktype = SOCK_STREAM;
  hints.ai_family = AF_UNSPEC;
  
  if(getaddrinfo(hostname, portNo, &hints, service) != 0)
    {
      RTMP_Log(RTMP_LOGERROR, "Problem accessing the DNS. (addr: %s)", hostname);
      ret = FALSE;
    }
finish:
  if (hostname != host->av_val)
    free(hostname);
  return ret;
}
```
**代码片段分析1**
```c
RTMP_Log(RTMP_LOGDEBUG, "CCQ: host->av_val：%s", host->av_val);
if (host->av_val[host->av_len])
{
  hostname = malloc(host->av_len+1);
  memcpy(hostname, host->av_val, host->av_len);
  hostname[host->av_len] = '\0';
    RTMP_Log(RTMP_LOGDEBUG, "CCQ: hostname：%s", hostname);
}
else
{
  hostname = host->av_val;
    RTMP_Log(RTMP_LOGDEBUG, "CCQ: hostname2：%s", hostname);
}
// 输出结果：
// DEBUG: host->av_val：192.168.0.12:1935/zbcs/room
// DEBUG: hostname：192.168.0.12
```
通过打印结果分析，这段代码就是给hostname赋值，得到IP地址段。

**代码片段分析2**
```c
sprintf(portNo, "%d", port);
    RTMP_Log(RTMP_LOGDEBUG, "CCQ: portNo：%d", portNo);
// DEBUG: CCQ: portNo：1935
```
sprintf：https://baike.baidu.com/item/sprintf/9703430?fr=aladdin

这里就是给portNo赋值，将`int`转`char *`。

**代码片段分析3**
```c
memset(&hints, 0, sizeof(struct addrinfo));// 给hints分配内存
  hints.ai_socktype = SOCK_STREAM;// 设置sock类型，设置范围：__socket_type
  hints.ai_family = AF_UNSPEC;// 指定返回地址的协议簇
```
内容来源于：

https://blog.csdn.net/u011003120/article/details/78277133 

https://www.cnblogs.com/LubinLew/p/POSIX-getaddrinfo.html

ai_family解释：指定返回地址的协议簇，取值范围:AF_INET(IPv4)、AF_INET6(IPv6)、AF_UNSPEC(IPv4 and IPv6)。

**代码片段分析4**
```c
// hostname：IP地址，例如：192.168.0.12
// portNo：端口号，例如：1935
// hints：struct addrinfo地址
// service：传进来的struct addrinfo，用于获取信息结果
if(getaddrinfo(hostname, portNo, &hints, service) != 0)
{
  RTMP_Log(RTMP_LOGERROR, "Problem accessing the DNS. (addr: %s)", hostname);
  ret = FALSE;
}
```
内容来源于：

https://www.cnblogs.com/LubinLew/p/POSIX-getaddrinfo.html

函数注释：
```c
int getaddrinfo(const char *restrict nodename, /* host 或者IP地址 */
    const char *restrict servname, /* 十进制端口号 或者常用服务名称如"ftp"、"http"等 */
    const struct addrinfo *restrict hints, /* 获取信息要求设置 */
    struct addrinfo **restrict res); /* 获取信息结果 */
```

IPv4中使用gethostbyname()函数完成主机名到地址解析，这个函数仅仅支持IPv4，且不允许调用者指定所需地址类型的任何信息，返回的结构只包含了用于存储IPv4地址的空间。IPv6中引入了新的API getaddrinfo()，它是协议无关的，既可用于IPv4也可用于IPv6。getaddrinfo() 函数能够处理名字到地址以及服务到端口这两种转换，返回的是一个 struct addrinfo 的结构体(列表)指针而不是一个地址清单。这些 struct addrinfo 结构体随后可由套接口函数直接使用。如此以来，getaddrinfo()函数把协议相关性安全隐藏在这个库函数内部。应用程序只要处理由getaddrinfo()函数填写的套接口地址结构。

**代码片段分析5**
```c
finish:
  if (hostname != host->av_val)
    free(hostname);
```
释放hostname内存，至此`add_addr_info`函数分析完毕。

## RTMP_Connect0

```c
int
RTMP_Connect0(RTMP *r, struct addrinfo * service)
{
  int on = 1;
  r->m_sb.sb_timedout = FALSE;
  r->m_pausing = 0;
  r->m_fDuration = 0.0;
    // 创建套接字
  r->m_sb.sb_socket = socket(service->ai_family, service->ai_socktype, service->ai_protocol);
  if (r->m_sb.sb_socket != -1)
    {// 连接对端
      if (connect(r->m_sb.sb_socket, service->ai_addr, service->ai_addrlen) < 0)
  {
    int err = GetSockError();
    RTMP_Log(RTMP_LOGERROR, "%s, failed to connect socket. %d (%s)",
        __FUNCTION__, err, strerror(err));
    RTMP_Close(r);
    return FALSE;
  }
        // 执行Socks协商
      if (r->Link.socksport)
  {
    RTMP_Log(RTMP_LOGDEBUG, "%s ... SOCKS negotiation", __FUNCTION__);
    if (!SocksNegotiate(r))
      {
        RTMP_Log(RTMP_LOGERROR, "%s, SOCKS negotiation failed.", __FUNCTION__);
        RTMP_Close(r);
        return FALSE;
      }
  }
    }
  else
    {
      RTMP_Log(RTMP_LOGERROR, "%s, failed to create socket. Error: %d", __FUNCTION__,
    GetSockError());
      return FALSE;
    }

  /* set timeout */
  {
    SET_RCVTIMEO(tv, r->Link.timeout);
    if (setsockopt
        (r->m_sb.sb_socket, SOL_SOCKET, SO_RCVTIMEO, (char *)&tv, sizeof(tv)))
      {
        RTMP_Log(RTMP_LOGERROR, "%s, Setting socket timeout to %ds failed!",
      __FUNCTION__, r->Link.timeout);
      }
  }

  setsockopt(r->m_sb.sb_socket, SOL_SOCKET, SO_NOSIGPIPE, (char *) &on, sizeof(on));
  setsockopt(r->m_sb.sb_socket, IPPROTO_TCP, TCP_NODELAY, (char *) &on, sizeof(on));

  return TRUE;
}
```
**代码片段分析1**
```c
int on = 1;// setsockopt函数使用
r->m_sb.sb_timedout = FALSE;// 超时标志
r->m_pausing = 0;// 是否暂停状态
r->m_fDuration = 0.0;// 当前媒体的时长
```
**代码片段分析2**
```c
// 创建套接字
// DEBUG: CCQ: addrinfo->ai_family:2 /* 2代表`AF_INET`，也就是`PF_INET`，取之范围见上`AF_UNSPEC`... */
// DEBUG: CCQ: addrinfo->ai_socktype:1 /* 1代表`SOCK_STREAM`，取值范围见上`__socket_type` */
// DEBUG: CCQ: addrinfo->ai_protocol:6 /* 6代表`IPPROTO_TCP`，取之范围见上`Ip Protocol` */
r->m_sb.sb_socket = socket(service->ai_family, service->ai_socktype, service->ai_protocol);
if (r->m_sb.sb_socket != -1)
  { // 连接对端
    // DEBUG: CCQ: addrinfo->ai_addrlen:16 /* socket address 的长度 */
    // DEBUG: CCQ: addrinfo->ai_addr->sa_family:2 /* 2代表`AF_INET`，也就是`PF_INET`，取之范围见上`AF_UNSPEC`... */
    // DEBUG: CCQ: addrinfo->ai_addr->sa_data:\217\300\250
    if (connect(r->m_sb.sb_socket, service->ai_addr, service->ai_addrlen) < 0)
{
  int err = GetSockError();
  RTMP_Log(RTMP_LOGERROR, "%s, failed to connect socket. %d (%s)",
      __FUNCTION__, err, strerror(err));
  RTMP_Close(r);
  return FALSE;
}
```
内容来源于：http://c.biancheng.net/view/2131.html

在 Linux 下使用 <sys/socket.h> 头文件中 socket() 函数来创建套接字，原型为：
```c
int socket(int af, int type, int protocol);
```

1) af 为地址族（Address Family），也就是 IP 地址类型，常用的有 AF_INET 和 AF_INET6。AF 是“Address Family”的简写，INET是“Inetnet”的简写。AF_INET 表示 IPv4 地址，例如 127.0.0.1；AF_INET6 表示 IPv6 地址，例如 1030::C9B4:FF12:48AA:1A2B。

大家需要记住127.0.0.1，它是一个特殊IP地址，表示本机地址，后面的教程会经常用到。

>你也可以使用 PF 前缀，PF 是“Protocol Family”的简写，它和 AF 是一样的。例如，PF_INET 等价于 AF_INET，PF_INET6 等价于 AF_INET6。

2) type 为数据传输方式/套接字类型，常用的有 SOCK_STREAM（流格式套接字/面向连接的套接字） 和 SOCK_DGRAM（数据报套接字/无连接的套接字），我们已经在《套接字有哪些类型》一节中进行了介绍。

3) protocol 表示传输协议，常用的有 IPPROTO_TCP 和 IPPTOTO_UDP，分别表示 TCP 传输协议和 UDP 传输协议。

`connect(r->m_sb.sb_socket, service->ai_addr, service->ai_addrlen)`抓包结果：

过滤条件：ip.addr eq 81.68.250.191

9833  2261.079011 192.168.1.3 81.68.250.191 TCP 78  51965 → 1935 [SYN] Seq=0 Win=65535 Len=0 MSS=1460 WS=64 TSval=45457028 TSecr=0 SACK_PERM=1

9834  2261.090254 81.68.250.191 192.168.1.3 TCP 74  1935 → 51965 [SYN, ACK] Seq=0 Ack=1 Win=28960 Len=0 MSS=1400 SACK_PERM=1 TSval=2657772015 TSecr=45457028 WS=128

9835  2261.090325 192.168.1.3 81.68.250.191 TCP 66  51965 → 1935 [ACK] Seq=1 Ack=1 Win=131840 Len=0 TSval=45457039 TSecr=2657772015

**代码片段分析3**
```c
// 执行Socks协商
      RTMP_Log(RTMP_LOGDEBUG, "CCQ: r->Link.socksport：%d", r->Link.socksport);
      // DEBUG: CCQ: r->Link.socksport：0
    if (r->Link.socksport)
{
  RTMP_Log(RTMP_LOGDEBUG, "%s ... SOCKS negotiation", __FUNCTION__);
  if (!SocksNegotiate(r))
    {
      RTMP_Log(RTMP_LOGERROR, "%s, SOCKS negotiation failed.", __FUNCTION__);
      RTMP_Close(r);
      return FALSE;
    }
}
```
r->Link.socksport：0，首次不会执行`SocksNegotiate`。

**代码片段分析4**
```c
/* set timeout */
  {
      RTMP_Log(RTMP_LOGDEBUG, "CCQ: r->Link.timeout：%d", r->Link.timeout);
      // DEBUG: CCQ: r->Link.timeout：30
      // #define SET_RCVTIMEO(tv,s)  int tv = s*1000
    SET_RCVTIMEO(tv, r->Link.timeout);
    // r->m_sb.sb_socket：标识一个套接口的描述字（RTMP->RTMPSockBuf->sb_socket）
    // SOL_SOCKET：选项定义的层次；目前仅支持SOL_SOCKET和IPPROTO_TCP层次。
    // SO_RCVTIMEO：接收超时。
    // tv：超时时间
    if (setsockopt
        (r->m_sb.sb_socket, SOL_SOCKET, SO_RCVTIMEO, (char *)&tv, sizeof(tv)))
      {
        RTMP_Log(RTMP_LOGERROR, "%s, Setting socket timeout to %ds failed!",
      __FUNCTION__, r->Link.timeout);
      }
  }
```
内容来源于：https://www.cnblogs.com/cthon/p/9270778.html

`SET_RCVTIMEO`是宏定义，给`tv`赋值，这里`tv`为30*1000。

**代码片段分析5**
```c
setsockopt(r->m_sb.sb_socket, SOL_SOCKET, SO_NOSIGPIPE, (char *) &on, sizeof(on));
setsockopt(r->m_sb.sb_socket, IPPROTO_TCP, TCP_NODELAY, (char *) &on, sizeof(on));
```

内容来源于：https://www.cnblogs.com/cthon/p/9270778.html

TCP_NODELAY选项禁止Nagle算法。Nagle算法通过将未确认的数据存入缓冲区直到蓄足一个包一起发送的方法，来减少主机发送的零碎小数据包的数目。但对于某些应用来说，这种算法将降低系统性能。所以TCP_NODELAY可用来将此算法关闭。应用程序编写者只有在确切了解它的效果并确实需要的情况下，才设置TCP_NODELAY选项，因为设置后对网络性能有明显的负面影响。TCP_NODELAY是唯一使用IPPROTO_TCP层的选项，其他所有选项都使用SOL_SOCKET层。

内容来源于：http://www.sinohandset.com/mac-osx%E4%B8%8Bso_nosigpipe%E7%9A%84%E6%80%AA%E5%BC%82%E8%A1%A8%E7%8E%B0

在linux下为了避免网络出错引起程序退出，我们一般采用`MSG_NOSIGNAL`来避免系统发送singal。这种错误一般发送在网络断开，但是程序仍然发送数据时，在接收时，没有必要使用。但是在linux下，使用此参数，也不会引起不好的结果。

## RTMP_Connect1
 
```c
int
RTMP_Connect1(RTMP *r, RTMPPacket *cp)
{
  if (r->Link.protocol & RTMP_FEATURE_SSL)
    {
#if defined(CRYPTO) && !defined(NO_SSL)
      TLS_client(RTMP_TLS_ctx, r->m_sb.sb_ssl);
      TLS_setfd(r->m_sb.sb_ssl, r->m_sb.sb_socket);
      if (TLS_connect(r->m_sb.sb_ssl) < 0)
    {
      RTMP_Log(RTMP_LOGERROR, "%s, TLS_Connect failed", __FUNCTION__);
      RTMP_Close(r);
      return FALSE;
    }
#else
      RTMP_Log(RTMP_LOGERROR, "%s, no SSL/TLS support", __FUNCTION__);
      RTMP_Close(r);
      return FALSE;

#endif
    }
  if (r->Link.protocol & RTMP_FEATURE_HTTP)
    {
      r->m_msgCounter = 1;
      r->m_clientID.av_val = NULL;
      r->m_clientID.av_len = 0;
      HTTP_Post(r, RTMPT_OPEN, "", 1);
      if (HTTP_read(r, 1) != 0)
    {
      r->m_msgCounter = 0;
      RTMP_Log(RTMP_LOGDEBUG, "%s, Could not connect for handshake", __FUNCTION__);
      RTMP_Close(r);
      return 0;
    }
      r->m_msgCounter = 0;
    }
  RTMP_Log(RTMP_LOGDEBUG, "%s, ... connected, handshaking", __FUNCTION__);
  if (!HandShake(r, TRUE))
    {
      RTMP_Log(RTMP_LOGERROR, "%s, handshake failed.", __FUNCTION__);
      RTMP_Close(r);
      return FALSE;
    }
  RTMP_Log(RTMP_LOGDEBUG, "%s, handshaked", __FUNCTION__);

  if (!SendConnectPacket(r, cp))
    {
      RTMP_Log(RTMP_LOGERROR, "%s, RTMP connect failed.", __FUNCTION__);
      RTMP_Close(r);
      return FALSE;
    }
  return TRUE;
}
```
**代码片段分析1**
```c
    RTMP_Log(RTMP_LOGDEBUG, "CCQ: %s, r->Link.protocol:%d", __FUNCTION__, r->Link.protocol);
    RTMP_Log(RTMP_LOGDEBUG, "CCQ: %s, RTMP_FEATURE_SSL:%d", __FUNCTION__, RTMP_FEATURE_SSL);
    RTMP_Log(RTMP_LOGDEBUG, "CCQ: %s, r->Link.protocol & RTMP_FEATURE_SSL:%d", __FUNCTION__, r->Link.protocol & RTMP_FEATURE_SSL);
    // DEBUG: CCQ: RTMP_Connect1, r->Link.protocol:16
    // DEBUG: CCQ: RTMP_Connect1, RTMP_FEATURE_SSL:4
    // #define RTMP_FEATURE_SSL 0x04
    // DEBUG: CCQ: RTMP_Connect1, r->Link.protocol & RTMP_FEATURE_SSL:0
  if (r->Link.protocol & RTMP_FEATURE_SSL)
    {
#if defined(CRYPTO) && !defined(NO_SSL)
      TLS_client(RTMP_TLS_ctx, r->m_sb.sb_ssl);
      TLS_setfd(r->m_sb.sb_ssl, r->m_sb.sb_socket);
      if (TLS_connect(r->m_sb.sb_ssl) < 0)
    {
      RTMP_Log(RTMP_LOGERROR, "%s, TLS_Connect failed", __FUNCTION__);
      RTMP_Close(r);
      return FALSE;
    }
#else
      RTMP_Log(RTMP_LOGERROR, "%s, no SSL/TLS support", __FUNCTION__);
      RTMP_Close(r);
      return FALSE;

#endif
    }
```
1.为什么r->Link.protocol=16？

```c
#define RTMP_FEATURE_WRITE  0x10  /* publish, not play */

void
RTMP_EnableWrite(RTMP *r)
{
  r->Link.protocol |= RTMP_FEATURE_WRITE;
}

RTMP_Log(RTMP_LOGDEBUG, "CCQ: %s, r->Link.protocol1:%d", __FUNCTION__, _rtmp->Link.protocol);
// DEBUG: CCQ: -[RTMPPusher connectWithURL:], r->Link.protocol1:0
RTMP_EnableWrite(_rtmp);
RTMP_Log(RTMP_LOGDEBUG, "CCQ: %s, r->Link.protocol2:%d", __FUNCTION__, _rtmp->Link.protocol);
// DEBUG: CCQ: -[RTMPPusher connectWithURL:], r->Link.protocol2:16 
```

2.`r->Link.protocol & RTMP_FEATURE_SSL`为0，不会执行if后的代码。

**代码片段分析2**

```c
RTMP_Log(RTMP_LOGDEBUG, "CCQ: %s, r->Link.protocol & RTMP_FEATURE_HTTP:%d", __FUNCTION__, r->Link.protocol & RTMP_FEATURE_HTTP);
    // DEBUG: CCQ: RTMP_Connect1, r->Link.protocol & RTMP_FEATURE_HTTP:0
  if (r->Link.protocol & RTMP_FEATURE_HTTP)
    {
      r->m_msgCounter = 1;
      r->m_clientID.av_val = NULL;
      r->m_clientID.av_len = 0;
      HTTP_Post(r, RTMPT_OPEN, "", 1);
      if (HTTP_read(r, 1) != 0)
  {
    r->m_msgCounter = 0;
    RTMP_Log(RTMP_LOGDEBUG, "%s, Could not connect for handshake", __FUNCTION__);
    RTMP_Close(r);
    return 0;
  }
      r->m_msgCounter = 0;
    }
  RTMP_Log(RTMP_LOGDEBUG, "%s, ... connected, handshaking", __FUNCTION__);
```

r->Link.protocol & RTMP_FEATURE_HTTP为0，不会执行if后的代码。连接成功，开始执行`handshaking`。

**代码片段3**
```c
// 进行HandShake
if (!HandShake(r, TRUE))
    {
      RTMP_Log(RTMP_LOGERROR, "%s, handshake failed.", __FUNCTION__);
      RTMP_Close(r);
      return FALSE;
    }
  RTMP_Log(RTMP_LOGDEBUG, "%s, handshaked", __FUNCTION__);
```

`connect(r->m_sb.sb_socket, service->ai_addr, service->ai_addrlen)`：

```
14  6.159961  192.168.1.3 81.68.250.191 TCP 78  52049 → 1935 [SYN] Seq=0 Win=65535 Len=0 MSS=1460 WS=64 TSval=1695460720 TSecr=0 SACK_PERM=1
15  6.177631  81.68.250.191 192.168.1.3 TCP 74  1935 → 52049 [SYN, ACK] Seq=0 Ack=1 Win=28960 Len=0 MSS=1400 SACK_PERM=1 TSval=2658240513 TSecr=1695460720 WS=128
16  6.177717  192.168.1.3 81.68.250.191 TCP 66  52049 → 1935 [ACK] Seq=1 Ack=1 Win=131840 Len=0 TSval=1695460737 TSecr=2658240513
```

`HandShake`：

```
17  6.177792  192.168.1.3 81.68.250.191 TCP 1454  52049 → 1935 [ACK] Seq=1 Ack=1 Win=131840 Len=1388 TSval=1695460737 TSecr=2658240513
18  6.177793  192.168.1.3 81.68.250.191 RTMP  215 Handshake C0+C1
19  6.186903  81.68.250.191 192.168.1.3 TCP 66  1935 → 52049 [ACK] Seq=1 Ack=1538 Win=32128 Len=0 TSval=2658240524 TSecr=1695460737
20  6.187494  81.68.250.191 192.168.1.3 TCP 1454  1935 → 52049 [ACK] Seq=1 Ack=1538 Win=32128 Len=1388 TSval=2658240524 TSecr=1695460737
21  6.187498  81.68.250.191 192.168.1.3 TCP 1454  1935 → 52049 [ACK] Seq=1389 Ack=1538 Win=32128 Len=1388 TSval=2658240524 TSecr=1695460737
22  6.187499  81.68.250.191 192.168.1.3 RTMP  363 Handshake S0+S1+S2
23  6.187559  192.168.1.3 81.68.250.191 TCP 66  52049 → 1935 [ACK] Seq=1538 Ack=3074 Win=128768 Len=0 TSval=1695460746 TSecr=2658240524
24  6.187636  192.168.1.3 81.68.250.191 TCP 1454  52049 → 1935 [ACK] Seq=1538 Ack=3074 Win=131072 Len=1388 TSval=1695460746 TSecr=2658240524
25  6.187636  192.168.1.3 81.68.250.191 RTMP  214 Handshake C2
26  6.195197  81.68.250.191 192.168.1.3 TCP 66  1935 → 52049 [ACK] Seq=3074 Ack=3074 Win=35200 Len=0 TSval=2658240532 TSecr=1695460746
```

**代码片段4**
```c

// /*握手成功之后，发送Connect Packet*/
if (!SendConnectPacket(r, cp))
    {
      RTMP_Log(RTMP_LOGERROR, "%s, RTMP connect failed.", __FUNCTION__);
      RTMP_Close(r);
      return FALSE;
    }
```