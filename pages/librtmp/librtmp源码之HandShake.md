# librttmp源码之HandShake

## HandShake

```c
static int
HandShake(RTMP * r, int FP9HandShake)
{
    RTMP_Log(RTMP_LOGDEBUG, "CCQ: %s start", __FUNCTION__);
  int i, offalg = 0;
  int dhposClient = 0;
  int digestPosClient = 0;
  int encrypted = r->Link.protocol & RTMP_FEATURE_ENC;

  RC4_handle keyIn = 0;
  RC4_handle keyOut = 0;

  int32_t *ip;
  uint32_t uptime;

  uint8_t clientbuf[RTMP_SIG_SIZE + 4], *clientsig=clientbuf+4;
  uint8_t serversig[RTMP_SIG_SIZE], client2[RTMP_SIG_SIZE], *reply;
  uint8_t type;
  getoff *getdh = NULL, *getdig = NULL;

  if (encrypted || r->Link.SWFSize)
    FP9HandShake = TRUE;
  else
    FP9HandShake = FALSE;

  r->Link.rc4keyIn = r->Link.rc4keyOut = 0;

  if (encrypted)
    {
      clientsig[-1] = 0x06; /* 0x08 is RTMPE as well */
      offalg = 1;
    }
  else
    clientsig[-1] = 0x03;

  uptime = htonl(RTMP_GetTime());
  memcpy(clientsig, &uptime, 4);

  if (FP9HandShake)
    {
      /* set version to at least 9.0.115.0 */
      if (encrypted)
  {
    clientsig[4] = 128;
    clientsig[6] = 3;
  }
      else
        {
    clientsig[4] = 10;
    clientsig[6] = 45;
  }
      clientsig[5] = 0;
      clientsig[7] = 2;

      RTMP_Log(RTMP_LOGDEBUG, "%s: Client type: %02X", __FUNCTION__, clientsig[-1]);
      getdig = digoff[offalg];
      getdh  = dhoff[offalg];
    }
  else
    {
      memset(&clientsig[4], 0, 4);
    }

  /* generate random data */
#ifdef _DEBUG
  memset(clientsig+8, 0, RTMP_SIG_SIZE-8);
#else
  ip = (int32_t *)(clientsig+8);
  for (i = 2; i < RTMP_SIG_SIZE/4; i++)
    *ip++ = rand();
#endif

  /* set handshake digest */
  if (FP9HandShake)
    {
      if (encrypted)
  {
    /* generate Diffie-Hellmann parameters */
    r->Link.dh = DHInit(1024);
    if (!r->Link.dh)
      {
        RTMP_Log(RTMP_LOGERROR, "%s: Couldn't initialize Diffie-Hellmann!",
      __FUNCTION__);
        return FALSE;
      }

    dhposClient = getdh(clientsig, RTMP_SIG_SIZE);
    RTMP_Log(RTMP_LOGDEBUG, "%s: DH pubkey position: %d", __FUNCTION__, dhposClient);

    if (!DHGenerateKey(r->Link.dh))
      {
        RTMP_Log(RTMP_LOGERROR, "%s: Couldn't generate Diffie-Hellmann public key!",
      __FUNCTION__);
        return FALSE;
      }

    if (!DHGetPublicKey(r->Link.dh, &clientsig[dhposClient], 128))
      {
        RTMP_Log(RTMP_LOGERROR, "%s: Couldn't write public key!", __FUNCTION__);
        return FALSE;
      }
  }

      digestPosClient = getdig(clientsig, RTMP_SIG_SIZE); /* reuse this value in verification */
      RTMP_Log(RTMP_LOGDEBUG, "%s: Client digest offset: %d", __FUNCTION__,
    digestPosClient);

      CalculateDigest(digestPosClient, clientsig, GenuineFPKey, 30,
          &clientsig[digestPosClient]);

      RTMP_Log(RTMP_LOGDEBUG, "%s: Initial client digest: ", __FUNCTION__);
      RTMP_LogHex(RTMP_LOGDEBUG, clientsig + digestPosClient,
       SHA256_DIGEST_LENGTH);
    }

#ifdef _DEBUG
  RTMP_Log(RTMP_LOGDEBUG, "Clientsig: ");
  RTMP_LogHex(RTMP_LOGDEBUG, clientsig, RTMP_SIG_SIZE);
#endif

  if (!WriteN(r, (char *)clientsig-1, RTMP_SIG_SIZE + 1))
    return FALSE;

  if (ReadN(r, (char *)&type, 1) != 1)  /* 0x03 or 0x06 */
    return FALSE;

  RTMP_Log(RTMP_LOGDEBUG, "%s: Type Answer   : %02X", __FUNCTION__, type);

  if (type != clientsig[-1])
    RTMP_Log(RTMP_LOGWARNING, "%s: Type mismatch: client sent %d, server answered %d",
  __FUNCTION__, clientsig[-1], type);

  if (ReadN(r, (char *)serversig, RTMP_SIG_SIZE) != RTMP_SIG_SIZE)
    return FALSE;

  /* decode server response */
  memcpy(&uptime, serversig, 4);
  uptime = ntohl(uptime);

  RTMP_Log(RTMP_LOGDEBUG, "%s: Server Uptime : %d", __FUNCTION__, uptime);
  RTMP_Log(RTMP_LOGDEBUG, "%s: FMS Version   : %d.%d.%d.%d", __FUNCTION__, serversig[4],
      serversig[5], serversig[6], serversig[7]);

  if (FP9HandShake && type == 3 && !serversig[4])
    FP9HandShake = FALSE;

#ifdef _DEBUG
  RTMP_Log(RTMP_LOGDEBUG, "Server signature:");
  RTMP_LogHex(RTMP_LOGDEBUG, serversig, RTMP_SIG_SIZE);
#endif

  if (FP9HandShake)
    {
      uint8_t digestResp[SHA256_DIGEST_LENGTH];
      uint8_t *signatureResp = NULL;

      /* we have to use this signature now to find the correct algorithms for getting the digest and DH positions */
      int digestPosServer = getdig(serversig, RTMP_SIG_SIZE);

      if (!VerifyDigest(digestPosServer, serversig, GenuineFMSKey, 36))
  {
    RTMP_Log(RTMP_LOGWARNING, "Trying different position for server digest!");
    offalg ^= 1;
    getdig = digoff[offalg];
    getdh  = dhoff[offalg];
    digestPosServer = getdig(serversig, RTMP_SIG_SIZE);

    if (!VerifyDigest(digestPosServer, serversig, GenuineFMSKey, 36))
      {
        RTMP_Log(RTMP_LOGERROR, "Couldn't verify the server digest"); /* continuing anyway will probably fail */
        return FALSE;
      }
  }

      /* generate SWFVerification token (SHA256 HMAC hash of decompressed SWF, key are the last 32 bytes of the server handshake) */
      if (r->Link.SWFSize)
  {
    const char swfVerify[] = { 0x01, 0x01 };
    char *vend = r->Link.SWFVerificationResponse+sizeof(r->Link.SWFVerificationResponse);

    memcpy(r->Link.SWFVerificationResponse, swfVerify, 2);
    AMF_EncodeInt32(&r->Link.SWFVerificationResponse[2], vend, r->Link.SWFSize);
    AMF_EncodeInt32(&r->Link.SWFVerificationResponse[6], vend, r->Link.SWFSize);
    HMACsha256(r->Link.SWFHash, SHA256_DIGEST_LENGTH,
         &serversig[RTMP_SIG_SIZE - SHA256_DIGEST_LENGTH],
         SHA256_DIGEST_LENGTH,
         (uint8_t *)&r->Link.SWFVerificationResponse[10]);
  }

      /* do Diffie-Hellmann Key exchange for encrypted RTMP */
      if (encrypted)
  {
    /* compute secret key */
    uint8_t secretKey[128] = { 0 };
    int len, dhposServer;

    dhposServer = getdh(serversig, RTMP_SIG_SIZE);
    RTMP_Log(RTMP_LOGDEBUG, "%s: Server DH public key offset: %d", __FUNCTION__,
      dhposServer);
    len = DHComputeSharedSecretKey(r->Link.dh, &serversig[dhposServer],
            128, secretKey);
    if (len < 0)
      {
        RTMP_Log(RTMP_LOGDEBUG, "%s: Wrong secret key position!", __FUNCTION__);
        return FALSE;
      }

    RTMP_Log(RTMP_LOGDEBUG, "%s: Secret key: ", __FUNCTION__);
    RTMP_LogHex(RTMP_LOGDEBUG, secretKey, 128);

    InitRC4Encryption(secretKey,
          (uint8_t *) & serversig[dhposServer],
          (uint8_t *) & clientsig[dhposClient],
          &keyIn, &keyOut);
  }


      reply = client2;
#ifdef _DEBUG
      memset(reply, 0xff, RTMP_SIG_SIZE);
#else
      ip = (int32_t *)reply;
      for (i = 0; i < RTMP_SIG_SIZE/4; i++)
        *ip++ = rand();
#endif
      /* calculate response now */
      signatureResp = reply+RTMP_SIG_SIZE-SHA256_DIGEST_LENGTH;

      HMACsha256(&serversig[digestPosServer], SHA256_DIGEST_LENGTH,
     GenuineFPKey, sizeof(GenuineFPKey), digestResp);
      HMACsha256(reply, RTMP_SIG_SIZE - SHA256_DIGEST_LENGTH, digestResp,
     SHA256_DIGEST_LENGTH, signatureResp);

      /* some info output */
      RTMP_Log(RTMP_LOGDEBUG,
    "%s: Calculated digest key from secure key and server digest: ",
    __FUNCTION__);
      RTMP_LogHex(RTMP_LOGDEBUG, digestResp, SHA256_DIGEST_LENGTH);

#ifdef FP10
      if (type == 8 )
        {
    uint8_t *dptr = digestResp;
    uint8_t *sig = signatureResp;
    /* encrypt signatureResp */
          for (i=0; i<SHA256_DIGEST_LENGTH; i+=8)
      rtmpe8_sig(sig+i, sig+i, dptr[i] % 15);
        }
      else if (type == 9)
        {
    uint8_t *dptr = digestResp;
    uint8_t *sig = signatureResp;
    /* encrypt signatureResp */
          for (i=0; i<SHA256_DIGEST_LENGTH; i+=8)
            rtmpe9_sig(sig+i, sig+i, dptr[i] % 15);
        }
#endif
      RTMP_Log(RTMP_LOGDEBUG, "%s: Client signature calculated:", __FUNCTION__);
      RTMP_LogHex(RTMP_LOGDEBUG, signatureResp, SHA256_DIGEST_LENGTH);
    }
  else
    {
      reply = serversig;
#if 0
      uptime = htonl(RTMP_GetTime());
      memcpy(reply+4, &uptime, 4);
#endif
    }

#ifdef _DEBUG
  RTMP_Log(RTMP_LOGDEBUG, "%s: Sending handshake response: ",
    __FUNCTION__);
  RTMP_LogHex(RTMP_LOGDEBUG, reply, RTMP_SIG_SIZE);
#endif
  if (!WriteN(r, (char *)reply, RTMP_SIG_SIZE))
    return FALSE;

  /* 2nd part of handshake */
  if (ReadN(r, (char *)serversig, RTMP_SIG_SIZE) != RTMP_SIG_SIZE)
    return FALSE;

#ifdef _DEBUG
  RTMP_Log(RTMP_LOGDEBUG, "%s: 2nd handshake: ", __FUNCTION__);
  RTMP_LogHex(RTMP_LOGDEBUG, serversig, RTMP_SIG_SIZE);
#endif

  if (FP9HandShake)
    {
      uint8_t signature[SHA256_DIGEST_LENGTH];
      uint8_t digest[SHA256_DIGEST_LENGTH];

      if (serversig[4] == 0 && serversig[5] == 0 && serversig[6] == 0
    && serversig[7] == 0)
  {
    RTMP_Log(RTMP_LOGDEBUG,
        "%s: Wait, did the server just refuse signed authentication?",
        __FUNCTION__);
  }
      RTMP_Log(RTMP_LOGDEBUG, "%s: Server sent signature:", __FUNCTION__);
      RTMP_LogHex(RTMP_LOGDEBUG, &serversig[RTMP_SIG_SIZE - SHA256_DIGEST_LENGTH],
       SHA256_DIGEST_LENGTH);

      /* verify server response */
      HMACsha256(&clientsig[digestPosClient], SHA256_DIGEST_LENGTH,
     GenuineFMSKey, sizeof(GenuineFMSKey), digest);
      HMACsha256(serversig, RTMP_SIG_SIZE - SHA256_DIGEST_LENGTH, digest,
     SHA256_DIGEST_LENGTH, signature);

      /* show some information */
      RTMP_Log(RTMP_LOGDEBUG, "%s: Digest key: ", __FUNCTION__);
      RTMP_LogHex(RTMP_LOGDEBUG, digest, SHA256_DIGEST_LENGTH);

#ifdef FP10
      if (type == 8 )
        {
    uint8_t *dptr = digest;
    uint8_t *sig = signature;
    /* encrypt signature */
          for (i=0; i<SHA256_DIGEST_LENGTH; i+=8)
      rtmpe8_sig(sig+i, sig+i, dptr[i] % 15);
        }
      else if (type == 9)
        {
    uint8_t *dptr = digest;
    uint8_t *sig = signature;
    /* encrypt signatureResp */
          for (i=0; i<SHA256_DIGEST_LENGTH; i+=8)
            rtmpe9_sig(sig+i, sig+i, dptr[i] % 15);
        }
#endif
      RTMP_Log(RTMP_LOGDEBUG, "%s: Signature calculated:", __FUNCTION__);
      RTMP_LogHex(RTMP_LOGDEBUG, signature, SHA256_DIGEST_LENGTH);
      if (memcmp
    (signature, &serversig[RTMP_SIG_SIZE - SHA256_DIGEST_LENGTH],
     SHA256_DIGEST_LENGTH) != 0)
  {
    RTMP_Log(RTMP_LOGWARNING, "%s: Server not genuine Adobe!", __FUNCTION__);
    return FALSE;
  }
      else
  {
    RTMP_Log(RTMP_LOGDEBUG, "%s: Genuine Adobe Flash Media Server", __FUNCTION__);
  }

      if (encrypted)
  {
    char buff[RTMP_SIG_SIZE];
    /* set keys for encryption from now on */
    r->Link.rc4keyIn = keyIn;
    r->Link.rc4keyOut = keyOut;


    /* update the keystreams */
    if (r->Link.rc4keyIn)
      {
        RC4_encrypt(r->Link.rc4keyIn, RTMP_SIG_SIZE, (uint8_t *) buff);
      }

    if (r->Link.rc4keyOut)
      {
        RC4_encrypt(r->Link.rc4keyOut, RTMP_SIG_SIZE, (uint8_t *) buff);
      }
  }
    }
  else
    {
      if (memcmp(serversig, clientsig, RTMP_SIG_SIZE) != 0)
  {
    RTMP_Log(RTMP_LOGWARNING, "%s: client signature does not match!",
        __FUNCTION__);
  }
    }

  RTMP_Log(RTMP_LOGDEBUG, "%s: Handshaking finished....", __FUNCTION__);
  return TRUE;
}
```

