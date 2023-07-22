# IDEA环境配置

### 链接地址
---

官方地址：https://www.jetbrains.com/idea/

官方使用文档：https://www.jetbrains.com/idea/getting-started.html

### 安装目录
---

<img src="images/idea_01.png" width=100%/>

### 核心bin目录介绍
---

<img src="images/idea_02.png" width=100%/>

IDEA的VM配置，是指占用的机器内存。idea.vmoptions:

```java
-Xms128m// 占用最小内存
-Xmx750m// 张永最大内存
-XX:ReservedCodeCacheSize=512m// 代码占用的缓存大小
-XX:+UseG1GC
-XX:SoftRefLRUPolicyMSPerMB=50
-XX:CICompilerCount=2
-XX:+HeapDumpOnOutOfMemoryError
-XX:-OmitStackTraceInFastThrow
-XX:+IgnoreUnrecognizedVMOptions
-XX:CompileCommand=exclude,com/intellij/openapi/vfs/impl/FilePartNodeRoot,trieDescend
-ea
-Dsun.io.useCanonCaches=false
-Dsun.java2d.metal=true
-Djbr.catch.SIGABRT=true
-Djdk.http.auth.tunneling.disabledSchemes=""
-Djdk.attach.allowAttachSelf=true
-Djdk.module.illegalAccess.silent=true
-Dkotlinx.coroutines.debug=off
-XX:ErrorFile=$USER_HOME/java_error_in_idea_%p.log
-XX:HeapDumpPath=$USER_HOME/java_error_in_idea.hprof
-Dfile.encoding=UTF-8// 设置文件编码格式
-Dconsole.encoding=UTF-8// 设置控制台编码格式

```
如果电脑低于8G没有太多的修改必要，如果16G的内存，可以适当的修改最小内存和最大内存的值，调整最小内存可以提供Java程序的启动速度，调整最大内存可以减少内存回收的频率，提供程序性能。

### 常用配置
---

>设置常规视图界面

<img src="images/idea_04.png" width=100%/>
<img src="images/idea_03.png" width=100%/>
**注意**：由于项目具体的不同，展示的界面也不尽相同。

>设置主题

<img src="images/idea_07.png" width=100%/>

>设置启动时是否打开项目

<img src="images/idea_08.png" width=100%/>

>设置鼠标滚轮修改字体

<img src="images/idea_09.png" width=100%/>

>设置自动打包

<img src="images/idea_10.png" width=100%/>

>设置行号和分隔符

<img src="images/idea_11.png" width=100%/>

>代码提示规则

<img src="images/idea_12.png" width=100%/>

>取消单行显示

<img src="images/idea_13.png" width=100%/>

>设置编辑区字体

<img src="images/idea_14.png" width=100%/>

>设置编辑区主题

<img src="images/idea_15.png" width=100%/>

>更多主题

<img src="images/idea_16.png" width=100%/>

>修改控制台字体

<img src="images/idea_17.png" width=100%/>

>修改注释颜色

<img src="images/idea_18.png" width=100%/>

>修改类头的注释文档

<img src="images/idea_19.png" width=100%/>

>设置项目文件编码

<img src="images/idea_20.png" width=100%/>

>Build,Exeution,Deployment

<img src="images/idea_21.png" width=100%/>