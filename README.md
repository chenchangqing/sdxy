# FFmpeg视频编码

## 一、音频编码流程

<img src="../images/ffmpeg_06_1.jpeg" width=100%/>

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
AVOutputFormat *avoutput_format = av_guess_format(NULL, coutFilePath, NULL);
设置视频压缩数据格式类型(h264、h265、mpeg2等等...)
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
    return;
}
```

### 第四步：创建输出码流

```c
// 第四步：创建输出码流
// 注意：创建了一块内存空间，并不知道他是什么类型流，希望他是视频流
AVStream *av_video_stream = avformat_new_stream(avformat_context, NULL);
```

### 第五步：初始化编码器上下文

#### 1. 获取编码器上下文

```c
// 5.1 获取编码器上下文
AVCodecContext *avcodec_context = av_video_stream->codec;
```

#### 2. 设置视频编码器ID

```c
// 5.2 设置视频编码器ID
avcodec_context->codec_id = avoutput_format->video_codec;
```

#### 3. 设置为视频编码器

```c
// 5.3 设置为视频编码器
avcodec_context->codec_type = AVMEDIA_TYPE_VIDEO;
```

#### 4. 设置像素数据格式

```c
// 5.4 设置像素数据格式
// 编码的是像素数据格式，视频像素数据格式为YUV420P(YUV422P、YUV444P等等...)
// 注意：这个类型是根据你解码的时候指定的解码的视频像素数据格式类型
avcodec_context->pix_fmt = AV_PIX_FMT_YUV420P;
```

#### 5. 设置视频尺寸

```c
// 5.5 设置视频尺寸
avcodec_context->width = 640;
avcodec_context->height = 352;
```

#### 6. 设置视频帧率

```c
// 5.6 设置视频帧率
// 视频帧率：25fps（每秒25帧）
// 单位：fps，"f"表示帧数，"ps"表示每秒
avcodec_context->time_base.num = 1;
avcodec_context->time_base.den = 25;
```

#### 7. 设置视频码率

```c
// 5.7 设置视频码率

//（1）什么是码率？
// 含义：每秒传送的比特(bit)数单位为 bps(Bit Per Second)，比特率越高，传送数据速度越快。
// 单位：bps，"b"表示数据量，"ps"表示每秒。

//（2）什么是视频码率?
// 含义：视频码率就是数据传输时单位时间传送的数据位数，一般我们用的单位是kbps即千位每秒。

//（3）视频码率计算如下？
// 基本的算法是：码率（kbps）= 视频大小 - 音频大小（bit位）/ 时间（秒）。
// 例如：Test.mov时间 = 24秒，文件大小（视频+音频） = 1.73MB。
// 视频大小 = 1.34MB（文件占比：77%）= 1.34MB * 1024 * 1024 * 8 / 24 = 字节大小 = 468365字节 = 468Kbps。
// 音频大小 = 376KB（文件占比：21%）。
// 计算出来的码率 : 468Kbps，K表示1000，b表示位（bit）。
// 总结：码率越大，视频越大。
avcodec_context->bit_rate = 468000;
```

#### 8. 设置GOP

```c
// 5.8 设置GOP
// 影响到视频质量问题，是一组连续画面

//（1）MPEG格式画面类型
// 3种类型：I帧、P帧、B帧。

//（2）I帧：
// 内部编码帧，是原始帧（原始视频数据）
// 是完整画面，是关键帧（必需的有，如果没有I，那么你无法进行编码，解码）。
// 视频第1帧：视频序列中的第一个帧始终都是I帧，因为它是关键帧。

//（3）P帧
// 向前预测帧
// 预测前面的一帧类型，处理前面的一阵数据(->I帧、B帧)。
// P帧数据根据前面的一帧数据进行处理得到了P帧。

//（4）B帧
// 前后预测帧（双向预测帧），前面一帧和后面一帧的差别。
// B帧压缩率高，但是对解码性能要求较高。

//（5）总结
// I只需要考虑自己 = 1帧，P帧考虑自己+前面一帧 = 2帧，B帧考虑自己+前后帧 = 3帧
// 说白了，P帧和B帧是对I帧压缩。
// 每250帧，插入1个I帧，I帧越少，视频越小
avcodec_context->gop_size = 250;
```

#### 9. 设置量化参数

```c
// 5.9 设置量化参数
// 数学算法（高级算法），量化系数越小，视频越是清晰
// 一般情况下都是默认值，最小量化系数默认值是10，最大量化系数默认值是51
avcodec_context->qmin = 10;
avcodec_context->qmax = 51;
```

#### 10. 设置b帧最大值

```c
// 5.10 设置b帧最大值
// 设置不需要B帧
avcodec_context->max_b_frames = 0;
```

### 第六步：查找视频编码器

```c
AVCodec *avcodec = avcodec_find_encoder(avcodec_context->codec_id);
if (avcodec == NULL) {
    __android_log_print(ANDROID_LOG_INFO, "main", "找不到编码器");
    return;
}