**代码片段分析1**
```c
int i, offalg = 0;// offalg加密才使用
int dhposClient = 0;// 加密才使用
int digestPosClient = 0;// 加密才使用
int encrypted = r->Link.protocol & RTMP_FEATURE_ENC;
  RTMP_Log(RTMP_LOGDEBUG, "CCQ: %s encrypted:%d", __FUNCTION__, encrypted);
  // DEBUG: CCQ: HandShake encrypted:0
  // 不加密
RC4_handle keyIn = 0;// 加密才使用
RC4_handle keyOut = 0;// 加密才使用

int32_t *ip;/* generate random data */
uint32_t uptime;// 当前时间，填充C1前4字节
```

**代码片段分析2**

```c
RC4_handle keyIn = 0;// 加密才使用
RC4_handle keyOut = 0;// 加密才使用

int32_t *ip;/* generate random data */
uint32_t uptime;// 当前时间，填充C1前4字节
// #define RTMP_SIG_SIZE 1536:C1和S1消息有1536字节长
uint8_t clientbuf[RTMP_SIG_SIZE + 4], *clientsig=clientbuf+4;
uint8_t serversig[RTMP_SIG_SIZE], client2[RTMP_SIG_SIZE], *reply;// reply,client2加密才使用
uint8_t type;// ReadN(r, (char *)&type, 1)之后获得
getoff *getdh = NULL, *getdig = NULL;// 加密才使用
```

