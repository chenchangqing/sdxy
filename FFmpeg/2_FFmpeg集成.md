# 2.FFmpeg集成

[FFmpegCompiled](https://gitee.com/learnany/ffmpeg.git)

工程路径：02 FFmpeg集成/FFmpegCompiled。

库文件路径：01 FFmpeg编译/FFmpeg-3.4。

工程默认没有库文件，需要自己拷贝到工程。

## 一、iOS集成FFmpeg

### 1. 集成FFmpeg

测试我们自己编译库FFmpeg。

#### (1) 第一步：新建工程

删除Scenedelegate，参考：[Xcode 11新建项目多了Scenedelegate](https://www.jianshu.com/p/25b37bd40cd7)。

#### (2) 第二步：导入库文件。

在工程新建FFmpeg-3.4，拷贝已经编译好的arm64静态库文件夹，删除不需要的share、lib/pkgconfig文件夹，最后将FFmpeg-3.4Add进入工程。

#### (3）第三步：添加依赖库

- CoreMedia.framework
- CorGraphics.framework
- VideoToolbox.framework
- AudioToolbox.framework
- libiconv.tbd 
- libz.tbd 
- libbz2.tbd 

#### (4) 配置头文件

1) 复制头文件路径

选中Target>Build Setting>搜索Library Search>双击Library Search Paths复制FFmpeg lib路径>修改lib为include就是FFmpeg头文件路径：

$(PROJECT_DIR)/FFmpegCompiled/FFmpeg-3.4/arm64/include。

2) 配置头文件路径

选中Target>Build Setting>搜索Header Search>选中Header Search Paths>增加上面复制好头文件路径。

#### (5) 编译成功

### 2. 测试案例

#### (1) 打印配置信息

新建FFmpegTest测试类，增加类方法：
```c
// 引入头文件
// 核心库->音视频编解码库
#import <libavcodec/avcodec.h>

/// 测试FFmpeg配置
+ (void)ffmpegTestConfig {
    const char *configuration = avcodec_configuration();
    NSLog(@"配置信息: %s", configuration);
}
```
在ViewController中测试：
```c
#import "FFmpegTest.h"

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //测试一
    [FFmpegTest ffmpegTestConfig];
}
```
console输出：
```
配置信息: --target-os=darwin --arch=arm64 --cc='xcrun -sdk iphoneos clang' --as='gas-preprocessor.pl -arch aarch64 -- xcrun -sdk iphoneos clang' --enable-cross-compile --disable-debug --disable-programs --disable-doc --enable-pic --extra-cflags='-arch arm64 -mios-version-min=7.0 -fembed-bitcode' --extra-ldflags='-arch arm64 -mios-version-min=7.0 -fembed-bitcode' --prefix=/Users/chenchangqing/Documents/FFmpeg/ffmpeg-3.4-target-iOS/arm64
```

#### (2) 打开视频文件

FFmpegTest增加类方法：
```c
// 导入封装格式库
#import <libavformat/avformat.h>

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
项目新增视频Test.mov，在ViewController中测试：
```c
// 测试二
NSString *path = [[NSBundle mainBundle] pathForResource:@"Test" ofType:@".mov"];
[FFmpegTest ffmpegVideoOpenfile:path];
```
console输出：
```
打开文件成功
```
## 二、Android集成FFmpeg

**未完待续**