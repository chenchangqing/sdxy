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

## RTMP

内容来源于：https://www.jianshu.com/p/05b1e5d70c06

RTMP定义在`rtmp.h`。

```c
/*
** 远程调用方法
*/
typedef struct RTMP_METHOD
{
AVal name;
int num;
} RTMP_METHOD;

typedef struct RTMPSockBuf
{
  int sb_socket;    // 套接字
  int sb_size;    // 缓冲区可读大小
  char *sb_start;    // 缓冲区读取位置
  char sb_buf[RTMP_BUFFER_CACHE_SIZE];    // 套接字读取缓冲区
  int sb_timedout;    // 超时标志
  void *sb_ssl;    // TLS上下文
} RTMPSockBuf;

typedef struct RTMP
{
  int m_inChunkSize;    // 最大接收块大小
  int m_outChunkSize;    // 最大发送块大小
  int m_nBWCheckCounter;    // 带宽检测计数器
  int m_nBytesIn;    // 接收数据计数器
  int m_nBytesInSent;    // 当前数据已回应计数器
  int m_nBufferMS;    // 当前缓冲的时间长度，以MS为单位
  int m_stream_id;    // 当前连接的流ID
  int m_mediaChannel;    // 当前连接媒体使用的块流ID
  uint32_t m_mediaStamp;    // 当前连接媒体最新的时间戳
  uint32_t m_pauseStamp;    // 当前连接媒体暂停时的时间戳
  int m_pausing;    // 是否暂停状态
  int m_nServerBW;    // 服务器带宽
  int m_nClientBW;    // 客户端带宽
  uint8_t m_nClientBW2;    // 客户端带宽调节方式
  uint8_t m_bPlaying;    // 当前是否推流或连接中
  uint8_t m_bSendEncoding;    // 连接服务器时发送编码
  uint8_t m_bSendCounter;    // 设置是否向服务器发送接收字节应答

  int m_numInvokes;    // 0x14命令远程过程调用计数
  int m_numCalls;    // 0x14命令远程过程请求队列数量
  RTMP_METHOD *m_methodCalls;    // 远程过程调用请求队列

  RTMPPacket *m_vecChannelsIn[RTMP_CHANNELS];    // 对应块流ID上一次接收的报文
  RTMPPacket *m_vecChannelsOut[RTMP_CHANNELS];    // 对应块流ID上一次发送的报文
  int m_channelTimestamp[RTMP_CHANNELS];    // 对应块流ID媒体的最新时间戳

  double m_fAudioCodecs;    // 音频编码器代码
  double m_fVideoCodecs;    // 视频编码器代码
  double m_fEncoding;         /* AMF0 or AMF3 */

  double m_fDuration;    // 当前媒体的时长

  int m_msgCounter;    // 使用HTTP协议发送请求的计数器
  int m_polling;    // 使用HTTP协议接收消息主体时的位置
  int m_resplen;    // 使用HTTP协议接收消息主体时的未读消息计数
  int m_unackd;    // 使用HTTP协议处理时无响应的计数
  AVal m_clientID;    // 使用HTTP协议处理时的身份ID

  RTMP_READ m_read;    // RTMP_Read()操作的上下文
  RTMPPacket m_write;    // RTMP_Write()操作使用的可复用报文对象
  RTMPSockBuf m_sb;    // RTMP_ReadPacket()读包操作的上下文
  RTMP_LNK Link;    // RTMP连接上下文
} RTMP;
```

## RTMP_LINK

内容来源于：https://www.jianshu.com/p/05b1e5d70c06

```c
typedef struct RTMP_LNK
{
  AVal hostname;    // 目标主机地址
  AVal sockshost;    // socks代理地址

  // 连接和推拉流涉及的一些参数信息
  AVal playpath0;     /* parsed from URL */
  AVal playpath;      /* passed in explicitly */
  AVal tcUrl;
  AVal swfUrl;
  AVal pageUrl;
  AVal app;
  AVal auth;
  AVal flashVer;
  AVal subscribepath;
  AVal token;
  AMFObject extras;
  int edepth;

  int seekTime;    // 播放流的开始时间
  int stopTime;    // 播放流的停止时间

#define RTMP_LF_AUTH    0x0001  /* using auth param */
#define RTMP_LF_LIVE    0x0002  /* stream is live */
#define RTMP_LF_SWFV    0x0004  /* do SWF verification */
#define RTMP_LF_PLST    0x0008  /* send playlist before play */
#define RTMP_LF_BUFX    0x0010  /* toggle stream on BufferEmpty msg */
#define RTMP_LF_FTCU    0x0020  /* free tcUrl on close */
  int lFlags;

  int swfAge;

  int protocol;    // 连接使用的协议
  int timeout;    // 连接超时时间

  unsigned short socksport;    // socks代理端口
  unsigned short port;    // 目标主机端口

#ifdef CRYPTO
#define RTMP_SWF_HASHLEN        32
  void *dh;                   /* for encryption */
  void *rc4keyIn;
  void *rc4keyOut;

  uint32_t SWFSize;
  uint8_t SWFHash[RTMP_SWF_HASHLEN];
  char SWFVerificationResponse[RTMP_SWF_HASHLEN+10];
#endif
} RTMP_LNK;
```

