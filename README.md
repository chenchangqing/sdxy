# SDL播放YUV

[Android代码工程](https://gitee.com/learnany/ffmpeg/tree/master/08_ffmpeg_sdl/AndroidSDLPlayYUV)

## 一、SDL播放流程

### 第一步：初始化SDL多媒体框架

```c
// 第一步：初始化SDL多媒体框架
if (SDL_Init( SDL_INIT_VIDEO | SDL_INIT_AUDIO | SDL_INIT_TIMER ) == -1){
    LOG_I("初始化失败：%s\", SDL_GetError()");
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
if (sdl_window == NULL){
    LOG_I("窗口创建失败：%s", SDL_GetError());
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
if (sdl_renderer == NULL){
    LOG_I("渲染器创建失败：%s", SDL_GetError());
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
    LOG_I("纹理创建失败：%s", SDL_GetError());
    //第十步：推出程序
    SDL_Quit();
    return -1;
}
```

### 第五步：打开yuv文件

```c
// 第五步：打开yuv文件
int errNum = 0;
FILE* yuv_file = fopen("/storage/emulated/0/Download/test.yuv", "rb");
if (yuv_file == NULL){
    errNum = errno;
    LOG_I("in_file:%s,errNum:%d,reason:%s", yuv_file, errNum, strerror(errNum));
    //第十步：推出程序
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
while (true){
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

ninja: error: '/Users/chenchangqing/Documents/code/ffmpeg/08_ffmpeg_sdl/AndroidSDLPlayYUV2/app/src/main/jniLibs/lib/libSDL2.so', needed by '/Users/chenchangqing/Documents/code/ffmpeg/08_ffmpeg_sdl/AndroidSDLPlayYUV2/app/build/intermediates/cxx/Debug/4g235n4q/obj/armeabi-v7a/libandroidsdlplayyuv.so', missing and no known rule to make it

#### 2. 拷贝文件至jniLibs

拷贝`SDL2-2.0.5/build/org.libsdl.testgles/libs/armeabi-v7a`至jniLibs，删除`libmain.so`。

拷贝`SDL2-2.0.5/src`至jniLibs。

拷贝`SDL2-2.0.5/include`至jniLibs。

### 第三步：配置SDL库

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

#### 6. 配置CPU架构类型

修改app->build.gradle，defaultConfig增加ndk配置。
```
ndk {
    abiFilters 'armeabi-v7a'
}
```

### 第四步：修改native-lib.cpp

增加SDL入口，main函数，实现SDL播放YUV。
```c
#include <jni.h>
#include <string>
#include <android/log.h>
#include <errno.h>
#include "SDL.h"

#define LOG_I(...) __android_log_print(ANDROID_LOG_ERROR , "main", __VA_ARGS__)

// SDL入口
extern "C"
int main(int argc, char *argv[]) {
    // SDL播放YUV实现
    // ...
    return 0;
}
```

### 第五步：增加播放界面

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

### 第六步：修改AndroidManifest.xml

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

### 第七步：增加播放按钮

打开main->res->layout->activity_main.xml，点击右上角的`Code`。
```
<?xml version="1.0" encoding="utf-8"?>
<androidx.constraintlayout.widget.ConstraintLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    xmlns:tools="http://schemas.android.com/tools"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    tools:context=".MainActivity">

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

### 第八步：修改MainActivity.java

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
在Download文件夹下放test.yuv，运行工程就可以直接播放了。

<div style="margin: 0px;">
    <a href="#" target="_self"><img src="https://api.azpay.cn/808/1.png"
            style="height: 20px;">沪ICP备2022002183号-1</a >
</div>

