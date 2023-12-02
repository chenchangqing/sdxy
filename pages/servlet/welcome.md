# 配置欢迎页

## 什么是web站点的欢迎页

对于一个webapp来说，我们是可以设置他的欢迎页面，设置了欢迎页面之后，当你访问这个webapp的时候，或者访问这个web站点的时候，没有指定任何“资源路径”，这个时候会默认访问你的欢迎页面。

我们一般的访问方式是：http://localhost:4000/pages/servlet/welcome.html 
>这种方式是指定了要访问的就是welcome.html资源。

如果我们访问的方式是：http://localhost:4000/pages 
>没有指定具体的资源路径，它会默认访问设置的欢迎页面。

## 怎么设置欢迎页面

1）在IDEA工具的web目录下新建了一个文件login.html  
2）在web.xml文件中进行了以下的配置
```xml
<welcome-file-list>
	<welcome-file>login.html</welcome-file>
</welcome-file-list>
```
>注意：设置欢迎页面的时候，这个路径不需要以“/”开始，并且这个路径默认是从webapp的根下开始查找。  

3）启动服务器，浏览器地址输入地址：http://localhost:4000/pages  

## 设置多个欢迎页面
```xml
<welcome-file-list>
	<welcome-file>page1/page2/page.html</welcome-file>
	<welcome-file>login.html</welcome-file>
</welcome-file-list>
```
>注意：越靠上的优先级越高，找不到的继续向下找。

## 默认欢迎页配置

1）webapp内部的web.xml。（局部配置）  
2）CATALINA_HOME/conf/web.xml。（全局配置）
```xml
<welcome-file-list>
	<welcome-file>index.html</welcome-file>
	<welcome-file>index.htm</welcome-file>
	<welcome-file>index.jsp</welcome-file>
</welcome-file-list>
```
>注意：局部优先原则（就近原则）。

## WEB-INF目录

1）在WEB-INF目录下新建了一个文件，webcome.html  
2）打开浏览器访问：http://localhost:8080/project/WEB-INF/welcome.html ，出现了404错误。
>注意：放在WEB-INF目录下的资源是受保护的。在浏览器上不能通过路径直接访问。所以像HTML、CSS、JS、Image等静态资源一定要放在WEB-INF目录之外。

## 视频地址

https://www.bilibili.com/video/BV1Z3411C7NZ?p=20