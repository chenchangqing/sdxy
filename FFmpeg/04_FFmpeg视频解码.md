# 4.FFmpeg视频解码

[代码工程](https://gitee.com/learnany/ffmpeg/tree/master/04_ffmpeg_decoding/AndroidFFmpegDecodingVideo)

## 一、视频解码流程

### 1. 注册组件

例如：编码器、解码器等等。

```
av_register_all();
```

### 2. 打开封装格式（打开文件）

例如：.mp4、.mov、.wmv文件等等。
```
avformat_open_input();
```

### 3. 查找视频流

如果是视频解码，那么查找视频流，如果是音频解码，那么就查找音频流。

```
avformat_find_stream_info();
```

### 4. 查找视频解码器

(1) 查找视频流索引位置。

(2) 根据视频流索引，获取解码器上下文。

(3) 根据解码器上下文，获得解码器ID，然后查找解码器。

### 5. 打开解码器
```
avcodec_open2();
```

### 6. 读取视频压缩数据

循环读取，每读取一帧数据，立马解码一帧数据。

### 7. 视频解码

播放视频，得到视频像素数据。

### 8. 关闭解码器，解码完成

## 二、android代码实现

### 1. 新建工程

参考之前[FFmpeg集成](http://www.1221.site/FFmpeg/02_FFmpeg%E9%9B%86%E6%88%90.html)，新建ndk工程AndroidFFmpegDecodingVideo。

### 2. 定义java方法

寻找MainActivity：app->src->main->java->MainActivity，增加代码如下：
```java
public native void ffmepgDecodeVideo(String inFilePath, String outFilePath);
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
}
```

在native-lib.cpp中新增java方法ffmepgDecodeVideo的C++实现，输入`MainActivity.`就会有代码提示，选择正确ffmepgDecodeVideo方法补全代码。
```c
extern "C"
JNIEXPORT void JNICALL
Java_com_ccq_androidffmpegdecodingvideo_MainActivity_ffmepgDecodeVideo(JNIEnv *env, jobject thiz,
                                                                       jstring in_file_path,
                                                                       jstring out_file_path) {
    // TODO: implement ffmepgDecodeVideo()
}
```

## 三、NDK方法实现

### 第一步：注册组件

```c
// 第一步：注册组件
av_register_all();
```

### 第二步：打开封装格式（打开文件）

```c
// 第二步：打开封装格式（打开文件）

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

### 第三步：查找视频流

```c
// 第三步：查找视频流->拿到视频信息
// 参数一：封装格式上下文
// 参数二：指定默认配置
int avformat_find_stream_info_result = avformat_find_stream_info(avformat_context, NULL);
if (avformat_find_stream_info_result < 0){
    __android_log_print(ANDROID_LOG_INFO, "main", "查找失败");
    return;
}
```

### 第四步：查找视频解码器

```c
// 第四步：查找视频解码器
// 1、查找视频流索引位置
int av_stream_index = -1;
for (int i = 0; i < avformat_context->nb_streams; ++i) {
    // 判断流类型：视频流、音频流、字母流等等...
    if (avformat_context->streams[i]->codec->codec_type == AVMEDIA_TYPE_VIDEO){
        av_stream_index = i;
        break;
    }
}
// 2、根据视频流索引，获取解码器上下文
AVCodecContext *avcodec_context = avformat_context->streams[av_stream_index]->codec;
// 3、根据解码器上下文，获得解码器ID，然后查找解码器
AVCodec *avcodec = avcodec_find_decoder(avcodec_context->codec_id);
```

### 第五步：打开解码器

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

### 第六步：读取视频压缩数据

```c
// 1、分析av_read_frame参数
// 参数一：封装格式上下文
// 参数二：一帧压缩数据 = 一张图片
// av_read_frame()
// 结构体大小计算：字节对齐原则
AVPacket* packet = (AVPacket*)av_malloc(sizeof(AVPacket));

// 3.2 解码一帧视频压缩数据->进行解码(作用：用于解码操作)
// 开辟一块内存空间
AVFrame* avframe_in = av_frame_alloc();
int decode_result = 0;

// 4、注意：在这里我们不能够保证解码出来的一帧视频像素数据格式是yuv格式
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

// 4.1 创建一个yuv420视频像素数据格式缓冲区(一帧数据)
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

// 4.2 开辟一块内存空间
uint8_t *out_buffer = (uint8_t *)av_malloc(buffer_size);
// 4.3 向avframe_yuv420p->填充数据
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

int y_size, u_size, v_size;

// 5.2 将yuv420p数据写入.yuv文件中
// 打开写入文件
const char *outfile = env->GetStringUTFChars(out_file_path, NULL);
FILE* file_yuv420p = fopen(outfile, "wb+");
if (file_yuv420p == NULL){
    __android_log_print(ANDROID_LOG_INFO, "main", "输出文件打开失败");
    return;
}

int current_index = 0;
while (av_read_frame(avformat_context, packet) >= 0) {
    // >=:读取到了
    // <0:读取错误或者读取完毕
    // 2、是否是我们的视频流
    if (packet->stream_index == av_stream_index) {
        // 3、解码一帧压缩数据->得到视频像素数据->yuv格式
        // 采用新的API
        // 3.1 发送一帧视频压缩数据
        avcodec_send_packet(avcodec_context, packet);
        // 3.2 解码一帧视频压缩数据->进行解码(作用：用于解码操作)
        decode_result = avcodec_receive_frame(avcodec_context, avframe_in);
        if (decode_result == 0) {
            // 解码成功
            // 4、注意：在这里我们不能够保证解码出来的一帧视频像素数据格式是yuv格式
            // 视频像素数据格式很多种类型: yuv420P、yuv422p、yuv444p等等...
            // 保证：我的解码后的视频像素数据格式统一为yuv420P->通用的格式
            // 进行类型转换: 将解码出来的视频像素点数据格式->统一转类型为yuv420P
            // sws_scale作用：进行类型转换的
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
            // 方式一：直接显示视频上面去
            // 方式二：写入yuv文件格式
            // 5、将yuv420p数据写入.yuv文件中
            // 5.1 计算YUV大小
            // 分析一下原理?
            // Y表示：亮度
            // UV表示：色度
            // 有规律
            // YUV420P格式规范一：Y结构表示一个像素(一个像素对应一个Y)
            // YUV420P格式规范二：4个像素点对应一个(U和V: 4Y = U = V)
            y_size = avcodec_context->width * avcodec_context->height;
            u_size = y_size / 4;
            v_size = y_size / 4;
            // 5.2 写入.yuv文件
            // 首先->Y数据
            fwrite(avframe_yuv420p->data[0], 1, y_size, file_yuv420p);
            // 其次->U数据
            fwrite(avframe_yuv420p->data[1], 1, u_size, file_yuv420p);
            // 再其次->V数据
            fwrite(avframe_yuv420p->data[2], 1, v_size, file_yuv420p);

            current_index++;
            __android_log_print(ANDROID_LOG_INFO, "main", "当前解码第%d帧", current_index);
        }
    }
}

// 第八步：释放内存资源，关闭解码器
av_packet_free(&packet);
fclose(file_yuv420p);
av_frame_free(&avframe_in);
av_frame_free(&avframe_yuv420p);
free(out_buffer);
avcodec_close(avcodec_context);
avformat_free_context(avformat_context);
```

### 视频解码测试

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
String inFilePath = rootPath.concat("/DCIM/Camera/VID_20220220_181306412.mp4");
String downloadPath = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS).getAbsolutePath();
String outFilePath = downloadPath.concat("/VID_20220220_181306412.yuv");

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
ffmepgDecodeVideo(inFilePath, outFilePath);
```
出现问题，待解决：
```
I/main: 解码器名称：h264
A/libc: Fatal signal 6 (SIGABRT), code -1 (SI_QUEUE) in tid 5713 (egdecodingvideo), pid 5713 (egdecodingvideo)
```