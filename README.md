 
# JSP原理
---

* 23.12.16 1:16更新

## 我的第一个JSP程序

1）在WEB-INF目录之外创建一个index.jsp文件，然后这个文件没有任何内容。  
2）在上面的项目部署之后，启动服务器，打开浏览器访问以下路径 ，展示空白页面。  
>http://localhost:8080/jsp/index.jsp

3）实际上访问index.jsp，底层执行的是index_jsp.class这个java程序。  
4）这个index.jsp会被tomcat翻译生成index_jsp.java文件，然后tomcat服务器又会将index_jsp.java编译生成index_jsp.class文件。

控制台找到：  
>CATALINA_BASE: C:\Users\Administrator\AppData\Local\JetBrains\IntelliJIdea2021.3\tomcat\xxx

index_jsp.java路径：
>CATALINA_BASE\work/Catalina\localhost\jsp\org\apache\jsp\index_jsp.java  

5）访问index.jsp，实际上执行的是index_jsp.class中的方法。

## JSP实际是一个Servlet

1）index.jsp访问的时候，会自动翻译生成index_jsp.java，会自动翻译生成index_jsp.class，那么index_jsp这就是一个类。  
2）index_jsp类继承HttpJspBase，而HttpJspBase类继承的是HttpServlet。所以index_jsp类就是一个Servlet类。  
3）jsp的生命周期和Servlet的生命周期完全相同。完全就是一个东西，没有任何区别。  
4）jsp和servlet一样，都是单例的。（假单例）

## JSP文件第一次访问的时候是比较慢的，为什么？

1）要把jsp文件翻译生成java文件。  
2）java源文件要编译生成class字节码文件。  
3）然后通过class去创建servlet对象。  
4）然后调用servlet对象的init方法。  
5）最后调用servlet对象的service方法。

第二次就比较快了，为什么？因为第二次直接调用单例servlet对象的esrvice方法即可。

## JSP是什么？

1）JSP是java程序。（JSP本质还是一个Servlet）  
2）JSP是：JavaServer Pages的缩写。（基于java语言实现的服务器的页面）  
3）Servlet是JavaEE的13个子规范之一，那么JSP也是13个子规范之一。  
4）JSP是一套规范。所有的web容器/web服务器都是遵循这套规范的，都是按照这套规范进行的“翻译”。  
5）每一个web容器/web服务器都会内置一个JSP翻译引擎。

## 翻译JSP

在JSP文件中直接编写文件，都会自动被翻译到哪里？

1）翻译到servlet类的service方法的out.writer("翻译到这里")，直接翻译到双引号里，被java程序当做普通字符串打印输出到浏览器。  
2）在JSP中编写的HTML CSS JS代码，这些代码对于JSP来说只是一个普通的字符串。但是JSP把这个普通的字符串一旦输出到浏览器，浏览器就会对HTML CSS JS进行解释执行，展示页面效果。

## 中文乱码

通过page指令来设置响应的内容类型，在内容类型的最后面添加：charset=UTF-8。
```java
<%@page contentType="text/html;charset=UTF-8"%>
```
表示响应的内容类型是text/html，采用字符集UTF-8。

## <%Java代码%>

1）在这个符号当中编写的被视为java程序，被翻译到Servlet类的service方法内部。  
>注意：在<%%>这个符号里面写java代码的时候，要时时刻刻地记住你正在“方法提”当中写代码，方法体中可以写什么，不可以写什么。

2）在service方法当中编写的代码是有顺序的，方法体当中的代码要遵循自上而下的顺序依次逐行执行。  
3）service方法当中不能写静态代码块，不能写方法，不能定义成员变量。  
4）在同一个JSP当中<%%>这个符号可以出现多个。

## <%!Java代码%>
在这个符号中编写的java程序自动翻译到service方法之外。  
>这个语法很少用，因为在service方法外面写静态变量和实例变量，都会存在线程安全问题，JSP就是servlet，servlet是单例的，多线程并发的环境下，这个静态变量和实例变量一旦有修改操作，必然会存在线程安全问题。

## <%--注释--%>
JSP的专业注释，不会被翻译到java源代码当中。
><!-- -->这种注释属于HTML的注视，仍然会被翻译到java源代码当中。

## JSP的输出语句
```java
<% String name="jack"; out.write("name="+name);%>
```
>注意：以上代码中的out是JSP的九大内置对象之一。可以直接拿来用。当然，必须只能在service方法内部使用。  

>如果向浏览器傻姑娘输出的内容中没有“java代码”，例如输出的字符串是一个固定的字符串，可以直接在jsp中编写，不需要写到<%%>这里。

## <%=Java代码%>

在等号后面编写要输出的内容，翻译成以下java代码，翻译到service方法当中了。
```java
out.print();
```
>当输出的内容中含有java的变量，输出的内容是一个动态的内容，不是一个死的字符串。如果输出是一个固定的字符串，直接在JSP文件中编写科技。

## JSP指令

指导JSP的翻译引擎如何工作。

* include：包含，在JSP中完成静态包含。
* taglib：引入标签库，例如：JSTL标签。
* page：可以指定contetType等
* 语法：<%@指令名 属性名=属性值%>

## page指令

* `<%@page session="true/false"%>`：true表示启用JSP的内置对象session，false，反之不启用session。
* `<%@page contentType="text/json"%>`：contentType属性用来设置响应的内容类型。
* `<%@page pageEncoding="UTF-8"%>`：设置字符集编码。

>`<%@page contentType="text/json;charset=UTF-8"%>` 和 `<%@page contentType="text/json" pageEncoding="UTF-8"%>`功能一样。

* `<%@page import="java.util.list"%>`：导入包。
* `<%@page errorPage="/error.jsp"%>`：当java程序出现错误后，会跳转到error.jsp页面。

>注意：当配置了errorPage时，需要在errorPage输出错误堆栈信息，要不然程序员无法获取错误信息日志。

* `<%@page isErrorPage="true"%>`：表示启用JSP九大内置对象之一：exception，默认是false。配置错误error.jsp页面：

```java
<%@page contentType="text/html;chartset=UTF-8" %>
<%-- 在错误页面启用JSP九大内置对象之：exception--%>
<%--exception内置对象就是刚刚发生的异常对象。--%>
<%@page isErrorPage="true"%>
<html>
<head>
    <title>error</title>
</head>
<body>
<h1>网络繁忙，稍后再试！！！</h1>
<%--打印异常堆栈信息，输出到后台控制台，exception是九大内置对象之一。--%>
<%
    exception.printStackTrace();
%>
</body>
</html>
```

## JSP的九大内置对象

* pageContext：页面作用域。
* request：请求作用域。
* session：会话作用域。
* application：应用作用域。

> * pageContext<request<session<application
* 以上四个作用域都用：setAttribute getAttribute removeAttribute class中的方法。
* 以上作用域的使用原则：尽可能使用小的域。

* exception：打印异常堆栈信息。
* config：获取web.xml的配置信息。
* page：其实就是this，当前的servlet对象。
* out：负责输出。
* response：负责响应。

## 视频

* start:https://www.bilibili.com/video/BV1Z3411C7NZ?p=36  
* end:https://www.bilibili.com/video/BV1Z3411C7NZ?p=37
* end:https://www.bilibili.com/video/BV1Z3411C7NZ?p=50

<div style="margin: 0px;">
    备案号：
    <a href="https://beian.miit.gov.cn/" target="_blank">
        <!-- <img src="https://api.azpay.cn/808/1.png" style="height: 20px;"> -->沪ICP备2022002183号-1
    </a >
</div>

