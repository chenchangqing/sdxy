# librttmp源码之RTMP_Connect

分析`RTMP_Connect`之前，有必要了解下一下定义。

## Ip Protocol

```c
/* Standard well-defined IP protocols.  */
enum {
    IPPROTO_IP = 0,    /* Dummy protocol for TCP.  */
    IPPROTO_ICMP = 1,      /* Internet Control Message Protocol.  */
    IPPROTO_IGMP = 2,      /* Internet Group Management Protocol. */
    IPPROTO_IPIP = 4,      /* IPIP tunnels (older KA9Q tunnels use 94).  */
    IPPROTO_TCP = 6,       /* Transmission Control Protocol.  */
    IPPROTO_EGP = 8,       /* Exterior Gateway Protocol.  */
    IPPROTO_PUP = 12,      /* PUP protocol.  */
    IPPROTO_UDP = 17,      /* User Datagram Protocol.  */
    IPPROTO_IDP = 22,      /* XNS IDP protocol.  */
    IPPROTO_TP = 29,       /* SO Transport Protocol Class 4.  */
    IPPROTO_DCCP = 33,     /* Datagram Congestion Control Protocol.  */
    IPPROTO_IPV6 = 41,     /* IPv6 header.  */
    IPPROTO_RSVP = 46,     /* Reservation Protocol.  */
    IPPROTO_GRE = 47,      /* General Routing Encapsulation.  */
    IPPROTO_ESP = 50,      /* encapsulating security payload.  */
    IPPROTO_AH = 51,       /* authentication header.  */
    IPPROTO_MTP = 92,      /* Multicast Transport Protocol.  */
    IPPROTO_BEETPH = 94,   /* IP option pseudo header for BEET.  */
    IPPROTO_ENCAP = 98,    /* Encapsulation Header.  */
    IPPROTO_PIM = 103,     /* Protocol Independent Multicast.  */
    IPPROTO_COMP = 108,    /* Compression Header Protocol.  */
    IPPROTO_SCTP = 132,    /* Stream Control Transmission Protocol.  */
    IPPROTO_UDPLITE = 136, /* UDP-Lite protocol.  */
    IPPROTO_RAW = 255,     /* Raw IP packets.  */
    IPPROTO_MAX
};
```

## struct sockaddr

内容来源于：https://www.cnblogs.com/cyx-b/p/12450811.html

```c
struct sockaddr
{ 
　　unsigned short sa_family;// 2字节，地址族，AF_xxx
　　char sa_data[14]; // 14字节，包含套接字中的目标地址和端口信息 
};
```

## struct addrinfo

内容来源于：https://www.cnblogs.com/LubinLew/p/POSIX-DataStructure.html

