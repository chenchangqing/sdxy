# FFmpeg音频编码

[Android代码工程](https://gitee.com/learnany/ffmpeg/tree/master/07_ffmpeg_audio_encoding/AndroidFFmpegEncodingAudio)

[iOS代码工程](https://gitee.com/learnany/ffmpeg/tree/master/07_ffmpeg_audio_encoding/iOSFFmpegEncodingAudio)

## 一、音频编码流程

### 第一步：注册组件

`av_register_all`：例如：编码器、解码器等等。

```c
// 第一步：注册组件
av_register_all();
```
        
### 第二步：初始化封装格式上下文

```c
// 第二步：初始化封装格式上下文
AVFormatContext *avformat_context = avformat_alloc_context();
const char *coutFilePath = env->GetStringUTFChars(out_file_path, NULL);
// iOS使用
// const char *coutFilePath = [outFilePath UTF8String];
AVOutputFormat *avoutput_format = av_guess_format(NULL, coutFilePath, NULL);
// 设置音频压缩数据格式类型(aac、mp3等等...)
avformat_context->oformat = avoutput_format;
```

### 第三步：打开输出文件

```c
// 第三步：打开输出文件
// 参数一：输出流
// 参数二：输出文件
// 参数三：权限->输出到文件中
if (avio_open(&avformat_context->pb, coutFilePath, AVIO_FLAG_WRITE) < 0) {
    __android_log_print(ANDROID_LOG_INFO, "main", "打开输出文件失败");
    // iOS使用
    // NSLog(@"打开输出文件失败");
    return;
}
```

### 第四步：创建输出码流

```c
// 第四步：创建输出码流
// 注意：创建了一块内存空间，并不知道他是什么类型流，希望他是音频流
AVStream *av_audio_stream = avformat_new_stream(avformat_context, NULL);
```

### 第五步：初始化编码器上下文

#### 1. 获取编码器上下文

```c
// 第五步：初始化编码器上下文
// 5.1 获取编码器上下文
AVCodecContext *avcodec_context = av_audio_stream->codec;
```

#### 2. 设置音频编码器ID

```c
// 5.2 设置音频编码器ID
avcodec_context->codec_id = avoutput_format->audio_codec;
```
run工程时，这一步出现了问题：
```
A/libc: Fatal signal 11 (SIGSEGV), code 1 (SEGV_MAPERR), fault addr 0x10 in tid 13086 (egencodingaudio), pid 13086 (egencodingaudio)
```
困挠了好几个小时，终于找到原因了，我把编码音频的输出文件后缀写成了acc，将后缀改成aac就解决了。
```java
// 错误
String outFilePath = downloadPath.concat("/test.acc");
// 正确
String outFilePath = downloadPath.concat("/test.aac");
```

#### 3. 设置为音频编码器

```c
// 5.3 设置为视频编码器
avcodec_context->codec_type = AVMEDIA_TYPE_AUDIO;
```

#### 4. 设置音频数据格式等

```c
// 5.4 设置像素数据格式
// 编码的是音频采样数据格式，视频像素数据格式为PCM
// 注意：这个类型是根据你解码的时候指定的解码的音频采样数据格式类型
avcodec_context->sample_fmt = AV_SAMPLE_FMT_S16;
// 设置采样率
avcodec_context->sample_rate = 44100;
// 立体声
avcodec_context->channel_layout = AV_CH_LAYOUT_STEREO;
// 声道数量
int channels = av_get_channel_layout_nb_channels(avcodec_context->channel_layout);
avcodec_context->channels = channels;
// 设置码率
// 基本的算法是：【码率】(kbps)=【视频大小 - 音频大小】(bit位) /【时间】(秒)
avcodec_context->bit_rate = 128000;
```

### 第六步：查找音频编码器

```c
// 第六步：查找音频编码器
AVCodec *avcodec = avcodec_find_encoder(avcodec_context->codec_id);
if (avcodec == NULL) {
    __android_log_print(ANDROID_LOG_INFO, "main", "找不到编码器");
    // iOS使用
    // NSLog(@"找不到编码器");
    return;
}

__android_log_print(ANDROID_LOG_INFO, "main", "编码器名称为：%s", avcodec->name);
// iOS使用
// NSLog(@"编码器名称为：%s", avcodec->name);
```

### 第七步：打开音频编码器

```c
// 第七步：打开音频编码器
// 打开编码器
if (avcodec_open2(avcodec_context, avcodec, NULL) < 0) {
    __android_log_print(ANDROID_LOG_INFO, "main", "打开编码器失败");
    // iOS使用
    // NSLog(@"打开编码器失败");
    return;
}
```

#### 1. 出现问题

新建测试工程（稍后会介绍建工程测试），代码运行到这一步会出现“打开编码器失败”，因为虽然找到了aac编码器，但是无法打开。
```
I/main: 编码器名称为：aac
I/main: 打开编码器失败
```

#### 2. 查找原因

下面我们通过打印错误日志定位错误原因。

修改`MainActivity.java`，新增方法：
```java
private void createAVLogFile() {
    // String rootPath = Environment.getExternalStorageDirectory().getAbsolutePath();
    String downloadPath = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS).getAbsolutePath();
    String logFilePath = downloadPath.concat("/av_log.txt");
    // 文件不存在我创建一个文件
    File file = new File(logFilePath);
    if (file.exists()) {
        Log.i("日志：","存在");
    } else {
        try {
            file.createNewFile();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
```
修改`native-lib.cpp`，新增方法：
```c
// 这个函数作用：统计程序报错信息，FFmpeg报错信息打印到av_log文件中
// 我们将av_log保存到了sdcard（外部存储）
// 或者你打印到控制台也可以，这里我们将错误信息打印到文件中
void custom_log(void *ptr, int level, const char* fmt, va_list vl) {
    __android_log_print(ANDROID_LOG_INFO, "main", fmt, vl);
    // 由于权限问题，还是无法将日志打印至sdcard，临时解决方案就是每次都先创建一个新的av_log.txt。
    FILE *fp=fopen("/storage/emulated/0/Download/av_log.txt","a+");
    if(fp){
        vfprintf(fp,fmt,vl);
        fflush(fp);
        fclose(fp);
    }
}
```
修改第七步，这样就可以打印日志至`av_log.txt`。
```c
// 第七步：打开音频编码器
// 设置log错误监听函数
av_log_set_callback(custom_log);
// 打开编码器
if (avcodec_open2(avcodec_context, avcodec, NULL) < 0) {
    __android_log_print(ANDROID_LOG_INFO, "main", "打开编码器失败");
    // iOS使用
    // NSLog(@"打开编码器失败");
    return;
}
```
run测试工程，查看`av_log.txt`，发现编码器有问题，不支持s16（AV_SAMPLE_FMT_S16）格式。
```
Specified sample format s16 is invalid or not supported
```

#### 3. 解决问题

通过分析，我们发现编码器有问题，那么我们需要换一个编码器。老得FFmpeg框架里面支持`faac`格式，新的FFmpeg框架里面`fdk_aac`格式。

`faac`和`fdk_aac`区别：fdk_aac编码出来音频质量高，占用内存少。

这里我们需要更换编码器为`libfdk_aac`，`fdk_aac`同时也支持s16（AV_SAMPLE_FMT_S16）格式。

##### (1) 下载源码

[fdk-aac](https://www.linuxfromscratch.org/blfs/view/svn/multimedia/fdk-aac.html)。

我使用的是[fdk-aac-0.1.4.zip](https://gitee.com/learnany/ffmpeg/blob/master/07_ffmpeg_audio_encoding/fdk-aac-0.1.4.zip)。

注意：编译0.1.5是有问题。

##### (2) 下载ndk

https://developer.android.google.cn/ndk/downloads/older_releases.html

我这里使用的是[ndkr10e](https://dl.google.com/android/repository/android-ndk-r10e-darwin-x86_64.zip?hl=zh-cn)。

在fdkaac源码的同目录下新建ndk文件交，将下载好的ndk放入ndk文件夹。

##### (3) 编译fdk-aac

编译fdk-aac的.a静态库。

[android-build-fdkaac.sh](https://gitee.com/learnany/ffmpeg/blob/master/07_ffmpeg_audio_encoding/android-build-fdkaac.sh)是编译脚本，将编译脚本放在和源码的同一目录，执行：

```
sh android-build-fdkaac.sh
```
执行过程会提示开机密码，看到`Android aac builds finished`说明编译成功。

##### (4) 编译FFmpeg

修改Android的FFmpeg动态库编译脚本，将fdkaac库其编译进去。[android-build-ffmpeg.sh](https://gitee.com/learnany/ffmpeg/blob/master/01_ffmpeg_compiled/android-build-ffmpeg.sh)是原来的编译脚本，在原来的编译脚本./configure增加如下选项。

```
# 以下是编译fdkaac库增加的
# 禁用所有编码器
--disable-encoders \
--enable-libfdk-aac \
--enable-encoder=libfdk_aac \
--enable-decoder=libfdk_aac \
# 和FFmpeg动态库一起编译，指定你之前编译好的fdkaac静态库和头文件
--extra-cflags="-I/Users/chenchangqing/Documents/code/ffmpeg/07_ffmpeg_audio_encoding/android_build_fdkaac/include" \
--extra-ldflags="-L/Users/chenchangqing/Documents/code/ffmpeg/07_ffmpeg_audio_encoding/android_build_fdkaac/lib" \
```
[android-build-ffmpeg-fdkaac.sh](https://gitee.com/learnany/ffmpeg/blob/master/07_ffmpeg_audio_encoding/android-build-ffmpeg-fdkaac.sh)是修改后的脚本，再次[编译FFmpeg库](http://www.1221.site/FFmpeg/01_FFmpeg%E7%BC%96%E8%AF%91.html)，重新生成.so动态库。

重新编译，发现错误，删除`--enable-gpl \`。
```
libfdk_aac is incompatible with the gpl and --enable-nonfree is not specified.
```
查看`ffmpeg-3.4/ffbuild/config.log`重新编译，发现错误：
```
/var/folders/vx/w486nkxn1dx05w199n5dl76m0000gn/T//ffconf.C7cXMk2x/test.o:test.c:function check_aacEncOpen: error: undefined reference to 'aacEncOpen'
collect2: error: ld returned 1 exit status
ERROR: libfdk_aac not found
```
哈哈，最后解决方案还是让我找到了，又耗费了几个小时，资料在这[mac下编译android下aac,不愿孤独-Mac 上用NDK编译lib库的问题 no archive symbol table (run ran lib)...](https://blog.csdn.net/weixin_31419249/article/details/117545210)。

解决方案是，手动调用$NDK_HOME/toolchains/arm-linux-androideabi-4.9/prebuilt/darwin-x86_64/bin/arm-linux-androideabi-runlib，对生成的.a进行接口的导出。
```
./arm-linux-androideabi-runlib libfdk-aac.a
```
经过这么一步，就可以顺利的执行支持fdk-aac的FFmpeg脚本（[android-build-ffmpeg-fdkaac.sh](https://gitee.com/learnany/ffmpeg/blob/master/07_ffmpeg_audio_encoding/android-build-ffmpeg-fdkaac.sh)）了。

注意：这里有个细节，在fdk-aac编译后的安装目录执行ranlib命令是无效的，所以我新建了`android_build_fdkaac2`文件夹，将lib和include文件夹复制进来，在执行ranlib命令就可以了，编译ffmpeg时指定fdk-aac的目录为`android_build_fdkaac2`即可。

#### 4. 解决问题（iOS）

这个问题在iOS上也是存在的，这里也列出解决步骤。

##### (1) 下载源码

[fdk-aac](https://www.linuxfromscratch.org/blfs/view/svn/multimedia/fdk-aac.html)。

我使用的是[fdk-aac-0.1.4.zip](https://gitee.com/learnany/ffmpeg/blob/master/07_ffmpeg_audio_encoding/fdk-aac-0.1.4.zip)。

注意：编译0.1.5是有问题。

##### (2) 编译fdk-aac

[ios-build-fdkaac.sh](https://gitee.com/learnany/ffmpeg/blob/master/07_ffmpeg_audio_encoding/ios-build-fdkaac.sh)是编译脚本，将编译脚本放在和源码的同一目录，执行：

```
sh ios-build-fdkaac.sh
```
出现错误：
```
configure: error: source directory already configured; run "make distclean" there first
make: *** No rule to make target `install'.  Stop.
```
根据提示，执行`make distclean`可以解决。

##### (3) 编译FFmpeg

修改iOS的FFmpeg库编译脚本，将fdkaac库其编译进去。[ios-build-ffmpeg.sh](https://gitee.com/learnany/ffmpeg/blob/master/01_ffmpeg_compiled/ios-build-ffmpeg.sh)是原来的编译脚本，在原来的编译脚本./configure增加如下选项。

```
# 以下是编译fdkaac库增加的
# 禁用所有编码器
--disable-encoders \
--enable-libfdk-aac \
--enable-encoder=libfdk_aac \
--enable-decoder=libfdk_aac \
# 和FFmpeg动态库一起编译，指定你之前编译好的fdkaac静态库和头文件
--extra-cflags="-I/Users/chenchangqing/Documents/code/ffmpeg/07_ffmpeg_audio_encoding/ios_build_fdkaac/include" \
--extra-ldflags="-L/Users/chenchangqing/Documents/code/ffmpeg/07_ffmpeg_audio_encoding/ios_build_fdkaac/lib" \
```
[ios-build-ffmpeg-fdkaac.sh](https://gitee.com/learnany/ffmpeg/blob/master/07_ffmpeg_audio_encoding/ios-build-ffmpeg-fdkaac.sh)是修改后的脚本，再次[编译FFmpeg库](http://www.1221.site/FFmpeg/01_FFmpeg%E7%BC%96%E8%AF%91.html)，重新生成.a静态库。
```
sh ios-build-ffmpeg-fdkaac.sh arm64
```

出现下面的错误，重新下载FFmpeg就可以解决了。
```
Out of tree builds are impossible with config.h in source dir.
```

注意：这里fdkaac和ffmpeg都指定了arm64的架构。

#### 5. 使用fdk-aac编码器

```c
// 错误
// AVCodec *avcodec = avcodec_find_encoder(avcodec_context->codec_id);
// 正确
AVCodec *avcodec = avcodec_find_encoder_by_name("libfdk_aac");
```
run工程，正常打开编码器。
```
I/main: 编码器名称为：libfdk_aac
```

### 第八步：写入文件头信息

```c
// 第八步：写入文件头信息
avformat_write_header(avformat_context, NULL);
```

### 第九步：打开pcm文件

```c
// 第九步：打开pcm文件
// 遇到问题：fopen Permission denied
const char *cinFilePath = env->GetStringUTFChars(in_file_path, NULL);
// iOS使用
// const char *cinFilePath = [inFilePath UTF8String];
int errNum = 0;
FILE *in_file = fopen(cinFilePath, "rb");
if (in_file == NULL) {
    errNum = errno;
    __android_log_print(ANDROID_LOG_INFO, "main", "文件不存在:%s,in_file:%s,errNum:%d,reason:%s", cinFilePath, in_file, errNum, strerror(errNum));
    // iOS使用
    // NSLog(@"文件不存在");
    return;
}
```

这一步有坑，打开pcm文件（fopen）一直出现“Permission denied”错误，困扰了有一天，最后还是没有找到很好的办法，但是有个临时解决办法，就是先执行音频解码为.pcm文件，这个时候去打开（fopen）刚生成的.pcm文件，是可以成功的。

### 第十步：音频编码准备

```c
// 第十步：音频编码准备
// 10.1 创建音频原始数据帧
// 作用：存储音频原始数据帧
AVFrame *av_frame = av_frame_alloc();
av_frame->nb_samples = avcodec_context->frame_size;
av_frame->format = avcodec_context->sample_fmt;

// 10.2 创建一个缓冲区
// 作用：用于缓存读取音频数据
// 先获取缓冲区大小
int buffer_size = av_samples_get_buffer_size(NULL,
                                                 avcodec_context->channels,
                                                 avcodec_context->frame_size,
                                                 avcodec_context->sample_fmt,
                                                 1);
// 创建一个缓冲区，作用是缓存一帧音频像素数据
uint8_t *out_buffer = (uint8_t *) av_malloc(buffer_size);

// 10.3 填充音频原始数据帧
avcodec_fill_audio_frame(av_frame,
                             avcodec_context->channels,
                             avcodec_context->sample_fmt,
                             (const uint8_t *)out_buffer,
                             buffer_size,
                             1);

// 10.4 创建压缩数据帧数据
// 作用：接收压缩数据帧数据
AVPacket *av_packet = (AVPacket *) av_malloc(buffer_size);
```

### 第十一步：循环读取视频像素数据

```c
// 第十一步：循环读取音频数据
// 编码是否成功
int result = 0;
int current_frame_index = 1;
int i = 0;
while (true) {
    // 从pcm文件里面读取缓冲区
    if (fread(out_buffer, 1, buffer_size, in_file) <= 0) {
        __android_log_print(ANDROID_LOG_INFO, "main", "读取完毕...");
        // iOS使用
        // NSLog(@"读取完毕...");
        break;
    } else if (feof(in_file)) {
        break;
    }

    // 将缓冲区数据转成AVFrame类型
    av_frame->data[0] = out_buffer;
    av_frame->pts = i;
    // 注意时间戳
    i++;

    // 第十二步：音频编码处理
    // ...
    current_frame_index++;
}
```

### 第十二步：音频编码处理

代码位置在第十一步。

```c
// 第十二步：音频编码处理
// 发送一帧音频数据
avcodec_send_frame(avcodec_context, av_frame);
if (result != 0) {
    __android_log_print(ANDROID_LOG_INFO, "main", "Failed to send frame!");
    // iOS使用
    // NSLog(@"Failed to send frame!", current_frame_index);
    return;
}
// 接收一帧音频数据，编码为音频压缩数据格式
result = avcodec_receive_packet(avcodec_context, av_packet);
// 判定是否编码成功
if (result == 0) {
    // 编码成功

    // 第十三步：将音频压缩数据写入到输出文件中
    // ...
} else {
    __android_log_print(ANDROID_LOG_INFO, "main", "编码第%d帧失败2", current_frame_index);
    // iOS使用
    // NSLog(@"编码第%d帧失败2", current_frame_index);
    return;
}
```

### 第十三步：将音频压缩数据写入到输出文件中

代码位置在第十二步。

```c
// 第十三步：将音频压缩数据写入到输出文件中
av_packet->stream_index = av_audio_stream->index;
result = av_write_frame(avformat_context, av_packet);
// 是否输出成功
if (result < 0) {
    __android_log_print(ANDROID_LOG_INFO, "main", "编码第%d帧失败", current_frame_index);
    // iOS使用
    // NSLog(@"编码第%d帧失败", current_frame_index);
    return;
} else {
    __android_log_print(ANDROID_LOG_INFO, "main", "编码第%d帧成功", current_frame_index);
    // iOS使用
    // NSLog(@"编码第%d帧成功", current_frame_index);
}
```

### 第十四步：写入剩余帧数据

增加`flush_encoder`方法：
```c
int flush_encoder(AVFormatContext *fmt_ctx, unsigned int stream_index) {
    int ret;
    int got_frame;
    AVPacket enc_pkt;
    if (!(fmt_ctx->streams[stream_index]->codec->codec->capabilities &
          CODEC_CAP_DELAY))
        return 0;
    while (1) {
        enc_pkt.data = NULL;
        enc_pkt.size = 0;
        av_init_packet(&enc_pkt);
        ret = avcodec_encode_audio2(fmt_ctx->streams[stream_index]->codec, &enc_pkt,
                                    NULL, &got_frame);
        av_frame_free(NULL);
        if (ret < 0)
            break;
        if (!got_frame) {
            ret = 0;
            break;
        }
        __android_log_print(ANDROID_LOG_INFO, "main", "Flush Encoder: Succeed to encode 1 frame!\tsize:%5d\n", enc_pkt.size);
        // iOS使用
        // NSLog(@"Flush Encoder: Succeed to encode 1 frame!\tsize:%5d\n", enc_pkt.size);
        /* mux encoded frame */
        ret = av_write_frame(fmt_ctx, &enc_pkt);
        if (ret < 0)
            break;
    }
    return ret;
}
```
调用`flush_encoder`方法：

```c
// 第十四步：写入剩余帧数据
// 作用：输出编码器中剩余AVPacket，可能没有
result = flush_encoder(avformat_context, 0);
if (result < 0) {
    __android_log_print(ANDROID_LOG_INFO, "main", "Flushing encoder failed!");
    // iOS使用
    // NSLog(@"Flushing encoder failed!");
}
```

### 第十五步：写入文件尾部信息

```c
// 第十五步：写入文件尾部信息
av_write_trailer(avformat_context);
```

### 第十六步：释放内存，关闭编码器

```c
// 第十六步：释放内存，关闭编码器
avcodec_close(avcodec_context);
av_free(av_frame);
av_free(out_buffer);
av_packet_free(&av_packet);
avio_close(avformat_context->pb);
avformat_free_context(avformat_context);
fclose(in_file);
```   

## 二、新建Android音频编码工程

### 1. 新建工程

参考之前[FFmpeg集成](http://www.1221.site/FFmpeg/02_FFmpeg%E9%9B%86%E6%88%90.html)，新建ndk工程AndroidFFmpegEncodingAudio。

### 2. 定义java方法

寻找MainActivity：app->src->main->java->MainActivity，增加代码如下：
```java
public native void ffmpegDecodeAudio(String inFilePath, String outFilePath);
public native void ffmpegEncodeAudio(String inFilePath, String outFilePath);
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
// 音频采样数据格式库
#include "libswresample/swresample.h"
}
```

在native-lib.cpp中新增java方法flush_encoder、ffmpegDecodeAudio、ffmpegEncodeVideo的C++实现，输入`MainActivity.`就会有代码提示，选择正确ffmepgEncodeAudio方法补全代码。

ffmpegDecodeAudio方法实现参考[FFmpeg视频解码](http://www.1221.site/FFmpeg/05_FFmpeg%E9%9F%B3%E9%A2%91%E8%A7%A3%E7%A0%81.html)。
```c
extern "C"
JNIEXPORT void JNICALL
Java_com_ccq_androidffmpegencodingaudio_MainActivity_ffmpegEncodeAudio(JNIEnv *env, jobject thiz,
                                                                       jstring in_file_path,
                                                                       jstring out_file_path) {
    // 这里拷贝上面的音频编码流程的代码即可。
}

extern "C"
JNIEXPORT void JNICALL
Java_com_ccq_androidffmpegencodingaudio_MainActivity_ffmpegDecodeAudio(JNIEnv *env, jobject thiz,
                                                                       jstring in_file_path,
                                                                       jstring out_file_path) {
}
``` 

## 三、测试Android音频编码工程

准备视频文件：[test.mov](https://gitee.com/learnany/ffmpeg/tree/master/resources/test.mov)

在AndroidManifest.xml增加SD卡的读写权限。

```
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

MainActivity增加测试代码，这里先进行视频解码，生成的.pcm文件后，直接对.pcm文件再进行编码。

注意：如果打开失败，可能读写存储设备的权限被禁用。

摩托罗拉·刀锋：设置->应用和通知->高级->权限管理器->隐私相关·读写存储设备->找到应用->如果禁用，则修改为允许。

```java
import android.os.Environment;
import java.io.File;
import java.io.IOException;
import android.util.Log;

private void ffmpegEncodeAudio() {
    // String rootPath = Environment.getExternalStorageDirectory().getAbsolutePath();
    String downloadPath = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS).getAbsolutePath();
    String inFilePath = downloadPath.concat("/test.pcm");
    // 错误，会导致程序崩溃
    // String outFilePath = downloadPath.concat("/test.aac");
    // 正确
    String outFilePath = downloadPath.concat("/test.aac");

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
    ffmpegEncodeAudio(inFilePath, outFilePath);
}

private void createAVLogFile() {
    // String rootPath = Environment.getExternalStorageDirectory().getAbsolutePath();
    String downloadPath = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS).getAbsolutePath();
    String logFilePath = downloadPath.concat("/av_log.txt");
    // 文件不存在我创建一个文件
    File file = new File(logFilePath);
    if (file.exists()) {
        Log.i("日志：","存在");
    } else {
        try {
            file.createNewFile();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}

private void ffmepgDecodeAudio() {
    // String rootPath = Environment.getExternalStorageDirectory().getAbsolutePath();
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
    ffmpegDecodeAudio(inFilePath, outFilePath);
}

ffmepgDecodeAudio();
createAVLogFile();
ffmpegEncodeAudio();
```
run工程代码，正确打印，同时正确生成.h264文件。
```
I/日志：: 存在
I/main: 解码器名称：aac
I/main: 当前解码第1帧
.
.
.
I/main: 当前解码第1036帧
I/日志：: 存在
I/main: 编码器名称为：libfdk_aac
I/main: Using AVStream.codec.time_base as a timebase hint to the muxer is deprecated. Set AVStream.time_base instead.
I/main: Using AVStream.codec to pass codec parameters to muxers is deprecated, use AVStream.codecpar instead.
I/main: 编码第1帧成功
.
.
.
I/main: 编码第1035帧成功
读取完毕...
I/main: Flush Encoder: Succeed to encode 1 frame!   size:  363
I/main: Flush Encoder: Succeed to encode 1 frame!   size:   95
I/main: Statistics: -2770196 seeks, -498852848 writeouts
```
[aac文件](https://gitee.com/learnany/ffmpeg/tree/master/resources/test.aac)播放：
```
ffplay test.aac
```

## 四、新建iOS视频编码工程

### 1. 新建工程

参考之前[FFmpeg集成](http://www.1221.site/FFmpeg/02_FFmpeg%E9%9B%86%E6%88%90.html)，新建ndk工程iOSFFmpegEncodingAudio。

注意：工程使用的是支持fdkacc编码的FFmpeg库文件。

### 2. 导入资源文件

资源文件就是音频解码后的.pcm文件。先将.pcm文件拷贝至工程目录下，再通过add files的方式加入工程。

### 3. 导入fdkacc静态库

在工程目录新建fdk-aac，拷贝编译好的ios_build_fdkaac/thin文件夹至fdkaac-0.1.4目录，只保留arm64的文件夹，删除lib文件夹中的pkgconfig和libfdk-aac.la，再通过add files的方式加入工程。

配置fdkaac头文件，参考[FFmpeg集成](http://www.1221.site/FFmpeg/02_FFmpeg%E9%9B%86%E6%88%90.html)。

### 4. 增加音编码方法

#### (1) 导入FFmpeg头文件

修改`FFmpegTest.h`，新增如下：
```c
//核心库
#include "libavcodec/avcodec.h"
//封装格式处理库
#include "libavformat/avformat.h"
//工具库
#include "libavutil/imgutils.h"
#include "libswresample/swresample.h"
```

#### (2) 新增音频编码方法

修改`FFmpegTest.h`，新增如下：
```c
/// FFmpeg音频编码
+ (void)ffmpegAudioEncode: (NSString *)inFilePath outFilePath: (NSString *)outFilePath;
```
修改`FFmpegTest.m`，新增如下：
```c
+ (void)ffmpegAudioEncode: (NSString *)inFilePath outFilePath: (NSString *)outFilePath {
    // 代码复制音频编码流程中的代码
    // 将备注`iOS使用`的代码打开
}
```

#### (3) 增加方法测试

修改ViewController.m，新增测试代码如下：
```c
NSString* inPath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"pcm"];
NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                     
                                                     NSUserDomainMask, YES);
NSString* path = [paths objectAtIndex:0];
NSString* tmpPath = [path stringByAppendingPathComponent:@"temp"];
[[NSFileManager defaultManager] createDirectoryAtPath:tmpPath withIntermediateDirectories:YES attributes:nil error:NULL];
NSString* outFilePath = [tmpPath stringByAppendingPathComponent:[NSString stringWithFormat:@"test.aac"]];
[FFmpegTest ffmpegAudioEncode:inPath outFilePath:outFilePath];
```
run工程代码，正确打印，同时正确生成.aac文件。