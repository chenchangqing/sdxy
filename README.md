 
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

* request是一次请求一个对象。  
* ServletContext对象是服务器启动的时候创建，服务器关闭的时候销毁，这个ServletContext对象只有一个。  
* ServletContext对象的域太大。  
* request请求域（HttpServletRequest)、session会话域（HttpSession）、application域（ServletContext)  
* request小于session小于application。

## 思考一下
```java
HttpSession session = request.getSession()；
```
这行代码很神奇：张三访问的时候获取的session对象就是张三的；李四访问的时候获取的session对象就是李四的。

## session的实现原理

1. JSESSIONID=xxxx 这个是一Cookie的形式保存在浏览器的内存中的。浏览器只要关闭，这个cookie就没有了。  
2. session列表是一个Map，map的key是sessionid，map的value是session对象。  
3. 用户第一次请求，服务器生成session对象，同时生成ID，将ID发送给浏览器。  
4. 用户第二次请求，自动将浏览器内存中的ID发送给服务器，服务器根据ID查找session对象。  
5. 关闭浏览器，内存消失，cookie消失，sessionid消失，会话等同于结束。

## Cookie禁用了，session还能找到吗？

* cookie禁用是什么意思？服务器正常发送cookie给浏览器，但是浏览器不要了，拒收了，并不是服务器不发了。  
* 找不到了，每次请求都会获取到新的session对象。
* cookie禁用了，session机制还能实现吗？可以，需要使用URL重写机制。
    http://xxxx;jsessionid=DD5EC49931F2AC378DC68548C9E5?v=f050045a0c

>URL重写机制会提高开发者的成本，开发人员在编写任何请求路径的时候，后面都要添加一个sessionid，给开发带来了很大的难度，很大的成本，所以大部分的网站都是这样设计：你要是禁用cookie，你就别用了。

## 销毁session对象

```java
session.invalidate();
```

## 视频

* start:https://www.bilibili.com/video/BV1Z3411C7NZ?p=44
* end:https://www.bilibili.com/video/BV1Z3411C7NZ?p=45

<div style="margin: 0px;">
    备案号：
    <a href="https://beian.miit.gov.cn/" target="_blank">
        <!-- <img src="https://api.azpay.cn/808/1.png" style="height: 20px;"> -->沪ICP备2022002183号-1
    </a >
</div>

