# iOS集成FFmpeg

[代码工程](https://gitee.com/learnany/ffmpeg/tree/master/02_ffmpeg_integrated/iOSIntegrationWithFFmpeg)

## 下载FFmpeg源码

ffmpeg-3.4下载脚本：[download-ffmpeg.sh](https://gitee.com/learnany/ffmpeg/blob/master/01_ffmpeg_compiled/download-ffmpeg.sh)。

```
sh download-ffmpeg.sh
```

## 安装gas-preprocessor

ffmpeg-3.4对应的[gas-preprocessor.pl](https://gitee.com/learnany/ffmpeg/blob/master/01_ffmpeg_compiled/gas-preprocessor.pl)。

```
cd gas-preprocessor directory
sudo cp -f gas-preprocessor.pl /usr/local/bin/
chmod 777 /usr/local/bin/gas-preprocessor.pl
```

>注意：使用Github最新的[gas-preprocessor.pl](https://github.com/libav/gas-preprocessor)编译FFmpeg，报错"GNU assembler not found, install/update gas-preprocessor"，所以使用指定版本的`gas-preprocessor`。

## 编译FFmpeg

ffmpeg-3.4编译脚本：[ios-build-ffmpeg.sh](https://gitee.com/learnany/ffmpeg/blob/master/01_ffmpeg_compiled/ios-build-ffmpeg.sh)，将编译脚本放在和源码的同一目录。

默认分别编译arm64、armv7、i386、x86_64，代码如下：
```
sh ios-build-ffmpeg.sh
```
指定架构编译，可以指定arm64、armv7、i386、x86_64，代码如下：
```
sh ios-build-ffmpeg.sh arm64
```
指定armv7编译时出现问题，待解决：
```
AS  libavcodec/arm/aacpsdsp_neon.o
src/libavutil/arm/asm.S:50:9: error: unknown directive
        .arch armv7-a
        ^
make: *** [libavcodec/arm/aacpsdsp_neon.o] Error 1
make: *** Waiting for unfinished jobs....
```

## 新建工程

删除Scenedelegate，参考：[Xcode 11新建项目多了Scenedelegate](https://www.jianshu.com/p/25b37bd40cd7)。

## 导入库文件

在工程目录新建FFmpeg-3.4，拷贝已经编译好的arm64静态库文件夹至FFmpeg-3.4，删除不需要的share、lib/pkgconfig文件夹，最后将FFmpeg-3.4通过Add Files加入工程。

## 配置头文件

1) 复制头文件路径

选中Target>Build Setting>搜索Library Search>双击Library Search Paths复制FFmpeg lib路径>修改lib为include就是FFmpeg头文件路径：
```
$(PROJECT_DIR)/iOSIntegrationWithFFmpeg（工程名）/FFmpeg-3.4/arm64/include
```

2) 配置头文件路径

选中Target>Build Setting>搜索Header Search>选中Header Search Paths>增加上面复制好头文件路径。

## 添加依赖库

- CoreMedia.framework
- CoreGraphics.framework
- VideoToolbox.framework
- AudioToolbox.framework
- libiconv.tbd 
- libz.tbd 
- libbz2.tbd 

添加完毕，编译成功。

## 简单测试

下载[test.mov](https://gitee.com/learnany/ffmpeg/blob/master/resources/test.mov)，加入工程，新建测试类`FFmpegTest`，`FFmpegTest.h`增加方法定义。
```c
/// 测试FFmpeg配置
+ (void)ffmpegTestConfig;

/// 打开视频文件
+ (void)ffmpegVideoOpenfile:(NSString*)filePath;
```
`FFmpegTest.m`引入FFmpeg头文件。
```c
// 核心库->音视频编解码库
#import <libavcodec/avcodec.h>
// 导入封装格式库
#import <libavformat/avformat.h>
```
`FFmpegTest.m`增加方法实现。
```c
/// 测试FFmpeg配置
+ (void)ffmpegTestConfig {
    const char *configuration = avcodec_configuration();
    NSLog(@"配置信息: %s", configuration);
}

/// 打开视频文件
+ (void)ffmpegVideoOpenfile:(NSString*)filePath {
    // 第一步：注册组件
    av_register_all();
    // 第二步：打开封装格式文件
    // 参数一：封装格式上下文
    AVFormatContext* avformat_context = avformat_alloc_context();
    // 参数二：打开视频地址->path
    const char *url = [filePath UTF8String];
    // 参数三：指定输入封装格式->默认格式
    // 参数四：指定默认配置信息->默认配置
    int avformat_open_input_reuslt = avformat_open_input(&avformat_context, url, NULL, NULL);
    if (avformat_open_input_reuslt != 0){
        // 失败了
        // 获取错误信息
        // char* error_info = NULL;
        // av_strerror(avformat_open_input_reuslt, error_info, 1024);
        NSLog(@"打开文件失败");
        return;
    }
    
    NSLog(@"打开文件成功");
}
```
在`ViewController`引入`FFmpegTest.h`头文件。
```c
#import "FFmpegTest.h"
```
在`ViewController`的`viewDidLoad`加入方法调用。
```c
// 测试一
[FFmpegTest ffmpegTestConfig];
// 测试二
NSString *path = [[NSBundle mainBundle] pathForResource:@"Test" ofType:@".mov"];
[FFmpegTest ffmpegVideoOpenfile:path];
```
run工程，console正确输出。
```
2022-05-08 01:32:12.320527+0800 iOSIntegrationWithFFmpeg[34898:1017443] 配置信息: --target-os=darwin --arch=arm64 --cc='xcrun -sdk iphoneos clang' --as='gas-preprocessor.pl -arch aarch64 -- xcrun -sdk iphoneos clang' --enable-cross-compile --disable-debug --disable-programs --disable-doc --enable-pic --extra-cflags='-arch arm64 -mios-version-min=7.0 -fembed-bitcode' --extra-ldflags='-arch arm64 -mios-version-min=7.0 -fembed-bitcode' --prefix=/Users/chenchangqing/Documents/code/ffmpeg/01_ffmpeg_compiled/ios_build/arm64
2022-05-08 01:32:12.338556+0800 iOSIntegrationWithFFmpeg[34898:1017443] 打开文件成功
```