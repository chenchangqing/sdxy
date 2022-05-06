# FFmpeg+SDL同步视频

[Android工程代码](https://gitee.com/learnany/ffmpeg/tree/master/12_ffmpeg_sdl_syn_video/AndroidFFmpegSDLSynVideo)

ffmpeg播放器实现详解 - 视频同步控制：https://www.cnblogs.com/breakpointlab/p/15771348.html

## 源代码一览

```c
#include <jni.h>
#include <string>
#include <android/log.h>
#include <errno.h>
#include "SDL.h"
#include <SDL_thread.h>

#define SDL_AUDIO_BUFFER_SIZE 1024
#define MAX_AUDIO_FRAME_SIZE 192000

#define AV_SYNC_THRESHOLD 0.01//前后两帧间的显示时间间隔的最小值0.01s
#define AV_NOSYNC_THRESHOLD 10.0//最小刷新间隔时间10ms

#define MAX_AUDIOQ_SIZE (5 * 16 * 1024)
#define MAX_VIDEOQ_SIZE (5 * 256 * 1024)

#define FF_ALLOC_EVENT (SDL_USEREVENT)
#define FF_REFRESH_EVENT (SDL_USEREVENT + 1)
#define FF_QUIT_EVENT (SDL_USEREVENT + 2)

#define VIDEO_PICTURE_QUEUE_SIZE 1

extern "C" {
#include <libavcodec/avcodec.h>
#include "libavformat/avformat.h"
#include <libavutil/avstring.h>
#include <libavutil/imgutils.h>
#include <libswscale/swscale.h>
#include <libavutil/time.h>
}

/*-------链表节点结构体--------
typedef struct AVPacketList {
    AVPacket pkt;//链表数据
    struct AVPacketList *next;//链表后继节点
} AVPacketList;
---------------------------*/
// 数据包队列(链表)结构体
typedef struct PacketQueue {
    AVPacketList *first_pkt, *last_pkt;// 队列首尾节点指针
    int nb_packets;// 队列长度
    int size;// 保存编码数据的缓存长度，size=packet->size
    SDL_mutex *qlock;// 队列互斥量，保护队列数据
    SDL_cond *qready;// 队列就绪条件变量
} PacketQueue;

// 图像帧结构体
typedef struct VideoPicture {
    AVFrame *avframe_yuv420p;
    int width, height;//Source height & width.
    int allocated;//是否分配内存空间，视频帧转换为SDL overlay标识
    double pts;//当前图像帧的绝对显示时间戳
} VideoPicture;

typedef struct VideoState {
    AVFormatContext *pFormatCtx;// 保存文件容器封装信息及码流参数的结构体
    AVStream *video_st;// 视频流信息结构体
    AVStream *audio_st;//音频流信息结构体
    struct SwsContext *sws_ctx;// 描述转换器参数的结构体

    PacketQueue videoq;// 视频编码数据包队列(编码数据队列，以链表方式实现)
    VideoPicture pictq[VIDEO_PICTURE_QUEUE_SIZE];
    int pictq_size, pictq_rindex, pictq_windex;// 队列长度，读/写位置索引
    SDL_mutex *pictq_lock;// 队列读写锁对象，保护图像帧队列数据
    SDL_cond *pictq_ready;// 队列就绪条件变量
    SDL_Rect sdl_rect;
    SDL_Renderer* sdl_renderer;
    SDL_Texture* sdl_texture;

    PacketQueue audioq;// 音频编码数据包队列(编码数据队列，以链表方式实现)
    uint8_t audio_buf[(MAX_AUDIO_FRAME_SIZE*3)/2];//保存解码一个packet后的多帧原始音频数据(解码数据队列，以数组方式实现)
    unsigned int audio_buf_size;//解码后的多帧音频数据长度
    unsigned int audio_buf_index;//累计写入stream的长度
    uint8_t *audio_pkt_data;//编码数据缓存指针位置
    int audio_pkt_size;//缓存中剩余的编码数据长度(是否已完成一个完整的pakcet包的解码，一个数据包中可能包含多个音频编码帧)
    AVPacket audio_pkt;//保存从队列中提取的数据包
    AVFrame audio_frame;//保存从数据包中解码的音频数据

    int video_width;
    int video_height;
    char filename[1024];// 输入文件完整路径名

    int videoStream, audioStream;// 音视频流类型标号
    SDL_Thread *parse_tid;// 编码数据包解析线程id
    SDL_Thread *decode_tid;// 解码线程id
    int quit;// 全局退出进程标识，在界面上点了退出后，告诉线程退出

    //video/audio_clock save pts of last decoded frame/predicted pts of next decoded frame
    double video_clock;//keep track of how much time has passed according to the video
    double audio_clock;
    double frame_timer;//视频播放到当前帧时的累计已播放时间
    double frame_last_pts;//上一帧图像的显示时间戳，用于在video_refersh_timer中保存上一帧的pts值
    double frame_last_delay;//上一帧图像的动态刷新延迟时间
} VideoState;// Since we only have one decoding thread, the Big Struct can be global in case we need it.
VideoState *global_video_state;

/*------取得当前播放音频数据的pts------
 * 音视频同步的原理是根据音频的pts来控制视频的播放
 * 也就是说在视频解码一帧后，是否显示以及显示多长时间，是通过该帧的PTS与同时正在播放的音频的PTS比较而来的
 * 如果音频的PTS较大，则视频准备完毕立即刷新，否则等待
 *
 * 因为pcm数据采用audio_callback回调方式进行播放
 * 对于音频播放我们只能得到写入回调函数前缓存音频帧的pts，而无法得到当前播放帧的pts(需要采用当前播放音频帧的pts作为参考时钟)
 * 考虑到音频的大小与播放时间成正比(相同采样率)，那么当前时刻正在播放的音频帧pts(位于回调函数缓存中)
 * 就可以根据已送入声卡的pcm数据长度、缓存中剩余pcm数据长度，缓存长度及采样率进行推算了
 --------------------------------*/
double get_audio_clock(VideoState *is) {
    double pts=is->audio_clock;//Maintained in the audio thread，取得解码操作完成时的当前播放时间戳
    //还未(送入声卡)播放的剩余原始音频数据长度，等于解码后的多帧原始音频数据长度-累计送入声卡的长度
    int hw_buf_size=is->audio_buf_size-is->audio_buf_index;//计算当前音频解码数据缓存索引位置
    int bytes_per_sec=0;//每秒的原始音频字节数
    int pcm_bytes=is->audio_st->codec->channels*2;//每组原始音频数据字节数=声道数*每声道数据字节数
    if (is->audio_st) {
        bytes_per_sec=is->audio_st->codec->sample_rate*pcm_bytes;//计算每秒的原始音频字节数
    }
    if (bytes_per_sec) {//检查每秒的原始音频字节数
        pts-=(double)hw_buf_size/bytes_per_sec;//根据送入声卡缓存的索引位置，往前倒推计算当前时刻的音频播放时间戳pts
    }
    return pts;//返回当前正在播放的音频时间戳
}

// 定时器触发的回调函数
static Uint32 sdl_refresh_timer_cb(Uint32 interval, void *opaque) {
    SDL_Event event;//SDL事件对象
    event.type = FF_REFRESH_EVENT;//视频显示刷新事件
    event.user.data1 = opaque;//传递用户数据
    SDL_PushEvent(&event);//发送事件
    return 0; // 0 means stop timer.
}

/*---------------------------
 * Schedule a video refresh in 'delay' ms.
 * 告诉sdl在指定的延时后来推送一个 FF_REFRESH_EVENT 事件
 * 这个事件将在事件队列里触发sdl_refresh_timer_cb函数的调用
 --------------------------*/
static void schedule_refresh(VideoState *is, int delay) {
    SDL_AddTimer(delay, sdl_refresh_timer_cb, is);//在指定的时间(ms)后回调用户指定的函数
}

// 视频(图像)帧渲染
void video_display(VideoState *is) {
    SDL_Rect rect;// SDL矩形对象
    VideoPicture *vp;// 图像帧结构体指针
    vp = &is->pictq[is->pictq_rindex];//从图像帧队列(数组)中提取图像帧结构对象
    if (vp->avframe_yuv420p) {//检查像素数据指针是否有效

        // 设置纹理数据
        SDL_UpdateTexture(is->sdl_texture, // 纹理
                          NULL,// 渲染区域
                          vp->avframe_yuv420p->data[0],// 需要渲染数据：视频像素数据帧
                          vp->avframe_yuv420p->linesize[0]);// 帧宽

        // 将纹理数据拷贝给渲染器
        // 设置左上角位置(全屏)
        is->sdl_rect.x = 100;
        is->sdl_rect.y = 100;
        is->sdl_rect.w = vp->width;
        is->sdl_rect.h = vp->height;
        SDL_RenderClear(is->sdl_renderer);
        SDL_RenderCopy(is->sdl_renderer, is->sdl_texture, NULL, &is->sdl_rect);
        // 呈现画面帧
        SDL_RenderPresent(is->sdl_renderer);
    }// end for if
}// end for video_display

// 显示刷新函数(FF_REFRESH_EVENT响应函数)
int video_current_index = 0;
void video_refresh_timer(void *userdata) {
    VideoState *is = (VideoState *)userdata;// 传递用户数据

    VideoPicture *vp;//图像帧对象
    //delay-前后帧间的显示时间间隔，diff-图像帧显示与音频帧播放间的时间差
    //sync_threshold-前后帧间的最小时间差，actual_delay-当前帧-下已帧的显示时间间隔(动态时间、真实时间、绝对时间)
    double delay,diff,sync_threshold,actual_delay,ref_clock;//ref_clock-音频时间戳

    if (is->video_st) {
        if (is->pictq_size == 0) {// 检查图像帧队列是否有待显示图像
            schedule_refresh(is, 1);//若队列为空，则发送显示刷新事件并再次进入video_refresh_timer函数
        } else {// 刷新图像
            vp = &is->pictq[is->pictq_rindex];//从显示队列中取得等待显示的图像帧
            //计算当前帧和前一帧显示(pts)的间隔时间(显示时间戳的差值)
            delay = vp->pts - is->frame_last_pts;//The pts from last time，前后帧间的时间差
            if (delay <= 0 || delay >= 1.0) {//检查时间间隔是否在合理范围
                // If incorrect delay, use previous one
                delay = is->frame_last_delay;//沿用之前的动态刷新间隔时间
            }
            // Save for next time
            is->frame_last_delay = delay;//保存上一帧图像的动态刷新延迟时间
            is->frame_last_pts = vp->pts;//保存上一帧图像的显示时间戳

            // Update delay to sync to audio，取得声音播放时间戳(作为视频同步的参考时间)
            ref_clock=get_audio_clock(is);//根据Audio clock来判断Video播放的快慢，获取当前播放声音的时间戳
            //也就是说在diff这段时间中声音是匀速发生的，但是在delay这段时间frame的显示可能就会有快慢的区别
            diff=vp->pts-ref_clock;//计算图像帧显示与音频帧播放间的时间差

            //根据时间差调整播放下一帧的延迟时间，以实现同步 Skip or repeat the frame，Take delay into account
            sync_threshold=(delay>AV_SYNC_THRESHOLD) ? delay : AV_SYNC_THRESHOLD;//比较前后两帧间的显示时间间隔与最小时间间隔
            //判断音视频不同步条件，即音视频间的时间差 & 前后帧间的时间差<10ms阈值，若>该阈值则为快进模式，不存在音视频同步问题
            if (fabs(diff)<AV_NOSYNC_THRESHOLD) {
                if (diff<=-sync_threshold) {//比较前一帧&当前帧[画面-声音]间的时间间隔与前一帧 & 当前帧[画面-画面]间的时间间隔，慢了，delay设为0
                    //下一帧画面显示的时间和当前的声音很近的话加快显示下一帧（即后面video_display显示完当前帧后开启定时器很快去显示下一帧
                    delay=0;
                } else if (diff>=sync_threshold) {//比较两帧画面间的显示时间与两帧画面间声音的播放时间，快了，加倍delay
                    delay=2*delay;
                }
            }//如果diff(明显)大于AV_NOSYNC_THRESHOLD，即快进的模式了，画面跳动太大，不存在音视频同步的问题了

            //更新视频播放到当前帧时的已播放时间值(所有图像帧动态播放累计时间值-真实值)，frame_timer一直累加在播放过程中我们计算的延时
            is->frame_timer+=delay;
            //每次计算frame_timer与系统时间的差值(以系统时间为基准时间)，将frame_timer与系统时间(绝对时间)相关联的目的
            actual_delay=is->frame_timer-(av_gettime()/1000000.0);//Computer the REAL delay
            if (actual_delay < 0.010) {//检查绝对时间范围
                actual_delay = 0.010;// Really it should skip the picture instead
            }
            schedule_refresh(is, (int)(actual_delay*1000+0.5));//用绝对时间开定时器去动态显示刷新下一帧

            // Show the picture!
            video_display(is);// 图像帧渲染
            video_current_index++;
            __android_log_print(ANDROID_LOG_INFO, "main", "video_current_index：%d，vp->pts: %f，ref_clock：%f，actual_delay：%f", video_current_index, vp->pts, ref_clock, actual_delay);

            // Update queue for next picture!
            if (++is->pictq_rindex == VIDEO_PICTURE_QUEUE_SIZE) {// 更新并检查图像帧队列读位置索引
                is->pictq_rindex = 0;// 重置读位置索引
            }
            SDL_LockMutex(is->pictq_lock);// 锁定互斥量，保护画布的像素数据
            is->pictq_size--;// 更新图像帧队列长度
            SDL_CondSignal(is->pictq_ready);// 发送队列就绪信号
            SDL_UnlockMutex(is->pictq_lock);// 释放互斥量
        }
    } else {
        schedule_refresh(is, 100);
    }
}

// 数据包队列初始化函数
void packet_queue_init(PacketQueue *q) {
    memset(q, 0, sizeof(PacketQueue));// 全零初始化队列结构体对象
    q->qlock = SDL_CreateMutex();// 创建互斥量对象
    q->qready = SDL_CreateCond();// 创建条件变量对象
}

// 向队列中插入数据包
int packet_queue_put(PacketQueue *q, AVPacket *pkt) {
    /*-------准备队列(链表)节点对象------*/
    AVPacketList *pktlist=(AVPacketList *)av_malloc(sizeof(AVPacketList));// 在堆上创建链表节点对象
    if (!pktlist) {// 检查链表节点对象是否创建成功
        return -1;
    }
    pktlist->pkt = *pkt;// 将输入数据包赋值给新建链表节点对象中的数据包对象
    pktlist->next = NULL;// 链表后继指针为空
    //  if (av_packet_ref(pkt, pkt) < 0) {// 增加pkt编码数据的引用计数(输入参数中的pkt与新建链表节点中的pkt共享同一缓存空间)
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

// 从队列中提取数据包，并将提取的数据包出队列
static int packet_queue_get(PacketQueue *q, AVPacket *pkt, int block) {
    AVPacketList *pktlist;// 临时链表节点对象指针
    int ret;// 操作结果

    SDL_LockMutex(q->qlock);// 队列互斥量加锁，保护队列数据
    for (;;) {
        if (global_video_state->quit) {// 检查退出进程标识
            ret = -1;// 操作失败
            break;
        }//end for if

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
    }//end for for-loop
    SDL_UnlockMutex(q->qlock);// 释放互斥量
    return ret;
}

// 创建/重置图像帧，为图像帧分配内存空间
void alloc_picture(void *userdata) {
    VideoState *is = (VideoState *)userdata;// 传递用户数据
    VideoPicture *vp=&is->pictq[is->pictq_windex];// 从图像帧队列(数组)中提取图像帧结构对象
    if (vp->avframe_yuv420p) {// 检查图像帧是否已存在
        // We already have one make another, bigger/smaller.
        av_frame_free(&vp->avframe_yuv420p);
    }
    vp->width = is->video_st->codec->width;// 设置图像帧宽度
    vp->height = is->video_st->codec->height;// 设置图像帧高度

    SDL_LockMutex(is->pictq_lock);// 锁定互斥量，保护画布的像素数据
    vp->allocated = 1;// 图像帧像素缓冲区已分配内存

    // AV_PIX_FMT_YUV420P格式的视频帧
    vp->avframe_yuv420p = av_frame_alloc();
    // 给缓冲区设置类型
    int buffer_size =av_image_get_buffer_size(AV_PIX_FMT_YUV420P,// 视频像素数据格式类型
                                              is->video_st->codec->width,// 一帧视频像素数据宽 = 视频宽
                                              is->video_st->codec->height,// 一帧视频像素数据高 = 视频高
                                              1);// 字节对齐方式，默认是1
    // 开辟一块内存空间
    uint8_t *out_buffer = (uint8_t *)av_malloc(buffer_size);
    // 向avframe_yuv420p填充数据
    av_image_fill_arrays(vp->avframe_yuv420p->data,// 目标视频帧数据
                         vp->avframe_yuv420p->linesize,// 目标视频帧行大小
                         out_buffer,// 原始数据
                         AV_PIX_FMT_YUV420P,// 视频像素数据格式类型
                         is->video_st->codec->width,// 视频宽
                         is->video_st->codec->height,//视频高
                         1);// 字节对齐方式
    SDL_CondSignal(is->pictq_ready);// 给等待线程发出消息，通知队列已就绪
    SDL_UnlockMutex(is->pictq_lock);// 释放互斥量
}

/*---------------------------
 * queue_picture：图像帧插入队列等待渲染
 * @is：全局状态参数集
 * @pFrame：保存图像解码数据的结构体
 * 1、首先检查图像帧队列(数组)是否存在空间插入新的图像，若没有足够的空间插入图像则使当前线程休眠等待
 * 2、在初始化的条件下，队列(数组)中VideoPicture的bmp对象(YUV overlay)尚未分配空间，通过FF_ALLOC_EVENT事件的方法调用alloc_picture分配空间
 * 3、当队列(数组)中所有VideoPicture的bmp对象(YUV overlay)均已分配空间的情况下，直接跳过步骤2向bmp对象拷贝像素数据，像素数据在进行格式转换后执行拷贝操作
 ---------------------------*/
int queue_picture(VideoState *is, AVFrame *pFrame, double pts) {
    /*--------1、检查队列是否有插入空间-------*/
    // Wait until we have space for a new pic.
    SDL_LockMutex(is->pictq_lock);// 锁定互斥量，保护图像帧队列
    while (is->pictq_size >= VIDEO_PICTURE_QUEUE_SIZE && !is->quit) {// 检查队列当前长度
        SDL_CondWait(is->pictq_ready, is->pictq_lock);// 线程休眠等待pictq_ready信号
    }
    SDL_UnlockMutex(is->pictq_lock);// 释放互斥量

    if (is->quit) {// 检查进程退出标识
        return -1;
    }
    /*-------2、初始化/重置YUV overlay-------*/
    // windex is set to 0 initially.
    VideoPicture *vp=&is->pictq[is->pictq_windex];// 从图像帧队列中抽取图像帧对象

    // Allocate or resize the buffer，检查YUV overlay是否已存在，否则初始化YUV overlay，分配像素缓存空间
    if (!vp->avframe_yuv420p || vp->width!=is->video_st->codec->width || vp->height!=is->video_st->codec->height) {
        vp->allocated = 0;// 图像帧未分配空间
        // We have to do it in the main thread.
        SDL_Event event;// SDL事件对象
        event.type = FF_ALLOC_EVENT;//指定分配图像帧内存事件
        event.user.data1 = is;//传递用户数据
        SDL_PushEvent(&event);//发送SDL事件

        // Wait until we have a picture allocated.
        SDL_LockMutex(is->pictq_lock);// 锁定互斥量，保护图像帧队列
        while (!vp->allocated && !is->quit) {// 检查当前图像帧是否已初始化
            SDL_CondWait(is->pictq_ready, is->pictq_lock);// 线程休眠等待alloc_picture发送pictq_ready信号唤醒当前线程
        }
        SDL_UnlockMutex(is->pictq_lock);// 释放互斥量
        if (is->quit) {// 检查进程退出标识
            return -1;
        }
    }// end for if
    /*--------3、拷贝视频帧到YUV overlay-------*/
    // We have a place to put our picture on the queue.
    if (vp->avframe_yuv420p) {//检查像素数据指针是否有效

        // Convert the image into YUV format that SDL uses，将解码后的图像帧转换为AV_PIX_FMT_YUV420P格式，并拷贝到图像帧队列
        sws_scale(is->sws_ctx, (uint8_t const * const *)pFrame->data, pFrame->linesize, 0, is->video_st->codec->height, vp->avframe_yuv420p->data, vp->avframe_yuv420p->linesize);
        vp->pts = pts;//传递当前图像帧的绝对显示时间戳
        // Now we inform our display thread that we have a pic ready.
        if (++is->pictq_windex == VIDEO_PICTURE_QUEUE_SIZE) {//更新并检查当前图像帧队列写入位置
            is->pictq_windex = 0;//重置图像帧队列写入位置
        }
        SDL_LockMutex(is->pictq_lock);//锁定队列读写锁，保护队列数据
        is->pictq_size++;//更新图像帧队列长度
        SDL_UnlockMutex(is->pictq_lock);//释放队列读写锁
    }// end for if
    return 0;
}



/*---------------------------
 * 更新内部视频播放计时器(记录视频已经播时间(video_clock)）
 * @is：全局状态参数集
 * @src_frame：当前(输入的)(待更新的)图像帧对象
 * @pts：当前图像帧的显示时间戳
 * update the PTS to be in sync
 ---------------------------*/
double synchronize_video(VideoState *is, AVFrame *src_frame, double pts) {
    /*----------检查显示时间戳----------*/
    if (pts != 0) {//检查显示时间戳是否有效
        // If we have pts, set video clock to it.
        is->video_clock = pts;//用显示时间戳更新已播放时间
    } else {//若获取不到显示时间戳
        // If we aren't given a pts, set it to the clock.
        pts = is->video_clock;//用已播放时间更新显示时间戳
    }
    /*--------更新视频已经播时间--------*/
    // Update the video clock，若该帧要重复显示(取决于repeat_pict)，则全局视频播放时序video_clock应加上重复显示的数量*帧率
    double frame_delay = av_q2d(is->video_st->codec->time_base);//该帧显示完将要花费的时间
    // If we are repeating a frame, adjust clock accordingly,若存在重复帧，则在正常播放的前后两帧图像间安排渲染重复帧
    frame_delay += src_frame->repeat_pict*(frame_delay*0.5);//计算渲染重复帧的时值(类似于音符时值)
    is->video_clock += frame_delay;//更新视频播放时间
    //  printf("repeat_pict=%d \n",src_frame->repeat_pict);
    return pts;//此时返回的值即为下一帧将要开始显示的时间戳
}

// 视频解码线程函数
int decode_thread(void *arg) {
    VideoState *is = (VideoState *) arg;// 传递用户数据
    AVPacket pkt, *packet = &pkt;// 在栈上创建临时数据包对象并关联指针
    int frameFinished;// 解码操作是否成功标识

    // Allocate video frame，为解码后的视频信息结构体分配空间并完成初始化操作(结构体中的图像缓存按照下面两步手动安装)
    AVFrame *pFrame = av_frame_alloc();
    double pts;//当前桢在整个视频中的(绝对)时间位置

    for (;;) {
        if (packet_queue_get(&is->videoq,packet,1)<0) {// 从队列中提取数据包到packet，并将提取的数据包出队列
            // Means we quit getting packets.
            break;
        }
        pts = 0;//(绝对)显示时间戳初始化
        //      global_video_pkt_pts = packet->pts;// Save global pts to be stored in pFrame in first call.
        /*-----------------------
          * Decode video frame，解码完整的一帧数据，并将frameFinished设置为true
         * 可能无法通过只解码一个packet就获得一个完整的视频帧frame，可能需要读取多个packet才行
          * avcodec_decode_video2()会在解码到完整的一帧时设置frameFinished为真
         * Technically a packet can contain partial frames or other bits of data
         * ffmpeg's parser ensures that the packets we get contain either complete or multiple frames
         * convert the packet to a frame for us and set frameFinisned for us when we have the next frame
          -----------------------*/
        avcodec_decode_video2(is->video_st->codec, pFrame, &frameFinished, packet);

        //取得编码数据包中的显示时间戳PTS(int64_t),并暂时保存在pts(double)中
//      if (packet->dts==AV_NOPTS_VALUE && pFrame->opaque && *(uint64_t*)pFrame->opaque!=AV_NOPTS_VALUE) {
//          pts = *(uint64_t *)pFrame->opaque;
//      } else if (packet->dts != AV_NOPTS_VALUE) {
//          pts = packet->dts;
//      } else {
//          pts = 0;
//      }
        pts=av_frame_get_best_effort_timestamp(pFrame);//取得编码数据包中的图像帧显示序号PTS(int64_t),并暂时保存在pts(double)中
        /*-------------------------
         * 在解码线程函数中计算当前图像帧的显示时间戳
         * 1、取得编码数据包中的图像帧显示序号PTS(int64_t),并暂时保存在pts(double)中
         * 2、根据PTS*time_base来计算当前桢在整个视频中的显示时间戳，即PTS*(1/framerate)
         *    av_q2d把AVRatioal结构转换成double的函数，
         *    用于计算视频源每个图像帧显示的间隔时间(1/framerate),即返回(time_base->num/time_base->den)
         -------------------------*/
        //根据pts=PTS*time_base={numerator=1,denominator=25}计算当前桢在整个视频中的显示时间戳
        pts*=av_q2d(is->video_st->time_base);//time_base为AVRational有理数结构体{num=1,den=25}，记录了视频源每个图像帧显示的间隔时间

        // Did we get a video frame，检查是否解码出完整一帧图像
        if (frameFinished) {
            pts = synchronize_video(is, pFrame, pts);//检查当前帧的显示时间戳pts并更新内部视频播放计时器(记录视频已经播时间(video_clock)）
            if (queue_picture(is, pFrame, pts)<0) {// 将解码完成的图像帧添加到图像帧队列
                break;
            }
        }
        av_packet_unref(packet);// 释放pkt中保存的编码数据
    }
    av_free(pFrame);// 清除pFrame中的内存空间
    return 0;
}

// 音频解码函数，从缓存队列中提取数据包、解码，并返回解码后的数据长度(对一个完整的packet解码，将解码数据写入audio_buf缓存，并返回多帧解码数据的总长度)
int audio_decode_frame(VideoState *is, double *pts_ptr) {
    int coded_consumed_size,data_size=0,pcm_bytes;// 每次消耗的编码数据长度[input](len1)，输出原始音频数据的缓存长度[output]，每组音频采样数据的字节数
    AVPacket *pkt = &is->audio_pkt;// 保存从队列中提取的数据包
    double pts;//音频播放时间戳

    for (;;) {
        while (is->audio_pkt_size>0) {// 检查缓存中剩余的编码数据长度(是否已完成一个完整的pakcet包的解码，一个数据包中可能包含多个音频编码帧)
            int got_frame = 0;// 解码操作成功标识，成功返回非零值
            // 解码一帧音频数据，并返回消耗的编码数据长度
            coded_consumed_size = avcodec_decode_audio4(is->audio_st->codec, &is->audio_frame, &got_frame, pkt);
            if (coded_consumed_size < 0) {// 检查是否执行了解码操作
                // If error, skip frame.
                is->audio_pkt_size = 0;// 更新编码数据缓存长度
                break;
            }
            if (got_frame) {// 检查解码操作是否成功
                // 计算解码后音频数据长度[output]
                data_size = av_samples_get_buffer_size(NULL, is->audio_st->codec->channels, is->audio_frame.nb_samples, is->audio_st->codec->sample_fmt, 1);
                memcpy(is->audio_buf, is->audio_frame.data[0], data_size);// 将解码数据复制到输出缓存
            }
            is->audio_pkt_data += coded_consumed_size;// 更新编码数据缓存指针位置
            is->audio_pkt_size -= coded_consumed_size;// 更新缓存中剩余的编码数据长度
            if (data_size <= 0) {// 检查输出解码数据缓存长度
                // No data yet, get more frames.
                continue;
            }
            pts=is->audio_clock;//用每次更新的音频播放时间更新音频PTS
            *pts_ptr=pts;
            /*---------------------
             * 当一个packet中包含多个音频帧时
             * 通过[解码后音频原始数据长度]及[采样率]来推算一个packet中其他音频帧的播放时间戳pts
             * 采样频率44.1kHz，量化位数16位，意味着每秒采集数据44.1k个，每个数据占2字节
             --------------------*/
            pcm_bytes=2*is->audio_st->codec->channels;//计算每组音频采样数据的字节数=每个声道音频采样字节数*声道数
            /*----更新audio_clock---
             * 一个pkt包含多个音频frame，同时一个pkt对应一个pts(pkt->pts)
             * 因此，该pkt中包含的多个音频帧的时间戳由以下公式推断得出
             * bytes_per_sec=pcm_bytes*is->audio_st->codec->sample_rate
             * 从pkt中不断的解码，推断(一个pkt中)每帧数据的pts并累加到音频播放时钟
             --------------------*/
            is->audio_clock+=(double)data_size/(double)(pcm_bytes*is->audio_st->codec->sample_rate);
            // We have data, return it and come back for more later.
            return data_size;// 返回解码数据缓存长度
        }
        if (pkt->data) {// 检查数据包是否已从队列中提取
            av_packet_unref(pkt);// 释放pkt中保存的编码数据
        }

        if (is->quit) {// 检查退出进程标识
            return -1;
        }
        // Next packet，从队列中提取数据包到pkt
        if (packet_queue_get(&is->audioq, pkt, 1) < 0) {
            return -1;
        }
        is->audio_pkt_data = pkt->data;// 传递编码数据缓存指针
        is->audio_pkt_size = pkt->size;// 传递编码数据缓存长度
        // If update, update the audio clock w/pts
        if (pkt->pts != AV_NOPTS_VALUE) {//检查音频播放时间戳
            //获得一个新的packet的时候，更新audio_clock，用packet中的pts更新audio_clock(一个pkt对应一个pts)
            is->audio_clock=pkt->pts*av_q2d(is->audio_st->time_base);//更新音频已经播的时间
        }
    }
}

/*------Audio Callback-------
 * 音频输出回调函数，sdl通过该回调函数将解码后的pcm数据送入声卡播放,
 * sdl通常一次会准备一组缓存pcm数据，通过该回调送入声卡，声卡根据音频pts依次播放pcm数据
 * 待送入缓存的pcm数据完成播放后，再载入一组新的pcm缓存数据(每次音频输出缓存为空时，sdl就调用此函数填充音频输出缓存，并送入声卡播放)
 * When we begin playing audio, SDL will continually call this callback function
 * and ask it to fill the audio buffer with a certain number of bytes
 * The audio function callback takes the following parameters:
 * stream: A pointer to the audio buffer to be filled，输出音频数据到声卡缓存
 * len: The length (in bytes) of the audio buffer,缓存长度wanted_spec.samples=SDL_AUDIO_BUFFER_SIZE(1024)
 --------------------------*/
void audio_callback(void *userdata, Uint8 *stream, int len) {
    VideoState *is = (VideoState *) userdata;// 传递用户数据
    int wt_stream_len, audio_size;// 每次写入stream的数据长度，解码后的数据长度
    double pts;//音频时间戳

    while (len > 0) {//检查音频缓存的剩余长度
        if (is->audio_buf_index >= is->audio_buf_size) {// 检查是否需要执行解码操作
            // We have already sent all our data; get more，从缓存队列中提取数据包、解码，并返回解码后的数据长度，audio_buf缓存中可能包含多帧解码后的音频数据
            audio_size = audio_decode_frame(is, &pts);
            if (audio_size < 0) {// 检查解码操作是否成功
                // If error, output silence.
                is->audio_buf_size = 1024;
                memset(is->audio_buf, 0, is->audio_buf_size);// 全零重置缓冲区
            } else {
                is->audio_buf_size = audio_size;// 返回packet中包含的原始音频数据长度(多帧)
            }
            is->audio_buf_index = 0;// 初始化累计写入缓存长度
        }//end for if

        wt_stream_len=is->audio_buf_size-is->audio_buf_index;// 计算解码缓存剩余长度
        if (wt_stream_len > len) {// 检查每次写入缓存的数据长度是否超过指定长度(1024)
            wt_stream_len = len;// 指定长度从解码的缓存中取数据
        }

        // 每次从解码的缓存数据中以指定长度抽取数据并写入stream传递给声卡
        memcpy(stream, (uint8_t *)is->audio_buf + is->audio_buf_index, wt_stream_len);
        len -= wt_stream_len;// 更新解码音频缓存的剩余长度
        stream += wt_stream_len;// 更新缓存写入位置
        is->audio_buf_index += wt_stream_len;// 更新累计写入缓存数据长度
    }//end for while
}

// 根据指定类型打开流，找到对应的解码器、创建对应的音频配置、保存关键信息到 VideoState、启动音频和视频线程
int stream_component_open(VideoState *is, int stream_index) {

    AVFormatContext *pFormatCtx = is->pFormatCtx;// 传递文件容器的封装信息及码流参数
    AVCodecContext *codecCtx = NULL;// 解码器上下文对象，解码器依赖的相关环境、状态、资源以及参数集的接口指针
    AVCodec *codec = NULL;// 保存编解码器信息的结构体，提供编码与解码的公共接口，可以看作是编码器与解码器的一个全局变量

    //检查输入的流类型是否在合理范围内
    if (stream_index < 0 || stream_index >= pFormatCtx->nb_streams) {
        return -1;
    }

    // Get a pointer to the codec context for the video stream.
    codecCtx = pFormatCtx->streams[stream_index]->codec;// 取得解码器上下文

    if (codecCtx->codec_type == AVMEDIA_TYPE_AUDIO) {//检查解码器类型是否为音频解码器
        SDL_AudioSpec wanted_spec, spec;//SDL_AudioSpec a structure that contains the audio output format，创建 SDL_AudioSpec 结构体，设置音频播放数据
        // Set audio settings from codec info,SDL_AudioSpec a structure that contains the audio output format
        // 创建SDL_AudioSpec结构体，设置音频播放参数
        wanted_spec.freq = codecCtx->sample_rate;//采样频率 DSP frequency -- samples per second
        wanted_spec.format = AUDIO_S16SYS;//采样格式 Audio data format
        wanted_spec.channels = codecCtx->channels;//声道数 Number of channels: 1 mono, 2 stereo
        wanted_spec.silence = 0;//无输出时是否静音
        //默认每次读音频缓存的大小，推荐值为 512~8192，ffplay使用的是1024 specifies a unit of audio data refers to the size of the audio buffer in sample frames
        wanted_spec.samples = SDL_AUDIO_BUFFER_SIZE;
        wanted_spec.callback = audio_callback;//设置读取音频数据的回调接口函数 the function to call when the audio device needs more data
        wanted_spec.userdata = is;//传递用户数据

        /*---------------------------
         * 以指定参数打开音频设备，并返回与指定参数最为接近的参数，该参数为设备实际支持的音频参数
         * Opens the audio device with the desired parameters(wanted_spec)
         * return another specs we actually be using
         * and not guaranteed to get what we asked for
         --------------------------*/
        if (SDL_OpenAudio(&wanted_spec, &spec) < 0) {
            fprintf(stderr, "SDL_OpenAudio: %s\n", SDL_GetError());
            return -1;
        }
    }

    /*-----------------------
     * Find the decoder for the video stream，根据视频流对应的解码器上下文查找对应的解码器，返回对应的解码器(信息结构体)
     * The stream's information about the codec is in what we call the "codec context.
     * This contains all the information about the codec that the stream is using
     -----------------------*/
    codec = avcodec_find_decoder(codecCtx->codec_id);
    AVDictionary *optionsDict = NULL;
    if (!codec || (avcodec_open2(codecCtx, codec, &optionsDict) < 0)) {
        __android_log_print(ANDROID_LOG_INFO, "main", "打开解码器失败\n");
        return -1;
    }
    // 打印解码器信息
    __android_log_print(ANDROID_LOG_INFO, "main", "解码器名称：%s\n", codec->name);

    // 检查解码器类型
    switch(codecCtx->codec_type) {
        case AVMEDIA_TYPE_AUDIO:// 音频解码器
            is->audioStream = stream_index;// 音频流类型标号初始化
            is->audio_st = pFormatCtx->streams[stream_index];
            is->audio_buf_size = 0;// 解码后的多帧音频数据长度
            is->audio_buf_index = 0;//累 计写入stream的长度
            memset(&is->audio_pkt, 0, sizeof(is->audio_pkt));
            packet_queue_init(&is->audioq);// 音频数据包队列初始化
            SDL_PauseAudio(0);// audio callback starts running again，开启音频设备，如果这时候没有获得数据那么它就静音
            break;
        case AVMEDIA_TYPE_VIDEO:// 视频解码器
            is->videoStream = stream_index;// 视频流类型标号初始化
            is->video_st = pFormatCtx->streams[stream_index];
            //以系统时间为基准，初始化播放到当前帧的已播放时间值，该值为真实时间值、动态时间值、绝对时间值
            is->frame_timer=(double)av_gettime()/1000000.0;
            is->frame_last_delay = 40e-3;//初始化上一帧图像的动态刷新延迟时间
            packet_queue_init(&is->videoq);// 视频数据包队列初始化
            is->decode_tid = SDL_CreateThread(decode_thread,"视频解码线程" ,is);// 创建视频解码线程
            // Initialize SWS context for software scaling，设置图像转换像素格式为AV_PIX_FMT_YUV420P
            is->sws_ctx = sws_getContext(is->video_st->codec->width, is->video_st->codec->height, is->video_st->codec->pix_fmt, is->video_st->codec->width, is->video_st->codec->height, AV_PIX_FMT_YUV420P, SWS_BILINEAR, NULL, NULL, NULL);
            break;
        default:
            break;
    }
    return 0;
}

// 编码数据包解析线程函数(从视频文件中解析出音视频编码数据单元，一个AVPacket的data通常对应一个NAL)
int parse_thread(void *arg) {
    VideoState *is = (VideoState *)arg;// 传递用户参数
    global_video_state = is;// 传递全局状态参量结构体

    /*-------------------------
     * 打开封装格式
     * 打开视频文件，读文件头内容，取得文件容器的封装信息及码流参数并存储在avformat_context中
     * 参数一：封装格式上下文
     * 参数二：视频路径
     * 参数三：指定输入的格式
     * 参数四：设置默认参数
     --------------------------*/
    AVFormatContext *avformat_context = NULL;// 参数一：封装格式上下文
    int avformat_open_input_result = avformat_open_input(&avformat_context, is->filename, NULL, NULL);
    if (avformat_open_input_result != 0){
        __android_log_print(ANDROID_LOG_INFO, "main", "查找音视频流\n");
        return -1;
    }
    is->pFormatCtx = avformat_context;//传递文件容器封装信息及码流参数

    /*-------------------------
     * 查找码流
     * 取得文件中保存的码流信息，并填充到avformat_context->stream 字段
     * 参数一：封装格式上下文
     * 参数二：指定默认配置
     -------------------------*/
    int avformat_find_stream_info_result = avformat_find_stream_info(avformat_context, NULL);
    if (avformat_find_stream_info_result < 0){
        __android_log_print(ANDROID_LOG_INFO, "main", "查找音视频流失败\n");
        return -1;
    }

    // 查找解码器
    is->videoStream = -1;//视频流类型标号初始化为-1
    is->audioStream = -1;//音频流类型标号初始化为-1
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
        goto fail;//跳转至异常处理
        return -1;
    }
    // 检查文件中是否存在音频流
    if (av_audio_stream_index == -1) {
        __android_log_print(ANDROID_LOG_INFO, "main", "没有找到音频流\n");
        goto fail;//跳转至异常处理
        return -1;
    }

    stream_component_open(is, av_audio_stream_index);// 根据指定类型打开音频流
    stream_component_open(is, av_video_stream_index);// 根据指定类型打开视频流

    // Main decode loop.
    for (;;) {
        if (is->quit) {//检查退出进程标识
            break;
        }
        // Seek stuff goes here，检查音视频编码数据包队列长度是否溢出
        if (is->audioq.size > MAX_AUDIOQ_SIZE || is->videoq.size > MAX_VIDEOQ_SIZE) {
            SDL_Delay(10);
            continue;
        }
        /*-----------------------
         * read in a packet and store it in the AVPacket struct
          * ffmpeg allocates the internal data for us,which is pointed to by packet.data
         * this is freed by the av_free_packet()
          -----------------------*/
        // 负责保存压缩编码数据相关信息的结构体,每帧图像由一到多个packet包组成
        AVPacket pkt, *packet = &pkt;// 在栈上创建临时数据包对象并关联指针
        if (av_read_frame(is->pFormatCtx, packet) < 0) {
            if (is->pFormatCtx->pb->error == 0) {
                SDL_Delay(100); // No error; wait for user input.
                continue;
            } else {
                break;
            }
        }

        // Is this a packet from the video stream?
        if (packet->stream_index == is->videoStream) {// 检查数据包是否为视频类型
            packet_queue_put(&is->videoq, packet);// 向队列中插入数据包
        } else if (packet->stream_index == is->audioStream) {// 检查数据包是否为音频类型
            packet_queue_put(&is->audioq, packet);// 向队列中插入数据包
        } else {// 检查数据包是否为字幕类型
            av_packet_unref(packet);// 释放packet中保存的(字幕)编码数据
        }
    }
    // All done - wait for it.
    while (!is->quit) {
        SDL_Delay(100);
    }

    fail:// 异常处理
    if (1) {
        SDL_Event event;// SDL事件对象
        event.type = FF_QUIT_EVENT;// 指定退出事件类型
        event.user.data1 = is;// 传递用户数据
        SDL_PushEvent(&event);// 将该事件对象压入SDL后台事件队列
    }
    return 0;
}

int init_sdl(VideoState *is) {

    // 初始化SDL多媒体框架
    if (SDL_Init( SDL_INIT_VIDEO | SDL_INIT_AUDIO | SDL_INIT_TIMER ) == -1) {
        __android_log_print(ANDROID_LOG_INFO, "main", "初始化失败：%s", SDL_GetError());
        // Mac使用
        // printf("初始化失败：%s", SDL_GetError());
        return -1;
    }

    // 初始化SDL窗口
    SDL_Window* sdl_window = SDL_CreateWindow("FFmpeg+SDL播放视频",// 参数一：窗口名称
                                              SDL_WINDOWPOS_CENTERED,// 参数二：窗口在屏幕上的x坐标
                                              SDL_WINDOWPOS_CENTERED,// 参数三：窗口在屏幕上的y坐标
                                              is->video_width,// 参数四：窗口在屏幕上宽
                                              is->video_height,// 参数五：窗口在屏幕上高
                                              SDL_WINDOW_OPENGL);// 参数六：窗口状态(打开)
    if (sdl_window == NULL){
        __android_log_print(ANDROID_LOG_INFO, "main", "窗口创建失败：%s", SDL_GetError());
        // Mac使用
        // printf("窗口创建失败： %s\n", SDL_GetError());
        // 退出程序
        SDL_Quit();
        return -1;
    }

    // 创建渲染器
    // 定义渲染器区域
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

    // 创建纹理
    SDL_Texture* sdl_texture = SDL_CreateTexture(sdl_renderer,// 渲染器
                                                 SDL_PIXELFORMAT_IYUV,// 像素数据格式
                                                 SDL_TEXTUREACCESS_STREAMING,// 绘制方式：频繁绘制-
                                                 is->video_width,// 纹理宽
                                                 is->video_height);// 纹理高
    if (sdl_texture == NULL) {
        __android_log_print(ANDROID_LOG_INFO, "main", "纹理创建失败：%s", SDL_GetError());
        // Mac使用
        // printf("纹理创建失败： %s\n", SDL_GetError());
        // 退出程序
        SDL_Quit();
        return -1;
    }

    is->sdl_renderer = sdl_renderer;
    is->sdl_texture = sdl_texture;
    return 0;
}

// SDL入口
extern "C"
int main(int argc, char *argv[]) {

    /*-------------------------
     * 注册组件
     * 注册所有ffmpeg支持的多媒体格式及编解码器
     -------------------------*/
    av_register_all();

    // 创建全局状态对象
    VideoState *is= (VideoState *)av_mallocz(sizeof(VideoState));
    av_strlcpy(is->filename, "/storage/emulated/0/Download/test.mov", sizeof(is->filename));// 复制视频文件路径名
    is->video_width = 640;
    is->video_height = 352;
    is->pictq_lock = SDL_CreateMutex();// 创建编码数据包队列互斥锁对象
    is->pictq_ready = SDL_CreateCond();// 创建编码数据包队列就绪条件对象

    int init_sdl_result = init_sdl(is);
    if (init_sdl_result < 0) {
        __android_log_print(ANDROID_LOG_INFO, "main", "初始化SDL失");
    }

    // 在指定的时间(40ms)后回调用户指定的函数，进行图像帧的显示更新
    schedule_refresh(is, 40);

    // 创建编码数据包解析线程
    is->parse_tid = SDL_CreateThread(parse_thread, "编码数据包解析线程", is);
    if (!is->parse_tid) {// 检查线程是否创建成功
        av_free(is);
        return -1;
    }

    // SDL事件对象
    SDL_Event event;
    for (;;) {// SDL事件循环
        SDL_WaitEvent(&event);// 主线程阻塞，等待事件到来
        switch(event.type) {// 事件到来后唤醒主线程，检查事件类型
            case FF_QUIT_EVENT:
            case SDL_QUIT:// 退出进程事件
                is->quit = 1;
                // If the video has finished playing, then both the picture and audio queues are waiting for more data.
                // Make them stop waiting and terminate normally..
                avcodec_close(is->video_st->codec);
                avformat_free_context(is->pFormatCtx);
                SDL_CondSignal(is->audioq.qready);// 发出队列就绪信号避免死锁
                SDL_CondSignal(is->videoq.qready);
                SDL_DestroyTexture(is->sdl_texture);
                SDL_DestroyRenderer(is->sdl_renderer);
                SDL_Quit();
                return 0;
            case FF_ALLOC_EVENT:
                alloc_picture(event.user.data1);// 分配视频帧事件响应函数
                break;
            case FF_REFRESH_EVENT:// 视频显示刷新事件
                video_refresh_timer(event.user.data1);// 视频显示刷新事件响应函数
                break;
            default:
                break;
        }
    }

    return 0;
}
```