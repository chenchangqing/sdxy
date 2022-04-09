# 1.编译FFmpeg库

## 一、下载音视频框架

### 1. 上网下载

下载网址：http://www.ffmpeg.org/download.html

### 2. 通过Shell脚本下载音视频框架

1) 下载命令curl

它可以通过http\ftp等等这样的网络方式下载和上传文件（它是一个强大网络工具）。

2）解压命令tar

表示解压和压缩（打包），基本语法：tar options，例如：tar xj，options选项分为很多中类型：

- -x 表示：解压文件选项，
- -j 表示：是否需要解压bz2压缩包（压缩包格式类型有很多：zip、bz2等等…）。

3）脚本代码：

[ffmpeg-download.sh](ffmpeg-download.sh)

```
#!/bin/bash
# 库名称
source="ffmpeg-3.4"
# 下载这个库
if [ ! -r $source ]
then
	echo '文件不存在'
else
	rm -rf $source
fi
echo "下载FFmpeg库……"
curl http://ffmpeg.org/releases/${source}.tar.bz2 | tar xj || exit 1
```

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

## 三、编写脚本代码

### 1. 完整脚本

[ffmpeg-build.sh](ffmpeg-build.sh)

```
#!/bin/bash

#1、首先：定义下载的库名称
source="ffmpeg-3.4"

#2、其次：定义".h/.m/.c"文件编译的结果目录
#目录作用：用于保存.h/.m/.c文件编译后的结果.o文件
cache="cache"

#3、定义".a"静态库保存目录
#pwd命令：表示获取当前目录
staticdir=`pwd`/"ffmpeg-3.4-target-iOS"

#4、添加FFmpeg配置选项->默认配置
#Toolchain options:工具链选项（指定我么需要编译平台CPU架构类型，例如：arm64、x86等等…）
#--enable-cross-compile: 交叉编译
#Developer options:开发者选项
#--disable-debug: 禁止使用调试模式
#Program options选项
#--disable-programs:禁用程序(不允许建立命令行程序)
#Documentation options：文档选项
#--disable-doc：不需要编译文档
#Toolchain options：工具链选项
#--enable-pic：允许建立与位置无关代码
configure_flags="--enable-cross-compile --disable-debug --disable-programs --disable-doc --enable-pic"

#5、定义默认CPU平台架构类型
#arm64 armv7->真机->CPU架构类型
#x86_64 i386->模拟器->CPU架构类型
archs="arm64 armv7 x86_64 i386"

#6、指定我们的这个库编译系统版本->iOS系统下的7.0以及以上版本使用这个静态库
targetversion="7.0"

#7、接受命令后输入参数
#我是动态接受命令行输入CPU平台架构类型(输入参数：编译指定的CPU库)
if [ "$*" ]
then
    #存在输入参数，也就说：外部指定需要编译CPU架构类型
    archs="$*"
fi

#8、安装汇编器->yasm
#判断一下是否存在这个汇编器
#目的：通过软件管理器(Homebrew)，然后下载安装（或者更新）我的汇编器
#一个命令就能够帮助我们完成所有的操作
#错误一：`which` yasm
#正确一：`which yasm`
if [ ! `which yasm`  ]
then
    #Homebrew:软件管理器
    #下载一个软件管理器:安装、卸载、更新、搜索等等...
    #错误二：`which` brew
    #正确二：`which brew`
    if [ ! `which brew` ]
    then
        echo "安装brew"
        ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" || exit 1
    fi
    echo "安装yasm"
    #成功了
    #下载安装这个汇编器
    #exit 1->安装失败了，那么退出程序
    brew install yasm || exit 1
fi

echo "循环编译"

#9、for循环编译FFmpeg静态库
currentdir=`pwd`
for arch in $archs
do
    echo "开始编译"
    #9.1、创建目录
    #在编译结果目录下-创建对应的平台架构类型
    mkdir -p "$cache/$arch"
    #9.2、进入这个目录
    cd "$cache/$arch"

    #9.3、配置编译CPU架构类型->指定当前编译CPU架构类型
    #错误三："--arch $arch"
    #正确三："-arch $arch"
    archflags="-arch $arch"

    #9.4、判定一下你到底是编译的是模拟器.a静态库，还是真机.a静态库
    if [ "$arch" = "i386" -o "$arch" = "x86_64" ]
    then
        #模拟器
        platform="iPhoneSimulator"
        #支持最小系统版本->iOS系统
        archflags="$archflags -mios-simulator-version-min=$targetversion"
    else
        #真机(mac、iOS都支持)
        platform="iPhoneOS"
        #支持最小系统版本->iOS系统
        archflags="$archflags -mios-version-min=$targetversion -fembed-bitcode"
        #注意:优化处理(可有可无)
        #如果架构类型是"arm64"，那么
        if [ "$arch" = "arm64" ]
        then
            #GNU汇编器（GNU Assembler），简称为GAS
            #GASPP->汇编器预处理程序
            #解决问题：分段错误
            #通俗一点：就是程序运行时,变量访问越界一类的问题
            EXPORT="GASPP_FIX_XCODE5=1"
        fi
    fi


    #10、正式编译
    #tr命令可以对来自标准输入的字符进行替换、压缩和删除
    #'[:upper:]'->将小写转成大写
    #'[:lower:]'->将大写转成小写
    #将platform->转成大写或者小写
    XCRUN_SDK=`echo $platform | tr '[:upper:]' '[:lower:]'`
    #编译器->编译平台
    CC="xcrun -sdk $XCRUN_SDK clang"

    #架构类型->arm64
    if [ "$arch" = "arm64" ]
    then
        #音视频默认一个编译命令
        #preprocessor.pl帮助我们编译FFmpeg->arm64位静态库
        AS="gas-preprocessor.pl -arch aarch64 -- $CC"
    else
        #默认编译平台
        AS="$CC"
    fi

    #目录找到FFmepg编译源代码目录->设置编译配置->编译FFmpeg源码
    #--target-os:目标系统->darwin(mac系统早起版本名字)
    #darwin:是mac系统、iOS系统祖宗
    #--arch:CPU平台架构类型
    #--cc：指定编译器类型选项
    #--as:汇编程序
    #$configure_flags最初配置
    #--extra-cflags
    #--prefix：静态库输出目录
    TMPDIR=${TMPDIR/%\/} $currentdir/$source/configure \
        --target-os=darwin \
        --arch=$arch \
        --cc="$CC" \
        --as="$AS" \
        $configure_flags \
        --extra-cflags="$archflags" \
        --extra-ldflags="$archflags" \
        --prefix="$staticdir/$arch" \
        || exit 1

    echo "执行了"

    #解决问题->分段错误问题
    #安装->导出静态库(编译.a静态库)
    #执行命令
    make -j3 install $EXPORT || exit 1
    #回到了我们的脚本文件目录
    cd $currentdir
done
```

