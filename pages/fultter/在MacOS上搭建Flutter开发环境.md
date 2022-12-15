# 在MacOS上搭建Flutter开发环境

## 问题记录

### 下载地址错误

在下载fultter的时候，需要下载macOS下的x64，而不是arm64。如果使用了错误的CPU架构类型，运行flutter命令，flutter会提示CPU不支持的信息。

### 命令行没有翻墙

如果没有翻墙，会导致以下两个错误：

```
HTTP Host availability check is taking a long time...[!] HTTP Host Availability
    ✗ HTTP host "https://maven.google.com/" is not reachable. Reason: An error occurred while checking the HTTP host: Operation timed out
    ✗ HTTP host "https://cloud.google.com/" is not reachable. Reason: An error occurred while checking the HTTP host: Operation timed out
```

### Android sdkmanager not found.

https://stackoverflow.com/questions/70719767/android-sdkmanager-not-found-update-to-the-latest-android-sdk-and-ensure-that-t

### ! NO_PROXY is not set

https://zhuanlan.zhihu.com/p/474652737

[Flutter 开发文档](https://flutter.cn/docs)  
[Flutter Gallery](https://gallery.flutter.dev/#/)  
[推荐几个优质Flutter 开源项目](https://www.wanandroid.com/blog/show/2260)  
[Flutter 快速上手 - 4.2 assets导入资源 | 猫哥](https://www.bilibili.com/video/BV1ve4y197Ly/?spm_id_from=333.788&vd_source=0e0265662467c6caea699dd58aec6891)  
[Flutter学习记录——28.Flutter 调试及 Android 和 iOS 打包](https://blog.51cto.com/u_15781233/5654543#16_debugDumpSemanticsTree_132)  
[FLUTTER开发之DART线程与异步](https://www.freesion.com/article/1166661201/)