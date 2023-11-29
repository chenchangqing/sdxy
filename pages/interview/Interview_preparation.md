# 面试准备

## 自我介绍

谢谢您今天给我的这次机会，我是Green，我的专业是计算机通信，9年iOS开发经验，3年Java开发经验，担任过iOS团队负责人，有团队管理经验，有组件化开发经验，具备独立开发能力，具备文档编写能力，有良好的代码习惯。

Thank you for giving me the opportunity to be interviewed for this position today. I'm Green. My major is computer communication. I have 9 years of experience in iOS development, 3 years of experience in Java development, and served as the leader of the iOS team. I have experience in team management, component development, independent development, document writing, and good code habits.

我大学的专业是计算机通信，10年来到上海从事Java后端方面的工作，做了几个OA功能的系统，主要使用的技术有JavaWeb相关的技术，像JAVA、SpringMVC、HTMl、JS等。从事Java大概3年多，我自学进入到了iOS行业，期间做过多媒体拍摄项目，RTC直播项目，对自研播放器有所了解。我掌握的技术章有OC、Swift，熟悉C、C++编程，掌握组件化编程，能够独立开发iOS项目。最近也学习了Flutter相关知识，通过阅读开源项目，对Flutter技术栈了解。

## 擅长技术

熟练`OC`、`Swift`、`Java`、`RxSwift`、`MVVM`、`MVC`、`Cocoapods`、`GCD`、`Git Flow`。  
熟悉`C`、`C++`、`Maven`、`HTML`、`JS`、`CSS`、`SQL`、`Mysql`、`Tomcat`、`JDBC`、`SSH`。  
了解`Android`、`Flutter`、`ReactNative`、`libRTMP`、`OpenGLES`、`FFmpeg`。

[视频播放器](视频播放器.html) [组件化开发](组件化开发.html) [设计模式](设计模式.html) [排序算法](排序算法.html) [数据结构](数据结构.html) [RSA](RSA.html) [CICD](../../pages/持续化集成CI/03_使用jenkins打包.html) [SwiftUI](SwiftUI.html) [敏捷开发](敏捷开发.html)

## 如何学习

在工作中，如果遇到自己不会的问题，通过Google、百度相关资料，然后总结记录。学习一门新技术，我会通过查看其官方教程或找学习视频，同时买一本书籍阅读，然后实践，再根据自己的理解总结写文章记录。

## 职业规划

结合自身还有目前的职业环境，我有认真想过这个问题。在工作方面，我想通过积极完成工作任务，积累各方面经验，让自己成为这个领域的专业人士，也希望有机会能够带领团队，成为优秀的管理者，为单位作出更大的贡献，实现双赢。在学习方面，打算在iOS专业领域做进一步学习和研究，同时也学习Android、H5等技术，为以后自己成为管理者做下铺垫。

## 提问环节

项目中会使用SwiftUI吗？

项目是针对海外客户吗？

一个功能需求下来，在开发人员开发着前，您最希望它做好哪些开发准备？

项目中难免存在一些不得不进行重构优化的代码，您是如何看待这个问题的？

## 面试问题

函数式编程：函数式编程的一个特点就是，允许把函数本身作为参数传入另一个函数，还允许返回一个函数！

线程间通信：内存共享、通知、等待、锁。

swift特性：元组、可选、解包、扩展、泛型、枚举、泛型关联、命名空间、权限关键字、协议、闭包。

内存管理：Swift使用自动引用计数（ARC）来简化内存管理，与OC一致。

swift语言、架构能力、block原理、swift特性、项目管理、代码规范。

## 内存管理

