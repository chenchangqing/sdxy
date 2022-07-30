# librttmp源码之相关结构体

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
    // #define RTMP_PACKET_SIZE_LARGE    0 onMetaData流开始的绝对时间戳控制消息（如connect）
    // #define RTMP_PACKET_SIZE_MEDIUM   1 大部分的rtmp header都是8字节的
    // #define RTMP_PACKET_SIZE_SMALL    2 比较少见
    // #define RTMP_PACKET_SIZE_MINIMUM  3 偶尔出现，低于8字节频率
    // chunk type id (2bit)fmt 对应message head {0,3,7,11} + (6bit)chunk stream id
    // 块类型ID，消息头的第1个字节的前2位，决定消息头长度
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