The `<netdb.h>` header shall define the `addrinfo` structure, which shall include at least the following members:
```c
#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>

/* ======================Types of sockets====================== */
enum __socket_type {
    SOCK_STREAM = 1,        /* Sequenced, reliable, connection-based byte streams.  */
    SOCK_DGRAM = 2,         /* Connectionless, unreliable datagrams of fixed maximum length.  */
    SOCK_RAW = 3,           /* Raw protocol interface.  */
    SOCK_RDM = 4,           /* Reliably-delivered messages.  */
    SOCK_SEQPACKET = 5,     /* Sequenced, reliable, connection-based,datagrams of fixed maximum length.  */
    SOCK_DCCP = 6,          /* Datagram Congestion Control Protocol.  */
    SOCK_PACKET = 10,       /* Linux specific way of getting packets at the dev level.  For writing rarp and other similar things on the user level. */
    
    /* Flags to be ORed into the type parameter of socket and socketpair and used for the flags parameter of paccept.  */
    SOCK_CLOEXEC =  02000000,   /* Atomically set close-on-exec flag for the new descriptor(s).  */
    SOCK_NONBLOCK = 00004000    /* Atomically mark descriptor(s) as non-blocking.  */
};

/* ============Protocol families(只列出常用几个)================= */
#define PF_UNSPEC       0   /* Unspecified.  */
#define PF_LOCAL        1   /* Local to host (pipes and file-domain).  */
#define PF_INET         2   /* IP protocol family.  */
#define PF_IPX          4   /* Novell Internet Protocol.  */
#define PF_APPLETALK    5   /* Appletalk DDP.  */
#define PF_INET6        10  /* IP version 6.  */
#define PF_TIPC         30  /* TIPC sockets.  */
#define PF_BLUETOOTH    31  /* Bluetooth sockets.  */

/* ==============Address families(只列出常用几个)================= */
#define AF_UNSPEC   PF_UNSPEC
#define AF_LOCAL    PF_LOCAL
#define AF_UNIX     PF_UNIX
#define AF_FILE     PF_FILE
#define AF_INET     PF_INET
#define AF_IPX      PF_IPX
#define AF_APPLETALK    PF_APPLETALK
#define AF_INET6    PF_INET6
#define AF_ROSE     PF_ROSE
#define AF_NETLINK  PF_NETLINK
#define AF_TIPC     PF_TIPC
#define AF_BLUETOOTH    PF_BLUETOOTH

/* ====Possible values for `ai_flags' field in `addrinfo' structure.===== */
#define AI_PASSIVE        0x0001  /* Socket address is intended for `bind'. */
#define AI_CANONNAME      0x0002  /* Request for canonical name. */
#define AI_NUMERICHOST    0x0004  /* Don't use name resolution. */
#define AI_V4MAPPED       0x0008  /* IPv4 mapped addresses are acceptable. */
#define AI_ALL            0x0010  /* Return IPv4 mapped and IPv6 addresses. */
#define AI_ADDRCONFIG     0x0020  /* Use configuration of this host to choose returned address type. */
#ifdef __USE_GNU
#define AI_IDN                      0x0040  /* IDN encode input (assuming it is encoded
                  in the current locale's character set) before looking it up. */
#define AI_CANONIDN                 0x0080  /* Translate canonical name from IDN format. */
#define AI_IDN_ALLOW_UNASSIGNED     0x0100 /* Don't reject unassigned Unicode code points. */
#define AI_IDN_USE_STD3_ASCII_RULES 0x0200 /* Validate strings according to STD3 rules. */
#endif
#define AI_NUMERICSERV              0x0400  /* Don't use name resolution.  */

/* =======================struct addrinfo======================= */
struct addrinfo {
int ai_flags;              /* 附加选项,多个选项可以使用或操作结合 */
int ai_family;             /* 指定返回地址的协议簇,取值范围:AF_INET(IPv4)、AF_INET6(IPv6)、AF_UNSPEC(IPv4 and IPv6) */ 
int ai_socktype;           /* enum __socket_type 类型，设置为0表示任意类型 */
int ai_protocol;           /* 协议类型，设置为0表示任意类型,具体见上一节的 Ip Protocol */
socklen_t ai_addrlen;      /* socket address 的长度 */
struct sockaddr *ai_addr;  /* socket address 的地址 */
char *ai_canonname;        /* Canonical name of service location. */
struct addrinfo *ai_next;  /* 指向下一条信息,因为可能返回多个地址 */
};
```

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
      RTMP_Log(RTMP_LOGDEBUG, "CCQ: portNo：%d", portNo);
  
  memset(&hints, 0, sizeof(struct addrinfo));
  hints.ai_socktype = SOCK_STREAM;
  hints.ai_family = AF_UNSPEC;
  
    // https://www.cnblogs.com/LubinLew/p/POSIX-getaddrinfo.html
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
// DEBUG: CCQ: portNo：1834470648
```

<div style="margin: 0px;">
    备案号：
    <a href="https://beian.miit.gov.cn/" target="_blank">
        <!-- <img src="https://api.azpay.cn/808/1.png" style="height: 20px;"> -->沪ICP备2022002183号-1
    </a >
</div>

