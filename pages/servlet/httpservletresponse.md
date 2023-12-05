# HttpServletResponse

## 什么是HttpServletResponse？

1）HttpServletResponse是一个接口，全限定名称：jakarta.servlet.http.HttpServletResponse。  
2）HttpServletResponse接口Servlet规范中的一员，在Tomcat中存在servlet-api.jar。  
3）HttpServletResponse接口实现类由Http服务器负责提供。  
4）HttpServletResponse接口负责将doGet/doPost方法执行结果以二进制形式写入到【响应体】交给浏览器。  
5）开发人员习惯于将HttpServletResponse接口修饰的对象称为【响应对象】。  
6）设置响应头中【content-type】属性值，从而控制浏览器使用，对应编译器将响应体二进制数据编译为【文字、图片、视频、命令】。  
7）设置响应头中【location】属性，将一个请求地址赋值给location，从而控制浏览器向执行服务器发送请求。  

## 写入Hello world响应体
```java
public class OneServlet extends HttpServlet {
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOExcepiton {

		String result = "Hello，world";
		// ----- 响应对象将结果写入到响应体 ---- start
		// 1. 通过响应对象，向Tomcat索要输出流
		PrintWriter out = response.getWriter();
		// 2. 通过输出流，将执行结果以二进制形式写入到响应体
		out.write(result);
		// ----- 响应对象将结果写入到响应体 ---- end
	}
}
```

## 写入50，浏览器显示的是2？
```java
public class TwoServlet extends HttpServlet {
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOExcepiton {

		String result = 50;
		// ----- 响应对象将结果写入到响应体 ---- start
		// 1. 通过响应对象，向Tomcat索要输出流
		PrintWriter out = response.getWriter();
		// 2. 通过输出流，将执行结果以二进制形式写入到响应体
		out.write(result);
		// ----- 响应对象将结果写入到响应体 ---- end
	}
}
```
**问题：**浏览器显示不是50，而是2？

**原因：**out.writer方法将【字符】、【字符串】、【ASCII码】写入到响应体，【ASCII码】 a ---> 97, 2 ---> 50，这里的50对应2，所以显示2。

**修改：**out.write(result) ---> out.print(result)，这样就会显示50。

## 解析HTML
```java
public class ThreeServlet extends HttpServlet {
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOExcepiton {

		String result = "Java<br/>Mysql<br/>HTML<br/>";
		// ----- 响应对象将结果写入到响应体 ---- start
		// 1. 通过响应对象，向Tomcat索要输出流
		PrintWriter out = response.getWriter();
		// 2. 通过输出流，将执行结果以二进制形式写入到响应体
		out.print(result);
		// ----- 响应对象将结果写入到响应体 ---- end
	}
}
```
**问题：**浏览器在接收到响应结果时，将<br/>作为文字内容在窗口展示出来，没有将<br/>当作HTML变迁命令来执行。

**原因：**浏览器在接收到响应包之后，根据【响应头中content-type】属性的值，来采用对应【编译器】对【响应体中二进制内容】进行编译处理。在默认的情况下，content-type的属性值为“text”，content-type="text"，此时浏览器回采用【文本编译器】对响应体二进制数据进行解析。

**修改：**一定要在得到输出流之前，通过响应对象对应响应头中content-type的属性进行一次重新赋值用于指定浏览器采用正确编译器。
```java
// 设置响应头content-type
response.setContentType("text/html");
```

## 中文乱码
```java
public class ThreeServlet extends HttpServlet {
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOExcepiton {
		// 设置响应头content-type
		response.setContentType("text/html");

		String result = "Java<br/>Mysql<br/>HTML<br/>";
		String result2 = "红烧排骨<br/>梅菜扣肉<br/>糖处里脊"
		// ----- 响应对象将结果写入到响应体 ---- start
		// 1. 通过响应对象，向Tomcat索要输出流
		PrintWriter out = response.getWriter();
		// 2. 通过输出流，将执行结果以二进制形式写入到响应体
		out.print(result);
		out.print(result2);
		// ----- 响应对象将结果写入到响应体 ---- end
	}
}
```
**问题：**中文字符不可以正确显示？出现？？？

**修改：**
```java
response.setContentType("text/html;charset=utf-8");
```
>charset=ISO-8859-1：偏东欧的字符集，应该修改为charset=utf-8。

## 重定向
```java
public class FourServlet extends HttpServlet {
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOExcepiton {
		// 设置响应头content-type
		response.setContentType("text/html;charset=utf-8;");

		String result = "http://www.baidu.com";

		// 通过响应对象，将地址赋值给响应头中location属性
		response.sendRedirect(result);// [响应头 location="http://www.baidu.com"]
	}
}
```
**重定向：**浏览器在接收到响应包之后，如果发现响应头中存在location属性，自动通过地址栏向location指定网站发送请求。

`sendRedirect`方法远程控制浏览器请求行为【请求地址，请求方式，请求参数】。

## 转发和重定向区别

#### 1）代码区别

转发：
```java
request.getRequestDispatcher("/xxx").forward(request, response);
```
重定向：
```java
response.sendRedirect("/xxx/b");
```
>注意：路径上要加xxx项目名。因为浏览器发送请求，请求路径上需要添加项目名。

#### 2）形式区别
转发（一次请求）：在浏览器地址栏上发送的请求是：http://localhost:8080/xxx/a ，最终请求结束之后，浏览器地址上的地址还是这个，没变；

重定向（两次请求）：在浏览器地址栏上发送的请求是：http://localhost:8080/xxx/a ，最终在浏览器地址栏上显示的地址是：http://localhost:8080/xxx/b 。

#### 3）本质区别
转发：是由WEB服务器来控制的，A资源跳转到B资源，这个跳转动作是Tomcat服务器内部完成的；

重定向：是浏览器完成的，具体跳转到哪个资源，是浏览器说了算。

## 转发和重定向应该如何选择？

如果在上一个Servlet当中向request域当中绑定了数据，希望从下一个Servlet当中把request域里面的数据取出来，使用转发机制；剩下所有的请求均使用重定向。
>转发不会改变请求方法，比如doPost请求转发至doGet请求，会导致进入下个请求的doPost，出现405错误，这个时候需要考虑使用重定向。

## 视频

start:https://www.bilibili.com/video/BV1Z3411C7NZ?p=32  

2023.12.5 11:52