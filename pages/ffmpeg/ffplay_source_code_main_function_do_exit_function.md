# ffplay源码-main函数，do_exit函数

[iOS工程代码](https://gitee.com/learnany/ffmpeg/tree/master/15_ffplay_debug/iOSFFmpegSDLFastForwardAndBackward)

## 源代码一览

```c
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

/* options specified by the user */
static AVInputFormat *file_iformat;
static const char *input_filename;
static int default_width  = 640;
static int default_height = 480;

/* current context */
static AVPacket flush_pkt;

static SDL_Window *window;
static SDL_Renderer *renderer;
static SDL_RendererInfo renderer_info = {0};

typedef struct VideoState {
    
} VideoState;

static void stream_close(VideoState *is)
{
    // TODO: stream_close
}

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

static VideoState *stream_open(const char *filename, AVInputFormat *iformat)
{
    // TODO: stream_open
    return NULL;
}

/* handle an event sent by the GUI */
static void event_loop(VideoState *cur_stream)
{
    // TODO: event_loop
}

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