# Cookie
---

23.12.15 2:20 更新

## 什么是cookie？

在session实现原理中，jsessionid=DD5EC49931F2AC378DC68548C9E5?v=f050045a0c，这个键值对数据就是cookie对象，是一串字符串。

cookie机制和sesion机制其实都不属于java中的机制，实际上cookie机制和session机制都是HTTP协议的一部分。php开发中也有cookie和session机制，只要做web开发，不管是什么编程语言，cookie和session机制都是需要的。

HTTP协议中规定：任何一个cookie都是name和value组成的，name和value都是字符串类型的。

## cookie保存在哪里？

* 可以保存在浏览器的运行内存中，浏览器只要关闭，cookie就消失了。
* 也可以保存在硬盘文件中，永久保存。

## cookie有啥用？

* cookie和session机制其实都是为了保存会话的状态。
* cookie是将会话的状态保存在浏览器客户端上。
* session是将会话的状态保存在服务器上。
* 为什么要有cookie和session机制呢？因为HTTP协议是无状态无连接协议。

## 十天免登录

在126邮箱中有一个功能：十天免登录。怎么实现的？

用户输入正确的用户名和密码，并且同时选择十天内免登录。登录成功后，浏览器客户端会保存一个cookie，这个cookie中保存了用户名和密码等信息，这个cookie是保存在硬盘文件当中，十天有效，在十天内用户再次访问126的时候，浏览器自动提交126关联的cookie给服务器，服务器收到cookie之后，获取用户名和密码，验证，通过之后，自动登录成功。

## 怎么让cookie失效？

* cookie过期
* 修改密码
* 在浏览器上清除cookie

## Cookie类

在java的servlet中，对cookie提供了哪些支持呢？

* java提供了一个Cookie类类专门表示cookie数据，`jakarta.servlet.http.Cookie`
* java程序怎么把cookie数据发送给浏览器呢？`response.addCookie(cookie)`

>在HTTP协议中是这样规定的：当浏览器发送请求的时候，会自动携带该path下的cookie数据给服务器。（URL）

API：https://tomcat.apache.org/tomcat-7.0-doc/servletapi/index.html

## cookie的有效时间
```java
// 设置cookie在一小时后失效，保存在硬盘中
cookie.setMaxAge(60*60);
// 设置cookie的有效期为0，表示删除cookie，主要应用在：使用这种方式删除浏览器上的同名cookie
cookie.setMaxAge(0);
// 设置cookie的有效期<0，表示该cookie存储在浏览器运行内存中，不会存储到硬盘中
// 和不调用setMaxAge是同一效果
cookie.setMaxage(-1);
```

## cookie的path

假设现在发送的请求路径是`http://localhost:8080/servlet13/cookie/generate`生成cookie，如果cookie没有设置path，默认的path是什么？

* 默认的path是：`http://localhost:8080/servlet13/cookie`及它的子路径。
* 也就是说，以后只要浏览器请求的路径是`http://localhost:8080/servlet13/cookie`及它的子路径，cookie都会被发送到服务器。

>手动设置cookie的path：`cookie.setPath("servlet13");`表示只要是这个servlet13项目的请求路径，都会提交这个cookie给服务器。

## 服务器获取cookie

```java
Cookie[] cookies = request.getCookies();

// 如果不是null，表示一定有cookie
if (cookies != null) {
	// 遍历数组
	for (Cookie cookie: cookies) {

		// 获取cookie的name和value
		String name = cookie.getName();
		String value = cookie.getValue();
		System.out.println(name + "=" + value);
	}
}
```

## 视频

* start:https://www.bilibili.com/video/BV1Z3411C7NZ?p=47