**代码片段分析3**

```c
if (encrypted || r->Link.SWFSize)
  FP9HandShake = TRUE;
else
  //普通的
  FP9HandShake = FALSE;

r->Link.rc4keyIn = r->Link.rc4keyOut = 0;// 加密才使用

/*C0 字段已经写入clientsig*/
if (encrypted)
  {
    clientsig[-1] = 0x06; /* 0x08 is RTMPE as well */
    offalg = 1;
  }
else
  //0x03代表RTMP协议的版本（客户端要求的）  
  //数组竟然能有“-1”下标,因为clientsig指向的是clientbuf+4,所以不存在非法地址
  //C0中的字段(1B) 
  clientsig[-1] = 0x03;

uptime = htonl(RTMP_GetTime());
//void *memcpy(void *dest, const void *src, int n);
//由src指向地址为起始地址的连续n个字节的数据复制到以dest指向地址为起始地址的空间内
//把uptime的前4字节（其实一共就4字节）数据拷贝到clientsig指向的地址中
//C1中的字段(4B)
// ————————————————
// 版权声明：本文为CSDN博主「雷霄骅」的原创文章，遵循CC 4.0 BY-SA版权协议，转载请附上原文出处链接及本声明。
// 原文链接：https://blog.csdn.net/leixiaohua1020/article/details/12954329
memcpy(clientsig, &uptime, 4);
    RTMP_Log(RTMP_LOGDEBUG, "CCQ: uptime: ");
    RTMP_LogHexString(RTMP_LOGDEBUG, clientsig, 4);
    // DEBUG: Clientsig:
    // DEBUG:   0000:  0c b7 58 56                                        ..XV
```

