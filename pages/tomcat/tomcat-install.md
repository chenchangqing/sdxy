# Tomcat的安装
---

## Tomcat介绍

- apache官网地址：https://www.apache.org/
- tomcat官网地址：https://tomcat.apache.org
- tomcat开源免费的轻量级WEB服务器
- tomcat还有另外一个名字：catalina（catalina是美国的一个岛屿，风景秀丽，据说作者在这个风景秀丽的小岛上开发了一个轻量级的WEB服务器，体积小、运行速度快，因此tomcat又被称为catalina）。
- tomcat的logo是一只公猫（寓意表示Tomcat服务器是轻巧的，小巧的，果然，体积小，运行速度快，只实现了Servlet+JSP规范）。
- tomcat是java语言写的
- tomcat服务器要想运行，必须有jre（java的运行时环境）

## 下载Tomcat10.0.2

1. 打开tomcat官网地址，点击左侧Download->Tomcat 10
2. 点击Quick Navigation->Archives
3. 点击v10.0.2/，点击bin，点击apache-tomcat-10.0.2.zip下载
4. 点击v10.0.2/，点击src，点击apache-tomcat-10.0.2-src.zip下载

## 安装Tomcat10.0.2

1. 将apache-tomcat-10.0.2.zip解压缩
2. 将解压后的apache-tomcat-10.0.2文件夹，剪切至用户目录，方便管理
```python
mv apache-tomcat-10.0.2 ~/
```

## Tomcat目录介绍

- bin：这个目录是Tomcat服务器的命令文件存放的目录，比如：启动Tomcat、关闭Tomcat。
- config：这个目录是Tomcat服务器的配置文件存放目录。
	- server.xml：可以配置端口号，默认Tomcat端口是8080。
- lib：这个目录是Tomcat服务器核心程序目录，因为Tomcat服务器是Java语言编写的，这里的jar包里面都是class文件。
- logs：Tomcat服务器的日志目录，Tomcat服务器启动等信息都会在这个目录下生成日志文件。
- temp：Tomcat服务器的临时目录，存储临时文件。
- webapps：这个目录当中就是用来存放大量的webapp（web application：web应用）。
- work：这个目录是用来存放JSP文件翻译之后的java文件以及编译之后的class文件。

## 分析startup.bat

- Tomcat服务器提供了bat和sh文件，说明了这个Tomcat服务器的通用性。
- 分析startup.bat文件得出，执行这个命令，实际上最后是执行：catalina.bat文件。
- catalina.bat文件中有这样一行配置：set MAINCLASS=org.apache.catalina.startup.Bootstrap（这个类就是main方法所在的类）。
- Tomcat服务器就是JAVA语言写的，既然是JAVA语言写的，那么启动Tomcat服务器就是执行main方法。

## 配置CATALINA_HOME

1. 编辑.bash_profile
```python
vi ~/.bash_profile
```
2. 添加以下命令：
```python
# CATALINA
CATALINA_HOME=~/apache-tomcat-10.0.2
PATH=$CATALINA_HOME/bin:$PATH:.
export CATALINA_HOME
export PATH
```
3. source
```python
source ~/.bash_profile
```
4. 验证
```python
echo $CATALINA_HOME
```

## 启动Tomcat

1. 修改命令权限  
startup.sh
```python
chmod 777 $CATALINA_HOME/bin/startup.sh
```
catalina.sh
```python
chmod 777 $CATALINA_HOME/bin/catalina.sh
```
shutdown.sh
```python
chmod 777 $CATALINA_HOME/bin/shutdown.sh
```

2. 启动Tomcat
```python
startup.sh
```

3. 关闭Tomcat
```python
shutdown.sh
```

## 视频地址

https://www.bilibili.com/video/BV1Z3411C7NZ/?p=4
