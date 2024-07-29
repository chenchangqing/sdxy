# 注解
---

Servlet3.0版本之后，推出了各种Servlet基于注解式开发。优点：

1）开发效率高，不需要编写大量的配置信息。直接在java类上使用注解进行标注。  
2）web.xml文件体积变小了。

## @WebServlet

类路径：jakarta.servlet.annotation.WebServlet，WebServlet注解有哪些属性？

1）name：用来指定Servlet的名字。<servlet-name>  
2）urlPatterns：用来制定Servlet的映射路径，可以指定多个字符串。<url-pattern>  
3）loadOnStartUp：用来指定在服务器启动阶段是否加载该Servlet。<load-on-startup>  
4）value：当注解属性名称为value的时候，使用注解的时候，value属性名可以省略。
>- 不是必须将所有属性都写上，只需要提供需要的。（需要什么用什么）
- 属性是一个数组，如果数组中只有一个元素，使用该注解的时候，属性值的大括号可以省略。
- 注解对象的使用格式：@注解名称{属性名=属性值}

## 解析注解

```java
// 使用反射机制将类上面的注解进行解析
// 获取类Class对象
Class<?> welcomeServletClass = Class.forName("com.xxx.WelcomeServlet");
// 先判断这个类上面有没有这个注解对象，如果有这个注解对象，就获取该注解对象
if(welcomeServletClass.isAnnotationPresent(WebServlet.class)) {
	// 获取这个类上面的注解对象
	WebServlet webServletAnnotation = welcomeServletClass.getAnnotation(WebServlet.class);
	// 获取注解的value属性值
	String[] value = webServletAnnotation.value();
	for(int i=0;i<value.length;i++) {
		System.out.println(value[i]);
	}
}
```

## 解决类爆炸

一个请求对应一个方法，一个业务对应一个Servlet类：

```java
@WebServlet({"/dept/list", "/dept/save", "/dept/edit", "/dept/detail", "/dept/delete", "/dept/modify"})
public class DeptServlet extends HttpServlet {
	@Override
	protected void service(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOExcepiton {
		// 获取servlet path
		String servletPath = request.getServletPath();
		if ("/dept/list".equals(servletPath)) {
			doList(request, response);
		} else if ("/dept/save".equals(servletPath)) {
			doSave(request, response);
		} else if ("/dept/edit".equals(servletPath)) {
			doEdit(request, response);
		} else if ("/dept/detail".equals(servletPath)) {
			doDetail(request, response);
		} else if ("/dept/delete".equals(servletPath)) {
			doDelete(request, response);
		} else if ("/dept/modify".equals(servletPath)) {
			doModify(request, response);
		}
	}

	private void doList(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOExcepiton {
	}

	private void doSave(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOExcepiton {
	}

	...
}
```

## @MultipartConfig

* [Servlet文件上传||@MultipartConfig标注属性](https://blog.csdn.net/stven_king/article/details/22957001)

## 视频

start:https://www.bilibili.com/video/BV1Z3411C7NZ?p=34  
end:https://www.bilibili.com/video/BV1Z3411C7NZ?p=35  