# HttpServletRequest接口

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

