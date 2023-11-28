# ServletConfig
---
## 什么是ServletConfig？
1）Servlet对象的配置信息对象  
2）ServletConfig对象中封装了<servlet></servlet>标签中的配置信息。（web.xml文件中Servlet的配置信息）

## ServletConfig创建
1）一个Servlet对应一个ServletConfig对象。  
2）Servlet对象是Tomcat服务器创建，并且ServletConfig对象也是Tomcat服务器创建。并且默认情况下，它们都是在用户发送第一次请求的时候创建。  
3）Tomcat服务器调用Servlet对象的init方法的时候需要传一个ServletConfig对象的参数给init方法。  
4）ServletConfig接口的实现类是Tomcat服务器给实现的。（Tomcat服务器说的是WEB服务器） 

## ServletConfig接口有哪些常用的方法？
```java
public String getInitParameter(String name);// 通过初始化参数的name获取value
public Enumeration<String> getInitParameterNames();// 获取所有的初始化参数的name
public ServletContext getServletContext();// 获取ServletContext对象
public String getServletName();// 获取Servlet的name
```
以上方法在Servlet类当中，都可以使用this去调用。因为GenericServlet实现了ServletConfig接口。

## 视频
https://www.bilibili.com/video/BV1Z3411C7NZ?p=16