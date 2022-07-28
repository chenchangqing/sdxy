# librtmp源码之ReadN

```c
// 从HTTP或SOCKET中读取n个数据存放在buffer中.
static int
ReadN(RTMP *r, char *buffer, int n)
{
    int nOriginalSize = n;
    int avail;
    char *ptr;
    
    r->m_sb.sb_timedout = FALSE;
    
#ifdef _DEBUG
    memset(buffer, 0, n);
#endif
    
    ptr = buffer;
    while (n > 0)
    {
        int nBytes = 0, nRead;
        if (r->Link.protocol & RTMP_FEATURE_HTTP)
        {
            int refill = 0;
            while (!r->m_resplen)
            {
                int ret;
                if (r->m_sb.sb_size < 13 || refill)
                {
                    if (!r->m_unackd)
                        HTTP_Post(r, RTMPT_IDLE, "", 1);
                    if (RTMPSockBuf_Fill(&r->m_sb) < 1)
                    {
                        if (!r->m_sb.sb_timedout)
                            RTMP_Close(r);
                        return 0;
                    }
                }
                if ((ret = HTTP_read(r, 0)) == -1)
                {
                    RTMP_Log(RTMP_LOGDEBUG, "%s, No valid HTTP response found", __FUNCTION__);
                    RTMP_Close(r);
                    return 0;
                }
                else if (ret == -2)
                {
                    refill = 1;
                }
                else
                {
                    refill = 0;
                }
            }
            if (r->m_resplen && !r->m_sb.sb_size)
                RTMPSockBuf_Fill(&r->m_sb);
            avail = r->m_sb.sb_size;
            if (avail > r->m_resplen)
                avail = r->m_resplen;
        }
        else
        {
            avail = r->m_sb.sb_size;
            if (avail == 0)
            {
                if (RTMPSockBuf_Fill(&r->m_sb) < 1)
                {
                    if (!r->m_sb.sb_timedout)
                        RTMP_Close(r);
                    return 0;
                }
                avail = r->m_sb.sb_size;
            }
        }
        nRead = ((n < avail) ? n : avail);
        if (nRead > 0)
        {
            memcpy(ptr, r->m_sb.sb_start, nRead);
            r->m_sb.sb_start += nRead;
            r->m_sb.sb_size -= nRead;
            nBytes = nRead;
            r->m_nBytesIn += nRead;
            if (r->m_bSendCounter
                && r->m_nBytesIn > ( r->m_nBytesInSent + r->m_nClientBW / 10))
                if (!SendBytesReceived(r))
                    return FALSE;
        }
        /*RTMP_Log(RTMP_LOGDEBUG, "%s: %d bytes\n", __FUNCTION__, nBytes); */
#ifdef _DEBUG
        fwrite(ptr, 1, nBytes, netstackdump_read);
#endif
        
        if (nBytes == 0)
        {
            RTMP_Log(RTMP_LOGDEBUG, "%s, RTMP socket closed by peer", __FUNCTION__);
            /*goto again; */
            RTMP_Close(r);
            break;
        }
        
        if (r->Link.protocol & RTMP_FEATURE_HTTP)
            r->m_resplen -= nBytes;
        
#ifdef CRYPTO
        if (r->Link.rc4keyIn)
        {
            RC4_encrypt(r->Link.rc4keyIn, nBytes, ptr);
        }
#endif
        
        n -= nBytes;
        ptr += nBytes;
    }
    
    return nOriginalSize - n;
}

// 调用Socket编程中的recv()函数，接收数据
int
RTMPSockBuf_Fill(RTMPSockBuf *sb)
{
    int nBytes;
    
    if (!sb->sb_size)
        sb->sb_start = sb->sb_buf;
    
    while (1)
    {
        // 缓冲区长度：总长-未处理字节-已处理字节
        // |-----已处理--------|-----未处理--------|---------缓冲区----------|
        // sb_buf        sb_start    sb_size
        nBytes = sizeof(sb->sb_buf) - 1 - sb->sb_size - (sb->sb_start - sb->sb_buf);
#if defined(CRYPTO) && !defined(NO_SSL)
        if (sb->sb_ssl)
        {
            nBytes = TLS_read(sb->sb_ssl, sb->sb_start + sb->sb_size, nBytes);
        }
        else
#endif
        {
            // int recv( SOCKET s, char * buf, int len, int flags);
            // s    ：一个标识已连接套接口的描述字。
            // buf  ：用于接收数据的缓冲区。
            // len  ：缓冲区长度。
            // flags：指定调用方式。
            // 从sb_start（待处理的下一字节） + sb_size（）还未处理的字节开始buffer为空，可以存储
            nBytes = recv(sb->sb_socket, sb->sb_start + sb->sb_size, nBytes, 0);
        }
        if (nBytes != -1)
        {
            // 未处理的字节又多了
            sb->sb_size += nBytes;
        }
        else
        {
            int sockerr = GetSockError();
            RTMP_Log(RTMP_LOGDEBUG, "%s, recv returned %d. GetSockError(): %d (%s)",
                     __FUNCTION__, nBytes, sockerr, strerror(sockerr));
            if (sockerr == EINTR && !RTMP_ctrlC)
                continue;
            
            if (sockerr == EWOULDBLOCK || sockerr == EAGAIN)
            {
                sb->sb_timedout = TRUE;
                nBytes = 0;
            }
        }
        break;
    }
    
    return nBytes;
}
```

>参考：

[RTMP推流及协议学习](https://blog.csdn.net/huangyimo/article/details/83858620)

[RTMPdump（libRTMP） 源代码分析 9： 接收消息（Message）（接收视音频数据）](https://blog.csdn.net/leixiaohua1020/article/details/12971635)