## RTMPPacket

内容来源于：https://blog.csdn.net/NB_vol_1/article/details/58660181

https://blog.csdn.net/bwangk/article/details/112802823
 
```c

// 原始的rtmp消息块
typedef struct RTMPChunk
{
int c_headerSize; // 头部的长度
int c_chunkSize; // chunk的大小
char *c_chunk; // 数据
char c_header[RTMP_MAX_HEADER_SIZE]; // chunk头部
} RTMPChunk;

// rtmp消息块
typedef struct RTMPPacket
{
    // chunk basic header（大部分情况是一个字节）
    uint8_t m_headerType;

    // Message type ID（1-7协议控制；8，9音视频；10以后为AMF编码消息）
    uint8_t m_packetType;

    // 是否含有Extend timeStamp字段
    uint8_t m_hasAbsTimestamp;  /* timestamp absolute or relative? */

    // channel 即 stream id字段
    int m_nChannel;

    // 时间戳
    uint32_t m_nTimeStamp;  /* timestamp */

    // message stream id
    int32_t m_nInfoField2;  /* last 4 bytes in a long header */

    // chunk体的长度
    uint32_t m_nBodySize;
    uint32_t m_nBytesRead;
    RTMPChunk *m_chunk; // 原始rtmp消息块
    char *m_body;
} RTMPPacket;

typedef struct RTMPPacket
  {
    uint8_t m_headerType;       //basic header 中的type头字节，值为(0,1,2,3)表示ChunkMsgHeader的类型（4种）
    uint8_t m_packetType;       //Chunk Msg Header中msg type 1字节：消息类型id（8: audio；9:video；18:AMF0编码的元数据）
    uint8_t m_hasAbsTimestamp;  //bool值，是否是绝对时间戳(类型1时为true)
    int m_nChannel;             //块流ID  ，通过设置ChannelID来设置Basic stream id的长度和值
    uint32_t m_nTimeStamp;      //时间戳，消息头前三字节
    int32_t m_nInfoField2;      //Chunk Msg Header中msg StreamID 4字节：消息流id
    uint32_t m_nBodySize;       //Chunk Msg Header中msg length 4字节：消息长度
    uint32_t m_nBytesRead;      //已读取的数据
    RTMPChunk *m_chunk;         //raw chunk结构体指针，把RTMPPacket的真实头部和数据段拷贝进来
    char *m_body;               //数据段指针
  } RTMPPacket;
```

## RTMP_READ

内容来源于：https://blog.csdn.net/NB_vol_1/article/details/58660181

```c
/*
** AVal表示一个字符串
*/
typedef struct AVal
{
char *av_val;
int av_len;
} AVal;

/* state for read() wrapper */
  // read函数的包装器，包括状态等等
typedef struct RTMP_READ
{
char *buf;
char *bufpos;
unsigned int buflen;
uint32_t timestamp;
uint8_t dataType;
uint8_t flags;
#define RTMP_READ_HEADER    0x01
#define RTMP_READ_RESUME    0x02
#define RTMP_READ_NO_IGNORE 0x04
#define RTMP_READ_GOTKF     0x08
#define RTMP_READ_GOTFLVK   0x10
#define RTMP_READ_SEEKING   0x20
int8_t status;
#define RTMP_READ_COMPLETE  -3
#define RTMP_READ_ERROR -2
#define RTMP_READ_EOF   -1
#define RTMP_READ_IGNORE    0

/* if bResume == TRUE */
uint8_t initialFrameType;
uint32_t nResumeTS;
char *metaHeader;
char *initialFrame;
uint32_t nMetaHeaderSize;
uint32_t nInitialFrameSize;
uint32_t nIgnoredFrameCounter;
uint32_t nIgnoredFlvFrameCounter;
} RTMP_READ;
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
    // DEBUG: CCQ: RTMP_Connect1, r->Link.protocol:16
    // DEBUG: CCQ: RTMP_Connect1, RTMP_FEATURE_SSL:4
    // #define RTMP_FEATURE_SSL 0x04
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

<div style="margin: 0px;">
    备案号：
    <a href="https://beian.miit.gov.cn/" target="_blank">
        <!-- <img src="https://api.azpay.cn/808/1.png" style="height: 20px;"> -->沪ICP备2022002183号-1
    </a >
</div>

