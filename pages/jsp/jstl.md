# JSTL标签库
---
* 23.12.16 22:45开始
* 23.12.17 21:39更新

## 什么是JSTL标签库？

* Java Standard Tag Lib（Java标准的标签库）
* JSTL标签库通过结合EL表达式一起使用，目的是让JSP的java代码消失。
* 标签是写在JSP当中的，但是实际上最终还是要执行对应的java程序。

## 引入JSTL标签库对应的jar包

在tomcat10及之后引入的jar：
* jakarta.servlet.jsp.jstl-2.0.0.jar
* jakarta.servlet.jsp.jstl-api-2.0.0.jar

tomcat10之前使用：
* javax.servlet.jsp.jstl-2.0.0.jar
* taglibs-standard-impl-1.2.5.jar
* taglibs-standard-spec-1.2.5.jar


## 在IDEA当中怎么引入？

* 在WEB-INF下新建lib目录，然后将jar包拷贝到lib当中，然后将其“Add Lib...”。
* 一定是要和mysql的数据库驱动一样，都是放在WEB-INF/lib目录下的。
* 什么时候需要将jar包放到WEB-INF/lib目录下？如果这个jar是tomcat服务器没有的。

## 在JSP中引入要使用的标签库

使用taglib指令引入标签库：
```java
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
```
这个是核心标签库。

* 以上uri后面的路径实际上指向了一个`c.tld`文件。
* c.tld路径：在jakarta.servlet.jsp.jstl-2.0.0.jar里面META-INF目录下。
* c.tld文件实际是一个xml配置文件。

## 配置文件tld解析
```xml
<tag>
	<description>对该标签的描述</description>
	<name>catch</name>标签的名字
	<tag-class>org。apache.taglibs.standard.tag.common.core.CatchTag</tag-class>标签对应的java类
	<body-content>JSP</body-content>标签体当中可以出现的内容，如果是JSP，就表示标签体中可以出现符合JSP所有语法的代码，例如EL表达式。
	<attribute>
		<description>对这个属性的描述</description>
		<name>var</name>属性名
		<required>false</required>false表示该属性不是必须的，true则反之。
		<rtexprvalue>false</rtexprvalue>这个描述说明了该属性是否支持EL表达式，false表示不支持，true表示支持EL表达式。
	</attribute>
</tag>
```

## catch
```java
<c:catch var="">
	JSP...
</c:catch>
```

## forEach

```java
<%-- 使用core标签中forEach标签，对List集合进行遍历。 --%>
<%-- EL表达式只能从域中取数据。 --%>
<%-- var后面的名字是随意的，var属性代表的是集合中的每个元素。--%>
<%-- "varStatus="这个属性表示var的状态对象，这里是一个java对象，这个java对象代表了var的状态 --%>
<%-- "varStatus="这个名字是随意的。--%>
<%-- "varStatus="这个状态对象有count属性，可以直接使用 --%>
<c:forEach items="${stuList}" var="s" varStatus="varStatus">
	<%-- varStatus的count是从1开始，以1递增，主要是用于编号/序号 --%>
	id:${varStatus.count},${s.id},name:${s.name}</br>
</c:forEach>
```

```java
<%-- var 用来指定循环中的变量，begin开始，end结束，step步长 --%>
<%-- 底层实际上，会将i存储到pageContext域当中 --%>
<c:forEach var="i" begin="1" end="10" step="1">
	<%-- 所以这里才会使用EL表达式将其取出，一定是从某个域当中取出的。 --%>
	${i}<br>
</c:forEach>
```

## if

* 没有else标签，可以使用两个if。
* if标签还有var属性，不是必须的。
* if标签还有scope属性，用来指定var的存储域，也不是必须的
* scope有四个值可以选：page、request、session、application
* 将var中的v存储到request域。

```java
<c:if test="${not empty param.username}" var="v" scope="request">
欢迎你${param.username}。
</c:if>
```

## choose

```java
<% -- if(){} else if(){} else {} 结构 --%>
<c:choose>
	<c:when test="${param.age < 16}">
		青少年
	</c:when>
	<c:when test="${param.age < 35}">
		青年
	</c:when>
	<c:when test="${param.age < 55}">
		中年
	</c:when>
	<c:otherwise>
		老年
	</c:otherwise>
</c:choose>
```

## HTML中的base

```java
<html>
	<head>
		<meta charset="utf-8"/>
		<title>xxx</title>
		<%-- 设置整个耶main的基础路径是："http://localhost:8080/oa/" --%>
		<%-- 对前面没增加/的相对路径生效，例如：“user/exit”。--%>
		<base href="http://localhost:8080/oa/" />
	</head>
</html>
```
注意：html的base标签可能对JS代码不起作用，所以JS代码最好前面写项目根路径：
```js
document.location.href = "${pageContext.request.contextPath}/dept/delete?deptno=" + dno;
```
动态获取base：
```java
<base href="${pageContext.request.scheme}://${pageContext.request.serverName}:${pageContext.reqeust.serverPort}${pageContext.request.contextPath}/"
```
## 视频

* start：http://www.bilibili.com/video/BV1Z3411C7NZ?p=54
* end：http://www.bilibili.com/video/BV1Z3411C7NZ?p=55
