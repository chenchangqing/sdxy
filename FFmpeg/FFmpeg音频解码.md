# FFmpeg视频解码

[代码工程](https://gitee.com/learnany/ffmpeg/tree/master/05_ffmpeg_audio_decoding/AndroidFFmpegDecodingAudio)

## 一、视频解码流程

### 第一步：注册组件

`av_register_all`：例如：编码器、解码器等等。

```c
// 第一步：注册组件
av_register_all();
```

### 第二步：打开封装格式

`avformat_open_input`：例如：打开.mp4、.mov、.wmv文件等等。

```c
// 第二步：打开封装格式

// 参数一：封装格式上下文
// 作用：保存整个视频信息(解码器、编码器等等...)
// 信息：码率、帧率等...
AVFormatContext* avformat_context = avformat_alloc_context();

// 参数二：视频路径
// 在我们iOS里面
// NSString* path = @"test.mov";
// const char *url = [path UTF8String]
const char *url = env->GetStringUTFChars(in_file_path, NULL);
// 参数三：指定输入的格式
// 参数四：设置默认参数
int avformat_open_input_result = avformat_open_input(&avformat_context, url, NULL, NULL);
if (avformat_open_input_result != 0){
    // 安卓平台下log
    __android_log_print(ANDROID_LOG_INFO, "main", "打开文件失败");
    // iOS平台下log
    // NSLog("打开文件失败");
    // 不同的平台替换不同平台log日志
    return;
}
```

### 第三步：查找视频基本信息

`avformat_find_stream_info`：如果是视频解码，那么查找视频流，如果是音频解码，那么就查找音频流。

```c
// 第三步：查找视频流，拿到视频信息
// 参数一：封装格式上下文
// 参数二：指定默认配置
int avformat_find_stream_info_result = avformat_find_stream_info(avformat_context, NULL);
if (avformat_find_stream_info_result < 0){
    __android_log_print(ANDROID_LOG_INFO, "main", "查找失败");
    return;
}
```

### 第四步：查找音频解码器

`avcodec_find_decoder`：查找解码器。

#### 1. 查找音频流索引位置

```c
// 第四步：查找音频解码器
// 4.1 查找音频流索引位置
int av_stream_index = -1;
for (int i = 0; i < avformat_context->nb_streams; ++i) {
    // 判断流类型：视频流、音频流、字母流等等...
    if (avformat_context->streams[i]->codec->codec_type == AVMEDIA_TYPE_AUDIO){
        av_stream_index = i;
        break;
    }
}
```

#### 2. 获取解码器上下文

根据音频流索引，获取解码器上下文。

```c
// 4.2 根据音频流索引，获取解码器上下文
AVCodecContext *avcodec_context = avformat_context->streams[av_stream_index]->codec;
```

#### 3. 获得解码器ID

根据解码器上下文，获得解码器ID，然后查找解码器。

```c
// 4.3 根据解码器上下文，获得解码器ID，然后查找解码器
AVCodec *avcodec = avcodec_find_decoder(avcodec_context->codec_id);
```

### 第五步：打开解码器

`avcodec_open2`：打开解码器。

```c
// 第五步：打开解码器
int avcodec_open2_result = avcodec_open2(avcodec_context, avcodec, NULL);
if (avcodec_open2_result != 0){
    __android_log_print(ANDROID_LOG_INFO, "main", "打开解码器失败");
    return;
}
// 测试一下
// 打印信息
__android_log_print(ANDROID_LOG_INFO, "main", "解码器名称：%s", avcodec->name);
```

### 第六步：定义类型转换参数

用于`swr_convert()`，进行音频采样数据转换操作。

#### 1. 创建音频采样数据上下文

```c
// 第六步：定义类型转换参数
// 6.1 创建音频采样数据上下文
// 参数一：音频采样数据上下文
// 上下文：保存音频信息
SwrContext* swr_context = swr_alloc();
// 参数二：输出声道布局类型(立体声、环绕声、机器人等等...)
// 立体声
int64_t out_ch_layout = AV_CH_LAYOUT_STEREO;
//  int out_ch_layout = av_get_default_channel_layout(avcodec_context->channels);
// 参数三：输出采样精度（编码）
// 例如：采样精度8位 = 1字节，采样精度16位 = 2字节
// 直接指定
// int out_sample_fmt = AV_SAMPLE_FMT_S16;
// 动态获取，保持一致
AVSampleFormat out_sample_fmt = avcodec_context->sample_fmt;
// 参数四：输出采样率(44100HZ)
int out_sample_rate = avcodec_context->sample_rate;
// 参数五：输入声道布局类型
int64_t in_ch_layout = av_get_default_channel_layout(avcodec_context->channels);
// 参数六：输入采样精度
AVSampleFormat in_sample_fmt = avcodec_context->sample_fmt;
// 参数七：输入采样率
int in_sample_rate = avcodec_context->sample_rate;
// 参数八：log_offset->log日志，从那里开始统计
int log_offset = 0;
// 参数九：log上下文
swr_alloc_set_opts(swr_context,
               out_ch_layout,
               out_sample_fmt,
               out_sample_rate,
               in_ch_layout,
               in_sample_fmt,
               in_sample_rate,
               log_offset, NULL);
// 初始化音频采样数据上下文
swr_init(swr_context);
```

#### 2. 创建音频压缩数据帧

```c
// 6.2 创建音频压缩数据帧
// 音频压缩数据：acc格式、mp3格式
AVFrame* avframe_in = av_frame_alloc();
// 定义解码结果
int decode_result = 0;
```

#### 3. 创建音频采样数据帧

```c
// 6.3 创建音频采样数据帧
// 音频采样数据：PCM格式
// 缓冲区大小 = 采样率(44100HZ) * 采样精度(16位 = 2字节)
int MAX_AUDIO_SIZE = 44100 * 2;
uint8_t *out_buffer = (uint8_t *)av_malloc(MAX_AUDIO_SIZE);
```

### 第七步：打开.pcm文件

```c
// 第七步：打开.yuv文件
const char *outfile = env->GetStringUTFChars(out_file_path, NULL);
FILE* file_pcm = fopen(outfile, "wb+");
if (file_pcm == NULL){
    __android_log_print(ANDROID_LOG_INFO, "main", "输出文件打开失败");
    return;
}
```

### 第八步：读取视频压缩数据帧

`av_read_frame`：读取视频压缩数据帧。

```c
// 第八步：读取视频压缩数据帧
int current_index = 0;
// 分析av_read_frame参数。
// 参数一：封装格式上下文
// 参数二：一帧压缩数据
// 如果是解码音频流，是音频压缩帧数据，例如acc、mp3
AVPacket* packet = (AVPacket*)av_malloc(sizeof(AVPacket));
while (av_read_frame(avformat_context, packet) >= 0) {
    // >=:读取到了
    // <0:读取错误或者读取完毕
    // 是否是我们的音频流
    if (packet->stream_index == av_stream_index) {
        // 第九步：开始音频解码
        // ...
        current_index++;
        __android_log_print(ANDROID_LOG_INFO, "main", "当前解码第%d帧", current_index);
    }
}
```

### 第九步：开始视频解码

注意：代码位置在第八步。

`avcodec_send_packet`：发送一帧视频压缩数据。

`avcodec_receive_frame`：解码一帧视频数据。

```c
// 第九步：开始音频解码
// 发送一帧音频压缩数据
avcodec_send_packet(avcodec_context, packet);
// 解码一帧视频数据
decode_result = avcodec_receive_frame(avcodec_context, avframe_in);
if (decode_result == 0) {

    // 音频解码成功

    // 第十步：开始类型转换
    // ...

    // 第十一步：写入.pcm文件
    // ...
    
}      
```

### 第十步：开始类型转换

注意：代码位置在第九步。

```c
// 第十步：开始类型转换
// 将解码出来的音频数据格式统一转类型为PCM
// 参数一：音频采样数据上下文
// 参数二：输出音频采样数据
// 参数三：输出音频采样数据->大小
// 参数四：输入音频采样数据
// 参数五：输入音频采样数据->大小
swr_convert(swr_context,
            &out_buffer,
            MAX_AUDIO_SIZE,
            (const uint8_t **)avframe_in->data,
            avframe_in->nb_samples);
```

### 第十一步：写入.pcm文件

注意：代码位置在第九步。

```c
// 第十一步：写入.pcm文件
// 获取缓冲区实际存储大小
// 参数一：行大小
// 参数二：输出声道数量
int out_nb_channels = av_get_channel_layout_nb_channels(out_ch_layout);
// 参数三：输入大小
// 参数四：输出音频采样数据格式
// 参数五：字节对齐方式
int out_buffer_size = av_samples_get_buffer_size(NULL,
                           out_nb_channels,
                           avframe_in->nb_samples,
                           out_sample_fmt,
                           1);

// 写入文件
fwrite(out_buffer, 1, out_buffer_size, file_pcm);
```

### 第十二步：释放内存资源，关闭解码器

```c
// 第十二步：释放内存资源，关闭解码器
fclose(file_pcm);
av_packet_free(&packet);
swr_free(&swr_context);
av_free(out_buffer);
av_frame_free(&avframe_in);
avcodec_close(avcodec_context);
avformat_close_input(&avformat_context);
```

## 二、新建Android音频解码工程

### 1. 新建工程

参考之前[FFmpeg集成](http://www.1221.site/FFmpeg/02_FFmpeg%E9%9B%86%E6%88%90.html)，新建ndk工程AndroidFFmpegDecodingAudio。

### 2. 定义java方法

寻找MainActivity：app->src->main->java->MainActivity，增加代码如下：
```java
public native void ffmepgDecodeAudio(String inFilePath, String outFilePath);
```

### 3. 定义NDK方法

增加android打印。
```c
#include <android/log.h>
```

在native-lib.cpp中，导入FFmpeg头文件。
```c
extern "C" {
// 引入头文件
// 核心库->音视频编解码库
#include <libavcodec/avcodec.h>
// 封装格式处理库
#include "libavformat/avformat.h"
// 工具库
#include "libavutil/imgutils.h"
// 视频像素数据格式库
#include "libswscale/swscale.h"
// 音频采样数据格式库
#include "libswresample/swresample.h"
}
```

在native-lib.cpp中新增java方法ffmepgDecodeAudio的C++实现，输入`MainActivity.`就会有代码提示，选择正确ffmepgDecodeAudio方法补全代码。
```c
extern "C"
JNIEXPORT void JNICALL
Java_com_ccq_androidffmpegdecodingaudio_MainActivity_ffmepgDecodeAudio(JNIEnv *env, jobject thiz,
                                                                       jstring in_file_path,
                                                                       jstring out_file_path) {
    // 这里拷贝上面的音频解码流程的代码即可。
}
```

## 三、测试Android音频解码工程

准备视频文件：[test.mov](https://gitee.com/learnany/ffmpeg/tree/master/resources/test.mov)

在AndroidManifest.xml增加SD卡的读写权限。

```
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

MainActivity增加测试代码。

注意：如果打开失败，可能读写存储设备的权限被禁用。

摩托罗拉·刀锋：设置->应用和通知->高级->权限管理器->隐私相关·读写存储设备->找到应用->如果禁用，则修改为允许。

```java
import android.os.Environment;
import java.io.File;
import java.io.IOException;
import android.util.Log;

String rootPath = Environment.getExternalStorageDirectory().getAbsolutePath();
String downloadPath = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS).getAbsolutePath();
String inFilePath = downloadPath.concat("/test.mov");
String outFilePath = downloadPath.concat("/test.pcm");

// 文件不存在我创建一个文件
File file = new File(outFilePath);
    if (file.exists()) {
        Log.i("日志：","存在");
} else {
    try {
        file.createNewFile();
    } catch (IOException e) {
        e.printStackTrace();
    }
}
ffmepgDecodeAudio(inFilePath, outFilePath);
```
run工程代码，正确打印，同时正确生成pcm文件。
```
I/main: 解码器名称：acc
I/main: 当前解码第1帧
.
.
.
I/main: 当前解码第502帧
```
[pcm文件](https://gitee.com/learnany/ffmpeg/tree/master/resources/test.pcm)音频播放：
```
ffplay -f s16le -ac 2 -ar 44100 /Users/chenchangqing/Downloads/test.pcm
```