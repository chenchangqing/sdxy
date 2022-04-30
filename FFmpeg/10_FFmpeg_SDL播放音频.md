# 10.FFmpeg+SDL播放音频

[Android工程代码](https://gitee.com/learnany/ffmpeg/tree/master/10_ffmpeg_sdl_play_audio/AndroidFFmpegSDLPlayAudio)


## 一、代码实现

### 增加头文件

```c
#include <SDL_thread.h>
```
### 定义一

```c
// 定义一
// SDL读音频缓存的大小
#define SDL_AUDIO_BUFFER_SIZE 1024
#define MAX_AUDIO_FRAME_SIZE 192000
int quit = 0;// 全局退出进程标识，在界面上点了退出后，告诉线程退出
```

### 定义二：数据包队列(链表)结构体

```c
// 定义二：数据包队列(链表)结构体
/*-------链表节点结构体-------
typedef struct AVPacketList {
    AVPacket pkt;//链表数据
    struct AVPacketList *next;//链表后继节点
} AVPacketList;
---------------------------*/
typedef struct PacketQueue {
    AVPacketList *first_pkt, *last_pkt;// 队列首尾节点指针
    int nb_packets;// 队列长度
    int size;// 保存编码数据的缓存长度，size=packet->size
    SDL_mutex *qlock;// 队列互斥量，保护队列数据
    SDL_cond *qready;// 队列就绪条件变量
} PacketQueue;
PacketQueue audioq;// 定义全局队列对象
```

### 定义三：队列初始化函数

```c
// 定义三：队列初始化函数
void packet_queue_init(PacketQueue *q) {
    memset(q, 0, sizeof(PacketQueue));//全零初始化队列结构体对象
    q->qlock = SDL_CreateMutex();//创建互斥量对象
    q->qready = SDL_CreateCond();//创建条件变量对象
}
```

### 定义四：向队列中插入数据包

```c
// 定义四：向队列中插入数据包
int packet_queue_put(PacketQueue *q, AVPacket *pkt) {
    /*-------准备队列(链表)节点对象------*/
    AVPacketList *pktlist;// 创建链表节点对象指针
    pktlist = static_cast<AVPacketList *>(av_malloc(sizeof(AVPacketList)));// 在堆上创建链表节点对象
    if (!pktlist) {// 检查链表节点对象是否创建成功
        return -1;
    }
    pktlist->pkt = *pkt;// 将输入数据包赋值给新建链表节点对象中的数据包对象
    pktlist->next = NULL;// 链表后继指针为空
    //  if (av_packet_ref(pkt, pkt)<0) {// 增加pkt编码数据的引用计数(输入参数中的pkt与新建链表节点中的pkt共享同一缓存空间)
    //      return -1;
    //  }
    /*---------将新建节点插入队列-------*/
    SDL_LockMutex(q->qlock);// 队列互斥量加锁，保护队列数据

    if (!q->last_pkt) {// 检查队列尾节点是否存在(检查队列是否为空)
        q->first_pkt = pktlist;// 若不存在(队列尾空)，则将当前节点作队列为首节点
    }
    else {
        q->last_pkt->next = pktlist;// 若已存在尾节点，则将当前节点挂到尾节点的后继指针上，并作为新的尾节点
    }
    q->last_pkt = pktlist;// 将当前节点作为新的尾节点
    q->nb_packets++;// 队列长度+1
    q->size += pktlist->pkt.size;// 更新队列编码数据的缓存长度

    SDL_CondSignal(q->qready);// 给等待线程发出消息，通知队列已就绪

    SDL_UnlockMutex(q->qlock);// 释放互斥量
    return 0;
}
```

### 定义五：从队列中提取数据包，并将提取的数据包出队列

```c
// 定义五：从队列中提取数据包，并将提取的数据包出队列
static int packet_queue_get(PacketQueue *q, AVPacket *pkt, int block) {
    AVPacketList *pktlist;// 临时链表节点对象指针
    int ret;// 操作结果

    SDL_LockMutex(q->qlock);// 队列互斥量加锁，保护队列数据
    for (;;) {
        if (quit) {// 检查退出进程标识
            ret = -1;// 操作失败
            break;
        }

        pktlist = q->first_pkt;// 传递将队列首个数据包指针
        if (pktlist) {// 检查数据包是否为空(队列是否有数据)
            q->first_pkt = pktlist->next;// 队列首节点指针后移
            if (!q->first_pkt) {// 检查首节点的后继节点是否存在
                q->last_pkt = NULL;// 若不存在，则将尾节点指针置空
            }
            q->nb_packets--;// 队列长度-1
            q->size -= pktlist->pkt.size;// 更新队列编码数据的缓存长度
            *pkt = pktlist->pkt;// 将队列首节点数据返回
            av_free(pktlist);// 清空临时节点数据(清空首节点数据，首节点出队列)
            ret = 1;// 操作成功
            break;
        } else if (!block) {
            ret = 0;
            break;
        } else {// 队列处于未就绪状态，此时通过SDL_CondWait函数等待qready就绪信号，并暂时对互斥量解锁
            /*---------------------
             * 等待队列就绪信号qready，并对互斥量暂时解锁
             * 此时线程处于阻塞状态，并置于等待条件就绪的线程列表上
             * 使得该线程只在临界区资源就绪后才被唤醒，而不至于线程被频繁切换
             * 该函数返回时，互斥量再次被锁住，并执行后续操作
             --------------------*/
            SDL_CondWait(q->qready, q->qlock);// 暂时解锁互斥量并将自己阻塞，等待临界区资源就绪(等待SDL_CondSignal发出临界区资源就绪的信号)
        }
    }// end for for-loop
    SDL_UnlockMutex(q->qlock);// 释放互斥量
    return ret;
}
```

### 定义六：音频解码

```c
/*---------------------------
 * 定义六：音频解码
 * 从缓存队列中提取数据包、解码，并返回解码后的数据长度(对一个完整的packet解码，将解码数据写入audio_buf缓存，并返回多帧解码数据的总长度)
 * aCodecCtx:音频解码器上下文
 * audio_buf：保存解码一个完整的packe后的原始音频数据(缓存中可能包含多帧解码后的音频数据)
 * buf_size：解码后的音频数据长度，未使用
 --------------------------*/
int audio_decode_frame(AVCodecContext *aCodecCtx, uint8_t *audio_buf, int buf_size) {
    static AVPacket pkt;// 保存从队列中提取的数据包
    static AVFrame frame;// 保存从数据包中解码的音频数据
    static uint8_t *audio_pkt_data = NULL;// 保存数据包编码数据缓存指针
    static int audio_pkt_size = 0;// 数据包中剩余的编码数据长度
    int coded_consumed_size, data_size = 0;// 每次消耗的编码数据长度[input](len1)，输出原始音频数据的缓存长度[output]

    for (;;) {
        while(audio_pkt_size>0) {// 检查缓存中剩余的编码数据长度(是否已完成一个完整的pakcet包的解码，一个数据包中可能包含多个音频编码帧)
            int got_frame = 0;// 解码操作成功标识，成功返回非零值
            coded_consumed_size=avcodec_decode_audio4(aCodecCtx,&frame,&got_frame,&pkt);//解码一帧音频数据，并返回消耗的编码数据长度
            if (coded_consumed_size < 0) {// 检查是否执行了解码操作
                // if error, skip frame.
                audio_pkt_size = 0;// 更新编码数据缓存长度
                break;
            }
            audio_pkt_data += coded_consumed_size;// 更新编码数据缓存指针位置
            audio_pkt_size -= coded_consumed_size;// 更新缓存中剩余的编码数据长度
            if (got_frame) {// 检查解码操作是否成功
                // 计算解码后音频数据长度[output]
                data_size=av_samples_get_buffer_size(NULL,aCodecCtx->channels,frame.nb_samples,aCodecCtx->sample_fmt,1);
                memcpy(audio_buf, frame.data[0], data_size);// 将解码数据复制到输出缓存
            }
            if (data_size <= 0) {// 检查输出解码数据缓存长度
                // No data yet, get more frames.
                continue;
            }
            // We have data, return it and come back for more later.
            return data_size;// 返回解码数据缓存长度
        }// end for while

        if (pkt.data) {// 检查数据包是否已从队列中提取
            av_packet_unref(&pkt);// 释放pkt中保存的编码数据
        }

        if (quit) {// 检查退出进程标识
            return -1;
        }
        // 从队列中提取数据包到pkt
        if (packet_queue_get(&audioq, &pkt,1)<0) {
            return -1;
        }
        audio_pkt_data = pkt.data;// 传递编码数据缓存指针
        audio_pkt_size = pkt.size;// 传递编码数据缓存长度
    }// end for for-loop
}
```

### 定义七：音频输出回调函数

```c
/*------Audio Callback-------
 * 定义七：音频输出回调函数
 * sdl通过该回调函数将解码后的pcm数据送入声卡播放,
 * sdl通常一次会准备一组缓存pcm数据，通过该回调送入声卡，声卡根据音频pts依次播放pcm数据
 * 待送入缓存的pcm数据完成播放后，再载入一组新的pcm缓存数据(每次音频输出缓存为空时，sdl就调用此函数填充音频输出缓存，并送入声卡播放)
 * When we begin playing audio, SDL will continually call this callback function
 * and ask it to fill the audio buffer with a certain number of bytes
 * The audio function callback takes the following parameters:
 * stream: A pointer to the audio buffer to be filled，输出音频数据到声卡缓存
 * len: The length (in bytes) of the audio buffer,缓存长度wanted_spec.samples=SDL_AUDIO_BUFFER_SIZE(1024)
 --------------------------*/
void audio_callback(void *userdata, Uint8 *stream, int len) {
    AVCodecContext *aCodecCtx = (AVCodecContext *)userdata;// 传递用户数据
    int wt_stream_len, audio_size;// 每次写入stream的数据长度，解码后的数据长度

    static uint8_t audio_buf[(MAX_AUDIO_FRAME_SIZE*3)/2];// 保存解码一个packet后的多帧原始音频数据
    static unsigned int audio_buf_size = 0;// 解码后的多帧音频数据长度
    static unsigned int audio_buf_index = 0;// 累计写入stream的长度

    while (len>0) {// 检查音频缓存的剩余长度
        if (audio_buf_index >= audio_buf_size) {// 检查是否需要执行解码操作
            // We have already sent all our data; get more，从缓存队列中提取数据包、解码，并返回解码后的数据长度，audio_buf缓存中可能包含多帧解码后的音频数据
            audio_size = audio_decode_frame(aCodecCtx, audio_buf, audio_buf_size);
            if (audio_size < 0) {// 检查解码操作是否成功
                // If error, output silence.
                audio_buf_size = 1024; // arbitrary?
                memset(audio_buf, 0, audio_buf_size);// 全零重置缓冲区
            } else {
                audio_buf_size = audio_size;// 返回packet中包含的原始音频数据长度(多帧)
            }
            audio_buf_index = 0;// 初始化累计写入缓存长度
        }// end for if

        wt_stream_len = audio_buf_size-audio_buf_index;// 计算解码缓存剩余长度
        if (wt_stream_len > len) {// 检查每次写入缓存的数据长度是否超过指定长度(1024)
            wt_stream_len = len;// 指定长度从解码的缓存中取数据
        }
        // 每次从解码的缓存数据中以指定长度抽取数据并写入stream传递给声卡
        memcpy(stream,(uint8_t*)audio_buf+audio_buf_index,wt_stream_len);
        len -= wt_stream_len;// 更新解码音频缓存的剩余长度
        stream += wt_stream_len;// 更新缓存写入位置
        audio_buf_index += wt_stream_len;// 更新累计写入缓存数据长度
    }// end for while
}
```

### 第一步：注册组件

```c
/*-------------------------
 * 第一步：注册组件
 * 注册所有ffmpeg支持的多媒体格式及编解码器
 -------------------------*/
av_register_all();
```

### 第二步：打开封装格式

```c
/*-------------------------
 * 第二步：打开封装格式
 * 打开视频文件，读文件头内容，取得文件容器的封装信息及码流参数并存储在avformat_context中
 * 参数一：封装格式上下文
 * 参数二：视频路径
 * 参数三：指定输入的格式
 * 参数四：设置默认参数
 --------------------------*/
AVFormatContext* avformat_context = avformat_alloc_context();// 参数一：封装格式上下文
const char *url = "/storage/emulated/0/Download/test.mov";// 参数二：视频路径
int avformat_open_input_result = avformat_open_input(&avformat_context, url, NULL, NULL);
if (avformat_open_input_result != 0){
    __android_log_print(ANDROID_LOG_INFO, "main", "查找音视频流\n");
    return -1;
}
```

### 第三步：查找码流

```c
/*-------------------------
 * 第三步：查找码流
 * 取得文件中保存的码流信息，并填充到avformat_context->stream 字段
 * 参数一：封装格式上下文
 * 参数二：指定默认配置
 -------------------------*/
int avformat_find_stream_info_result = avformat_find_stream_info(avformat_context, NULL);
if (avformat_find_stream_info_result < 0){
    __android_log_print(ANDROID_LOG_INFO, "main", "查找音视频流失败\n");
    return -1;
}
```

### 第四步：查找解码器

```c
// 第四步：查找解码器
// 视频流类型标号初始化为-1
int av_video_stream_index = -1;
// 音频流类型标号初始化为-1
int av_audio_stream_index = -1;
for (int i = 0; i < avformat_context->nb_streams; ++i) {
    // 若文件中包含有视频流
    if (avformat_context->streams[i]->codec->codec_type == AVMEDIA_TYPE_VIDEO){
        av_video_stream_index = i;
    }
    // 若文件中包含有音频流
    if (avformat_context->streams[i]->codec->codec_type == AVMEDIA_TYPE_AUDIO){
        av_audio_stream_index = i;
    }
}
// 检查文件中是否存在视频流
if (av_video_stream_index == -1) {
    __android_log_print(ANDROID_LOG_INFO, "main", "没有找到视频流\n");
    return -1;
}
// 检查文件中是否存在音频流
if (av_audio_stream_index == -1) {
    __android_log_print(ANDROID_LOG_INFO, "main", "没有找到音频流\n");
    return -1;
}
// 根据流类型标号从avformat_context->streams中取得流对应的解码器上下文
AVCodecContext *video_avcodec_context = avformat_context->streams[av_video_stream_index]->codec;
AVCodecContext *audio_avcodec_context = avformat_context->streams[av_audio_stream_index]->codec;
// 根据流对应的解码器上下文查找对应的解码器，返回对应的解码器(信息结构体)
AVCodec *video_avcodec = avcodec_find_decoder(video_avcodec_context->codec_id);
AVCodec *audio_avcodec = avcodec_find_decoder(audio_avcodec_context->codec_id);
// 检查视频解码器
if (!video_avcodec) {
    __android_log_print(ANDROID_LOG_INFO, "main", "没找到视频解码器\n");
    return -1;
}
// 检查音频解码器
if (!audio_avcodec) {
    __android_log_print(ANDROID_LOG_INFO, "main", "没找到音频解码器\n");
    return -1;
}
```

### 第五步：打开解码器

```c
// 第五步：打开解码器
// 打开视频解码器
int avcodec_open2_result = avcodec_open2(video_avcodec_context, video_avcodec, NULL);
if (avcodec_open2_result != 0){
    __android_log_print(ANDROID_LOG_INFO, "main", "打开视频解码器失败\n");
    return -1;
}
// 打开音频解码器
avcodec_open2_result = avcodec_open2(audio_avcodec_context, audio_avcodec, NULL);
if (avcodec_open2_result != 0){
    __android_log_print(ANDROID_LOG_INFO, "main", "打开音频解码器失败\n");
    return -1;
}
// 打印解码器信息
__android_log_print(ANDROID_LOG_INFO, "main", "视频解码器：%s\n", video_avcodec->name);
__android_log_print(ANDROID_LOG_INFO, "main", "音频解码器：%s\n", audio_avcodec->name);
```

### 第六步：定义类型转换参数

```c
/*-------------------------
 * 第六步：定义类型转换参数
 * 参数一：原始视频像素数据格式宽
 * 参数二：原始视频像素数据格式高
 * 参数三：原始视频像素数据格式类型
 * 参数四：目标视频像素数据格式宽
 * 参数五：目标视频像素数据格式高
 * 参数六：目标视频像素数据格式类型
 -------------------------*/
// 设置图像转换像素格式为AV_PIX_FMT_YUV420P
SwsContext *swscontext = sws_getContext(video_avcodec_context->width,
                                        video_avcodec_context->height,
                                        video_avcodec_context->pix_fmt,
                                        video_avcodec_context->width,
                                        video_avcodec_context->height,
                                        AV_PIX_FMT_YUV420P,
                                        SWS_BICUBIC,
                                        NULL,
                                        NULL,
                                        NULL);
// 保存音视频解码后的数据，如状态信息、编解码器信息、宏块类型表，QP表，运动矢量表等数据
AVFrame* avframe_in = av_frame_alloc();
// 定义解码结果
int decode_result = 0;
// AV_PIX_FMT_YUV420P格式的视频帧
AVFrame* avframe_yuv420p = av_frame_alloc();
// 给缓冲区设置类型
int buffer_size =av_image_get_buffer_size(AV_PIX_FMT_YUV420P,// 视频像素数据格式类型
                                          video_avcodec_context->width,// 一帧视频像素数据宽 = 视频宽
                                          video_avcodec_context->height,// 一帧视频像素数据高 = 视频高
                                          1);// 字节对齐方式，默认是1
// 开辟一块内存空间
uint8_t *out_buffer = (uint8_t *)av_malloc(buffer_size);
// 向avframe_yuv420p填充数据
av_image_fill_arrays(avframe_yuv420p->data,// 目标视频帧数据
                     avframe_yuv420p->linesize,// 目标视频帧行大小
                     out_buffer,// 原始数据
                     AV_PIX_FMT_YUV420P,// 视频像素数据格式类型
                     video_avcodec_context->width,// 视频宽
                     video_avcodec_context->height,//视频高
                     1);// 字节对齐方式
```

### 第七步：初始化SDL多媒体框架

```c
// 第七步：初始化SDL多媒体框架
if (SDL_Init( SDL_INIT_VIDEO | SDL_INIT_AUDIO | SDL_INIT_TIMER ) == -1) {
    __android_log_print(ANDROID_LOG_INFO, "main", "初始化失败：%s", SDL_GetError());
    // Mac使用
    // printf("初始化失败：%s", SDL_GetError());
    return -1;
}
```

### 第八步：缓存队列初始化

```c
// 第八步：缓存队列初始化
packet_queue_init(&audioq);
```

### 第九步：设置音频播放参数

```c
// 第九步：设置音频播放参数
// SDL_AudioSpec a structure that contains the audio output format，创建 SDL_AudioSpec 结构体，设置音频播放数据
SDL_AudioSpec wanted_spec, spec;
// 创建SDL_AudioSpec结构体，设置音频播放参数
// 采样频率 DSP frequency -- samples per second
wanted_spec.freq = audio_avcodec_context->sample_rate;
// 采样格式 Audio data format
wanted_spec.format = AUDIO_S16SYS;
// 声道数 Number of channels: 1 mono, 2 stereo
wanted_spec.channels = audio_avcodec_context->channels;
wanted_spec.silence = 0;// 无输出时是否静音
// 默认每次读音频缓存的大小，推荐值为 512~8192，ffplay使用的是1024
wanted_spec.samples = SDL_AUDIO_BUFFER_SIZE;
// 设置取音频数据的回调接口函数 the function to call when the audio device needs more data
wanted_spec.callback = audio_callback;
// 传递用户数据
wanted_spec.userdata = audio_avcodec_context;
```

### 第十步：打开音频设备

```c
/*--------------------------
 * 第十步：打开音频设备
 * 以指定参数打开音频设备，并返回与指定参数最为接近的参数，该参数为设备实际支持的音频参数
 * Opens the audio device with the desired parameters(wanted_spec)
 * return another specs we actually be using
 * and not guaranteed to get what we asked for
 --------------------------*/
if (SDL_OpenAudio(&wanted_spec, &spec)<0) {
    fprintf(stderr, "SDL_OpenAudio: %s\n", SDL_GetError());
    return -1;
}
// 开启音频设备，如果这时候没有获得数据那么它就静音
SDL_PauseAudio(0);
```

### 第十一步：初始化SDL窗口

```c
// 第十一步：初始化SDL窗口
SDL_Window* sdl_window = SDL_CreateWindow("FFmpeg+SDL播放视频",// 参数一：窗口名称
                                          SDL_WINDOWPOS_CENTERED,// 参数二：窗口在屏幕上的x坐标
                                          SDL_WINDOWPOS_CENTERED,// 参数三：窗口在屏幕上的y坐标
                                          video_avcodec_context->width,// 参数四：窗口在屏幕上宽
                                          video_avcodec_context->height,// 参数五：窗口在屏幕上高
                                          SDL_WINDOW_OPENGL);// 参数六：窗口状态(打开)
if (sdl_window == NULL){
    __android_log_print(ANDROID_LOG_INFO, "main", "窗口创建失败：%s", SDL_GetError());
    // Mac使用
    // printf("窗口创建失败： %s\n", SDL_GetError());
    // 退出程序
    SDL_Quit();
    return -1;
}
__android_log_print(ANDROID_LOG_INFO, "main", "窗口创建成功，width：%d，height：%d", video_avcodec_context->width, video_avcodec_context->height);
```

### 第十二步：创建渲染器

```c
// 第十二步：创建渲染器
// 定义渲染器区域
SDL_Rect sdl_rect;
SDL_Renderer* sdl_renderer = SDL_CreateRenderer(sdl_window,// 渲染目标创建
                                                -1, // 从那里开始渲染(-1:表示从第一个位置开始)
                                                0);// 渲染类型(软件渲染)
if (sdl_renderer == NULL){
    __android_log_print(ANDROID_LOG_INFO, "main", "渲染器创建失败：%s", SDL_GetError());
    // Mac使用
    // printf("渲染器创建失败： %s\n", SDL_GetError());
    // 退出程序
    SDL_Quit();
    return -1;
}
```

### 第十三步：创建纹理

```c
// 第十三步：创建纹理
SDL_Texture* sdl_texture = SDL_CreateTexture(sdl_renderer,// 渲染器
                                             SDL_PIXELFORMAT_IYUV,// 像素数据格式
                                             SDL_TEXTUREACCESS_STREAMING,// 绘制方式：频繁绘制-
                                             video_avcodec_context->width,// 纹理宽
                                             video_avcodec_context->height);// 纹理高
if (sdl_texture == NULL) {
    __android_log_print(ANDROID_LOG_INFO, "main", "纹理创建失败：%s", SDL_GetError());
    // Mac使用
    // printf("纹理创建失败： %s\n", SDL_GetError());
    // 退出程序
    SDL_Quit();
    return -1;
}
```

### 第十四步：读取视频压缩数据帧

```c
// 第十四步：读取视频压缩数据帧
int video_current_index = 0;
// 负责保存压缩编码数据相关信息的结构体,每帧图像由一到多个packet包组成
AVPacket* packet = (AVPacket*)av_malloc(sizeof(AVPacket));
// 从文件中依次读取每个图像编码数据包，并存储在AVPacket数据结构中，>=:读取到了，<0:读取错误或者读取完毕
while (av_read_frame(avformat_context, packet) >= 0) {
    // 检查数据包类型是否是视频流
    if (packet->stream_index == av_video_stream_index) {

        /*-----------------------
         * 第十五步：视频解码
         * 解码完整的一帧数据，decode_result返回true
         * 可能无法通过只解码一个packet就获得一个完整的视频帧frame，可能需要读取多个packet才行
         * avcodec_receive_frame()会在解码到完整的一帧时，decode_result为true
         -----------------------*/
        // ...

        video_current_index++;
        __android_log_print(ANDROID_LOG_INFO, "main", "当前解码视频第%d帧", video_current_index);
    }
    // 检查数据包类型是否是音频流
    else if (packet->stream_index == av_audio_stream_index) {
        // 第二十一步：向缓存队列中填充编码数据包
        // ...
    }
    // 字幕流类型标识
    else {
        // 释放AVPacket数据结构中编码数据指针
        av_packet_free(&packet);
    }

    /*------------------------
     * 第二十二步：获取SDL事件
     * 在每次循环中从SDL后台队列取事件并填充到SDL_Event对象中
     * SDL的事件系统使得你可以接收用户的输入，从而完成一些控制操作
     ------------------------*/
    // ...
}
```

### 第十五步：视频解码

```c
/*-----------------------
 * 第十五步：视频解码
 * 解码完整的一帧数据，decode_result返回true
 * 可能无法通过只解码一个packet就获得一个完整的视频帧frame，可能需要读取多个packet才行
 * avcodec_receive_frame()会在解码到完整的一帧时，decode_result为true
 -----------------------*/
// 发送一帧视频压缩数据
avcodec_send_packet(video_avcodec_context, packet);
// 解码一帧视频数据
decode_result = avcodec_receive_frame(video_avcodec_context, avframe_in);
if (decode_result == 0) {
    // 视频解码成功

    // 第十六步：开始类型转换
    // ...


    // 第十七步：设置纹理数据
    // ...

    // 第十八步：将纹理数据拷贝给渲染器
    // ...

    // 第十九步：呈现画面帧
    // ...

    // 第二十步：渲染每一帧直接间隔时间
    // ...
}
```

### 第十六步：开始类型转换

```c
// 第十六步：开始类型转换
// 将解码出来的视频像素点数据格式统一转类型为yuv420P
sws_scale(swscontext,// 视频像素数据格式上下文
          (const uint8_t *const *)avframe_in->data,// 输入数据
          avframe_in->linesize,// 输入画面每一行大小
          0,// 输入画面每一行开始位置(0表示从原点开始读取)
          video_avcodec_context->height,// 输入数据行数
          avframe_yuv420p->data,// 输出数据
          avframe_yuv420p->linesize);// 输出画面每一行大小
```

### 第十七步：设置纹理数据

```c
// 第十七步：设置纹理数据
SDL_UpdateTexture(sdl_texture, // 纹理
                  NULL,// 渲染区域
                  avframe_yuv420p->data[0],// 需要渲染数据：视频像素数据帧
                  avframe_yuv420p->linesize[0]);// 帧宽
```

### 第十八步：将纹理数据拷贝给渲染器

```c
// 第十八步：将纹理数据拷贝给渲染器
// 设置左上角位置(全屏)
sdl_rect.x = 100;
sdl_rect.y = 100;
sdl_rect.w = video_avcodec_context->width;
sdl_rect.h = video_avcodec_context->height;
SDL_RenderClear(sdl_renderer);
SDL_RenderCopy(sdl_renderer, sdl_texture, NULL, &sdl_rect);
```

### 第十九步：呈现画面帧

```c
// 第十九步：呈现画面帧
SDL_RenderPresent(sdl_renderer);
```

### 第二十步：渲染每一帧直接间隔时间

```c
// 第二十步：渲染每一帧直接间隔时间
SDL_Delay(30);
```

### 第二十一步：向缓存队列中填充编码数据包

```c
// 第二十一步：向缓存队列中填充编码数据包
packet_queue_put(&audioq, packet);
```

### 第二十二步：获取SDL事件

```c
/*------------------------
 * 第二十二步：获取SDL事件
 * 在每次循环中从SDL后台队列取事件并填充到SDL_Event对象中
 * SDL的事件系统使得你可以接收用户的输入，从而完成一些控制操作
 ------------------------*/
SDL_Event event;//SDL事件对象
SDL_PollEvent(&event);
switch (event.type) {//检查SDL事件对象
    case SDL_QUIT://退出事件
        quit = 1;//退出进程标识置1
        SDL_Quit();//退出操作
        exit(0);//结束进程
        break;
    default:
        break;
}// end for switch
```

### 第二十三步：释放资源，退出程序

```c
// 第二十三步：释放资源，退出程序
av_packet_free(&packet);
av_frame_free(&avframe_in);
av_frame_free(&avframe_yuv420p);
free(out_buffer);
avcodec_close(video_avcodec_context);
avformat_free_context(avformat_context);
SDL_DestroyTexture(sdl_texture);
SDL_DestroyRenderer(sdl_renderer);
SDL_Quit();
```

## 一、Android实现

### 第一步：Android集成SDL

参考：http://www.1221.site/FFmpeg/08_SDL%E6%92%AD%E6%94%BEYUV.html

新建工程名称为`AndroidDisplayVideoWhileDecoding`，按上面文章配置，能正常播放YUV文件就算成功完成了第一步。

### 第二步：Android集成FFmpeg

参考：http://www.1221.site/FFmpeg/02_FFmpeg%E9%9B%86%E6%88%90.html

### 第三步：修改native-lib.cpp

```c
#include <jni.h>
#include <string>
#include <android/log.h>
#include <errno.h>
#include "SDL.h"
#include <SDL_thread.h>

extern "C" {
// 引入头文件
// 核心库->音视频编解码库
#include <libavcodec/avcodec.h>
#include "libavformat/avformat.h"
#include <libavutil/imgutils.h>
#include <libswscale/swscale.h>
}

// 定义一
// SDL读音频缓存的大小
#define SDL_AUDIO_BUFFER_SIZE 1024
#define MAX_AUDIO_FRAME_SIZE 192000
int quit = 0;// 全局退出进程标识，在界面上点了退出后，告诉线程退出

// SDL入口
extern "C"
int main(int argc, char *argv[]) {
    // 边解码边播放音视频实现
    // 复制代码实现
}
```