`clientsig[-1] = 0x03;`将RTMP协议的版本号写入，1字节。

`memcpy(clientsig, &uptime, 4);`将当前时间写入`clientsig`，4字节。

**代码片段分析4**

```c
if (FP9HandShake)// 加密才处理
    {
      /* set version to at least 9.0.115.0 */
      if (encrypted)
  {
    clientsig[4] = 128;
    clientsig[6] = 3;
  }
      else
        {
    clientsig[4] = 10;
    clientsig[6] = 45;
  }
      clientsig[5] = 0;
      clientsig[7] = 2;

      RTMP_Log(RTMP_LOGDEBUG, "%s: Client type: %02X", __FUNCTION__, clientsig[-1]);
      getdig = digoff[offalg];
      getdh  = dhoff[offalg];
    }
  else
    {
      memset(&clientsig[4], 0, 4);
    }
```

`memset(&clientsig[4], 0, 4);`当前时间的后补0，占4字节。

**代码片段分析5**

```c

  /* generate random data */
#ifdef _DEBUG
  //将clientsig+8开始的1528个字节替换为0（这是一种简单的方法）
  //这是C1中的random字段
  memset(clientsig+8, 0, RTMP_SIG_SIZE-8);
#else
  //实际中使用rand()循环生成1528字节的伪随机数
  ip = (int32_t *)(clientsig+8);
  for (i = 2; i < RTMP_SIG_SIZE/4; i++)
    *ip++ = rand();
    
  RTMP_Log(RTMP_LOGDEBUG, "CCQ: ip: ");
  RTMP_LogHexString(RTMP_LOGDEBUG, (int32_t *)(clientsig+8), 1528);
#endif
```

