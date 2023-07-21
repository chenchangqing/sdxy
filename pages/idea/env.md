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