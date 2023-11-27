# 带有Servlet的web应用
```
webapproot
	|-----WEB-INF
			|-----classes（存放字节码）
			|-----lib（第三方jar包）
			|-----web.xml（注册Servlet）
	|-----html
	|-----css
	|-----javascript
	|-----image
	...
```

## 第一步

在webapps目录下新建一个目录，起名crm（这个crm就是webapp的名字）。当然，也可以是其他项目，比如银行项目，可以创建一个目录bank，办工系统可以创建一个oa。
- 注意：crm就是这个webapp的根。

## 第二步

在webapp的根下新建一个目录：WEB-INF。
- 注意：这个目录的名字是Servlet规范中规定的，必须全部大写，必须一模一样。

## 第三步
在WEB-INF目录下新建一个目录：classes。
- 注意：这个目录的名字必须是全部小写的classes。这也是Servlet规范中规定的。另外这个目录下一定存放的是java程序编译之后的class文件（这里存放的字节文件）。

## 第四步

在WEB-INF目录下新建一个目录：lib
- 注意：这个目录不是必须的。但如果一个webapp需要第三方的jar包的话，这个jar包要放到这个lib目录下，这个目录的名字也不能随便编写，必须是全部小写的lib。例如java语言连接数据库需要的驱动jar包。那么这个jar包就一定要放到lib目录下。这是Servlet闺房中规定的。

## 第五步

在WEB-INF目录下新建一个文件：web.xml
- 注意：这个文件是必须的，这个文件名必须叫做web.xml。这个文件必须放在这里。一个合法的webapp，web.xml文件是必须的，这个web.xml文件是一个配置文件，在这个配置文件中描述了请求路径和Servlet类之间的对照关系。
- 这个文件最好从其他webapp中拷贝，最好别手写，没必要。复制粘切
```
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns="https://jakarta.ee/xml/ns/jakartaee"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="https://jakarta.ee/xml/ns/jakartaee
                      https://jakarta.ee/xml/ns/jakartaee/web-app_5_0.xsd"
  version="5.0"
  metadata-complete="true">
</web-app>
```

## 第六步
编写一个java程序，这个小java程序也不能随意开发，这个小java程序必须实现Servlet接口。
- 这个Servlet接口不在JDK中。（因为Servlet不是JavaSE了，Servlet属于JavaEE，是另外一套类库）
- Servlet接口（Servlet.class文件）是Oracle提供的。（最原始的是sun公司提供的）
- Servlet接口是JavaEE规范中的一员。
- Tomcat服务器实现了Servlet规范，所以Tomcat服务器也需要使用Servlet接口。Tomcat服务器中应该有这个接口，Tomcat服务器的CATALINA_HOME\lib目录下又个servlet.api.jar，解压这个servlet.api.jar之后，你会看到里面有个Servlet.class文件。
- 重点：从JakartaEE9开始，Servlet接口的全名变了：jakarta.servlet.Servlet
- 注意：编写这个java小程序的时候，java源代码愿意在哪里就在哪里，位置无所谓，你只需要将java源代码编译之后的class文件放到classes目录下即可。

## 第七步
编译我们编写的HelloServlet
- 重点：你怎么能让你的HelloServlet编译通过呢？配置环境变量CLASSPATH
```
CLASSPATH=.;C:\dev\apache-tomcat-10.0.12\lib\servlet.api.jar
```

## 第八步
将以上编译之后的HelloServlet.class文件拷贝到WEB-INF\classes目录下。

## 第九步
在web.xml文件中编写配置信息，让“请求路径”和“Servlet类名”关联在一起。
- 这一步用专业术语描述：在web.xml文件中注册Servlet类。
```
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns="https://jakarta.ee/xml/ns/jakartaee"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="https://jakarta.ee/xml/ns/jakartaee
                      https://jakarta.ee/xml/ns/jakartaee/web-app_5_0.xsd"
  version="5.0"
  metadata-complete="true">
  <servlet>
    <servelt-name>mm</servlet-name><!-- 声明一个变量存储servlet接口实现类类路径 -->
    <servlet-class>com.xxxx.controller.OneServlet</servlet-class><!-- 声明servlet接口实现类 -->
  </servlet>
  <servlet-mapping>
    <servlet-name>mm</servlet-name>
    <url-pattern>/one</url-pattern><!-- 设置简短请求别名，别名在书写时必须以“/”为开头 -->
  </servlet-mapping>
</web-app>
```

## 第十步
启动Tomcat服务器。

## 第十一步
打开浏览器，在浏览器地址栏上输入这样的URL：
- http://127.0.0.1:8080/crm/one

## 视频地址

https://www.bilibili.com/video/BV1Z3411C7NZ/?p=8