### 2. 使用步骤

#### 1）下载源码

先使用ffmpeg-download.sh下载源码，这里以ffmpeg-3.4为例。

#### 2）安装gas-preprocessor

下载最新的[gas-preprocessor.pl](https://github.com/libav/gas-preprocessor)，执行以下命令：

```
cd gas-preprocessor directory
sudo cp -f gas-preprocessor.pl /usr/local/bin/
chmod 777 /usr/local/bin/gas-preprocessor.pl
```

**问题**：编译 FFmpeg，执行 ffmpeg-build.sh 报错"GNU assembler not found, install/update gas-preprocessor"。

解决方法：我用Github最新的gas-preprocessor.pl，执行ffmpeg-build.sh脚本会报错，这里给出可以编译成功的[gas-preprocessor.pl](gas-preprocessor.pl)。

#### 3）执行编译

a) 默认分别编译arm64、armv7、i386、x86_64，代码如下：
```
sh ffmpeg-build.sh
```
b) 指定架构编译，可以指定arm64、armv7、i386、x86_64，代码如下：
```
sh ffmpeg-build.sh arm64
```
c) 指定armv7编译时出现问题，待解决：
```
sh ffmpeg-build.sh armv7

AS  libavcodec/arm/aacpsdsp_neon.o
src/libavutil/arm/asm.S:50:9: error: unknown directive
        .arch armv7-a
        ^
make: *** [libavcodec/arm/aacpsdsp_neon.o] Error 1
make: *** Waiting for unfinished jobs....
```