根据上面的分析，得知`clientsig`的-1位置存放这0x03（RTMP）的版本号，占1字节；0-4位置存放这当前时间uptime，占4字节；之后5-8位置补0，占4字节；而`clientsig`的总长度是1536个字节，已经占用了8字节，所以上面代码是在补全剩下的1528个字节，补全的方式是使用随机数。

**代码片段分析5**

```c
#ifdef _DEBUG
  RTMP_Log(RTMP_LOGDEBUG, "Clientsig: ");
  RTMP_LogHex(RTMP_LOGDEBUG, clientsig, RTMP_SIG_SIZE);
#endif
    RTMP_Log(RTMP_LOGDEBUG, "CCQ: Clientsig: ");
    RTMP_LogHexString(RTMP_LOGDEBUG, clientsig, RTMP_SIG_SIZE);
//发送数据报C0+C1
  //从clientsig-1开始发，长度1536+1，两个包合并
  //握手----------------
  RTMP_Log(RTMP_LOGDEBUG, "CCQ: %s 建立连接：第1次连接。发送握手数据C0+C1", __FUNCTION__);
if (!WriteN(r, (char *)clientsig-1, RTMP_SIG_SIZE + 1))
  return FALSE;
  //读取数据报，长度1，存入type
  //是服务器的S0，表示服务器使用的RTMP版本
if (ReadN(r, (char *)&type, 1) != 1)  /* 0x03 or 0x06 */
  return FALSE;
  RTMP_Log(RTMP_LOGDEBUG, "CCQ: %s 建立连接：第1次连接。接收握手数据S0", __FUNCTION__);

RTMP_Log(RTMP_LOGDEBUG, "%s: Type Answer   : %02X", __FUNCTION__, type);
  //客户端要求的版本和服务器提供的版本不同
if (type != clientsig[-1])
  RTMP_Log(RTMP_LOGWARNING, "%s: Type mismatch: client sent %d, server answered %d",
__FUNCTION__, clientsig[-1], type);
  RTMP_Log(RTMP_LOGDEBUG, "CCQ: %s 建立连接：第1次连接。接收握手数据S1", __FUNCTION__);
  //客户端和服务端随机序列长度是否相同
if (ReadN(r, (char *)serversig, RTMP_SIG_SIZE) != RTMP_SIG_SIZE)
  return FALSE;
  RTMP_Log(RTMP_LOGDEBUG, "CCQ: %s 建立连接：第1次连接。接收握手数据S1", __FUNCTION__);

/* decode server response */
  //把serversig的前四个字节赋值给uptime
memcpy(&uptime, serversig, 4);
uptime = ntohl(uptime);//大端转小端

RTMP_Log(RTMP_LOGDEBUG, "%s: Server Uptime : %d", __FUNCTION__, uptime);
RTMP_Log(RTMP_LOGDEBUG, "%s: FMS Version   : %d.%d.%d.%d", __FUNCTION__, serversig[4],
    serversig[5], serversig[6], serversig[7]);
```

