# 8.SDL播放YUV

[Android代码工程](https://gitee.com/learnany/ffmpeg/tree/master/08_ffmpeg_sdl/AndroidSDLPlayYUV)

[Mac代码工程](https://gitee.com/learnany/ffmpeg/tree/master/08_ffmpeg_sdl/MacSDLPlayYUV)

[iOS代码工程](https://gitee.com/learnany/ffmpeg/tree/master/08_ffmpeg_sdl/iOSSDLPlayYUV)

## 一、SDL播放流程

### 第一步：初始化SDL多媒体框架

```c
// 第一步：初始化SDL多媒体框架
if (SDL_Init( SDL_INIT_VIDEO | SDL_INIT_AUDIO | SDL_INIT_TIMER ) == -1) {
    LOG_I_ARGS("初始化失败：%s", SDL_GetError());
    // Mac使用
    // printf("初始化失败：%s", SDL_GetError());
    return -1;
}
```

### 第二步：初始化SDL窗口

```c
// 第二步：初始化SDL窗口
// 参数一：窗口名称
// 参数二：窗口在屏幕上的x坐标
// 参数三：窗口在屏幕上的y坐标
// 参数四：窗口在屏幕上宽
// 参数五：窗口在屏幕上高
// 参数六：窗口状态(打开)
int width = 640;
int height = 352;
SDL_Window* sdl_window = SDL_CreateWindow("SDL播放YUV视频",
                                          SDL_WINDOWPOS_CENTERED,
                                          SDL_WINDOWPOS_CENTERED,
                                          width,
                                          height,
                                          SDL_WINDOW_OPENGL);
if (sdl_window == NULL) {
    LOG_I_ARGS("窗口创建失败：%s", SDL_GetError());
    // Mac使用
    // printf("窗口创建失败： %s\n", SDL_GetError());
    // 退出程序
    SDL_Quit();
    return -1;
}
```

### 第三步：创建渲染器->渲染窗口

```c
// 第三步：创建渲染器->渲染窗口
// 参数一：渲染目标创建->目标
// 参数二：从那里开始渲染(-1:表示从第一个位置开始)
// 参数三：渲染类型(软件渲染)
SDL_Renderer* sdl_renderer = SDL_CreateRenderer(sdl_window, -1, 0);
if (sdl_renderer == NULL) {
    LOG_I_ARGS("渲染器创建失败：%s", SDL_GetError());
    // Mac使用
    // printf("渲染器创建失败： %s\n", SDL_GetError());
    // 退出程序
    SDL_Quit();
    return -1;
}
```

### 第四步：创建纹理

```c
// 第四步：创建纹理
// 参数一：纹理->目标渲染器
// 参数二：渲染格式->YUV格式->像素数据格式(视频)或者是音频采样数据格式(音频)
// 参数三：绘制方式->频繁绘制->SDL_TEXTUREACCESS_STREAMING
// 参数四：纹理宽
// 参数五：纹理高
SDL_Texture* sdl_texture = SDL_CreateTexture(sdl_renderer,
                                             SDL_PIXELFORMAT_IYUV,
                                             SDL_TEXTUREACCESS_STREAMING,
                                             width,
                                             height);
if (sdl_texture == NULL) {
    LOG_I_ARGS("纹理创建失败：%s", SDL_GetError());
    // Mac使用
    // printf("纹理创建失败： %s\n", SDL_GetError());
    // 退出程序
    SDL_Quit();
    return -1;
}
```

### 第五步：打开yuv文件

```c
// 第五步：打开yuv文件
int errNum = 0;
FILE* yuv_file = fopen("/storage/emulated/0/Download/test.yuv", "rb");
// MAC使用
// FILE* yuv_file = fopen("/Users/chenchangqing/Documents/code/ffmpeg/resources/test.yuv", "rb");
// iOS
// NSString* inPath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"yuv"];
// FILE* yuv_file = fopen([inPath UTF8String], "rb");
if (yuv_file == NULL) {
    errNum = errno;
    LOG_I_ARGS("打开文件失败：errNum:%d,reason:%s", errNum, strerror(errNum));
    // Mac使用
    // printf("打开文件失败：errNum:%d,reason:%s", errNum, strerror(errNum));
    // 退出程序
    SDL_Quit();
    return 0;
}
```

### 第六步：循环读取yuv视频像素数据帧

```c
// 第六步：循环读取yuv视频像素数据帧
int y_size = width * height;
// 定义缓冲区(内存空间开辟多大?)
// 缓存一帧视频像素数据 = Y + U + V
// Y:U:V = 4 : 1 : 1
// 假设：Y = 1.0  U = 0.25  V = 0.25
// 宽度：Y + U + V = 1.5
// 换算：Y + U + V = width * height * 1.5
char buffer_pix[y_size * 3 / 2];
// 定义渲染器区域
SDL_Rect sdl_rect;
int currentIndex = 1;
while (true) {
    // 一帧一帧读取
    fread(buffer_pix, 1, y_size * 3 / 2, yuv_file);
    // 判定是否读取完毕
    if (feof(yuv_file)){
        break;
    }

    // 第七步：设置纹理数据
    // ...

    // 第八步：将纹理数据拷贝给渲染器
    // ...

    // 第九步：呈现画面帧
    // ...

    // 第十步：渲染每一帧直接间隔时间
    // ...
    printf("当前到了第%d帧\n", currentIndex);
    currentIndex++;
}
```

### 第七步：设置纹理数据

```c
// 第七步：设置纹理数据
// 参数一：纹理
// 参数二：渲染区域
// 参数三：需要渲染数据->视频像素数据帧
// 参数四：帧宽
SDL_UpdateTexture(sdl_texture, NULL, buffer_pix, width);
```

### 第八步：将纹理数据拷贝给渲染器

```c
// 第八步：将纹理数据拷贝给渲染器
// 设置左上角位置(全屏)
sdl_rect.x = 100;
sdl_rect.y = 100;
sdl_rect.w = width;
sdl_rect.h = height;

SDL_RenderClear(sdl_renderer);
SDL_RenderCopy(sdl_renderer, sdl_texture, NULL, &sdl_rect);
```

### 第九步：呈现画面帧

```c
// 第九步：呈现画面帧
SDL_RenderPresent(sdl_renderer);
```

### 第十步：渲染每一帧直接间隔时间

```c
// 第十步：渲染每一帧直接间隔时间
SDL_Delay(30);
```

### 第十一步：释放资源

```c
// 第十一步：释放资源
fclose(yuv_file);
SDL_DestroyTexture(sdl_texture);
SDL_DestroyRenderer(sdl_renderer);
```

### 第十二步：退出程序

```c
// 第十二步：退出程序
SDL_Quit();
```

## 二、Android编译SDL

### 1. 下载工具包

### (1) SDL

http://www.libsdl.org/release/SDL2-2.0.5.tar.gz

    /Users/chenchangqing/Documents/code/ffmpeg/08_ffmpeg_sdl/SDL2-2.0.5

>注意：由于最新的SDL编译后使用遇到无法显示视频的问题，这里使用`SDL2-2.0.5`。
>问题：eglSwapBuffersWithDamageKHRImpl:1402 error 300d (EGL_BAD_SURFACE)

### (2) NDK

https://dl.google.com/android/repository/android-ndk-r10e-darwin-x86_64.zip

    /Users/chenchangqing/Documents/code/ffmpeg/resources/ndk/android-ndk-r10e

### (3) SDK

https://dl.google.com/android/adt/adt-bundle-linux-x86_64-20140702.zip

    /Users/chenchangqing/Documents/code/ffmpeg/resources/sdk/adt-bundle-linux-x86_64-20140702

### (3) ANT

https://dlcdn.apache.org//ant/binaries/apache-ant-1.10.12-bin.tar.gz

    /Users/chenchangqing/Documents/code/ffmpeg/resources/ant/apache-ant-1.10.12

## 2. 修改`androidbuild.sh`

查看`SDL2-2.0.5/docs/README-android.md`得知分别需要配置NDK、SDK、ANT，并且如果编译APK文件需要java环境，这里我们暂时不需要编译APK，忽略java环境即可。`androidbuild.sh`文件在`SDL-2.0.5/build-scripts`。

>注意：最新版（目前2.0.20）是不需要修改`androidbuild.sh`的，但是需要配置SDK、NDK的环境变量。

### (1) 配置NDK

    # NDKBUILD=`which ndk-build`
    NDKBUILD="/Users/chenchangqing/Documents/code/ffmpeg/resources/ndk/android-ndk-r10e/ndk-build"

### (2) 配置SDK

    # ANDROID=`which android`
    ANDROID="/Users/chenchangqing/Documents/code/ffmpeg/resources/sdk/adt-bundle-linux-x86_64-20140702/sdk"

### (3) 配置ANT
    
    # ANT=`which ant`
    ANT="/Users/chenchangqing/Documents/code/ffmpeg/resources/ant/apache-ant-1.10.12/bin/ant"

## 3. 运行脚本

    ./androidbuild.sh org.libsdl.testgles ../test/testgles.c

脚本执行完毕，分别生成了`armeabi`、`armeabi-v7a`、`x86`的.so动态库，`SDL2-2.0.5/build/org.libsdl.testgles/libs`是动态库的路径。

>注意：最新版（目前2.0.20）脚本执行完毕生成的是一个Android工程，编译后生成动态库文件，暂时没研究好动态库文件的路径在哪里。

## 三、Android集成SDL

### 第一步：新建工程

File->NewProject->Native C++->输入工程信息->Next->Finish。

工程名称：AndroidSDLPlayYUV。

### 第二步：导入库文件。

#### 1. 新建jniLibs文件夹

项目选中Project模式->app->src->main->右键new->Directory->输入jniLibs->enter。

同样的方式在jniLibs下心间lib文件夹，用来存放.so库文件。

#### 2. 拷贝文件至jniLibs

拷贝`SDL2-2.0.5/build/org.libsdl.testgles/libs/armeabi-v7a/libSDL2.so`至jniLibs/lib。

拷贝`SDL2-2.0.5/src`至jniLibs。

拷贝`SDL2-2.0.5/include`至jniLibs。

### 第三步：配置SDL库

修改`CMakeLists.txt`。

#### 1. 设置jniLibs
```c
# 1. 设置jniLibs
set(JNILIBS_DIR ${CMAKE_SOURCE_DIR}/../jniLibs)
```

#### 2. SDL核心库
```c
# 2. SDL核心库
add_library(
        SDL2
        SHARED
        IMPORTED)
set_target_properties(
        SDL2
        PROPERTIES IMPORTED_LOCATION
        ${JNILIBS_DIR}/lib/libSDL2.so)
```

#### 3. 配置SDL_android_main.c

修改`androidsdlplayyuv`为`SDL2main`，增加`${JNILIBS_DIR}/src/main/android/SDL_android_main.c`。

>`androidsdlplayyuv`为工程名称。

```c
# 3. 配置SDL_android_main.c
add_library( # Sets the name of the library.
        SDL2main
        # Sets the library as a shared library.
        SHARED
        # Provides a relative path to your source file(s).
        ${JNILIBS_DIR}/src/main/android/SDL_android_main.c
        native-lib.cpp)
```

#### 4. 链接SDL2mian和SDL2库

修改`androidsdlplayyuv`为`SDL2main`，增加`SDL2`。

>`androidsdlplayyuv`为工程名称。

```c
# 4. 链接SDL2mian和SDL2库
target_link_libraries( # Specifies the target library.
        SDL2main SDL2

        # Links the target library to the log library
        # included in the NDK.
        ${log-lib})
```
>注意1：3，4步完成后，然后马上编译，会出现`error: undefined reference to 'SDL_main'`错误，是因为`native-lib.cpp`还没写main函数，这里先忽略。注意2: `androidsdlplayyuv`库已经改成了`SDL2main`，MainActivity.java的`loadLibrary`也应该改下名称。

#### 5. SDL头文件和源码
```c
# 5. SDL头文件和源码
include_directories(${JNILIBS_DIR}/src)
include_directories(${JNILIBS_DIR}/include)
```

### 第四步：配置CPU架构类型

修改app->build.gradle，defaultConfig增加ndk配置。
```
ndk {
    abiFilters 'armeabi-v7a'
}
```

### 第五步：修改native-lib.cpp

引入头文件，增加SDL入口，新增main函数，实现SDL播放YUV。
```c
#include <android/log.h>
#include <errno.h>
#include "SDL.h"

#define LOG_I_ARGS(FORMAT,...) __android_log_print(ANDROID_LOG_INFO,"main",FORMAT,__VA_ARGS__);
#define LOG_I(FORMAT) LOG_I_ARGS(FORMAT,0);

// SDL入口
extern "C"
int main(int argc, char *argv[]) {
    // SDL播放YUV实现
    // 拷贝SDL播放流程的代码
    return 0;
}
```

### 第六步：增加播放界面

拷贝`SDL2-2.0.5/build/org.libsdl.testgles/src/org`至java。

修改`SDLActivity.java`，原来
```java
protected String[] getLibraries() {
    return new String[] {
        "SDL2",
        // "SDL2_image",
        // "SDL2_mixer",
        // "SDL2_net",
        // "SDL2_ttf",
        "main"
    };
}
```
修改为
```java
protected String[] getLibraries() {
    return new String[] {
        "SDL2",
        // "SDL2_image",
        // "SDL2_mixer",
        // "SDL2_net",
        // "SDL2_ttf",
        "SDL2main"// 这里的名字是上一步通过add_library配置好的。
    };
}
```

### 第七步：修改AndroidManifest.xml

在AndroidManifest.xml中声明MANAGE_EXTERNAL_STORAGE权限。
```
<?xml version="1.0" encoding="utf-8"?>
<!-- 所有文件权限1：add xmlns:tools="http://schemas.android.com/tools" -->
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools"
    package="com.ccq.androidsdlplayyuv">

    <!-- 所有文件权限2 -->
    <uses-permission android:name="android.permission.MANAGE_EXTERNAL_STORAGE"
        tools:ignore="ScopedStorage" />


    <!-- 所有文件权限3：add  android:requestLegacyExternalStorage="true"-->
    <application
        android:allowBackup="true"
        android:icon="@mipmap/ic_launcher"
        android:label="@string/app_name"
        android:roundIcon="@mipmap/ic_launcher_round"
        android:supportsRtl="true"
        android:theme="@style/Theme.AndroidSDLPlayYUV"
        android:requestLegacyExternalStorage="true">
        <activity
            android:name=".MainActivity"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>

        <!-- 配置播放界面 -->
        <activity android:name="org.libsdl.app.SDLActivity"
            android:label="@string/app_name">
        </activity>
    </application>

</manifest>
```

### 第八步：增加播放按钮

打开main->res->layout->activity_main.xml，点击右上角的`Code`，将原来的Text改为现在的Button。
```
<?xml version="1.0" encoding="utf-8"?>
<androidx.constraintlayout.widget.ConstraintLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    xmlns:tools="http://schemas.android.com/tools"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    tools:context=".MainActivity">
    <!-- 将原来的Text改为现在的Button -->
    <Button
        android:id="@+id/sample_text"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="播放视频"
        android:onClick="clickSDLPlayer"
        app:layout_constraintBottom_toBottomOf="parent"
        app:layout_constraintLeft_toLeftOf="parent"
        app:layout_constraintRight_toRightOf="parent"
        app:layout_constraintTop_toTopOf="parent" />

</androidx.constraintlayout.widget.ConstraintLayout>
```

### 第九步：修改MainActivity.java

这是最后一步，完成这一步，运行工程点击播放按钮就可以直接播放了。

>注意：在`/storage/emulated/0/Download`文件夹下放test.yuv。

```java

// 修改1：增加import
import android.view.View;
import android.content.Intent;
import org.libsdl.app.SDLActivity;
import android.widget.Toast;
import android.os.Build;
import android.provider.Settings;
import android.os.Environment;

public class MainActivity extends AppCompatActivity {

    // Used to load the 'androidsdlplayyuv' library on application startup.
    static {
        // 修改2：androidsdlplayyuv改为SDL2main
        System.loadLibrary("SDL2main");
    }

    private ActivityMainBinding binding;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        binding = ActivityMainBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());
        // 修改3：注释TextView，增加checkPermission
        // Example of a call to a native method
        // TextView tv = binding.sampleText;
        // tv.setText(stringFromJNI());
        checkPermission();
    }

    /**
     * 修改4：新增checkPermission方法
     * 检查所有文件的权限
     */
    public void checkPermission() {

        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R ||
                Environment.isExternalStorageManager()) {
            Toast.makeText(this, "已获得访问所有文件的权限", Toast.LENGTH_SHORT).show();
        } else {
            Intent intent = new Intent(Settings.ACTION_MANAGE_ALL_FILES_ACCESS_PERMISSION);
            startActivity(intent);
        }

    }

    /**
     * 修改5：新增点击播放
     * 启动SDL播放框架
     */
    public void clickSDLPlayer(View v){
        startActivity(new Intent(this, SDLActivity.class));
    }

    /**
     * A native method that is implemented by the 'androidsdlplayyuv' native library,
     * which is packaged with this application.
     */
    public native String stringFromJNI();
}
```
## 四、Mac集成SDL

### 第一步：配置SDL开发环境

#### 1. 下载SDL2.dmg
https://www.libsdl.org/release/SDL2-2.0.5.dmg

下载好了，点击安装，会得到`SDL2.framework`。

>为了避免不必要的麻烦，这里我们依然使用2.0.5的版本。

#### 2. 安装SDL2

将SDL2.Framework拷贝到`/Library/Frameworks`目录下。 

### 第二步：新建Mac工程

新建命令行项目：`New->Project->macOS->Command Line Tool`，项目名称MacSDLPlayYUV。

### 第三步：导入SDL库

在工程目录新建SDLFramework，将SDL2.Framework拷贝到`SDLFramework`，通过Add的方式加入工程。

### 第四步：修改main.m

引入SDL头文件，在main函数拷贝“SDL播放流程”的代码即可。

>注意：打印日志的方式需要修改为Mac的方式。

```c
#import <Foundation/Foundation.h>
#include <errno.h>
// 引入SDL头文件
#include <SDL2/SDL.h>

// SDL入口
int main(int argc, const char * argv[]) {
    // SDL播放YUV实现
    // ...
    return 0;
}
```

## 五、iOS集成SDL

### 第一步：编译.a静态库

#### 1. 下载SDL源码

http://www.libsdl.org/release/SDL2-2.0.5.tar.gz

    /Users/chenchangqing/Documents/code/ffmpeg/08_ffmpeg_sdl/SDL2-2.0.5
#### 2. 编译SDL静态库

打开`SDL2-2.0.5/Xcode-iOS/SDL`工程，选择`libSDL`目标，再选择`Any iOS Device`真机编译，编译完成后可以在工程的`Products`看到`libSDL2.a`由红色变为了白色，说明静态库已经编译好了，右键`show in Finder`获取生成好的静态库。

>注意：如果编译失败，可能是iOS编译版本不支持，修改SDL的`iOS Deployment Target`为9.0即可，默认是5.1.1。

### 第二步：新建iOS工程

删除Scenedelegate，参考：[Xcode 11新建项目多了Scenedelegate](https://www.jianshu.com/p/25b37bd40cd7)。

工程名称为iOSSDLPlayYUV。

### 第三步：导入库文件。

在工程目录新建SDLFramework，拷贝`libSDL2.a`、`SDL2-2.0.5/include`至`SDLFramework`，最后将`SDLFramework`进入工程。

### 第四步：添加依赖库

- CoreGraphics.framework
- AudioToolbox.framework
- AVFoundation.framework
- CoreAudio.framework
- OpenGLES.framework
- CoreMotion.framework
- GameController.framework

### 第五步：配置头文件

#### 1. 复制头文件路径

选中Target>Build Setting>搜索Library Search>双击Library Search Paths复制SDLFramework路径>追加/include就是SDL头文件路径：

    $(PROJECT_DIR)/iOSSDLPlayYUV/SDLFramework/include

#### 2. 配置头文件路径

选中Target>Build Setting>搜索Header Search>选中Header Search Paths>增加上面复制好头文件路径。

### 第六步：修改main.m

引入SDL头文件，在main函数拷贝“SDL播放流程”的代码即可。

>注意：打印日志的方式需要修改为iOS的方式，需要检查下yuv的路径。目前播放还是黑屏，待解决。

```c
#import <Foundation/Foundation.h>
#include <errno.h>
// 引入SDL头文件
#include "SDL.h"
// SDL入口
int main(int argc, char * argv[]) {
    // SDL播放YUV实现
    // 拷贝SDL播放流程的代码
    return 0;
}
```