# SDL播放YUV

[Android代码工程](https://gitee.com/learnany/ffmpeg/tree/master/08_ffmpeg_sdl/AndroidSDLPlayYUV)

## 一、下载SDL源码

地址：http://www.libsdl.org/download-2.0.php

## 二、Android集成SDL

### 1. 编译SDL

在SDL源码中已经提供了，Android平台下的编译脚本，位置是`SDL2-2.0.20/build-scripts/androidbuild.sh`。

有了脚本，但是并不是直接执行就可以的，查看`SDL2-2.0.20/doc/README-android.md`，得知需要执行：
```
./androidbuild.sh org.libsdl.testgles ../test/testgles.c
```
    注意：如果提示：

    Please set the ANDROID_HOME directory to the path of the Android SDK
    或
    Please set the ANDROID_NDK_HOME directory to the path of the 

    则需要在`vi ～/.bash_profile`，按i进入编辑，增加如下环境变量，然后`source ~/.bash_profile`使环境变量生效。

    export ANDROID_SDK=${ANDROID_HOME}
    export ANDROID_NDK_HOME=${ANDROID_HOME}/ndk/21.4.7075529

执行完脚本，生成`SDL2-2.0.20/build/org.libsdl.testgles`，`org.libsdl.testgles`是一个Android工程，可以直接编译运行。


### 2. 集成SDL

#### (1) 第一步：新建工程

File->NewProject->Native C++->输入工程信息->Next->Finish。

工程名称：AndroidSDLPlayYUV。

[三星手机开启开发者选项](https://publish.samsungsimulator.com/simulator/5e9b6c53-0b1e-499b-8096-9e3bb39502b8/#!topic)

#### (2) 第二步：导入库文件。

1) 项目选中Project模式->app->src->main->右键new->Directory->输入jniLibs2->enter。

注意：取名jniLibs遇到编译问题，改为jniLibs2解决。

2) 将准备好的库文件copy->选中刚才新建的jniLibs->paste。

注意：导入库文件步骤，应该导入libSDL2.so、include、src，下面是具体路径。
```
org.libsdl.testgles/app/build/intermediates/ndkBuild/debug/obj/local/arm64-v8a/libSDL2.so
org.libsdl.testgles/app/build/intermediates/ndkBuild/debug/obj/local/arm64-v8a/libmain.so
org.libsdl.testgles/app/jni/SDL/include
org.libsdl.testgles/app/jni/SDL/src
```

#### (3) 第三步：修改CMakeLists.txt

1) app->src->main->cpp->双击CMakeLists.txt。

2) 修改CMakeLists.txt。

```c
# SDL核心库(最重要的库)
add_library(
        SDL2
        SHARED
        IMPORTED)
set_target_properties(
        SDL2
        PROPERTIES IMPORTED_LOCATION
        ${JNILIBS_DIR}/arm64-v8a/libSDL2.so)

add_library(
        libmain
        SHARED
        IMPORTED)
set_target_properties(
        libmain
        PROPERTIES IMPORTED_LOCATION
        ${JNILIBS_DIR}/arm64-v8a/libmain.so)

# 配置编译的头文件
include_directories(${JNILIBS_DIR}/src)
include_directories(${JNILIBS_DIR}/include)

add_library( # Sets the name of the library.
        androidsdlplayyuv

        # Sets the library as a shared library.
        SHARED

        # Provides a relative path to your source file(s).
        ${JNILIBS_DIR}/src/main/android/SDL_android_main.c
        native-lib.cpp)
.
.
.
target_link_libraries( # Specifies the target library.
        androidsdlplayyuv SDL2 libmain

        # Links the target library to the log library
        # included in the NDK.
        ${log-lib})
```
#### (4) 配置CPU架构类型

修改app->build.gradle：
```c
externalNativeBuild {
    cmake {
        cppFlags ''
        abiFilters 'armeabi'
    }
}
```
发现编译失败，解决方法，修改为如下(
[参考链接](https://blog.csdn.net/mqdxiaoxiao/article/details/99477072))：
```
defaultConfig {
    ndk {
        abiFilters 'arm64-v8a'
    }
}
```
#### (5) 增加权限

在AndroidManifest.xml增加SD卡的读写权限。
```
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

#### (6) 拷贝播放界面

在工程选中java，paste。

```
org.libsdl.testgles/app/src/main/java/org
```

#### (7) 配置启动页

修改`AndroidManifest.xml`。

```
<activity android:name="org.libsdl.app.SDLActivity"
    android:label="@string/app_name">
</activity>
```

修改`MainActivity.java`。
```
import android.view.View;
import android.content.Intent;
import org.libsdl.app.SDLActivity;

//  TextView tv = binding.sampleText;
//  tv.setText(stringFromJNI());

// 启动SDL播放框架
public void clickSDLPlayer(View v){
    startActivity(new Intent(this, SDLActivity.class));
}
```

修改`main_activity.xml`。
```
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
```

#### (8) 配置动态库名称

修改native-lib.cpp
```
add_library( # Sets the name of the library.
        SDL2main

        # Sets the library as a shared library.
        SHARED

        # Provides a relative path to your source file(s).
        ${JNILIBS_DIR}/src/main/android/SDL_android_main.c
        native-lib.cpp)
.
.
.
target_link_libraries( # Specifies the target library.
        SDL2main SDL2 libmain

        # Links the target library to the log library
        # included in the NDK.
        ${log-lib})
```
修改MainActivity.java
```
// Used to load the 'androidsdlplayyuv' library on application startup.
static {
    System.loadLibrary("SDL2main");
}
```

#### (9) 修改native-lib.cpp

```c
#include <android/log.h>

#define LOG_I(...) __android_log_print(ANDROID_LOG_ERROR , "main", __VA_ARGS__)

#include "SDL.h"


//入口函数Main函数，在iOS平台也是Main入口，在Mac平台下也是Main函数入口
//在Windows平台下也是Main函数入口加载SDL框架
//重写了main函数入口逻辑->界面入口函数
int main(int argc, char *argv[]) {
}
```
运行出错：
```
W/System.err: dlopen failed: library "libmain.so" not found
```

<div style="margin: 0px;">
    <a href="#" target="_self"><img src="https://api.azpay.cn/808/1.png"
            style="height: 20px;">沪ICP备2022002183号-1</a >
</div>

