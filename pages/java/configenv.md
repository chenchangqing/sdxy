# Mac下配置JDK
---

### 如何下载JDK？

官网地址：https://www.oracle.com/java/technologies/downloads/

打开官网下载地址->点击“Java archive”->拉到最下面，点击目标版本（Java SE 7）->Mac，点击jdk-7u80-macosx-x64.dmg->登录下载->双击，然后一路next安装

### 查看JDK安装后的路径

```
/usr/libexec/java_home -V
```
输出：
```
chenchangqingdeMacBook-Pro-2:sdxy chenchangqing$ /usr/libexec/java_home -V
Matching Java Virtual Machines (3):
    19.0.2 (x86_64) "Oracle Corporation" - "OpenJDK 19.0.2" /Users/chenchangqing/Library/Java/JavaVirtualMachines/openjdk-19.0.2/Contents/Home
    1.7.80.15 (x86_64) "Oracle Corporation" - "Java" /Library/Internet Plug-Ins/JavaAppletPlugin.plugin/Contents/Home
    1.7.0_80 (x86_64) "Oracle Corporation" - "Java SE 7" /Library/Java/JavaVirtualMachines/jdk1.7.0_80.jdk/Contents/Home
/Users/chenchangqing/Library/Java/JavaVirtualMachines/openjdk-19.0.2/Contents/Home
```
记好即将要配置的JDK路径：
```
/Library/Java/JavaVirtualMachines/jdk1.7.0_80.jdk/Contents/Home
```

### 配置JDK环境变量

编辑.bash_profile文件
```
vi ~/.bash_profile
```
添加以下内容，`JAVA_HOME`就是上面的JDK路径。
```
# JDK
JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.7.0_80.jdk/Contents/Home
PATH=$JAVA_HOME/bin:$PATH:.
CLASSPATH=$JAVA_HOME/lib/tools.jar:$JAVA_HOME/lib/dt.jar:.
export JAVA_HOME
export PATH
export CLASSPATH
```
输入以下命令使配置文件生效：
```
source ~/.bash_profile
```
### 查看是否配置成功:
1.查看JDK路径：
```
echo $JAVA_HOME
```
输出：
```
/Library/Java/JavaVirtualMachines/jdk1.7.0_80.jdk/Contents/Home
```
2.查看JDK的版本信息:
```
java -version
```
输出：
```
java version "1.7.0_80"
Java(TM) SE Runtime Environment (build 1.7.0_80-b15)
Java HotSpot(TM) 64-Bit Server VM (build 24.80-b11, mixed mode)
```
>参考：https://juejin.cn/post/6844903878694010893  
参考：https://blog.csdn.net/chwshuang/article/details/54925950  



