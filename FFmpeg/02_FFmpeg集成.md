# 2.FFmpeg集成

## 一、iOS集成FFmpeg

[代码工程](https://gitee.com/learnany/ffmpeg/tree/master/02_ffmpeg_integrated/FFmpegCompiled/FFmpegCompiled)

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

[代码工程](https://gitee.com/learnany/ffmpeg/tree/master/02_ffmpeg_integrated/AndroidFFmpegCompiled)

### 1. 集成FFmpeg

#### (1) 第一步：新建工程

File->NewProject->Native C++->输入工程信息->Next->Finish。

[三星手机开启开发者选项](https://publish.samsungsimulator.com/simulator/5e9b6c53-0b1e-499b-8096-9e3bb39502b8/#!topic)

#### (2) 第二步：导入库文件。

1) 项目选中Project模式->app->src->main->右键new->Directory->输入jniLibs->enter。

2) 将准备好的库文件copy->选中刚才新建的jniLibs->paste。

#### (3) 第三步：修改CMakeLists.txt

1) app->src->main->cpp->双击CMakeLists.txt。

2) 修改CMakeLists.txt。
```c
# FFMpeg配置
# FFmpeg配置目录
set(JNILIBS_DIR ${CMAKE_SOURCE_DIR}/../jniLibs)

# 编解码(最重要的库)
add_library(
        avcodec
        SHARED
        IMPORTED)
set_target_properties(
        avcodec
        PROPERTIES IMPORTED_LOCATION
        ${JNILIBS_DIR}/lib/libavcodec.so)

# 滤镜特效处理库
add_library(
        avfilter
        SHARED
        IMPORTED)
set_target_properties(
        avfilter
        PROPERTIES IMPORTED_LOCATION
        ${JNILIBS_DIR}/lib/libavfilter.so)

# 封装格式处理库
add_library(
        avformat
        SHARED
        IMPORTED)
set_target_properties(
        avformat
        PROPERTIES IMPORTED_LOCATION
        ${JNILIBS_DIR}/lib/libavformat.so)

# 工具库(大部分库都需要这个库的支持)
add_library(
        avutil
        SHARED
        IMPORTED)
set_target_properties(
        avutil
        PROPERTIES IMPORTED_LOCATION
        ${JNILIBS_DIR}/lib/libavutil.so)

# 音频采样数据格式转换库
add_library(
        swresample
        SHARED
        IMPORTED)
set_target_properties(
        swresample
        PROPERTIES IMPORTED_LOCATION
        ${JNILIBS_DIR}/lib/libswresample.so)

# 视频像素数据格式转换
add_library(
        swscale
        SHARED
        IMPORTED)
set_target_properties(
        swscale
        PROPERTIES IMPORTED_LOCATION
        ${JNILIBS_DIR}/lib/libswscale.so)

add_library(
        avdevice
        SHARED
        IMPORTED)
set_target_properties(
        avdevice
        PROPERTIES IMPORTED_LOCATION
        ${JNILIBS_DIR}/lib/libavdevice.so)

add_library(
        postproc
        SHARED
        IMPORTED)
set_target_properties(
        postproc
        PROPERTIES IMPORTED_LOCATION
        ${JNILIBS_DIR}/lib/libpostproc.so)

#set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=gnu++11")
#判断编译器类型,如果是gcc编译器,则在编译选项中加入c++11支持
if(CMAKE_COMPILER_IS_GNUCXX)
    set(CMAKE_CXX_FLAGS "-std=c++11 ${CMAKE_CXX_FLAGS}")
    message(STATUS "optional:-std=c++11")
endif(CMAKE_COMPILER_IS_GNUCXX)

#配置编译的头文件
include_directories(${JNILIBS_DIR}/include)

.
.
.

target_link_libraries( # Specifies the target library.
        myapplication avcodec swresample avfilter avformat avutil swscale avdevice postproc

        # Links the target library to the log library
        # included in the NDK.
        ${log-lib})
```
#### (4) 配置CPU架构类型

