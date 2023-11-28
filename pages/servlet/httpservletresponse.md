# HttpServletResponse接口

1. 介绍：
	1. HttpServletResponse接口来自于Servlet规范中，在Tomcat中存在servlet-api.jar
	2. HttpServletResponse接口实现类由Http服务器负责提供。
	3. HttpServletResponse接口负责将doGet/doPost方法执行结果写入到【响应体】交给浏览器。
	4. 开发人员习惯于将HttpServletResponse接口修饰的对象称为【响应对象】。
2. 主要功能：
	1. 将执行接口以二进制形式写入到【响应体】。
	2. 设置响应头中【content-type】属性值，从而控制浏览器使用，对应编译器将响应体二进制数据编译为【文字、图片、视频、命令】
	3. 设置响应头中【location】属性，将一个请求地址赋值给location，从而控制浏览器向执行服务器发送请求。

3. 实例：
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
4. 实例2:
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
	浏览器显示不是50，时是2？

	out.writer方法将【字符】、【字符串】、【ASCII码】写入到响应体，【ASCII码】 a ---> 97, 2 ---> 50，这里的50对应2，所以显示2。

	out.write(result) ---> out.print(result)，这样就会显示50。

5. 实例3：
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
	浏览器在接收到响应结果时，将<br/>作为文字内容在窗口展示出来，没有将<br/>当作HTML变迁命令来执行。

	问题原因：浏览器在接收到响应包之后，根据【响应头中content-type】属性的值，来采用对应【编译器】对【响应体中二进制内容】进行编译处理。

	在默认的情况下，content-type的属性值为“text”，content-type="text"，此时浏览器回采用【文本编译器】对响应体二进制数据进行解析。

	解决方案：一定要在得到输出流之前，通过响应对象对应响应头中content-type的属性进行一次重新赋值用于指定浏览器采用正确编译器。
	```java
	// 设置响应头content-type
	response.setContentType("text/html");
	```
6. 实例4：
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
	中文字符不可以正确显示？出现？？？

	charset=ISO-8859-1：偏东欧的字符集，应该修改为charset=utf-8。
	```java
	response.setContentType("text/html;charset=utf-8");
	```
7. 实例5:
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
	浏览器在接收到响应包之后，如果发现响应头中存在location属性，自动通过地址栏向location指定网站发送请求。

	sendRedirect方法远程控制浏览器请求行为【请求地址，请求方式，请求参数】。