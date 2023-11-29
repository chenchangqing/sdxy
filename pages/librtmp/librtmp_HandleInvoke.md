# librtmp源码之HandleInvoke

```c
// 处理服务器发来的AMF0编码的命令
/* Returns 0 for OK/Failed/error, 1 for 'Stop or Complete' */
static int
HandleInvoke(RTMP *r, const char *body, unsigned int nBodySize){
    AMFObject obj;
    AVal method;
    double txn;
    int ret = 0, nRes;
    // 确保响应报文是0x14的命令字
    // 0x02:string
    if (body[0] != 0x02)        /* make sure it is a string method name we start with */
    {
        RTMP_Log(RTMP_LOGWARNING, "%s, Sanity failed. no string method in invoke packet",
                 __FUNCTION__);
        return 0;
    }
    // 将各参数以无名称的对象属性方式进行解析
    nRes = AMF_Decode(&obj, body, nBodySize, FALSE);
    if (nRes < 0)
    {
        RTMP_Log(RTMP_LOGERROR, "%s, error decoding invoke packet", __FUNCTION__);
        return 0;
    }
    
    AMF_Dump(&obj);
    // 获取过程名称和流水号
    AMFProp_GetString(AMF_GetProp(&obj, NULL, 0), &method);
    txn = AMFProp_GetNumber(AMF_GetProp(&obj, NULL, 1));
    RTMP_Log(RTMP_LOGDEBUG, "%s, server invoking <%s>", __FUNCTION__, method.av_val);
    
    // 接收到服务端返回的一个_result包，所以我们需要找到这个包对应的那条命令，从而处理这条命令的对应事件。
    // 比如我们之前发送了个connect给服务端，服务端必然会返回_result，然后我们异步收到result后，会调用
    // RTMP_SendServerBW,RTMP_SendCtrl,以及RTMP_SendCreateStream来创建一个stream
    // 过程名称为_result
    if (AVMATCH(&method, &av__result))
    {
        AVal methodInvoked = {0};
        int i;
        // 删除请求队列中的流水项
        for (i=0; i<r->m_numCalls; i++) {
            // 找到这条指令对应的触发的方法
            if (r->m_methodCalls[i].num == (int)txn) {
                methodInvoked = r->m_methodCalls[i].name;
                AV_erase(r->m_methodCalls, &r->m_numCalls, i, FALSE);
                break;
            }
        }
        if (!methodInvoked.av_val) {
            RTMP_Log(RTMP_LOGDEBUG, "%s, received result id %f without matching request",
                     __FUNCTION__, txn);
            goto leave;
        }
        
        RTMP_Log(RTMP_LOGDEBUG, "%s, received result for method call <%s>", __FUNCTION__,
                 methodInvoked.av_val);
        // 找到了连接请求，确认是连接响应
        if (AVMATCH(&methodInvoked, &av_connect))
        {
            if (r->Link.token.av_len)
            {
                AMFObjectProperty p;
                if (RTMP_FindFirstMatchingProperty(&obj, &av_secureToken, &p))
                {
                    DecodeTEA(&r->Link.token, &p.p_vu.p_aval);
                    SendSecureTokenResponse(r, &p.p_vu.p_aval);
                }
            }
            // 客户端推流
            if (r->Link.protocol & RTMP_FEATURE_WRITE)
            {
                // 通知服务器释放流通道和清理推流资源
                SendReleaseStream(r);
                SendFCPublish(r);
            }
            // 客户端拉流
            else
            {
                // 设置服务器的应答窗口大小
                // 告诉服务端，我们的期望是什么，窗口大小，等
                RTMP_SendServerBW(r);
                RTMP_SendCtrl(r, 3, 0, 300);
            }
            // 发送创建流通道请求
            // 因为服务端同意了我们的connect，所以这里发送createStream创建一个流
            // 创建完成后，会再次进如这个函数从而走到下面的av_createStream分支，从而发送play过去
            RTMP_SendCreateStream(r);
            
            if (!(r->Link.protocol & RTMP_FEATURE_WRITE))
            {
                /* Authenticate on Justin.tv legacy servers before sending FCSubscribe */
                if (r->Link.usherToken.av_len)
                    SendUsherToken(r, &r->Link.usherToken);
                /* Send the FCSubscribe if live stream or if subscribepath is set */
                if (r->Link.subscribepath.av_len)
                    SendFCSubscribe(r, &r->Link.subscribepath);
                else if (r->Link.lFlags & RTMP_LF_LIVE)
                    SendFCSubscribe(r, &r->Link.playpath);
            }
        }
        // 找到了创建流请求，确认是创建流的响应
        else if (AVMATCH(&methodInvoked, &av_createStream))
        {
            // 从响应中取流ID
            r->m_stream_id = (int)AMFProp_GetNumber(AMF_GetProp(&obj, NULL, 3));
            
            // 客户端推流
            if (r->Link.protocol & RTMP_FEATURE_WRITE)
            {
                // 发送推流点
                // 如果是要发送，那么高尚服务端，我们要发数据
                SendPublish(r);
            }
            // 客户端拉流
            else
            {
                // 否则告诉他我们要接受数据
                if (r->Link.lFlags & RTMP_LF_PLST)
                    SendPlaylist(r);
                // 发送play过去
                // 发送拉流点
                SendPlay(r);
                // 以及我们的buf大小
                // 发送拉流缓冲时长
                RTMP_SendCtrl(r, 3, r->m_stream_id, r->m_nBufferMS);
            }
        }
        // 找到了推流和拉流请求，确认是它们的响应
        else if (AVMATCH(&methodInvoked, &av_play) ||
                 AVMATCH(&methodInvoked, &av_publish))
        {
            // 接收到了play的回复，那么标记为play
            // 标识已经进入流状态
            r->m_bPlaying = TRUE;
        }
        free(methodInvoked.av_val);
    }
    else if (AVMATCH(&method, &av_onBWDone))
    {
        if (!r->m_nBWCheckCounter)
            SendCheckBW(r);
    }
    else if (AVMATCH(&method, &av_onFCSubscribe))
    {
        /* SendOnFCSubscribe(); */
    }
    else if (AVMATCH(&method, &av_onFCUnsubscribe))
    {
        RTMP_Close(r);
        ret = 1;
    }
    // 过程名称为ping
    else if (AVMATCH(&method, &av_ping))
    {
        // 发送pong响应
        SendPong(r, txn);
    }
    else if (AVMATCH(&method, &av__onbwcheck))
    {
        SendCheckBWResult(r, txn);
    }
    else if (AVMATCH(&method, &av__onbwdone))
    {
        int i;
        for (i = 0; i < r->m_numCalls; i++)
            if (AVMATCH(&r->m_methodCalls[i].name, &av__checkbw))
            {
                AV_erase(r->m_methodCalls, &r->m_numCalls, i, TRUE);
                break;
            }
    }
    // 过程名称为_error
    else if (AVMATCH(&method, &av__error))
    {
#ifdef CRYPTO
        AVal methodInvoked = {0};
        int i;
        
        if (r->Link.protocol & RTMP_FEATURE_WRITE)
        {
            for (i=0; i<r->m_numCalls; i++)
            {
                if (r->m_methodCalls[i].num == txn)
                {
                    methodInvoked = r->m_methodCalls[i].name;
                    AV_erase(r->m_methodCalls, &r->m_numCalls, i, FALSE);
                    break;
                }
            }
            if (!methodInvoked.av_val)
            {
                RTMP_Log(RTMP_LOGDEBUG, "%s, received result id %f without matching request",
                         __FUNCTION__, txn);
                goto leave;
            }
            
            RTMP_Log(RTMP_LOGDEBUG, "%s, received error for method call <%s>", __FUNCTION__,
                     methodInvoked.av_val);
            
            if (AVMATCH(&methodInvoked, &av_connect))
            {
                AMFObject obj2;
                AVal code, level, description;
                AMFProp_GetObject(AMF_GetProp(&obj, NULL, 3), &obj2);
                AMFProp_GetString(AMF_GetProp(&obj2, &av_code, -1), &code);
                AMFProp_GetString(AMF_GetProp(&obj2, &av_level, -1), &level);
                AMFProp_GetString(AMF_GetProp(&obj2, &av_description, -1), &description);
                RTMP_Log(RTMP_LOGDEBUG, "%s, error description: %s", __FUNCTION__, description.av_val);
                /* if PublisherAuth returns 1, then reconnect */
                if (PublisherAuth(r, &description) == 1)
                {
                    CloseInternal(r, 1);
                    if (!RTMP_Connect(r, NULL) || !RTMP_ConnectStream(r, 0))
                        goto leave;
                }
            }
        }
        else
        {
            RTMP_Log(RTMP_LOGERROR, "rtmp server sent error");
        }
        free(methodInvoked.av_val);
#else
        RTMP_Log(RTMP_LOGERROR, "rtmp server sent error");
#endif
    }
    // 过程名称为close
    else if (AVMATCH(&method, &av_close))
    {
        RTMP_Log(RTMP_LOGERROR, "rtmp server requested close");
        RTMP_Close(r);
    }
    // 过程名称为onStatus
    else if (AVMATCH(&method, &av_onStatus))
    {
        // 获取返回对象及其主要属性
        AMFObject obj2;
        AVal code, level;
        AMFProp_GetObject(AMF_GetProp(&obj, NULL, 3), &obj2);
        AMFProp_GetString(AMF_GetProp(&obj2, &av_code, -1), &code);
        AMFProp_GetString(AMF_GetProp(&obj2, &av_level, -1), &level);
        
        RTMP_Log(RTMP_LOGDEBUG, "%s, onStatus: %s", __FUNCTION__, code.av_val);
        // 出错返回
        if (AVMATCH(&code, &av_NetStream_Failed)
            || AVMATCH(&code, &av_NetStream_Play_Failed)
            || AVMATCH(&code, &av_NetStream_Play_StreamNotFound)
            || AVMATCH(&code, &av_NetConnection_Connect_InvalidApp))
        {
            r->m_stream_id = -1;
            RTMP_Close(r);
            RTMP_Log(RTMP_LOGERROR, "Closing connection: %s", code.av_val);
        }
        // 启动拉流成功
        else if (AVMATCH(&code, &av_NetStream_Play_Start)
                 || AVMATCH(&code, &av_NetStream_Play_PublishNotify))
        {
            int i;
            r->m_bPlaying = TRUE;
            for (i = 0; i < r->m_numCalls; i++)
            {
                if (AVMATCH(&r->m_methodCalls[i].name, &av_play))
                {
                    AV_erase(r->m_methodCalls, &r->m_numCalls, i, TRUE);
                    break;
                }
            }
        }
        // 启动推流成功
        else if (AVMATCH(&code, &av_NetStream_Publish_Start))
        {
            int i;
            r->m_bPlaying = TRUE;
            for (i = 0; i < r->m_numCalls; i++)
            {
                if (AVMATCH(&r->m_methodCalls[i].name, &av_publish))
                {
                    AV_erase(r->m_methodCalls, &r->m_numCalls, i, TRUE);
                    break;
                }
            }
        }
        // 通知流完成或结束
        /* Return 1 if this is a Play.Complete or Play.Stop */
        else if (AVMATCH(&code, &av_NetStream_Play_Complete)
                 || AVMATCH(&code, &av_NetStream_Play_Stop)
                 || AVMATCH(&code, &av_NetStream_Play_UnpublishNotify))
        {
            RTMP_Close(r);
            ret = 1;
        }
        
        else if (AVMATCH(&code, &av_NetStream_Seek_Notify))
        {
            r->m_read.flags &= ~RTMP_READ_SEEKING;
        }
        // 通知流暂停
        else if (AVMATCH(&code, &av_NetStream_Pause_Notify))
        {
            if (r->m_pausing == 1 || r->m_pausing == 2)
            {
                RTMP_SendPause(r, FALSE, r->m_pauseStamp);
                r->m_pausing = 3;
            }
        }
    }
    else if (AVMATCH(&method, &av_playlist_ready))
    {
        int i;
        for (i = 0; i < r->m_numCalls; i++)
        {
            if (AVMATCH(&r->m_methodCalls[i].name, &av_set_playlist))
            {
                AV_erase(r->m_methodCalls, &r->m_numCalls, i, TRUE);
                break;
            }
        }
    }
    else
    {
        
    }
leave:
    AMF_Reset(&obj);
    return ret;
}
```

>参考：

[librtmp实时消息传输协议(RTMP)库代码浅析](http://chenzhenianqing.com/articles/1009.html)

[librtmp源码分析之核心实现解读](https://www.jianshu.com/p/05b1e5d70c06)

[RTMPdump（libRTMP） 源代码分析 7： 建立一个流媒体连接 （NetStream部分 2）](https://blog.csdn.net/leixiaohua1020/article/details/12958617)

[手撕Rtmp协议细节（3）——Rtmp Body](https://cloud.tencent.com/developer/article/1630594)