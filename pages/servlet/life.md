# Servlet生命周期

## 什么是Servlet对象生命周期
- Servlet对象什么时候被创建
- Servlet对象什么时候被销毁
- Servlet对象创建了几个？
- Servlet对象的生命周期表示：一个Servlet对象从出生在最后的死亡，整个过程是怎么样的。

## Servlet对象是由谁来维护的？
- Servlet对象的创建，对象上方法的调用，对象最终的销毁，Javaweb程序员是无权干预的
- Servlet对象的生命周期是由Tomcat服务器（WEB Server）全权负责的。
- Tomcat服务器通常我们又称为WEB容器。
- WEB容器管理Servlet对象的死活。

## 思考：我们自己new的Servlet对象受WEB容器管理吗？
- 我们自己new的Servlet对象是不受WEB容器管理的。
- WEB容器创建的Servlet对象，这些Servlet对象都会被放到一个集合（HashMap），只有放到这个HashMap集合中的Servlet才能够被WEB容器管理，自己new的Servlet对象不会被WEB容器管理。（自己new的Servlet对象不在容器当中）。

## 研究：服务器在启动的时候，Servlet对象有没有创建出来？（默认情况下）
- 在Servlet中提供一个无参数的构造方法，启动服务器的时候看看构造方法是否执行。
- 经过测试得出结论：默认情况下，服务器在启动的时候Servlet对象并不会被实例化。
- 这个设计是合理的。用户没有发送请求之前，如果提前创建出来所有的Servlet对象，必然是耗费内存的，并且创建出来的Servlet如果一只没有用户访问，显然这个Servlet对象是一个废物，没必要先创建。

## 怎么让服务器启动的时候创建Servlet对象呢？

在默认情况下，Http服务器接收到对于当前Servlet接口实现类第一次请求时，自动创建这个Servlet接口实现类的实例对象。
	在手动配置情况下，要求Http服务器在启动时自动创建某个Servlet接口实现类的实例对象：
```
<servlet>
	<servelt-name>mm</servlet-name><!-- 声明一个变量存储servlet接口实现类类路径 -->
	<servlet-class>com.xxxx.controller.OneServlet</servlet-class><!-- 声明servlet接口实现类 -->
	<load-on-startup>30</load-on-starup><!-- 填写一个大于0的整数即可 -->
</servlet>
```

## Servlet对象生命周期

- 默认情况服务器启动的时候AServlet对象并没有被实例化。

### 用户发送第一次请求
- 用户发送第一次请求的时候，AServlet对象被实例化了。
- AServlet对象被创建出来之后，Tomcat服务器马上调用了AServlet对象的init方法。
- 用户发送第一次请你去的时候，init方法执行之后，Tomcat服务器马上调用了AServlet对象的service方法。

### 用户发送第二次请求
- Servlet对象并没有新建，还是使用之前创建好的Servlet对象，直接调用该Servlet对象的service方法。
- Servlet对象是单例的（单实例，但是要注意：Servlet对象是单实例的，但是Servlet类并不符合单里模式，我们称为假单例。之所以单例是因为Servlet对象的创建我们javaweb程序员管不着，这个对象的创建只能是Tomcat来说了算，Tomcat只创建了一个，所以导致了单例，但是属于假单里，真单例模式，构造方法是私有化的。）
- 无参构造方法、init方法只在第一次用户发送请求的时候执行，也就是说无参数构造方法只能执行一次。init方法也只被tomcat服务器调用一次。
- 只要用户发送一次请求：service方法必然会被Tomcat服务器调用一次。发送100次请求，service方法会被调用100次。

### 关闭服务器的时候
- 服务器销毁AServlet的对象内存
- 服务器会自动调用AServlet对象的destroy方法。

## 关于Servlet类中方法的调用次数？
- 构造方法只执行一次。
- init方法只执行一次。
- service方法：用户发送一次请求则执行一次，发送N次请求则执行N次。
- destroy方法只执行一次。

## 当我们Servlet类中编写一个由参数的构造方法，如果没有编写无参数构造方法会出现什么问题？
- 报错了：500错误。
- 注意：500是一个HTTP协议的错误状态码。
- 500一般情况下是因为服务器端的java程序出现了异常。
- 如果没有无参数的构造方法，会导致出现500错误，无法实例化Servlet对象。
- 所以，一定要注意：在Servlet开发当中，不建议程序员来定义构造方法，因为定义不当，一不小心就会导致无法实例化Servlet对象。

## 思考：Servlet的无参数构造方法是在对象第一次创建的时候执行，并且只执行一次，init方法也是在对象第一次创建的时候执行，并且只执行一次，那么这个无参数构造方法可以代替init方法吗？
- 不能
- Servlet规范中有要求，作为javaweb程序员，编写Servlet类的时候，不建议手动编写构造方法，因为编写构造方法，很容易让无参数构造方法消失，这个操作可能会导致Servlet对象无法实例化，所以init方法是有存在的必要的。

## 视频地址

https://www.bilibili.com/video/BV1Z3411C7NZ?p=11





