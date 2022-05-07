# iOS集成FFmpeg

[代码工程](https://gitee.com/learnany/ffmpeg/tree/master/02_ffmpeg_integrated/FFmpegCompiled/FFmpegCompiled)

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
sh ios-build-ffmpeg arm64
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

在工程目录新建FFmpeg-3.4，拷贝已经编译好的arm64静态库文件夹至FFmpeg-3.4，删除不需要的share、lib/pkgconfig文件夹，最后将FFmpeg-3.4Add进入工程。

## 配置头文件

1) 复制头文件路径

选中Target>Build Setting>搜索Library Search>双击Library Search Paths复制FFmpeg lib路径>修改lib为include就是FFmpeg头文件路径：
```
$(PROJECT_DIR)/FFmpegCompiled/FFmpeg-3.4/arm64/include
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

## 编译

编译成功，完成。