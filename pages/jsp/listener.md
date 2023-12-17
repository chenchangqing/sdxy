# 监听器
---
* 23.12.17 23:41开始
* 23.12.18 0:50更新

## 什么是监听器

* 监听器是Servlet规范中的一员，就像Filter一样，Filter是Servlet规范中的一员。
* 在Servlet中，所有的监听器都是“Listener”结尾。

## 监听器作用

* 监听器实际上是Servlet规范留给我们javaweb程序员的特殊时机。
* 特殊的时刻如果想执行这段代码，你需要想到使用对应的监听器。

## 有哪些监听器

* jakarta.servlet包下：
	* ServletContextListener
	* ServletContextAttributeListener
	* ServletRequestListener
	* ServletRequestAttributeListener
* jakarta.servlet.http包下：
	* HttpSessionListener
	* HttpSessionAttributeListener
	* HttpSessionBindingListener
	* HttpSessionIdListener：session的ID发生改变。
	* HttpSessionActivationListener

## 配置ContextListener

**第一步：**编写一个类，实现ServeltContextListener接口，并且实现里面的方法

```java
public class MyServletContextListener implements ServeltContextListener {

	@Override
	public void contextInitialed(ServeltContextEvent sce) {// 服务器启动时间点
		// 这个方法是在ServletContext对象被创建的时候调用
		System.out.println("ervletContext对象被创建了");
	}

	@Override
	public void contextDestroyed(ServeltContextEvent sce) {// 服务器关闭时间点
		// 这个方法是在ServletContext对象被销毁的时候调用
		System.out.println("ervletContext对象被销毁了");
	}
}
```

**第二步：**在web.xml文件中对ServeltContextListener进行配置，如下：
```xml
<listener>
	<listener-class>com.xxx.javaweb.lister.MyServletContextListener</listener-class>
</listener>
```
或者使用注解：`@WebListener`

## 配置HttpSessionAttributeListener

```java
@WebListener
public class MyHttpSessionAttributeListener implements HttpSessionAttributeListener {
	// 向session域当中存储数据的时候，以下方法被WEB容器调用
	@Override
	public void attributeAdded(HttpSessionBindingEvent se) {
		System.out.println("session data add");
	}

	// 将session域当中存储的数据删除的时候，以下方法被WEB容器调用。
	@Override
	public void attributeRemoved(HttpSessionBindingEvent se) {
		System.out.println("session data remove");
	}

	// session域当中的某个数据被替换的时候，以下方法被WEB容器调用。
	@Override
	public void attributeReplaced(HttpSessionBindingEvent se) {
		System.out.println("session data replace");
	}
}
```

## 配置HttpSessionBindingListener
```java
public class User implements HttpSessionBindingListener {
	@Override
	public void valueBound(HttpSessionBindingEvent event) {
		System.out.println("绑定数据");
	}

	@Override
	public void valueUnBound(HttpSessionBindingEvent event) {
		System.out.println("解绑数据");
	}
}

// 将user存储到session域
session.setAttribute("user", user);
```

User实现了HttpSessionBindingListener，会触发监听方法。

## 统计在线用户个数

* 不考虑登录：可以使用`HttpSessionAttributeListener`实现。
* 考虑登录：需要使用`HttpSessionBindingListener`。

## HttpSessionActivationListener

* 监听session对象的钝化和活化的。
* 钝化：session对象从内存存储到硬盘文件。
* 活化：从硬盘文件把session恢复到内存中。

## 视频

* start:https://www.bilibili.com/video/BV1Z3411C7NZ?p=59
* end:https://www.bilibili.com/video/BV1Z3411C7NZ?p=62
