# iOS集成SDL（源码）

[代码工程](https://gitee.com/learnany/ffmpeg/tree/master/08_ffmpeg_sdl/iOSIntegrationWithSDLSRC)

## 下载SDL源码

SDL2-2.0.5下载脚本：[download-sdl.sh](https://gitee.com/learnany/ffmpeg/blob/master/08_ffmpeg_sdl/download-sdl.sh)。

```
sh download-sdl.sh
```

> iOS文档位置：`源码/docs/README-ios.md`。

## 新建工程

删除Scenedelegate，参考：[Xcode 11新建项目多了Scenedelegate](https://www.jianshu.com/p/25b37bd40cd7)。

## 导入SDL工程

1）将`SDL2-2.0.5/Xcode-iOS/SDL/SDL.xcodeproj`工程通过Add Files加入工程。

2）选中Target->Build Phases->Link Binary With Libraries->点击+增加`libSDL2.a`。

3）选中Target>Build Setting>搜索Header Search>选中User Header Search Paths>源码include相对位置（例：../SDL2-2.0.5/include）。

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

## 遇到问题

1）SDL工程编译，GCDevice报错

解决：选中SDL的PROJECT->iOS Deployment Target->修改为9.0（源码里的好像是5.1）。

> [GCDevice编译错误](https://blog.csdn.net/u011291148/article/details/108979954)

2）引入SDL.h后无法编译

解决：`User Header Search Paths`配置的SDL头文件位置错误，修改正确即可。

