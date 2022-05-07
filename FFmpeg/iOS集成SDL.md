# iOS集成SDL

[代码工程](https://gitee.com/learnany/ffmpeg/tree/master/08_ffmpeg_sdl/iOSIntegrationWithSDL)

## 下载SDL源码

SDL2-2.0.5下载脚本：[download-sdl.sh](https://gitee.com/learnany/ffmpeg/blob/master/08_ffmpeg_sdl/download-sdl.sh)。

```
sh download-sdl.sh
```

## 编译SDL

打开`SDL2-2.0.5/Xcode-iOS/SDL`工程，选择`libSDL`目标，再选择`Any iOS Device`真机编译，编译完成后可以在工程的`Products`看到`libSDL2.a`由红色变为了白色，说明静态库已经编译好了，右键`show in Finder`获取生成好的静态库。

> iOS文档位置：`源码/docs/README-ios.md`。

## 新建工程

删除Scenedelegate，参考：[Xcode 11新建项目多了Scenedelegate](https://www.jianshu.com/p/25b37bd40cd7)。

## 导入库文件

在工程目录新建`SDL2-2.0.5/lib`，拷贝已经编译好的`libSDL2.a`至`SDL2-2.0.5/lib`，继续拷贝`SDL2-2.0.5/include`至`SDL2-2.0.5`，最后将`SDL2-2.0.5`通过Add Files加入工程。

## 配置头文件

1) 复制头文件路径

选中Target>Build Setting>搜索Library Search>双击Library Search Paths复制SDL lib路径>修改lib为include就是SDL头文件路径：
```
$(PROJECT_DIR)/iOSIntegrationWithSDL（工程名）/SDL2-2.0.5/include
```

2) 配置头文件路径

选中Target>Build Setting>搜索Header Search>选中Header Search Paths>增加上面复制好头文件路径。

## 添加依赖库

- AudioToolbox.framework
- AVFoundation.framework
- CoreAudio.framework
- CoreGraphics.framework
- CoreMotion.framework
- Foundation.framework
- GameController.framework
- OpenGLES.framework
- QuartzCore.framework
- UIKit.framework

添加完毕，编译成功。

## 简单测试

在`main.m`中引入`SDL`头文件，编译，编译成功就可以使用SDL开发了。
```
import "SDL.h"
```