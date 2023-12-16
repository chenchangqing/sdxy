# EL表达式
---

* 23.12.16 15:8开始
* 23.12.16 22:39更新

## EL表达式是什么？

* Expression Language（表达式语言）
* EL表达式可以代替JSP中的java代码，让JSP文件中的程序看起来更加整洁，美观。
* JSP中夹杂着各种java代码，例如：`<%java代码%>`、`<%=%>`等，导致JSP文件很混乱，不好看，不好维护，所以才有了后期的EL表达式。
* EL表达式可以算是JSP语法的一部分，EL表达式归属于JSP。

## EL表达式作用

* 从某个域中取数据。
* 将取出的数据转成字符串。
* 将字符串输出到浏览器。

## EL表达式使用

语法：${表达式}

```java
<%
	// 创建User对象
	User user = new User();
	user.setUsername("jackson");
	user.setPassword("1234");
	user.setAge(18);

	// 将User对象存储到某个域当中。一定要存，因为EL表达式只能从某个域范围中取数据。
	// 数据是必须存储到四大域之一的。
	request.setAttribute("userObj", user);
%>
${userObj}

```
* ${这里位置写什么？这里写的一定是存储到域对象当中时的name}
* ${userObj} 等同于代码<%=request.getAttribute("userObj")
* 不要这样写：${"userObj"}

## `${userObj}`底层怎么做的？

从域中取数据，取出user对象，然后调用user对象的toString方法，转成字符串，输出到浏览器。

## 怎么输出对象的属性值？

* ${userObj.username}：使用这个语法的前提是：User对象有getUsername()方法。
* ${userObj.password}
* ${userObj.age}
* ${userObj.email}
* ${userObj.address.street}：支持.语法

EL表达式对null进行了处理，如果是null，则在浏览器上显示空白。

EL表达式中这个语法，实际上调用了底层的getXXX()方法，getXXX方法的名称不使用驼峰命名也是可以的，但是不推荐。

## EL表达式取数据优先级

* 在没有指定域范围的前提下，EL表达式优先从小范围中取数据.

>域范围大小：pageContext < request < session < application 

* EL表达式中有四个隐式的范围，可以指定域范围来读取数据：

>* ${pageScope.data}：pageContext域
* ${requestScope.data}：request域
* ${sessionScope.data}：session域
* ${applicationScope.data}：application域

在实际开发中，因为向某个域中存储数据的时候，name都是不同的，所以，xxxScope都是可以省略的。

## EL表达式取数据的方式

* ${user.username}：一般使用这种就够用了。
* ${user["username"]}：如果存储到域的时候，这个name中含有特殊字符，可以使用[]方式，例如：name="xxx.xxx"。
* 怎么从Map取数据？${map.key}
* 怎么从Array取数据？${array[0]}：取出数组中第一个元素输出

>取不出数据，在浏览器显示空白，不会出现下标越界问题。

## 忽略EL表达式

page指令当中，有一个属性，可以忽略EL表达式：
```java
<%@page contentType="text/html;chartset=UTF-8" isELIgnored="true"%>
```
* isELIgnored="true"：表示忽略EL表达式
* isELIgnored="false"：表示不忽略EL表达式，默认false。

>isELIgnored="true"表示忽略JSP中整个页面的EL表达式，如果想忽略其中某个，可以使用反斜杠：\${username}。

## 使用EL表达式获取应用的根

```java
${pageContext.request.contextPath}
```

## 获取请求参数、应用域配置参数

* ${param.aihao}：获取request中参数为aihao的值。相当于以下代码：

```java
<%=request.getParameter("aihao")%>
```
* ${paramValues.aihao[0]}：当aihao对应多个值的时候使用。相当于以下代码：

```java
<%=request.getParameterValues("aihao")[0]%>
```
* ${initParam.pageNum}：获取web.xml中context初始化参数。相当于以下代码：

```java
application.getInitParameter("pageNum")；
```

## 算术运算符：+ - * / %

* ${10+20}：显示30。
* ${10+"20"}：“20”会自动转成数字，再相加，显示30。
* ${10+"abc"}：报数字格式化错误，NumberFormatException。
* +号在EL表达式中，只会做求和，不会做字符串拼接。

## 关系运算符：== != > >= < <= eq

${"abc"=="abc"}：显示true。
```java
<%
	Object obj = new Object();
	request.setAttribute("k1", obj);
	request.setAttribute("k2", obj);
%>
```
${k1 == k2}：显示true。
```java
<%
	String s1 = new String("abc");
	String s2 = new String("abc");
	request.setAttribute("s1", s1);
	request.setAttribute("s2", s2);
%>
```
${s1 == s2}：显示true，因为String重写了equals方法。
```java
<%
	Object obj1 = new Object();
	Object obj2 = new Object();
	request.setAttribute("obj1", obj1);
	request.setAttribute("obj2", obj2);
%>
```
${obj1 == obj2}：显示false。
* `==`调用了equals方法。
* `==` 和 `eq`效果一致。
* ${!stu1 eq stu2}：错误的写法。
* ${!(stu1 eq stu2)}：正确的写法。
* ${not(stu1 eq stu2)}：正确的写法。

## 空运算符：empty 

* ${empty param.username}：判空
* ${!empty param.username}：判非空
* ${not empty param.username}：判非空
* ${empty param.password == null}：前半部分是boolean， false == null，显示false。

## 其他运算符

* 逻辑运算符：! && || not and or
* 条件运算符：? :

```java
${empty param.username ? "对不起，用户名不能为空" : "欢迎访问"}
```
* 取值运算符：[] .


## 视频

* start：https://www.bilibili.com/video/BV1Z3411C7NZ?p=51
* end://www.bilibili.com/video/BV1Z3411C7NZ?p=53