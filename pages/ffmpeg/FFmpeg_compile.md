# 编译FFmpeg库

## 一、下载音视频框架

### 1. 上网下载

下载网址：http://www.ffmpeg.org/download.html

### 2. Shell脚本下载

1) 下载命令curl

它可以通过http\ftp等等这样的网络方式下载和上传文件（它是一个强大网络工具）。

2）解压命令tar

表示解压和压缩（打包），基本语法：tar options，例如：tar xj，options选项分为很多中类型：

- -x 表示：解压文件选项，
- -j 表示：是否需要解压bz2压缩包（压缩包格式类型有很多：zip、bz2等等…）。

3）Shell脚本：[download-ffmpeg.sh](https://gitee.com/learnany/ffmpeg/blob/master/01_ffmpeg_compiled/download-ffmpeg.sh)。

## 二、编译配置选项

### 1. 查看选项

进入FFmpeg框架包中，执行configure命令：
```
cd ffmpeg-3.4
./configure --help
```

### 2. 解释选项

#### 1）Help options：帮助选项

--list-decoders：显示所有的解码器

--list-encoders：显示所有的编码器

--list-hwaccels：显示所有可用硬件加速

#### 2）Standard options：标准选项

--logfile=FILE：日志输入文件

--disable-logging：不要打印debug日志

--prefix=PREFIX：安装目录

#### 3）Licensing options：许可证选项

--enable-gpl：允许使用gpl代码，由此生成你的库或者二进制文件

GPL（许可证）：开源、免费、公用、修改、扩展。

#### 4）Configuration options：配置备选选项

--disable-static：不能编译静态库

--enable-shared：构建动态库

#### 5）Component options：组件选项

--disable-avdevice       disable libavdevice build

--disable-avcodec        disable libavcodec build

--disable-avformat       disable libavformat build

--disable-swresample     disable libswresample build

--disable-swscale        disable libswscale build

--disable-postproc       disable libpostproc build

--disable-avfilter       disable libavfilter build

--enable-avresample      enable libavresample build [no]

#### 6）External library support：<span style="border-bottom:2px solid; black;">外部库支持</span>

Using any of the following switches will allow FFmpeg to link to the
corresponding external library. All the components depending on that library
will become enabled, if all their other dependencies are met and they are not
explicitly disabled. E.g. --enable-libwavpack will enable linking to
libwavpack and allow the libwavpack encoder to be built, unless it is
specifically disabled with --disable-encoder=libwavpack.

Note that only the system libraries are auto-detected. All the other external
libraries must be explicitly enabled.

Also note that the following help text describes the purpose of the libraries
themselves, not all their features will necessarily be usable by FFmpeg.

 --enable-libfdk-aac：启用acc编码

#### 7）Toolchain options：<span style="border-bottom:2px solid; black;">工具链选项</span>

--arch=ARCH：指定我么需要编译平台CPU架构类型，例如：arm64、x86等等…

--target-os=OS：指定操作系统

#### 8）Advanced options：高级选项（暂时用不到）

#### 9）Optimization options (experts only)：优化选项

#### 10）Developer options：开发者模式

 --disable-debug：禁用调试

 --enable-debug=LEVEL：调试级别

## 四、Android平台编译

### 1. 下载源码

[download-ffmpeg.sh](https://gitee.com/learnany/ffmpeg/blob/master/01_ffmpeg_compiled/download-ffmpeg.sh)是下载脚本，执行`sh download-ffmpeg.sh`下载源码，这里以ffmpeg-3.4为例。

### 2. 下载ndk

https://developer.android.google.cn/ndk/downloads/older_releases.html

我这里使用的是[ndkr10e](https://dl.google.com/android/repository/android-ndk-r10e-darwin-x86_64.zip?hl=zh-cn)。

在ffmpeg源码的同目录下新建ndk文件交，将下载好的ndk放入ndk文件夹。

### 3. 修改configure

```
# SLIBNAME_WITH_MAJOR='$(SLIBNAME).$(LIBMAJOR)'
# LIB_INSTALL_EXTRA_CMD='$$(RANLIB) "$(LIBDIR)/$(LIBNAME)"'
# SLIB_INSTALL_NAME='$(SLIBNAME_WITH_VERSION)'
# SLIB_INSTALL_LINKS='$(SLIBNAME_WITH_MAJOR) $(SLIBNAME)'
 
 The above code is modified as the following
 
SLIBNAME_WITH_MAJOR='$(SLIBPREF)$(FULLNAME)-$(LIBMAJOR)$(SLIBSUF)'
LIB_INSTALL_EXTRA_CMD='$$(RANLIB) "$(LIBDIR)/$(LIBNAME)"'
SLIB_INSTALL_NAME='$(SLIBNAME_WITH_MAJOR)'
SLIB_INSTALL_LINKS='$(SLIBNAME)'
```
### 4. 执行编译

[android-build-ffmpeg.sh](https://gitee.com/learnany/ffmpeg/blob/master/01_ffmpeg_compiled/android-build-ffmpeg.sh)是编译脚本，将编译脚本放在和源码的同一目录，执行：
```
sh android-build-ffmpeg.sh
```





