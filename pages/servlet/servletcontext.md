# ServletContext
---
## 什么是ServletContext？
1）一个Servlet对象对应一个ServletConfig。100个Servlet对象则对应100个ServletConfig对象。  
2）只要在同一个webapp当中，只要在同一个应用当中，所有的Servlet对象都是共享同一个ServletContext对象的。  
3）ServletContext对象在服务器启动阶段创建，在服务器关闭的时候销毁。这就是ServletContext对象的生命周期。ServletContext对象是应用级对象。  
4）Tomcat服务器中有一个webapps，这个webapps下可以存放webapp，可以存放多个webapp，假设有100个webapp，那么就有100个ServletContext对象。但是，总之，一个应用，一个webapp肯定只有一个ServletContext对象。  
5）ServletContext被称为Servlet上下文对象。（Servlet对象的四周环境对象）  
6）一个ServletContext对象通常对应的是一个web.xml文件。  
7）ServletContext是一个接口，Tomcat服务器对ServletContext接口进行了实现。  

## ServletContext接口中有哪些常用的方法？

```java
public String getInitParameter(String name);// 通过初始化参数的name获取value
public Enumeration<String> getInitParameterNames();// 获取所有的初始化参数的name
```
以上两个方法是ServletContext对象的方法，这个方法获取的是什么信息？是以下的配置信息。
```xml
<context-param>
	<param-name>pageSize</param-name>
	<param-value>10</param-value>
</context-param>
```
注意：  
1）以上的配置信息属于应用级的配置信息，一般一个项目中共享的配置信息会放到以上标签中。  
2）如果你的配置信息只是想给某一个Servlet作为参数，那么你配置到Servlet标签当中即可，使用ServletConfig对象来获取。

```java
public String getContextPath()
```
1）获取应用的根路径（非常重要），因为在java源代码当中有一些地方可能会需要应用的根路径，这个方法可以动态获取应用的根路径。  
2）在java源码当中，不要将应用的根路径血丝，因为你永远不知道这个应用在最终部署的时候，起一个什么名字。

```java
pubic String getRealPath(String path)// 获取文件的绝对路径（真实路径）
```

```java
// 通过ServletContext对象也是可以记录日志的
public void log(String message);
public void log(String message, Throwable t);
```
这些日志信息记录到哪里了？localhost.20xx-xx-xx.log

Tomcat服务器的logs目录下都有哪些日志文件？

1）catalina.20xx-xx-xx.log：服务器端的java程序运行的控制台信息  
2）localhost.20xx-xx-xx.log：ServletContext对象的log方法记录的日志信息存储到这个文件中。  
3）localhost_access_log.20xx-xx-xx.txt 访问日志

```java
// 存（怎么向ServletContext应用域中存数据）
public void setAttribute(String name, Object value);
// 取（怎么从ServletContext应用域中取数据）
public Object getAttribute(String name);
// 删（怎么删除ServletContext应用域中的数据）
public void removeAttribute(String name);
```

## 视频
https://www.bilibili.com/video/BV1Z3411C7NZ?p=16