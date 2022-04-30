# 9.FFmpeg+SDL播放视频

[Android工程代码](https://gitee.com/learnany/ffmpeg/tree/master/09_display_video_while_decoding/AndroidDisplayVideoWhileDecoding)


## 一、代码实现

### 第一步：注册组件

```c
// 第一步：注册组件
av_register_all();
```

### 第二步：打开封装格式

```c
// 第二步：打开封装格式
// 参数一：封装格式上下文
// 作用：保存整个视频信息(解码器、编码器等等...)
// 信息：码率、帧率等...
AVFormatContext* avformat_context = avformat_alloc_context();
// 参数二：视频路径
const char *url = "/storage/emulated/0/Download/test.mov";
// 参数三：指定输入的格式
// 参数四：设置默认参数
int avformat_open_input_result = avformat_open_input(&avformat_context, url, NULL, NULL);
if (avformat_open_input_result != 0){
    // 安卓平台下log
    __android_log_print(ANDROID_LOG_INFO, "main", "打开文件失败");
    // iOS平台下log
    // NSLog("打开文件失败");
    // 不同的平台替换不同平台log日志
    return -1;
}
```

### 第三步：查找视频流，拿到视频信息

```c
// 第三步：查找视频流，拿到视频信息
// 参数一：封装格式上下文
// 参数二：指定默认配置
int avformat_find_stream_info_result = avformat_find_stream_info(avformat_context, NULL);
if (avformat_find_stream_info_result < 0){
    __android_log_print(ANDROID_LOG_INFO, "main", "查找失败");
    return -1;
}
```

### 第四步：查找视频解码器

```c
// 第四步：查找视频解码器
// 4.1 查找视频流索引位置
int av_stream_index = -1;
for (int i = 0; i < avformat_context->nb_streams; ++i) {
    // 判断流类型：视频流、音频流、字母流等等...
    if (avformat_context->streams[i]->codec->codec_type == AVMEDIA_TYPE_VIDEO){
        av_stream_index = i;
        break;
    }
}
// 4.2 根据视频流索引，获取解码器上下文
AVCodecContext *avcodec_context = avformat_context->streams[av_stream_index]->codec;
// 4.3 根据解码器上下文，获得解码器ID，然后查找解码器
AVCodec *avcodec = avcodec_find_decoder(avcodec_context->codec_id);
```

### 第五步：打开解码器

```c
// 第五步：打开解码器
int avcodec_open2_result = avcodec_open2(avcodec_context, avcodec, NULL);
if (avcodec_open2_result != 0){
    __android_log_print(ANDROID_LOG_INFO, "main", "打开解码器失败");
    return -1;
}
// 测试一下
// 打印信息
__android_log_print(ANDROID_LOG_INFO, "main", "解码器名称：%s", avcodec->name);
```

### 第六步：定义类型转换参数

```c
// 第六步：定义类型转换参数
// 6.1 创建视频采样数据帧上下文
// 参数一：源文件->原始视频像素数据格式宽
// 参数二：源文件->原始视频像素数据格式高
// 参数三：源文件->原始视频像素数据格式类型
// 参数四：目标文件->目标视频像素数据格式宽
// 参数五：目标文件->目标视频像素数据格式高
// 参数六：目标文件->目标视频像素数据格式类型
SwsContext *swscontext = sws_getContext(avcodec_context->width,
                                        avcodec_context->height,
                                        avcodec_context->pix_fmt,
                                        avcodec_context->width,
                                        avcodec_context->height,
                                        AV_PIX_FMT_YUV420P,
                                        SWS_BICUBIC,
                                        NULL,
                                        NULL,
                                        NULL);
// 6.2 创建视频压缩数据帧
// 视频压缩数据：H264
AVFrame* avframe_in = av_frame_alloc();
// 定义解码结果
int decode_result = 0;
// 6.3 创建视频采样数据帧
// 视频采样数据：YUV格式
AVFrame* avframe_yuv420p = av_frame_alloc();
// 给缓冲区设置类型->yuv420类型
// 得到YUV420P缓冲区大小
// 参数一：视频像素数据格式类型->YUV420P格式
// 参数二：一帧视频像素数据宽 = 视频宽
// 参数三：一帧视频像素数据高 = 视频高
// 参数四：字节对齐方式->默认是1
int buffer_size = av_image_get_buffer_size(AV_PIX_FMT_YUV420P,
                                           avcodec_context->width,
                                           avcodec_context->height,
                                           1);
// 开辟一块内存空间
uint8_t *out_buffer = (uint8_t *)av_malloc(buffer_size);
// 向avframe_yuv420p填充数据
// 参数一：目标->填充数据(avframe_yuv420p)
// 参数二：目标->每一行大小
// 参数三：原始数据
// 参数四：目标->格式类型
// 参数五：宽
// 参数六：高
// 参数七：字节对齐方式
av_image_fill_arrays(avframe_yuv420p->data,
                     avframe_yuv420p->linesize,
                     out_buffer,
                     AV_PIX_FMT_YUV420P,
                     avcodec_context->width,
                     avcodec_context->height,
                     1);
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

### 第八步：初始化SDL窗口

```c
// 第八步：初始化SDL窗口
// 参数一：窗口名称
// 参数二：窗口在屏幕上的x坐标
// 参数三：窗口在屏幕上的y坐标
// 参数四：窗口在屏幕上宽
// 参数五：窗口在屏幕上高
// 参数六：窗口状态(打开)
int width = 640;
int height = 352;
SDL_Window* sdl_window = SDL_CreateWindow("SDL播放YUV视频",
                                          SDL_WINDOWPOS_CENTERED,
                                          SDL_WINDOWPOS_CENTERED,
                                          width,
                                          height,
                                          SDL_WINDOW_OPENGL);
if (sdl_window == NULL){
    __android_log_print(ANDROID_LOG_INFO, "main", "窗口创建失败：%s", SDL_GetError());
    // Mac使用
    // printf("窗口创建失败： %s\n", SDL_GetError());
    // 退出程序
    SDL_Quit();
    return -1;
}
```

### 第九步：创建渲染器->渲染窗口

```c
// 第九步：创建渲染器->渲染窗口
// 参数一：渲染目标创建->目标
// 参数二：从那里开始渲染(-1:表示从第一个位置开始)
// 参数三：渲染类型(软件渲染)
SDL_Renderer* sdl_renderer = SDL_CreateRenderer(sdl_window, -1, 0);
if (sdl_renderer == NULL){
    __android_log_print(ANDROID_LOG_INFO, "main", "渲染器创建失败：%s", SDL_GetError());
    // Mac使用
    // printf("渲染器创建失败： %s\n", SDL_GetError());
    // 退出程序
    SDL_Quit();
    return -1;
}
// 定义渲染器区域
SDL_Rect sdl_rect;
```

### 第十步：创建纹理

```c
// 第十步：创建纹理
// 参数一：纹理->目标渲染器
// 参数二：渲染格式->YUV格式->像素数据格式(视频)或者是音频采样数据格式(音频)
// 参数三：绘制方式->频繁绘制->SDL_TEXTUREACCESS_STREAMING
// 参数四：纹理宽
// 参数五：纹理高
SDL_Texture* sdl_texture = SDL_CreateTexture(sdl_renderer,
                                             SDL_PIXELFORMAT_IYUV,
                                             SDL_TEXTUREACCESS_STREAMING,
                                             width,
                                             height);
if (sdl_texture == NULL) {
    __android_log_print(ANDROID_LOG_INFO, "main", "纹理创建失败：%s", SDL_GetError());
    // Mac使用
    // printf("纹理创建失败： %s\n", SDL_GetError());
    // 退出程序
    SDL_Quit();
    return -1;
}
```

### 第十一步：读取视频压缩数据帧

```c
// 第十一步：读取视频压缩数据帧
int current_index = 0;
// 写入时yuv数据位置
int y_size, u_size, v_size;
// 分析av_read_frame参数。
// 参数一：封装格式上下文
// 参数二：一帧压缩数据
// 如果是解码视频流，是视频压缩帧数据，例如H264
AVPacket* packet = (AVPacket*)av_malloc(sizeof(AVPacket));
while (av_read_frame(avformat_context, packet) >= 0) {
    // >=:读取到了
    // <0:读取错误或者读取完毕
    // 是否是我们的视频流
    if (packet->stream_index == av_stream_index) {
        // 第十二步：开始视频解码
        // ...

        current_index++;
        __android_log_print(ANDROID_LOG_INFO, "main", "当前解码第%d帧", current_index);
    }
}
```

### 第十二步：开始视频解码

```c
// 第十二步：开始视频解码
// 发送一帧视频压缩数据
avcodec_send_packet(avcodec_context, packet);
// 解码一帧视频数据
decode_result = avcodec_receive_frame(avcodec_context, avframe_in);
if (decode_result == 0) {

    // 视频解码成功

    // 第十三步：开始类型转换
    // ...


    // 第十四步：设置纹理数据
    // ...

    // 第十五步：将纹理数据拷贝给渲染器
    // ...

    // 第十六步：呈现画面帧
    // ...

    // 第十七步：渲染每一帧直接间隔时间
    // ...
}
```

### 第十三步：开始类型转换

```c
// 第十三步：开始类型转换
// 将解码出来的视频像素点数据格式统一转类型为yuv420P
// 参数一：视频像素数据格式上下文
// 参数二：原来的视频像素数据格式->输入数据
// 参数三：原来的视频像素数据格式->输入画面每一行大小
// 参数四：原来的视频像素数据格式->输入画面每一行开始位置(填写：0->表示从原点开始读取)
// 参数五：原来的视频像素数据格式->输入数据行数
// 参数六：转换类型后视频像素数据格式->输出数据
// 参数七：转换类型后视频像素数据格式->输出画面每一行大小
sws_scale(swscontext,
          (const uint8_t *const *)avframe_in->data,
          avframe_in->linesize,
          0,
          avcodec_context->height,
          avframe_yuv420p->data,
          avframe_yuv420p->linesize);
```

### 第十四步：设置纹理数据

```c
// 第十四步：设置纹理数据
// 参数一：纹理
// 参数二：渲染区域
// 参数三：需要渲染数据->视频像素数据帧
// 参数四：帧宽
SDL_UpdateTexture(sdl_texture, NULL, avframe_yuv420p->data[0], avframe_yuv420p->linesize[0]);
```

### 第十五步：将纹理数据拷贝给渲染器

```c
// 第十五步：将纹理数据拷贝给渲染器
// 设置左上角位置(全屏)
sdl_rect.x = 100;
sdl_rect.y = 100;
sdl_rect.w = width;
sdl_rect.h = height;
SDL_RenderClear(sdl_renderer);
SDL_RenderCopy(sdl_renderer, sdl_texture, NULL, &sdl_rect);
```

### 第十六步：呈现画面帧

```c
// 第十六步：呈现画面帧
SDL_RenderPresent(sdl_renderer);
```

### 第十七步：渲染每一帧直接间隔时间

```c
// 第十七步：渲染每一帧直接间隔时间
SDL_Delay(30);
```

### 第十八步：释放资源

```c
// 第十八步：释放资源
SDL_DestroyTexture(sdl_texture);
SDL_DestroyRenderer(sdl_renderer);
```

### 第十九步：退出程序

```c
// 第十九步：退出程序
SDL_Quit();
```

### 第二十步：释放内存资源，关闭解码器

```c
// 第二十步：释放内存资源，关闭解码器
av_packet_free(&packet);
av_frame_free(&avframe_in);
av_frame_free(&avframe_yuv420p);
free(out_buffer);
avcodec_close(avcodec_context);
avformat_free_context(avformat_context);
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

extern "C" {
// 引入头文件
// 核心库->音视频编解码库
#include <libavcodec/avcodec.h>
#include "libavformat/avformat.h"
#include <libavutil/imgutils.h>
#include <libswscale/swscale.h>
}

// SDL入口
extern "C"
int main(int argc, char *argv[]) {
    // 边解码边显示视频实现
    // 复制代码实现
}
```