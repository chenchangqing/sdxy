# Servlet生命周期

1. 网站中所有的Servlet接口实现类的实例对象，只能由Http服务器负责创建。开发人员不能手动创建Servlet接口实现类的实例对象。
2. 在默认情况下，Http服务器接收到对于当前Servlet接口实现类第一次请求时，自动创建这个Servlet接口实现类的实例对象。
	在手动配置情况下，要求Http服务器在启动时自动创建某个Servlet接口实现类的实例对象：
	```
	<servlet>
		<servelt-name>mm</servlet-name><!-- 声明一个变量存储servlet接口实现类类路径 -->
		<servlet-class>com.xxxx.controller.OneServlet</servlet-class><!-- 声明servlet接口实现类 -->
		<load-on-startup>30</load-on-starup><!-- 天蝎一个大于0的整数即可 -->
	</servlet>
	```
3. 在Http服务器运行期间，一个Servlet接口实现类只能被创建出一个实例对象。
4. 在Http服务器关闭时刻，自动将网站中所有的Servlet对象进行销毁。

### HttpServletResponse接口

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

### HttpServletRequest接口

1. 介绍：
	1. HttpServletRequest接口来自于Servlet规范中，在Tomcat中存在servlet-api.jar
	2. HttpServletRequest接口实现类由Http服务器负责提供。
	3. HttpServletReqeust接口负责在doGet/doPost方法运行时读区http请求协议包中信息。
	4. 开发人员习惯于将HttpServletRequest接口修饰的对象称为【请求对象】。
2. 作用：
	1. 可以读区Http请求协议包中【请求行】信息
	2. 可以读区保存在Http请求协议包中【请求头】或者【请求体】中国呢的请求参数信息。
	3. 可以带起浏览器向Http服曲奇申请资源文件调用。

3. 实例：
	```java
	public class Servlet1 extends HttpServlet {
		protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOExcepiton {
			// 1. 通过请求对象，读取【请求行】中【url】信息
			String url = request.getRequestURL().toString();
			// 2. 通过请求对象，读取【请求行】中【method】信息
			String method = request.getMethod();
			// 3. 通过请求对象，读取【请求行】中uri信息
			String uri = request.getRequestURI();// substring
			System.out.println("URL "+url);
			System.out.println("method "+method);
			System.out.println("URI "+uri);
		}
	}
	```
	URI：资源文件精准定位地址，在请求行并没有URL这个属性，实际上URL中截取一个字符串，这个字符串格式“/网站名/资源文件名”，URI用于让Http服务器对被访问的资源文件进行定位。

4. 实例2:
	```java
	public class Servlet2 extends HttpServlet {
		protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOExcepiton {
			// 1. 通过请求对象，读取【请求行】中【所有请求参数名】信息
			Enumeration paramNames = request.getParameterNames();// 将所有请求参数名称保存到一个枚举对象进行返回
			while(paramNames.hasMoreElements()) {
				String paramName = (String)paramNames.nextElement();
				// 2. 通过请求对象读取指定的参数名称的值
				String value = request.getParameter(paramName);
				System.out.println("请求参数名 "+paramName+" 请求参数值"+value);
			}
		}
	}
	```
5. 实例3:
	```java
	public class Servlet3 extends HttpServlet {
		protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOExcepiton {
			// 通过请求对象，读取【请求头】参数信息
			String userName = request.getParameter("userName");
			System.out.println("从请求头得到参数值 "+userName);
		}
		protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOExcepiton {
			// 通过请求对象，读取【请求体】参数信息
			String value = request.getParameter("userName");
			Sytem.out.println("从请求体得到参数值 "+value);
		}
	}
	```
	问题：以GET方式发送中文参数内容“老杨是个正经人”时，得到正常值，以POST方式发送中文参数内容“劳瘁是个男人”，得到【乱码】“？？？？？”

	原因：浏览器以GET方式发送请求，请求参数保存在【请求头】，在Http请求协议包到达http服务器之后，第一件事就是进行解码请求头二进制内容由Tomcat9.0默认使用【utf-8】字符集，可以解析一切国家文字。

	浏览器以POST发送请求，请求参数保存在【请求体】，在Http请求协议包到达http服务器之后，第一件事就是进行解码，请求体二进制内容由当前请求（request）负责接吗，request默认使用【ISO-8859-1】字符集，一个东欧语系字符集，此时如果请求体参数内容是中文，将无法接嘛只能得到乱码。

	解决方案：在Post请求方式下，在读取请求体内容执勤啊，应该通知请求对象使用utf-8字符集请求体内容进行一次重新解码。
	```java
	request.setCHaracterEncoding("utf-8");
	```
	
### 请求对象和响应对象生命周期

1. http服务器接收到浏览器发送的【http请求协议包】之后，自动为当前的【Http请求协议包】生成1个【请求对象】和1一个【响应对象】。

2. 在http服务器调用doGet/doPost方法时，负责将【请求对象】和【响应对象】作为实参传递到方法，确保doGet/doPost正确执行。

3. 在http服务器准备推送http响应协议包之前，负责将本次请求关联的【请求对象】和【响应对象】销毁。

【请求对象】和【响应对象】生命周期贯穿一次请求的处理过程中，【请求对象】和【响应对象】相当于用户在服务端的代言人。