修改app->build.gradle：
```c
externalNativeBuild {
    cmake {
        cppFlags ''
        abiFilters 'armeabi'
    }
}
```
发现编译失败，解决方法，修改为如下(
[参考链接](https://blog.csdn.net/mqdxiaoxiao/article/details/99477072))：
```
defaultConfig {
    ndk {
        abiFilters 'armeabi-v7a'
    }
}
```

#### (5) 编译成功

### 2. 测试案例

#### (1) 打印配置信息

##### 1) 定义Java方法

新建Java类FFmpegTest，定义ffmpegTestConfig方法：
```java
// 测试FFmpeg配置
// native：标记这个方法是一个特殊方法，不是普通的java方法，而是用于与NDK进行交互的方法（C/C++语言交互）
// 用native修饰方法，方法没有实现，具体的实现在C/C++里面。
public static native void ffmpegTestConfig();
```
##### 2) 定义NDK方法

在native-lib.cpp中，导入FFmpeg头文件，由于 FFmpeg 是使用 C 语言编写的，所在 C++ 文件中引用 #include 的时候，也需要包裹在 extern "C" { }，才能正确的编译。
```c
#import <android/log.h>
extern "C" {
// 引入头文件
// 核心库->音视频编解码库
#include <libavcodec/avcodec.h>
}
```
在native-lib.cpp中新增Java方法ffmpegTestConfig的C++实现。
```c
extern "C" 
JNIEXPORT void JNICALL
Java_com_ccq_androidffmpegcompiled_FFmpegTest_ffmpegTestConfig(JNIEnv *env, jclass clazz) {
    const char *configuration = avcodec_configuration();
    __android_log_print(ANDROID_LOG_INFO, "ffmpeg configuration", "%s", configuration);
}
```
之所以可以这么写是因为在CMakeLists.txt中有如下配置，将Java和C/C++进行关联。
```
add_library( # Sets the name of the library.
        androidffmpegcompiled

        # Sets the library as a shared library.
        SHARED

        # Provides a relative path to your source file(s).
        native-lib.cpp)
```
##### 3) MainActivity增加测试代码。
```
protected void onCreate(Bundle savedInstanceState) {
        ...
        FFmpegTest.ffmpegTestConfig();
}
```
##### 4) 运行工程，正确打印。
```
I/ffmpeg configuration: --prefix=/Users/chenchangqing/Documents/code/ffmpeg/01_ffmpeg_compiled/ffmpeg-3.4-target-android/armeabi-v7a --enable-shared --enable-gpl --disable-static --disable-doc --disable-ffmpeg --disable-ffplay --disable-ffprobe --disable-ffserver --disable-doc --disable-symver --enable-small --cross-prefix=/Users/chenchangqing/Documents/code/ffmpeg/01_ffmpeg_compiled/ndk/android-ndk-r10e/toolchains/arm-linux-androideabi-4.9/prebuilt/darwin-x86_64/bin/arm-linux-androideabi- --target-os=android --arch=armeabi-v7a --enable-cross-compile --sysroot=/Users/chenchangqing/Documents/code/ffmpeg/01_ffmpeg_compiled/ndk/android-ndk-r10e/platforms/android-18/arch-arm --extra-cflags='-Os -fpic -marm' --enable-pic
```
#### (2) 打开视频文件

##### 1) 定义Java方法

FFmpegTest定义ffmpegVideoOpenFile方法：
```java
// 测试FFmpeg打开视频
// filePath:路径
public static native void ffmpegVideoOpenFile(String filePath);
```

##### 2) 定义NDK方法

在native-lib.cpp中，导入FFmpeg头文件。
```c
#import <android/log.h>
extern "C" {
// 引入头文件
// 核心库->音视频编解码库
#include <libavcodec/avcodec.h>
// 导入封装格式库
#import <libavformat/avformat.h>
}
```
在native-lib.cpp中新增Java方法ffmpegVideoOpenFile的C++实现。
```c
extern "C"
JNIEXPORT void JNICALL
Java_com_ccq_androidffmpegcompiled_FFmpegTest_ffmpegVideoOpenFile(JNIEnv *env, jclass clazz,
                                                                  jstring file_path) {
    // 第一步：注册组件
    av_register_all();
    // 第二步：打开封装格式文件
    // 参数一：封装格式上下文
    AVFormatContext* avformat_context = avformat_alloc_context();
    // 参数二：打开视频地址->path
    const char *url = env->GetStringUTFChars(file_path, NULL);
    // 参数三：指定输入封装格式->默认格式
    // 参数四：指定默认配置信息->默认配置
    int avformat_open_input_reuslt = avformat_open_input(&avformat_context, url, NULL, NULL);
    if (avformat_open_input_reuslt != 0){
        // 失败了
        // 获取错误信息
        // char* error_info = NULL;
        // av_strerror(avformat_open_input_reuslt, error_info, 1024);
        __android_log_print(ANDROID_LOG_INFO, "ffmpeg", "打开文件失败");
        return;
    }

    __android_log_print(ANDROID_LOG_INFO, "ffmpeg", "打开文件成功");
}
```
##### 3) 增加权限

在AndroidManifest.xml增加SD卡的读写权限。
```
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```
##### 4) MainActivity增加测试代码。

注意：如果打开失败，可能读写存储设备的权限被禁用。

摩托罗拉·刀锋：设置->应用和通知->高级->权限管理器->隐私相关·读写存储设备->找到应用->如果禁用，则修改为允许。

```java
String rootPath = Environment.getExternalStorageDirectory().getAbsolutePath();
String inFilePath = rootPath.concat("/DCIM/Camera/VID_20220220_181306412.mp4");
FFmpegTest.ffmpegVideoOpenFile(inFilePath);
```

