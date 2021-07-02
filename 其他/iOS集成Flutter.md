# iOS集成Flutter

[flutter开源地址](https://github.com/flutter/flutter)

[flutter中文文档](https://flutter.cn/docs)

[flutter英文文档](https://flutter.dev/docs)

### 一、flutter环境配置

[参考](https://www.jianshu.com/p/1bf5ef561a3c)

#### 第1步：下载最新的SDK

[下载地址](https://flutter.dev/docs/development/tools/sdk/releases?tab=macos)

我这里SDK文件放在用户目录下，解压后可以看到在用户目录下多了一个flutter文件夹。

#### 第2步：配置flutter命令

在用户目录下找到.bash_profile，可以直接用文本编辑器打开，或则使用vi命令：
```
vi ~/.bash_profile
```
在.bash_profile中写入以下命令，完成配置
```
export PATH=~/flutter/bin:$PATH
```

#### 第3步：检测flutter命令

帮助
```
flutter -h 
```
flutter安装地址
```
which flutter
```
dart安装地址
```
which flutter dart
```

#### 第4步：运行 flutter doctor 命令
```
flutter doctor
```
1.问题1

```
 🎉   ~  flutter doctor
Doctor summary (to see all details, run flutter doctor -v):
[✓] Flutter (Channel stable, 2.2.1, on Mac OS X 10.15.7 19H114 darwin-x64, locale zh-Hans-CN)
[✗] Android toolchain - develop for Android devices
    ✗ Unable to locate Android SDK.
      Install Android Studio from: https://developer.android.com/studio/index.html
      On first launch it will assist you in installing the Android SDK components.
      (or visit https://flutter.dev/docs/get-started/install/macos#android-setup for detailed
      instructions).
      If the Android SDK has been installed to a custom location, please use
      `flutter config --android-sdk` to update to that location.

[✓] Xcode - develop for iOS and macOS
[✓] Chrome - develop for the web
[!] Android Studio (not installed)
[✓] Connected device (1 available)
    ! Error: 陈长青的 iPhone is not connected. Xcode will continue when 陈长青的 iPhone is connected. (code -13)
```

将iPhone连接到电脑，并且解锁，解决问题：
```
 🎉   ~  flutter doctor
Doctor summary (to see all details, run flutter doctor -v):
[✓] Flutter (Channel stable, 2.2.1, on Mac OS X 10.15.7 19H114 darwin-x64, locale zh-Hans-CN)
[✗] Android toolchain - develop for Android devices
    ✗ Unable to locate Android SDK.
      Install Android Studio from: https://developer.android.com/studio/index.html
      On first launch it will assist you in installing the Android SDK components.
      (or visit https://flutter.dev/docs/get-started/install/macos#android-setup for detailed
      instructions).
      If the Android SDK has been installed to a custom location, please use
      `flutter config --android-sdk` to update to that location.

[✓] Xcode - develop for iOS and macOS
[✓] Chrome - develop for the web
[!] Android Studio (not installed)
[✓] Connected device (2 available)
```
1.问题2
```
[✗] Android toolchain - develop for Android devices
    ✗ Unable to locate Android SDK.
      Install Android Studio from: https://developer.android.com/studio/index.html
      On first launch it will assist you in installing the Android SDK components.
      (or visit https://flutter.dev/docs/get-started/install/macos#android-setup for detailed
      instructions).
      If the Android SDK has been installed to a custom location, please use
      `flutter config --android-sdk` to update to that location.
```


### 二、设置 iOS 开发环境

#### 第1步：安装 Xcode

1.通过 [直接下载](https://developer.apple.com/xcode/) 或者通过 [Mac App Store](https://apps.apple.com/us/app/xcode/id497799835) 来安装最新稳定版 Xcode

2.通过在命令行中运行以下命令来配置 Xcode command-line tools:
```
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
```
当你安装了最新版本的 Xcode，大部分情况下，上面的路径都是一样的。但如果你安装了不同版本的 Xcode，你可能要更改一下上述命令中的路径。

3.运行一次 Xcode 或者通过输入命令 `sudo xcodebuild -license` 来确保已经同意 Xcode 的许可协议。

#### 第2步：配置 iOS 模拟器

```
open -a Simulator

```

### 三、创建并运行一个简单的 Flutter 应用

通过以下步骤来创建你的第一个 Flutter 应用并进行测试：

1.通过运行以下命令来创建一个新的 Flutter 应用：
```
flutter create my_app
```

2.上述命令创建了一个 my_app 的目录，包含了 Flutter 初始的应用模版，切换路径到这个目录内：
```
cd my_app
```

3.确保模拟器已经处于运行状态，输入以下命令来启动应用：
```
flutter run
```

问题1:
```
 🎉   ~/Desktop/代码/flutter/my_app  flutter run
Multiple devices found:
陈长青的 iPhone (mobile)       • ac82c56391c359c3313eb0f84cfe5f9c6fb45ca5 • ios            • iOS 14.4.2
iPhone 12 Pro Max (mobile) • 4594BEED-D4F8-4CE4-A566-BF483F2A7565     • ios            •
com.apple.CoreSimulator.SimRuntime.iOS-14-4 (simulator)
Chrome (web)               • chrome                                   • web-javascript • Google Chrome
90.0.4430.212
[1]: 陈长青的 iPhone (ac82c56391c359c3313eb0f84cfe5f9c6fb45ca5)
[2]: iPhone 12 Pro Max (4594BEED-D4F8-4CE4-A566-BF483F2A7565)
[3]: Chrome (chrome)
Please choose one (To quit, press "q/Q"):
```
这里直接选择2，2是我刚才打开的模拟器，接下来会看到：
```
Please choose one (To quit, press "q/Q"): 2
Launching lib/main.dart on iPhone 12 Pro Max in debug mode...
Running Xcode build...
 └─Compiling, linking and signing...                        10.8s
Xcode build done.                                           39.8s
Syncing files to device iPhone 12 Pro Max...                        89ms

Flutter run key commands.
r Hot reload. 🔥🔥🔥
R Hot restart.
h Repeat this help message.
d Detach (terminate "flutter run" but leave application running).
c Clear the screen
q Quit (terminate the application on the device).

💪 Running with sound null safety 💪

An Observatory debugger and profiler on iPhone 12 Pro Max is available at:
http://127.0.0.1:54602/2Xt-Ae85-qk=/
Activating Dart DevTools...                                        24.5s
The Flutter DevTools debugger and profiler on iPhone 12 Pro Max is available at:
http://127.0.0.1:9100?uri=http%3A%2F%2F127.0.0.1%3A54602%2F2Xt-Ae85-qk%3D%2F
```
这个时候，切换至模拟器，就可以看到应用的界面了！

注意：如果选择1真机的话，需要打开Runner.xcworkspace，在xcode中配置好证书描述文件。

### 四、解决现有flutter项目问题

#### 问题1

Invalid Podfile file: cannot load such file -- ../my_flutter/.ios/Flutter/podhelper.rb. 

[参考](https://github.com/flutter/flutter/issues/37866)

#### 问题2

[Version solving failed. #18937](https://github.com/flutter/flutter/issues/18937)

#### 问题3

[pub get failed (server unavailable) ](https://github.com/flutter/flutter/issues/63053)

#### 问题4

[Include of non-modular header inside framework module error](https://stackoverflow.com/questions/38423565/include-of-non-modular-header-inside-framework-module-error/40314961)


