# librtmp源码之WriteN

```c
// 发送数据报的时候调用（连接，buffer，长度）
static int
WriteN(RTMP *r, const char *buffer, int n)
{
  const char *ptr = buffer;
#ifdef CRYPTO
  char *encrypted = 0;
  char buf[RTMP_BUFFER_CACHE_SIZE];

  if (r->Link.rc4keyOut)
    {
      if (n > sizeof(buf))
	encrypted = (char *)malloc(n);
      else
	encrypted = (char *)buf;
      ptr = encrypted;
      RC4_encrypt2(r->Link.rc4keyOut, n, buffer, ptr);
    }
#endif

  while (n > 0)
    {
      int nBytes;
        // 因方式的不同而调用不同函数
        // 如果使用的是HTTP协议进行连接
      if (r->Link.protocol & RTMP_FEATURE_HTTP)
        nBytes = HTTP_Post(r, RTMPT_SEND, ptr, n);
      else
        nBytes = RTMPSockBuf_Send(&r->m_sb, ptr, n);
      /*RTMP_Log(RTMP_LOGDEBUG, "%s: %d\n", __FUNCTION__, nBytes); */

        // 成功发送字节数<0
      if (nBytes < 0)
	{
	  int sockerr = GetSockError();
	  RTMP_Log(RTMP_LOGERROR, "%s, RTMP send error %d (%d bytes)", __FUNCTION__,
	      sockerr, n);

	  if (sockerr == EINTR && !RTMP_ctrlC)
	    continue;

	  RTMP_Close(r);
	  n = 1;
	  break;
	}

      if (nBytes == 0)
	break;

      n -= nBytes;
      ptr += nBytes;
    }

#ifdef CRYPTO
  if (encrypted && encrypted != buf)
    free(encrypted);
#endif

  return n == 0;
}

// Socket发送（指明套接字，buffer缓冲区，数据长度）
// 返回所发数据量
int
RTMPSockBuf_Send(RTMPSockBuf *sb, const char *buf, int len)
{
  int rc;

#ifdef _DEBUG
  fwrite(buf, 1, len, netstackdump);
#endif

#if defined(CRYPTO) && !defined(NO_SSL)
  if (sb->sb_ssl)
    {
      rc = TLS_write(sb->sb_ssl, buf, len);
    }
  else
#endif
    {
        // 向一个已连接的套接口发送数据。
        // int send( SOCKET s, const char * buf, int len, int flags);
        // s：一个用于标识已连接套接口的描述字。
        // buf：包含待发送数据的缓冲区。
        // len：缓冲区中数据的长度。
        // flags：调用执行方式。
        // rc:所发数据量。
      rc = send(sb->sb_socket, buf, len, 0);
    }
  return rc;
}
```

>参考：

[RTMPdump（libRTMP） 源代码分析 8： 发送消息（Message）](https://blog.csdn.net/leixiaohua1020/article/details/12958747)