内容来源于：https://blog.csdn.net/bwangk/article/details/112802823

C0 和 S0消息格式：C0和S0是单独的一个字节，表示版本信息。

在C0中这个字段表示客户端要求的RTMP版本 。在S0中这个字段表示服务器选择的RTMP版本。本规范所定义的版本是3；0-2是早期产品所用的，已被丢弃；4-31保留在未来使用 ；32-255不允许使用 （为了区分其他以某一字符开始的文本协议）。如果服务无法识别客户端请求的版本，应该返回3 。客户端可以选择减到版本3或选择取消握手

C1 和 S1消息格式：C1和S1消息有1536字节长。

时间：4字节：本字段包含时间戳。该时间戳应该是发送这个数据块的端点的后续块的时间起始点。可以是0，或其他的任何值。为了同步多个流，端点可能发送其块流的当前值。
零：4字节：本字段必须是全零。
随机数据：1528字节。本字段可以包含任何值。因为每个端点必须用自己初始化的握手和对端初始化的握手来区分身份，所以这个数据应有充分的随机性。但是并不需要加密安全的随机值，或者动态值。

C2 和 S2 消息格式：C2和S2消息有1536字节长，只是S1和C1的回复。

时间：4字节：本字段必须包含对等段发送的时间（对C2来说是S1，对S2来说是C1）。
时间2：4字节：本字段必须包含先前发送的并被对端读取的包的时间戳。
随机回复：1528字节：本字段必须包含对端发送的随机数据字段（对C2来说是S1，对S2来说是C1）。每个对等端可以用时间和时间2字段中的时间戳来快速地估计带宽和延迟。但这样做可能并不实用。

