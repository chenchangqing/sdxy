# Servlet+JSP项目改造
---
使用Servlet处理业务，收集数据，使用JSP展示数据。

## 修改html为jsp

1）修改html为jsp，然后在jsp文件头步添加page指令（指定contentType防止中文乱码，将所有JSP直接拷贝至web目录下。  
2）使用`<%=request.getContentPath()%>`替换超链接的根路径。  


## 修改Servlet

1）将数据集合list存储到request域当中。
2）转发forward到jsp。

## 修改JSP

1）从request域取出List集合。  
2）遍历List集合，取出每个对象，动态生成tr。

## 如果只用JSP这一个技术，能不能开发web应用？

当然可以使用JSP来完成所有的功能，因为JSP就是Servlet，在JSP的<%%>里面写的代码就是在service方法当中的，所以在<%%>当中完全可以编写JDBC代码，连接数据库，查询数据，也可以在这个方法当中编写业务逻辑代码，处理业务，都是可以的，所以使用单独的JSP开发web应用完全没问题。

虽然JSP一个技术就可以完成web应用，但是不建议，还是建议采用servlet+jsp的方式进行开发。这样都能将各自的优点发挥出来，JSP就是做数据展示，Servlet就是做数据的收集。
>JSP中编写的java代码越少越好，一定要职责分明。

## JSP文件的扩展名必须是xxx.jsp吗？

jsp文件的扩展名是可以配置的，不是固定的，在CATALINA_HOME/conf/web.xml可以配置jsp文件的扩展名：
```xml
<servlet-mapping>
		<servlet-name>jsp</servlet-name>
		<url-pattern>*.jsp</url-pattern>
		<url-pattern>*.jspx</url-pattern>
</servlet-mapping>
```
xxx.jsp文件对于tomcat来说，只是一个普通的文本文件，web容器会将xxx.jsp文件最终生成java程序，最终调用的是java对象相关的方法，真正执行的时候，和
jsp文件就没有关系了。

## 包名bean是什么意思？

1）javabean：java的logo是一杯冒着热气的咖啡，javabean被翻译为咖啡豆。  
2）java是一杯咖啡，咖啡又是由一粒一粒的咖啡研磨而成。  
3）整个java程序中有很多bean的存在，由很多bean组成。 
4）javabean其实就是java中的实体类，负责数据的封装。  
5）由于javabean符合javabean规范，具有更强的通用性。 

## 什么是javabean？

1）有无参数构造方法  
2）属性私有化  
3）对外提供公开的set和get方法  
4）实现java.io.Serializable接口  
5）重写toString  
6）重写hashCode+equals  