[OC 和 Swift 的弱引用源码分析](https://alvinzhu.me/2017/11/15/ios-weak-references.html)  
[iOS内存分配-栈和堆](https://juejin.cn/post/6938755477165572132)

## 多线程

[关于iOS多线程，你看我就够了](https://www.jianshu.com/p/0b0d9b1f1f19)

## 参考链接
 
[Swift 语言的一些功能特性](https://juejin.cn/post/6844903933786210317)  
[为何面试时都会问你的职业规划呢？该如何回答呢？](https://www.zhihu.com/question/20054953)  
[IOS面试题(其他) --- 英文自我介绍](https://www.jianshu.com/p/fb2d7370f38a)  

## 凯捷
---

### 代码加固**

https://zhuanlan.zhihu.com/p/33109826

1.字符串混淆

对应用程序中使用到的字符串进行加密，保证源码被逆向后不能看出字符串的直观含义。

2.类名、方法名混淆

对应用程序的方法名和方法体进行混淆，保证源码被逆向后很难明白它的真正功能。

3.程序结构混淆加密

对应用程序逻辑结构进行打乱混排，保证源码可读性降到最低。

4.反调试、反注入等一些主动保护策略

这是一些主动保护策略，增大破解者调试、分析App的门槛。

### 文件名重复会有什么影响

https://blog.csdn.net/weixin_33994429/article/details/93696758

duplicate symbol问题

### swift和oc的区别

1.Swift和Objective-C共用一套运行时环境，Swift的类型可以桥接到Objective-C。

2.swift是静态语言，有类型推断，更加安全，OC是动态语言。

3.swift支持泛型，OC只支持轻量泛型

4.Swift速度更快，运算性能更高。

5.Swift的访问权限变更。

7.Swift便捷的函数式编程。

8.swift有元组类型、支持运算符重载

9.swift引入了命名空间。

10.swift支持默认参数。

11.swift比oc代码更加简洁。

### struct和class的区别

https://blog.csdn.net/baidu_40537062/article/details/108349757

1.struct是值类型（Value Type）,深拷贝。class是引用类型（Reference Type），浅拷贝。

2.类允许被继承，结构体不允许被继承。

3.类中的每一个成员变量都必须被初始化，否则编译器会报错，而结构体不需要，编译器会自动帮我们生成init函数，给变量赋一个默认值。

4.NSUserDefaults：Struct 不能被序列化成 NSData 对象,无法归解档。

5.当你的项目的代码是 Swift 和 Objective-C 混合开发时，你会发现在 Objective-C 的代码里无法调用 Swift 的 Struct。因为要在 Objective-C 里调用 Swift 代码的话，对象需要继承于 NSObject。

6.class像oc的类一样，可以用kvo,kvc,runtime的相关方法，适用runtime系统。这些struct都不具备。

7.内存分配：struct分配在栈中，class分配在堆中。struct比class更“轻量级”（struct是跑车跑得快，class是SUV可以载更多的人和货物）。

### 验证HTTPS证书

1. 客户端向服务器发送支持的SSL/TSL的协议版本号，以及客户端支持的加密方法，和一个客户端生成的随机数。
2. 服务器确认协议版本和加密方法，向客户端发送一个由服务器生成的随机数，以及数字证书。
3. 客户端验证证书是否有效，有效则从证书中取出公钥，生成一个随机数，然后用公钥加密这个随机数，发给服务器。
4. 服务器用私钥解密，获取发来的随机数。
5. 客户端和服务器根据约定好的加密方法，使用前面生成的三个随机数，生成对话密钥，用来加密接下来的整个对话过程。

作者：阿拉斯加大狗
链接：https://juejin.cn/post/6844903892765900814
来源：稀土掘金
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。

### H5信息存储在哪

localStorage与？区别 cookie

### 图片宽高未知的情况下怎么自适应高度

1. Model层异步下载图片，然后缓存图片及图片宽高。
2. 图片显示先占位，按需加在图片，缓存图片及图片宽高，reload指定Cell。
3. 上传图片告诉服务器图片尺寸。
4. 通过约束让Cell高度随图片自适应。

### push很多页面后怎么控制导航栏里面的子控制器

1. push到相同页面产生递归。
2. 内存回收处理。

### 灵动岛

https://www.51cto.com/article/742613.html

展示： 紧凑(Compact)、最小化(Minimal)、扩展(Expanded)

开发框架：ActivityKit（实时活动）、SwiftUI（UI）、WidgetKit（小组件）

实时活动权限

### 静态库制作

https://www.jianshu.com/p/8ea45370a20d


### XCFramework

### H5的http拦截

### RSA 1024 2048区别

### Git分之管理

### 支付
