# Mac下配置MySQL驱动
---
* 23.12.19 1:08更新

## 下载MySQL驱动jar

官网地址：https://dev.mysql.com/downloads/connector/j/

打开官网地址->点击Select Operating System下拉->选中Platform Independent->找到Platform Independent (Architecture Independent), ZIP Archive，点击下载->解压ZIP，将mysql-connector-j-8.0.33.jar拷贝至如下路径：
```
~/Documents/code/java/mysql-connector-j-8.0.33.jar
```
以上是jar路径，也就是驱动所在位置。

## 配置驱动

如果没有配置过JDK，先配置JDK，参考：http://www.1221.site/pages/java/configenv.html

```
vi ~/.bash_profile
```
修改`classpath`:
```
CLASSPATH=$JAVA_HOME/lib/tools.jar:$JAVA_HOME/lib/dt.jar:~/Documents/code/java/mysql-connector-j-8.0.33.jar:.
```
输入以下命令使配置文件生效：
```
source ~/.bash_profile
```

>参考：https://blog.csdn.net/pan_junbiao/article/details/86626741
