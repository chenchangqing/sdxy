# GenericServlet

## 编写一个GenericServlet

这个类是一个抽象类，其中有一个抽象方法service。  

1）GenericServlet实现Servlet接口。  
2）GenericServlet是一个适配器。  
3）以后编写的所有Servlet类继承GenericServlet，重写service方法即可。

## 思考

GenericServlet是否需要改造一下？怎么改造？更便于子类程序的编写？

1）我提供了一个GenericServlet之后，init方法还会执行吗？
```
还会执行。会执行GenericServlet类中的init方法。
```
2）init方法是谁调用的？
```
Tomcat服务器调用的。
```
3）init方法中的ServletConfig对象是谁创建的？是谁传递过来的？
```
- 都是Tomcat干的。
- Tomcat服务器先创建了ServletConfig对象，然后调用init方法，将ServletConfig对象传递给了init方法。
```
4）Tomcat服务器为代码
```java
public class Tomcat {
	public static void main(String[] args) {
		// 创建LoginServlet对象（通过反射机制，调用无参数构造方法来实例化LoginServlet对象）
		Class clazz = Class.forName("com.xxx.javaweb.servlet.LoginServlet");
		Object obj = clazz.newInstance();

		// 向下转型
		Servlet servlet = (Servlet)obj;

		// 创建ServletConfig对象
		// Tomcat负责将ServletConfig对象实例化出来
		ServletConfig servletConfig = new org.apache.catalina.core.StandardwrapperFacade();

		// 调用Servlet的init方法
		servlet.init(servletConfig);

		// 调用Servlet的service方法
		...
	}
}
```

## 注意

以后我们编写Servlet类的时候，实际上是不会去直接继承GenericServlet类的，因为我们是B/S结构的系统，这种系统是基于HTTP超文本传输协议的，在Servlet规范当中，提供了一个类叫做HttpServlet，它是专门为HTTP协议准备的一个Servlet类。我们编写的Servlet类药即成HttpServlet。（HttpServlet是HTTP协议专用的）使用HttpServlet处理HTTP协议更便捷。但是你需要知道他的继承结构：
```
jakarta.servlet.Servlet（接口）爷爷
jakarta.servlet.GenericServlet（抽象类）儿子
jakarta.servlet.http.HttpServlet（抽象类）孙子
```

## 视频地址

https://www.bilibili.com/video/BV1Z3411C7NZ?p=13