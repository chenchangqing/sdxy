# HttpServlet
---
HttpServlet在`jakarta.servlet.http`包里，HttpServlet类是专门为HTTP协议准备的，比GenericServlet更加适合HTTP协议下的开发。

## Servlet规范中的接口
jakarta.servlet.Servlet **核心接口（接口）**  
jakarta.servlet.ServletConfig **Servlet配置信息接口（接口）**  
jakarta.servlet.ServletContext **Servlet上下文接口（接口）**  
jakarta.servlet.ServletRequest **Servlet请求接口（接口）**	
jakarta.servlet.ServletResponse **Servlet响应接口（接口）**	
jakarta.servlet.ServletException **Servlet异常（类）**	
jakarta.servlet.GenericServlet **标准通用的Servlet类（抽象类）**

## http包下都有哪些类和接口？  	
jakarta.servlet.http.HttpServlet **HTTP协议专用的Servlet类，抽象类**  	
jakarta.servlet.http.HttpServletRequest **HTTP协议专用的请求对象**  
jakarta.servlet.http.HttpServletResponse **HTTP协议专用的响应对象**  

## HttpServlet Request对象中封装了什么信息？
HttpServletRequest，简称request对象，封装了请求协议的全部内容。Tomcat服务器（WEB容器）将“请求协议”中的数据全部解析出来，然后将这些数据全部封装到request对象当中了。也就是说，我们只要面向HttpServletRequest，就可以获取请求协议中的信息。

## HttpServletResponse 

专门用来响应HTTP协议到浏览器的。

## Servlet生命周期

#### 用户第一次请求
- Tomcat服务器通过反射机制，调用无参数构造方法，创建Servlet对象。（web.xml文件中配置的Servlet类对应的对象。）
- Tomcat服务器调用Servlet对象的init方法完成初始化。
- Tomcat服务器调用Servlet对象的service方法处理请求。

#### 用户第二次请求
- Tomcat服务器调用Servlet对象的service方法处理请求。

#### 用户第三次请求
- Tomcat服务器调用Servlet对象的service方法处理请求。

#### 用户第N次请求
- Tomcat服务器调用Servlet对象的service方法处理请求。

#### 服务器关闭
- Tomcat服务器调用Servlet的对象的destroy方法，做销毁之前的准备工作。
- Tomcat服务器销毁Servlet对象。

## HttpServlet源码分析
HelloServlet：
```java
public class HelloServlet extends HttpServlet {
	// 用户第一次请求，创建HelloServlet对象的时候，会执行这个无参数的方法。
    public HttpServlet() {
    }

    // override 重写 doGet方法
    // override 重写 doPost方法
}

public abstract class GenericServlet implements Servlet, ServletConfig, Serializable {
	// 用户第一次请求的时候，HelloServlet对象第一次被创建之后，这个init方法会执行
	public void init(ServletConfig config) throws ServletException {
        this.config = config;
        this.init();
    }
    // 用户第一次请求的时候，带有参数的`init(ServletConfig config)`执行之后，会执行这个没有参数的init()
	public void init() throws ServletException {
	}
}
```
HttpServlet：
```java
// HttpServlet模板类
public abstract class HttpServlet extends GenericServlet {
	// 用户发送第一次请求的时候，这个service会执行
	// 用户发送第N次请求的时候，这个service方法还是会执行
	// 用户只要发送一次请求，这个service方法就会执行一次
	public void service(ServletRequest req, ServletResponse res) throws ServletException, IOException {
        if (req instanceof HttpServletRequest && res instanceof HttpServletResponse) {
        	// 将ServletRequest和ServletResponse向下转型为带有Http的HttpServlet和HttpServletResponse
            HttpServletRequest request = (HttpServletRequest)req;
            HttpServletResponse response = (HttpServletResponse)res;
            // 调用重载的service方法
            this.service(request, response);
        } else {
            throw new ServletException("non-HTTP request or response");
        }
    }
    // 这个service方法的两个参数都是带有Http的
    // 这个service是一个模板方法。
    // 在该方法中定义核心算法骨架，具体的实现步骤延迟到子类中去完成。
	protected void service(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		// 获取请求方式
		// 这个请求方式最终可能是：“”
		// 注意：request.getMethod()方法获取的时候请求方式，可能是七种之一
		// GET POST PUT DELETE HEAD OPTIONS TRACE
        String method = req.getMethod();
        long lastModified;
        if (method.equals("GET")) {
        	// 如果请求方式是GET，这执行doGet
            lastModified = this.getLastModified(req);
            if (lastModified == -1L) {
                this.doGet(req, resp);
            } else {
                long ifModifiedSince = req.getDateHeader("If-Modified-Since");
                if (ifModifiedSince < lastModified) {
                    this.maybeSetLastModified(resp, lastModified);
                    this.doGet(req, resp);
                } else {
                    resp.setStatus(304);
                }
            }
        } else if (method.equals("HEAD")) {
            lastModified = this.getLastModified(req);
            this.maybeSetLastModified(resp, lastModified);
            this.doHead(req, resp);
        } else if (method.equals("POST")) {
        	// 如果请求方式是POST，这执行doPost
            this.doPost(req, resp);
        } else if (method.equals("PUT")) {
            this.doPut(req, resp);
        } else if (method.equals("DELETE")) {
            this.doDelete(req, resp);
        } else if (method.equals("OPTIONS")) {
            this.doOptions(req, resp);
        } else if (method.equals("TRACE")) {
            this.doTrace(req, resp);
        } else {
            String errMsg = lStrings.getString("http.method_not_implemented");
            Object[] errArgs = new Object[]{method};
            errMsg = MessageFormat.format(errMsg, errArgs);
            resp.sendError(501, errMsg);
        }

    }

    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
    	// 报405错误
        String protocol = req.getProtocol();
        String msg = lStrings.getString("http.method_get_not_supported");
        resp.sendError(this.getMethodNotSupportedCode(protocol), msg);
    }

    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
    	// 报405错误
        String protocol = req.getProtocol();
        String msg = lStrings.getString("http.method_post_not_supported");
        resp.sendError(this.getMethodNotSupportedCode(protocol), msg);
    }
}
```

#### 通过以上源代码分析：

1）假设前端发送的请求是get请求，后端程序员重写的方法是doPost；发生405这样的错误。  
2）假设前端发送的请求是post请求，后端程序员重写的方法是doGet；发生405这样的错误。	
3）只要HttpServlet类中的doGet方法或doPost方法执行了，必然405。	
4）HelloServlet继承HttpServelt，重写HttpServlet类中的service()方法，享受不到405错误，享受不到HTTP协议专属的东西。

>405表示前端的错误，发送的请求方式不对。和服务器不一致。不是服务器需要的请求方式。

## Servlet类的开发步骤

1）编写一个Servlet类，直接继承HttpServlet；  
2）重写doGet方法或者重写doPost方法，到底重写谁，javaweb程序员说了算；  
3）将Servlet类配置到web.xml文件当中。  
4）准备前端的页面（form表单），form表单中指定请求路径即可。

## 视频地址

https://www.bilibili.com/video/BV1Z3411C7NZ?p=20