上面代码的功能简单说：发送C0+C1，解析S0、S1。

**代码片段分析6**
```c
#ifdef _DEBUG
  RTMP_Log(RTMP_LOGDEBUG, "Server signature:");
  RTMP_LogHex(RTMP_LOGDEBUG, serversig, RTMP_SIG_SIZE);
#endif
    RTMP_Log(RTMP_LOGDEBUG, "CCQ: Server signature:");
    RTMP_LogHexString(RTMP_LOGDEBUG, serversig, RTMP_SIG_SIZE);
  if (FP9HandShake)
    {}
  else
    {
        RTMP_Log(RTMP_LOGDEBUG, "CCQ: %s reply = serversig", __FUNCTION__);
        //直接赋值
      reply = serversig;
#if 0
      uptime = htonl(RTMP_GetTime());
      memcpy(reply+4, &uptime, 4);
#endif
    }
```

**代码片段分析7**
```c
#ifdef _DEBUG
  RTMP_Log(RTMP_LOGDEBUG, "%s: Sending handshake response: ",
    __FUNCTION__);
  RTMP_LogHex(RTMP_LOGDEBUG, reply, RTMP_SIG_SIZE);
#endif
    //把reply中的1536字节数据发送出去
    //对应C2
    //握手----------------
    RTMP_Log(RTMP_LOGDEBUG, "CCQ: %s 建立连接：第1次连接。发送握手数据C2", __FUNCTION__);
  if (!WriteN(r, (char *)reply, RTMP_SIG_SIZE))
    return FALSE;

  /* 2nd part of handshake */
    //读取1536字节数据到serversig
    //握手----------------
    RTMP_Log(RTMP_LOGDEBUG, "CCQ: %s 建立连接：第1次连接。读取握手数据S2", __FUNCTION__);
  if (ReadN(r, (char *)serversig, RTMP_SIG_SIZE) != RTMP_SIG_SIZE)
    return FALSE;

#ifdef _DEBUG
  RTMP_Log(RTMP_LOGDEBUG, "%s: 2nd handshake: ", __FUNCTION__);
  RTMP_LogHex(RTMP_LOGDEBUG, serversig, RTMP_SIG_SIZE);
#endif
    RTMP_Log(RTMP_LOGDEBUG, "CCQ: %s: 2nd handshake: ", __FUNCTION__);
    RTMP_LogHexString(RTMP_LOGDEBUG, serversig, RTMP_SIG_SIZE);

  if (FP9HandShake)// 加密才执行
    {}
  else
    {
        //int memcmp(const void *buf1, const void *buf2, unsigned int count); 当buf1=buf2时，返回值=0
        //比较serversig和clientsig是否相等
        //握手----------------
        RTMP_Log(RTMP_LOGDEBUG, "CCQ: %s 建立连接：第1次连接。比较握手数据签名", __FUNCTION__);
      if (memcmp(serversig, clientsig, RTMP_SIG_SIZE) != 0)
  {
        RTMP_Log(RTMP_LOGDEBUG, "CCQ: %s 建立连接：第1次连接。握手数据签名不匹配！", __FUNCTION__);
    RTMP_Log(RTMP_LOGWARNING, "%s: client signature does not match!",
        __FUNCTION__);
  }
    }
```

上面代码简单说：发送C2，解析S2，客户端成功解析S2，服务端成功接收C2，第一次连接握手成功。

至此，HandShake的代码分析完毕。