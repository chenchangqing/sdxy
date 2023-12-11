# Session
--- 

## 什么是会话？
用户打开浏览器，进行一系列操作，然后最终将浏览器关闭，这个整个过程叫做：一次会话。会话在服务器端也有一个对应的java对象，这个java对象叫做session。  

什么是一次请求：用户在浏览器上点击了一下，然后在页面停下来，可以粗略认为是一次请求。请求对应的服务器的java对象是request。  一次会话当中包含多次请求。

在java的servlet规范当中，session对象类名：HttpSession(jarkata.servlet.http.HttpSession)。  

session机制属于B/S结构的一部分。如果使用php语言开发WEB项目，同样也是有session这种机制的。session机制实际上是一种规范。然后不同的语言对这种会话机制都有实现。

## Session的作用

保存会话状态：用户登录成功了，这是一种刚登陆成功的状态，你怎么把登录成功的状态一只保存起来？使用session对象可以保留会话状态。

## 为什么需要session对象来保存会话状态呢？

因为HTTP协议是一种无状态协议。只要B和S断开了，那么关闭浏览器这个动作，服务器知道吗？不知道，服务器不知道浏览器关闭的。
>什么是无状态：请求的时候，B和S是连接的，但是请求结束之后，连接就断了。为什么要这么做？HTTP协议为什么要设计成这样？因为这样的无状态协议，可以降低服务器的压力，请求的瞬间是连接的，请求结束后，连接断开，这样服务器压力小。

## 为什么不使用request对象保存会话状态？

同问：为什么不是用ServletContext对象保存会话状态？

1）request是一次请求一个对象。  
2）ServletContext对象是服务器启动的时候创建，服务器关闭的时候销毁，这个ServletContext对象只有一个。  
3）ServletContext对象的域太大。  
4）request请求域（HttpServletRequest)、session会话域（HttpSession）、application域（ServletContext)  
5）request小于session小于application。

## 思考一下
```java
HttpSession session = request.getSession()；
```
这行代码很神奇：张三访问的时候获取的session对象就是张三的；李四访问的时候获取的session对象就是李四的。