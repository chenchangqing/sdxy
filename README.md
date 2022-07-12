# ffplay源码-event_loop函数、refresh_loop_wait_event函数

[iOS工程代码](https://gitee.com/learnany/ffmpeg/tree/master/15_ffplay_debug/iOSFFmpegSDLFastForwardAndBackward)

## 源代码一览

```c
//
//  main.m
//  iOSFFmpegSDLFastForwardAndBackward
//
//  Created by 陈长青 on 2022/5/8.
//

#import <UIKit/UIKit.h>

#include "libavutil/avstring.h"
#include "libavutil/eval.h"
#include "libavutil/mathematics.h"
#include "libavutil/pixdesc.h"
#include "libavutil/imgutils.h"
#include "libavutil/dict.h"
#include "libavutil/parseutils.h"
#include "libavutil/samplefmt.h"
#include "libavutil/avassert.h"
#include "libavutil/time.h"
#include "libavformat/avformat.h"
#include "libavdevice/avdevice.h"
#include "libswscale/swscale.h"
#include "libavutil/opt.h"
#include "libavcodec/avfft.h"
#include "libswresample/swresample.h"

#include <SDL.h>
#include <SDL_thread.h>

const char program_name[] = "ffplay";

/* Step size for volume control in dB */
#define SDL_VOLUME_STEP (0.75)

/* polls for possible required screen refresh at least this often, should be less than 1/fps */
#define REFRESH_RATE 0.01

#define CURSOR_HIDE_DELAY 1000000

/* options specified by the user */
static AVInputFormat *file_iformat;
static const char *input_filename;
static int default_width  = 640;
static int default_height = 480;
static int screen_width  = 0;
static int screen_height = 0;
static int cursor_hidden = 0;
static int64_t cursor_last_shown;

/* current context */
// 命令行 -fs 指定，控制是否全屏显示
static int is_full_screen;

static AVPacket flush_pkt;

#define FF_QUIT_EVENT    (SDL_USEREVENT + 2)

static SDL_Window *window;
static SDL_Renderer *renderer;
static SDL_RendererInfo renderer_info = {0};

// MARK: 视频状态
typedef struct VideoState {
    int force_refresh;
    int paused;
    int seek_req;
    int seek_flags;
    int64_t seek_pos;
    int64_t seek_rel;
    AVFormatContext *ic;
    
    int muted;
    int width, height, xleft, ytop;
    int step;
    
    // 命令行 -showmode 指定
    enum ShowMode {
        SHOW_MODE_NONE = -1, SHOW_MODE_VIDEO = 0, SHOW_MODE_WAVES, SHOW_MODE_RDFT, SHOW_MODE_NB
    } show_mode;
    
    SDL_Texture *vis_texture;
    
    SDL_cond *continue_read_thread;
} VideoState;

// MARK: 关闭码流
static void stream_close(VideoState *is)
{
    // TODO: stream_close
}

// MARK: 打开码流
static VideoState *stream_open(const char *filename, AVInputFormat *iformat)
{
    // TODO: stream_open
    VideoState *is;

    is = av_mallocz(sizeof(VideoState));
    if (!is)
        return NULL;
    return is;
}

// MARK: 切换码流
static void stream_cycle_channel(VideoState *is, int codec_type)
{
    // TODO: stream_cycle_channel
}

// MARK: 退出
static void do_exit(VideoState *is)
{
    if (is) {
        stream_close(is);
    }
    if (renderer)
        SDL_DestroyRenderer(renderer);
    if (window)
        SDL_DestroyWindow(window);
    // uninit_opts();
//#if CONFIG_AVFILTER
    // av_freep(&vfilters_list);
//#endif
    // avformat_network_deinit();
    // if (show_status)
    //    printf("\n");
    SDL_Quit();
    av_log(NULL, AV_LOG_QUIET, "%s", "");
    exit(0);
}

// MARK: 刷新视频
/* called to display each frame */
static void video_refresh(void *opaque, double *remaining_time)
{
    // TODO: video_refresh
    // av_log(NULL, AV_LOG_INFO, "player，刷新视频\n");
}

static void toggle_full_screen(VideoState *is)
{
    is_full_screen = !is_full_screen;
    SDL_SetWindowFullscreen(window, is_full_screen ? SDL_WINDOW_FULLSCREEN_DESKTOP : 0);
}

// MARK: 主时钟
/* get the current master clock value */
static double get_master_clock(VideoState *is)
{
    // TODO: get_master_clock
    return 0;
}

// MARK: Seek
/* seek in the stream */
static void stream_seek(VideoState *is, int64_t pos, int64_t rel, int seek_by_bytes)
{
    if (!is->seek_req) {
        is->seek_pos = pos;
        is->seek_rel = rel;
        is->seek_flags &= ~AVSEEK_FLAG_BYTE;
        if (seek_by_bytes)
            is->seek_flags |= AVSEEK_FLAG_BYTE;
        is->seek_req = 1;
        SDL_CondSignal(is->continue_read_thread);
    }
}

// MARK: 暂停2
/* pause or resume the video */
static void stream_toggle_pause(VideoState *is)
{
    // TODO: stream_toggle_pause
}

// MARK: 暂停
static void toggle_pause(VideoState *is)
{
    stream_toggle_pause(is);
    is->step = 0;
}

// MARK: 禁音
static void toggle_mute(VideoState *is)
{
    is->muted = !is->muted;
}

// MARK: 调声音
static void update_volume(VideoState *is, int sign, double step)
{
    // TODO: update_volume
}

// MARK: 进入下一帧
static void step_to_next_frame(VideoState *is)
{
    /* if the stream is paused unpause it, then step */
    if (is->paused)
        stream_toggle_pause(is);
    is->step = 1;
}

// MARK: SDL事件
/**
 *  SDL 事件
 *
 * 循环检测并优先处理用户输入事件
 * 内置刷新率控制，约10ms刷新一次
 * https://blog.csdn.net/qq_36783046/article/details/88706162
 */
static void refresh_loop_wait_event(VideoState *is, SDL_Event *event) {
    double remaining_time = 0.0;
    /* 从输入设备收集事件并放到事件队列中 */
    SDL_PumpEvents();
    /**
     * SDL_PeepEvents
     * 从事件队列中提取事件，由于这里使用的是SDL_GETEVENT, 所以获取事件时会从队列中移除
     * 如果有事件发生，返回事件数量，则while循环不执行。
     * 如果出错，返回负数的错误码，则while循环不执行。
     * 如果当前没有事件发生，且没有出错，返回0，进入while循环。
     */
    while (!SDL_PeepEvents(event, 1, SDL_GETEVENT, SDL_FIRSTEVENT, SDL_LASTEVENT)) {
        /* 隐藏鼠标指针， CURSOR_HIDE_DELAY = 1s */
        if (!cursor_hidden && av_gettime_relative() - cursor_last_shown > CURSOR_HIDE_DELAY) {
            SDL_ShowCursor(0);
            cursor_hidden = 1;
        }
        /* 默认屏幕刷新率控制，REFRESH_RATE = 10ms */
        if (remaining_time > 0.0)
            av_usleep((int64_t)(remaining_time * 1000000.0));
        remaining_time = REFRESH_RATE;
        /* 显示视频 */
        if (is->show_mode != SHOW_MODE_NONE && (!is->paused || is->force_refresh))
            video_refresh(is, &remaining_time);
        /* 再次检测输入事件 */
        SDL_PumpEvents();
    }
}

// MARK: 事件循环
/* handle an event sent by the GUI */
static void event_loop(VideoState *cur_stream)
{
    SDL_Event event;
    double incr, pos, frac;

    for (;;) {
        double x;
        refresh_loop_wait_event(cur_stream, &event);
        switch (event.type) {
        // 按键按下事件
        case SDL_KEYDOWN:
            // 按esc,q退出
            if (1/**exit_on_keydown*/ || event.key.keysym.sym == SDLK_ESCAPE || event.key.keysym.sym == SDLK_q) {
                do_exit(cur_stream);
                break;
            }
            // If we don't yet have a window, skip all key events, because read_thread might still be initializing...
            if (!cur_stream->width)
                continue;
            switch (event.key.keysym.sym) {
            // 按F键，全屏
            case SDLK_f:
                toggle_full_screen(cur_stream);
                // 调用video_refresh()刷新视频
                cur_stream->force_refresh = 1;
                break;
            // 按P、SPACE键，暂停
            case SDLK_p:
            case SDLK_SPACE:
                toggle_pause(cur_stream);
                break;
            // 按M键，静音
            case SDLK_m:
                toggle_mute(cur_stream);
                break;
            // 按+、0键，增加音量
            // https://blog.csdn.net/huzhifei/article/details/112682390
            case SDLK_KP_MULTIPLY:
            case SDLK_0:
                update_volume(cur_stream, 1, SDL_VOLUME_STEP);
                break;
            // 按-、9键，减小音量
            case SDLK_KP_DIVIDE:
            case SDLK_9:
                update_volume(cur_stream, -1, SDL_VOLUME_STEP);
                break;
            // 按S键，下一帧
            case SDLK_s: // S: Step to next frame
                step_to_next_frame(cur_stream);
                break;
            // 按A键，切换音频流
            case SDLK_a:
                stream_cycle_channel(cur_stream, AVMEDIA_TYPE_AUDIO);
                break;
            // 按V键，切换视频流
            case SDLK_v:
                stream_cycle_channel(cur_stream, AVMEDIA_TYPE_VIDEO);
                break;
            // 按C键，循环切换节目（切换音频、视频、字幕流）
            case SDLK_c:
                stream_cycle_channel(cur_stream, AVMEDIA_TYPE_VIDEO);
                stream_cycle_channel(cur_stream, AVMEDIA_TYPE_AUDIO);
                stream_cycle_channel(cur_stream, AVMEDIA_TYPE_SUBTITLE);
                break;
            // 按T键，切换字幕流
            case SDLK_t:
                stream_cycle_channel(cur_stream, AVMEDIA_TYPE_SUBTITLE);
                break;
            // 按W键，循环切换过滤器或显示模式
            case SDLK_w:
//#if CONFIG_AVFILTER
                // if (cur_stream->show_mode == SHOW_MODE_VIDEO && cur_stream->vfilter_idx < nb_vfilters - 1) {
                //     if (++cur_stream->vfilter_idx >= nb_vfilters)
                //         cur_stream->vfilter_idx = 0;
                // } else {
                //     cur_stream->vfilter_idx = 0;
                //     toggle_audio_display(cur_stream);
                // }
//#else
                // toggle_audio_display(cur_stream);
//#endif
                break;
            // mac上好像没找到这个键
            case SDLK_PAGEUP:
                // 如果只有一个视频则向前10分钟
                // if (cur_stream->ic->nb_chapters <= 1) {
                    incr = 600.0;
                    goto do_seek;
                // }
                // 有多个视频则寻找下一视频
                // seek_chapter(cur_stream, 1);
                break;
            // mac上好像没找到这个键
            case SDLK_PAGEDOWN:
                // 如果只有一个视频则向后10分钟
                // if (cur_stream->ic->nb_chapters <= 1) {
                    incr = -600.0;
                    goto do_seek;
                // }
                // 有多个视频则寻找上一视频
                // seek_chapter(cur_stream, -1);
                break;
            // 按LEFT键，向后10秒
            case SDLK_LEFT:
                // seek_interval：命令行 -seek_interval 指定
                incr = /**seek_interval ? -seek_interval : */-10.0;
                goto do_seek;
            // 按RIGHT键，向前10秒
            case SDLK_RIGHT:
                incr = /**seek_interval ? seek_interval :*/ 10.0;
                goto do_seek;
            // 按UP键，向前60秒
            case SDLK_UP:
                incr = 60.0;
                goto do_seek;
            // 按UP键，向后60秒
            case SDLK_DOWN:
                incr = -60.0;
            do_seek:
                    // seek_by_bytes：命令行 -bytes 指定，默认-1
                    // if (seek_by_bytes) {
                    //     pos = -1;
                    //     if (pos < 0 && cur_stream->video_stream >= 0)
                    //         pos = frame_queue_last_pos(&cur_stream->pictq);
                    //     if (pos < 0 && cur_stream->audio_stream >= 0)
                    //         pos = frame_queue_last_pos(&cur_stream->sampq);
                    //     if (pos < 0)
                    //         pos = avio_tell(cur_stream->ic->pb);
                    //     if (cur_stream->ic->bit_rate)
                    //         incr *= cur_stream->ic->bit_rate / 8.0;
                    //     else
                    //         incr *= 180000.0;
                    //     pos += incr;
                    //     stream_seek(cur_stream, pos, incr, 1);
                    // } else {
                         pos = get_master_clock(cur_stream);
                         if (isnan(pos))
                             pos = (double)cur_stream->seek_pos / AV_TIME_BASE;
                         pos += incr;
                         if (cur_stream->ic->start_time != AV_NOPTS_VALUE && pos < cur_stream->ic->start_time / (double)AV_TIME_BASE)
                             pos = cur_stream->ic->start_time / (double)AV_TIME_BASE;
                         stream_seek(cur_stream, (int64_t)(pos * AV_TIME_BASE), (int64_t)(incr * AV_TIME_BASE), 0);
                    // }
                break;
            default:
                break;
            }
            break;
        case SDL_MOUSEBUTTONDOWN:
            // exit_on_mousedown：命令行 -exitonmousedown 指定，鼠标单击左键退出
            // if (exit_on_mousedown) {
            //    do_exit(cur_stream);
            //    break;
            // }
            // 双击左键全屏
            if (event.button.button == SDL_BUTTON_LEFT) {
                static int64_t last_mouse_left_click = 0;
                if (av_gettime_relative() - last_mouse_left_click <= 500000) {
                    toggle_full_screen(cur_stream);
                    cur_stream->force_refresh = 1;
                    last_mouse_left_click = 0;
                } else {
                    last_mouse_left_click = av_gettime_relative();
                }
            }
        // 鼠标移动事件，执行Seek（暂时不会用）
        case SDL_MOUSEMOTION:
            // if (cursor_hidden) {
            //     SDL_ShowCursor(1);
            //     cursor_hidden = 0;
            // }
            // cursor_last_shown = av_gettime_relative();
            // if (event.type == SDL_MOUSEBUTTONDOWN) {
            //     if (event.button.button != SDL_BUTTON_RIGHT)
            //         break;
            //     x = event.button.x;
            // } else {
            //     if (!(event.motion.state & SDL_BUTTON_RMASK))
            //         break;
            //     x = event.motion.x;
            // }
            //     if (seek_by_bytes || cur_stream->ic->duration <= 0) {
            //         uint64_t size =  avio_size(cur_stream->ic->pb);
            //         stream_seek(cur_stream, size*x/cur_stream->width, 0, 1);
            //     } else {
            //         int64_t ts;
            //         int ns, hh, mm, ss;
            //         int tns, thh, tmm, tss;
            //         tns  = cur_stream->ic->duration / 1000000LL;
            //         thh  = tns / 3600;
            //         tmm  = (tns % 3600) / 60;
            //         tss  = (tns % 60);
            //         frac = x / cur_stream->width;
            //         ns   = frac * tns;
            //         hh   = ns / 3600;
            //         mm   = (ns % 3600) / 60;
            //         ss   = (ns % 60);
            //         av_log(NULL, AV_LOG_INFO,
            //                "Seek to %2.0f%% (%2d:%02d:%02d) of total duration (%2d:%02d:%02d)       \n", frac*100,
            //                 hh, mm, ss, thh, tmm, tss);
            //         ts = frac * cur_stream->ic->duration;
            //         if (cur_stream->ic->start_time != AV_NOPTS_VALUE)
            //             ts += cur_stream->ic->start_time;
            //         stream_seek(cur_stream, ts, 0, 0);
            //     }
            break;
        case SDL_WINDOWEVENT:
            switch (event.window.event) {
                case SDL_WINDOWEVENT_SIZE_CHANGED:
                    screen_width  = cur_stream->width  = event.window.data1;
                    screen_height = cur_stream->height = event.window.data2;
                    if (cur_stream->vis_texture) {
                        SDL_DestroyTexture(cur_stream->vis_texture);
                        cur_stream->vis_texture = NULL;
                    }
                case SDL_WINDOWEVENT_EXPOSED:
                    cur_stream->force_refresh = 1;
            }
            break;
        case SDL_QUIT:
        case FF_QUIT_EVENT:
            do_exit(cur_stream);
            break;
        default:
            break;
        }
    }
}

// MARK: 入口函数
int main(int argc, char *argv[]) {
    int flags;
    VideoState *is;
    
    // 动态加载的初始化，这是Windows平台的dll库相关处理；
    // https://blog.csdn.net/ericbar/article/details/79541420
    // init_dynload();

    // 设置打印的标记，AV_LOG_SKIP_REPEATED表示对于重复打印的语句，不重复输出；
    // https://blog.csdn.net/ericbar/article/details/79541420
    av_log_set_flags(AV_LOG_SKIP_REPEATED);
    // 使命令行'-loglevel'生效
    // parse_loglevel(argc, argv, options);

    /* register all codecs, demux and protocols */
//#if CONFIG_AVDEVICE
    // 在使用libavdevice之前，必须先运行avdevice_register_all()对设备进行注册，否则就会出错
    // https://blog.csdn.net/leixiaohua1020/article/details/41211121
    avdevice_register_all();
//#endif
    // 打开网络流的话，前面要加上函数
    // avformat_network_init();
    // Initialize the cmdutils option system, in particular allocate the *_opts contexts.
    // 初始化 cmdutils 选项系统，特别是分配 *_opts 上下文。
    // init_opts();

    // signal(SIGINT , sigterm_handler); /* Interrupt (ANSI).    */
    // signal(SIGTERM, sigterm_handler); /* Termination (ANSI).  */

    // 将程序横幅打印到 stderr。 横幅内容取决于当前版本的存储库和程序使用的 libav* 库。
    // Print the program banner to stderr. The banner contents depend
    // on the current version of the repository and of the libav* libraries used by
    // the program.
    // show_banner(argc, argv, options);

    // parse_options(NULL, argc, argv, options, opt_input_file);

    // input_filename：命令行 -i 指定，视频路径
    NSString *inPath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"mov"];
    input_filename = [inPath UTF8String];
    if (!input_filename) {
    //     show_usage();
    //     av_log(NULL, AV_LOG_FATAL, "An input file must be specified\n");
    //     av_log(NULL, AV_LOG_FATAL,
    //            "Use -h to get full help or, even better, run 'man %s'\n", program_name);
        exit(1);
    }

    // display_disable：命令行 -nodisp 指定，不渲染画面不播放声音
    // if (display_disable) {
    //     video_disable = 1;
    // }
    flags = SDL_INIT_VIDEO | SDL_INIT_AUDIO | SDL_INIT_TIMER;
    // audio_disable：命令行 -an 指定，渲染画面不播放声音
    // if (audio_disable)
    //     flags &= ~SDL_INIT_AUDIO;
    // else {
    //     /* Try to work around an occasional ALSA buffer underflow issue when the
    //      * period size is NPOT due to ALSA resampling by forcing the buffer size. */
    //     if (!SDL_getenv("SDL_AUDIO_ALSA_SET_BUFFER_SIZE"))
    //         SDL_setenv("SDL_AUDIO_ALSA_SET_BUFFER_SIZE","1", 1);
    // }
    // if (display_disable)
    //     flags &= ~SDL_INIT_VIDEO;
    // 指定flags，SDL初始化
    if (SDL_Init (flags)) {
        av_log(NULL, AV_LOG_FATAL, "Could not initialize SDL - %s\n", SDL_GetError());
        av_log(NULL, AV_LOG_FATAL, "(Did you set the DISPLAY variable?)\n");
        exit(1);
    }

    // 禁用一些事件
    SDL_EventState(SDL_SYSWMEVENT, SDL_IGNORE);
    SDL_EventState(SDL_USEREVENT, SDL_IGNORE);

    av_init_packet(&flush_pkt);
    flush_pkt.data = (uint8_t *)&flush_pkt;

    if (1/**!display_disable*/) {
        int flags = SDL_WINDOW_HIDDEN;
        // if (alwaysontop)
#if SDL_VERSION_ATLEAST(2,0,5)
            flags |= SDL_WINDOW_ALWAYS_ON_TOP;
#else
            av_log(NULL, AV_LOG_WARNING, "Your SDL version doesn't support SDL_WINDOW_ALWAYS_ON_TOP. Feature will be inactive.\n");
#endif
        // borderless：命令行 -noborder 指定，没有边框
        // if (borderless)
        //     flags |= SDL_WINDOW_BORDERLESS;
        // else
            // 可以自由拉伸
            flags |= SDL_WINDOW_RESIZABLE;
        window = SDL_CreateWindow(program_name, SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, default_width, default_height, flags);
        // "0" or "nearest" - Nearest pixel sampling
        // "1" or "linear"  - Linear filtering (supported by OpenGL and Direct3D)
        // "2" or "best"    - Currently this is the same as "linear"
        SDL_SetHint(SDL_HINT_RENDER_SCALE_QUALITY, "linear");
        if (window) {
            renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
            if (!renderer) {
                av_log(NULL, AV_LOG_WARNING, "Failed to initialize a hardware accelerated renderer: %s\n", SDL_GetError());
                renderer = SDL_CreateRenderer(window, -1, 0);
            }
            if (renderer) {
                if (!SDL_GetRendererInfo(renderer, &renderer_info))
                    av_log(NULL, AV_LOG_VERBOSE, "Initialized %s renderer.\n", renderer_info.name);
            }
        }
        if (!window || !renderer || !renderer_info.num_texture_formats) {
            av_log(NULL, AV_LOG_FATAL, "Failed to create window or renderer: %s", SDL_GetError());
            do_exit(NULL);
        }
    }

    is = stream_open(input_filename, file_iformat);
    if (!is) {
        av_log(NULL, AV_LOG_FATAL, "Failed to initialize VideoState!\n");
        do_exit(NULL);
    }

    event_loop(is);

    /* never returns */

    return 0;
}
```

<div style="margin: 0px;">
    备案号：
    <a href="https://beian.miit.gov.cn/" target="_blank">
        <!-- <img src="https://api.azpay.cn/808/1.png" style="height: 20px;"> -->沪ICP备2022002183号-1
    </a >
</div>

