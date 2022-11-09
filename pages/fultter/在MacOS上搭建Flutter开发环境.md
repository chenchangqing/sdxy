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