__android_log_print(ANDROID_LOG_INFO, "main", "编码器名称为：%s", avcodec->name);
```

#### 1. 出现问题

新建测试工程（稍后会介绍建工程测试），代码运行到这一步会出现“找不到编码器”，因为编译库没有依赖x264库（默认情况下FFmpeg没有编译进行h264库）。

#### 2. 解决问题

##### (1) 下载源码

[x264库](https://www.videolan.org/developers/x264.html)，翻墙更快。

```
git clone https://code.videolan.org/videolan/x264.git
```

##### (2) 下载ndk

https://developer.android.google.cn/ndk/downloads/older_releases.html

我这里使用的是[ndkr10e](https://dl.google.com/android/repository/android-ndk-r10e-darwin-x86_64.zip?hl=zh-cn)。

在x264源码的同目录下新建ndk文件交，将下载好的ndk放入ndk文件夹。

##### (3) 编译x264脚本

编译x264的.a静态库，指定编译平台类型：iOS平台、安卓平台、Mac平台、Windows平台等等。

[android_build_x264.sh](https://gitee.com/learnany/ffmpeg/blob/master/06_ffmpeg_video_encoding/android-build-x264.sh)是编译脚本，将编译脚本放在和源码的同一目录，执行：

```
sh android-build-x264.sh
```
执行过程会提示开机密码，看到`Android h264 builds finished`说明编译成功。

##### (4) 编译Android动态库

修改FFmpeg动态库编译脚本，将x264库其编译进去。[ios-build-ffmpeg.sh](https://gitee.com/learnany/ffmpeg/blob/master/01_ffmpeg_compiled/ios-build-ffmpeg.sh)是原来的编译脚本，在原来的编译脚本./configure增加如下选项。

```
# 以下是编译x264库增加的

# 禁用所有编码器
--disable-encoders \
# 通过libx264库启用H.264编码
--enable-libx264 \
# 启用编码器名称
--enable-encoder=libx264 \
# 启用几个图片编码，由于生成视频预览
--enable-encoder=mjpeg \
--enable-encoder=png \
#和FFmpeg动态库一起编译，指定你之前编译好的x264静态库和头文件
--extra-cflags="-I/Users/chenchangqing/Documents/code/ffmpeg/06_ffmpeg_video_encoding/android_build_x264/include" \
--extra-ldflags="-L/Users/chenchangqing/Documents/code/ffmpeg/06_ffmpeg_video_encoding/android_build_x264/lib" \
```
[android-build-ffmpeg-x264.sh](https://gitee.com/learnany/ffmpeg/blob/master/06_ffmpeg_video_encoding/android-build-ffmpeg-x264.sh)是修改后的脚本，再次[编译FFmpeg库](http://www.1221.site/FFmpeg/01_FFmpeg%E7%BC%96%E8%AF%91.html)，重新生成.so动态库。

重新编译，发现错误：
```
libavcodec/libx264.c: In function 'X264_frame':
libavcodec/libx264.c:282:9: error: 'x264_bit_depth' undeclared (first use in this function)
     if (x264_bit_depth > 8)
         ^
libavcodec/libx264.c:282:9: note: each undeclared identifier is reported only once for each function it appears in
libavcodec/libx264.c: In function 'X264_init_static':
libavcodec/libx264.c:892:9: error: 'x264_bit_depth' undeclared (first use in this function)
     if (x264_bit_depth == 8)
         ^
make: *** [libavcodec/libx264.o] Error 1
```
查询资料（[“x264_bit_depth”未声明](https://serverok.in/error-x264_bit_depth-undeclared)），是因为ffmpeg和x264不兼容，这里不使用最新版本的x264，尝试另一个版本的[x264](https://gitee.com/learnany/ffmpeg/blob/master/06_ffmpeg_video_encoding/x264.zip)，重新编译x264，再重新生成.so动态库。

再次运行测试工程，成功输出：
```
I/main: 编码器名称为：libx264
```
问题解决。

<div style="margin: 0px;">
    <a href="#" target="_self"><img src="https://api.azpay.cn/808/1.png"
            style="height: 20px;">沪ICP备2022002183号-1</a >
</div>

