 
# HttpServletRequest

## 什么是HttpServletReqeust？
1）HttpServletRequest是一个接口，全限定名称：jakarta.servlet.http.HttpServletRequest。  
2）HttpServletRequest接口是Servlet规范中的一员，在Tomcat中存在servlet-api.jar。  
3）HttpServletRequest接口实现类由Http服务器负责提供。  
4）HttpServletReqeust接口负责在doGet/doPost方法运行时读区http请求协议包中信息。  
5）开发人员习惯于将HttpServletRequest接口修饰的对象称为【请求对象】。 

## HttpServletRequest父接口
jakarta.servlet.ServletRequest：
```java
public interface HttpServletRequest extends ServletRequest {}
```

## HttpServletRequest实现类
`org.apache.catalina.connector.RequestFacade`
```java
public class RequestFacade implements HttpServletRequest {}
```
>Tomcat服务器实现了HttpServletRequest接口，也说明了了Tomcat服务器实现了Servlet规范。

## HttpServletRequest对象中有什么信息？
1）HttpServletRequest对象是Tomcat服务器负责创建的。封装了HTTP的请求协议。  
>实际上是用户发送请求的时候，遵循了HTTP协议，发送的是HTTP的请求协议，Tomcat服务器将HTTP协议中的信息以及数据全部解析出来，然后Tomcat服务器把这些信息封装到HttpServletRequest对象当中，传给了javaweb程序员。

## request对象和response对象生命周期
1）http服务器接收到浏览器发送的【http请求协议包】之后，自动为当前的【Http请求协议包】生成1个【请求对象】和1一个【响应对象】。  
2）在http服务器调用doGet/doPost方法时，负责将【请求对象】和【响应对象】作为实参传递到方法，确保doGet/doPost正确执行。  
3）在http服务器准备推送http响应协议包之前，负责将本次请求关联的【请求对象】和【响应对象】销毁。  
>【请求对象】和【响应对象】生命周期贯穿一次请求的处理过程中，【请求对象】和【响应对象】相当于用户在服务端的代言人。

## 获取前端浏览器用户提交的数据
```java
String getParameter(String name)
Map<String,String[]>getParameterMap()
Enumeration<String>getParameterNames()
String[] getParameterValues(String name)
```
以上4个方法和获取用户提交的数据有关系。
>注意：`getParameterValues`之所以使用`String[]`格式，是因为前端提交的数据格式可能是：name=张三&name=李四，解决同一个key对应了多个值的问题。

## 获取请求信息

javaweb程序员面向HttpServletRequest接口编程，调用方法就可以获取请求的信息了。
>请求信息包括：请求行、请求头、请求体。

**1）获取请求行信息：**
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
>URI：资源文件精准定位地址，在请求行并没有URL这个属性，实际上URL中截取一个字符串，这个字符串格式“/网站名/资源文件名”，URI用于让Http服务器对被访问的资源文件进行定位。

**2）获取请求体信息：**
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

## 请求转发
可以代替浏览器向Http服务器申请资源文件调用。

```java
// 第一步：获取请求转发器对象
RequestDispatcher dispatcher = request.getRequestDispatcher("/xxx");
// 第二步：调用转发器的forward方法完成跳转/转发
dispatcher.forward(request, response);
```
```java
// 第一步和第二步代码可以联合在一起
request.getRequestDispatcher("/xxx").forward(request, response);
```
>转发的时候，转发的路径以“/”开始，不加项目名。
    
## 中文乱码

**1）Post请求**
```java
public class Servlet3 extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOExcepiton {
        // 通过请求对象，读取【请求体】参数信息
        String value = request.getParameter("userName");
        Sytem.out.println("从请求体得到参数值 "+value);
    }
}
```
问题：以POST方式发送中文参数内容“劳瘁是个男人”，得到【乱码】“？？？？？”

原因：浏览器以POST发送请求，请求参数保存在【请求体】，在Http请求协议包到达http服务器之后，第一件事就是进行解码，请求体二进制内容由当前请求（request）负责解码，request默认使用【ISO-8859-1】字符集，一个东欧语系字符集，此时如果请求体参数内容是中文，将无法解码只能得到乱码。

解决：在Post请求方式下，在读取请求体内容时，应该通知请求对象使用utf-8字符集请求体内容进行一次重新解码。
```java
request.setCHaracterEncoding("utf-8");
```
>Tomcat10不会乱码，Tomcat8、9都会乱码。

**2）Get请求**
```java
public class Servlet3 extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOExcepiton {
        // 通过请求对象，读取【请求头】参数信息
        String userName = request.getParameter("userName");
        System.out.println("从请求头得到参数值 "+userName);
    }
}
```
问题：以GET方式发送中文参数内容“老杨是个正经人”时，得到正常值，

原因：浏览器以GET方式发送请求，请求参数保存在【请求头】，在Http请求协议包到达http服务器之后，第一件事就是进行解码请求头二进制内容由Tomcat9.0默认使用【utf-8】字符集，可以解析一切国家文字。 

Get请求中文乱码怎么解决？修改`CATALINA_HOME/conf/server.xml`配置文件。
```xml
<Connector- URIEncoding="UTF-8" />
```
如何查看Tomcat默认使用什么字符集解析Get请求：`CATALINA_HOME/webapps/docs/config/http.html`找到URIEncoding说明。例如tomcat7:
>This specifies the character encoding used to decode the URI bytes, after %xx decoding the URL. If not specified, ISO-8859-1 will be used.

**3) Response中文乱码**  
在Tomcat9及之前，响应中文也是有乱码的，如何解决：
```java
response.setContentType("text/html;charset=UTF-8")
```

## 请求域对象

1）请求域对象要比应用域对象范围小很多，生命周期短很多，请求域只在一次请求内有效。  
2）一个请求对象request对应一个请求域对象，一次请求结束之后，这个请求域就销毁了。  
3）请求域对象也有这三个方法：
```java
void setAttribute(String name, Object o)// 向请求域绑定数据
void removeAttribute(String name)// 从域当中根据name获取数据
Object getAttribute(String name)// 将域当中绑定的数据移出
```
4）请求域和应用域的选用原则
>尽量使用小的域对象，因为小的域对象占用的资源较小。

## 其他常用方法
```java
// 获取客户端的IP地址
String remoteAddr = request.getRemoteAddr();
// 获取应用的根路径
String contextPath = request.getContextPath();
// 获取请求方式
String method = request.getMethod();
// 获取请求的URI
String requestURI = request.getRequestURI();
// 获取servlet路径
String servletPath = request.getServletPath();
```

## 视频地址

start:https://www.bilibili.com/video/BV1Z3411C7NZ?p=22  
end:https://www.bilibili.com/video/BV1Z3411C7NZ?p=26

2023.12.4 00:38

<div style="margin: 0px;">
    备案号：
    <a href="https://beian.miit.gov.cn/" target="_blank">
        <!-- <img src="https://api.azpay.cn/808/1.png" style="height: 20px;"> -->沪ICP备2022002183号-1
    </a >
</div>

