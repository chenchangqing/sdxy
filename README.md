# Servlet考试管理系统

### 准备工作
---

#### 1. 创建用户信息表Users

```sql
CREATE TABLE Users(
    userId int primary key auto_increment, #用户编号
    userName varchar(50), #用户名称
    password varchar(50), #用户密码
    sex char(1), #用户性别 ‘男’ 或 ‘女’
    email varchar(50) # 用户邮箱
);
```
#### 2. 在src下新建com.c1221.entity.Users实体类
```java
package com.c1221.entity;

public class Users {
    private Integer userId;
    private String userName;
    private String password;
    private String sex;
    private String email;

    public User(Integer userId, String userName, String password, String sex, String email) {
        this.userId = userId;
        this.userName = userName;
        this.password = password;
        this.sex = sex;
        this.email = email;
    }

    /// Getter

    /// Setter
}
```
生成get、set、构造方法：右键类文件编辑区（Command+N）->Generate->Constructor、Getter、Setter
#### 3. 在web下WEB-INF下创建lib文件夹，存放mysql提供的JDBC实现jar包
#### 4. 在src下新建com.c1221.util.JdbcUtil工具类
```java
package com.c1221.util;

import java.sql.*;

/**
 * JDBC工具类，简化JDBC编程
 */
public class JdbcUtil {

    static final String URL = "jdbc:mysql://localhost:3306/mysql";
    static final String USERNAME = "root";
    static final String PASSWORD = "333";

    /**
     * 工具类中的构造方法都是私有的
     * 因为工具类当中的方法都是静态的，不需要new对象，直接采用类名调用
     */
    private JdbcUtil(){}

    // 静态代码块在类加载时执行，并且只执行一次
    static {
        try {
            Class.forName("com.mysql.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
    }

    /**
     * 获取数据库连接对象
     *
     * @return 连接对象
     * @throws SQLException
     */
    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USERNAME, PASSWORD);
    }

    /**
     * 关闭资源
     * @param conn 连接对象
     * @param ps 数据库操作对象
     * @param rs 结果集
     */
    public static void close(Connection conn, Statement ps, ResultSet rs) {
        if (rs != null) {
            try {
                rs.close();
            }catch(SQLException e) {
                e.printStackTrace();
            }
        }
        if (ps != null) {
            try {
                ps.close();
            } catch(SQLException e) {
                e.printStackTrace();
            }
        }
        if (conn != null) {
            try {
                conn.close();
            } catch(SQLException e) {
                e.printStackTrace();
            }
        }
    }
}
```

### 用户信息注册流程图
---
<img src="images/servlet_02.png" width=100%/>

### 注册页面
---
在web下，新建user_add.html
```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Title</title>
</head>
<body>
    <center>
        <form action="/examsystem/user/add" method="get">
            <table>
                <tr>
                    <td>用户姓名</td>
                    <td><input type="text" name="userName"></td>
                </tr>
                <tr>
                    <td>用户密码</td>
                    <td><input type="password" name="password"></td>
                </tr>
                <tr>
                    <td>用户性别</td>
                    <td>
                        <input type="radio" name="sex" value="1"/>男
                        <input type="radio" name="sex" value="2"/>女
                    </td>
                </tr>
                <tr>
                    <td>用户邮箱</td>
                    <td><input type="text" name="email"></td>
                </tr>
                <tr>
                    <td><input type="submit" value="用户注册"/></td>
                    <td><input type="reset"/></td>
                </tr>
            </table>
        </form>
    </center>
</body>
</html>
```

### 编写UserDao
---
在src下新建com.c1221.dao.UserDao
```java
package com.c1221.com.c1221.dao;

import com.c1221.entity.Users;
import com.c1221.util.JdbcUtil;

import java.sql.*;

public class UserDao {

    public int add(Users users) {
        Connection conn = null;
        PreparedStatement ps = null;
        int result = 0;
        try {
            // 2、获取连接
            conn = JdbcUtil.getConnection();
            // 将自动提交机制修改为手动提交
            conn.setAutoCommit(false);
            // 3、获取数据库操作对象
            String sql = "insert into users(userName,password,sex,email)" +
                    " values(?,?,?,?)";
            ps = conn.prepareStatement(sql);
            // 4、执行SQL语句
            ps.setString(1, users.getUserName());
            ps.setString(2, users.getPassword());
            ps.setString(3, users.getSex());
            ps.setString(4, users.getEmail());
            result = ps.executeUpdate();
            conn.commit();
        } catch(Exception e) {
            // 回滚事务
            if(conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException e1) {
                    e1.printStackTrace();
                }
            }
            e.printStackTrace();
        } finally {
            JdbcUtil.close(conn, ps, null);
        }
        return result;
    }
}

```

### 注册Servlet
---
#### 1. 导入servlet-api.jar：https://blog.51cto.com/laoshifu/4839810
#### 2. 修改web.xml
```xml
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns="http://xmlns.jcp.org/xml/ns/javaee"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://xmlns.jcp.org/xml/ns/javaee http://xmlns.jcp.org/xml/ns/javaee/web-app_4_0.xsd"
         version="4.0">
    <servlet>
        <servlet-name>UserAddServlet</servlet-name>
        <servlet-class>com.c1221.controller.UserAddServlet</servlet-class>
    </servlet>
    <servlet-mapping>
        <servlet-name>UserAddServlet</servlet-name>
        <url-pattern>/user/add</url-pattern>
    </servlet-mapping>
</web-app>
```
#### 3. 在src下新建com.c1221.controller.UserAddServlet

```java
package com.c1221.controller;

import com.c1221.com.c1221.dao.UserDao;
import com.c1221.entity.Users;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;

public class UserAddServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String userName,password,sex,email;
        UserDao dao = new UserDao();
        Users user = null;
        int result = 0;
        PrintWriter out = null;
        // 1.【调用请求对象】读取【请求头】参数信息，得到用户的信息
        userName = req.getParameter("userName");
        password = req.getParameter("password");
        sex = req.getParameter("sex");
        email = req.getParameter("email");
        // 2.【调用UserDao】将用户信息填充到INSERT命令借助JDBC规范发送到数据库服务器
        user = new Users(null, userName, password, sex, email);
        result = dao.add(user);
        // 3.【调用响应对象】将【处理结果】以二进制形式写入到响应体
        resp.setContentType("text/html;charset=utf-8");
        out = resp.getWriter();
        if (result == 1) {
            out.print("<font style='color:red;font-size:40'>用户信息注册成功</font>");
        } else {
            out.print("<font style='color:red;font-size:40'>用户信息注册失败</font>");
        }
        out.close();
        // Tomcat负责销毁【请求对象】和【响应对象】
        // Tomcat负责将Http响应协议包推送到发起请求的浏览器上
        // 浏览器根据响应头content-type指定编译器对响应体二进制内容编辑
        // 浏览器将编辑后结果在窗口中展示给用户【结束】
    }
}

```
### 查询Servlet
---
<img src="images/servlet_03.png" width=100%/>

#### 1. 修改web.xml

```xml
<servlet>
    <servlet-name>UserFindServlet</servlet-name>
    <servlet-class>com.c1221.controller.UserFindServlet</servlet-class>
</servlet>
<servlet-mapping>
    <servlet-name>UserFindServlet</servlet-name>
    <url-pattern>/user/find</url-pattern>
</servlet-mapping>
```

#### 2. 新增UserFindServlet
```java
@Override
protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    UserDao dao;
    PrintWriter out;
    // 1【调用DAO】将查询命令推送到数据服务器上，得到所有用户信息【List】
    dao = new UserDao();
    List<Users> userList = dao.findAll();
    // 2【调用响应对象】将用户信息结合《table》标签命令以二进制形式写入到响应体
    response.setContentType("text/html;charset=utf-8");
    out = response.getWriter();
    out.print("<table border='2' align='center'>");
    out.print("<tr>");
    out.print("<td>用户编号</td>");
    out.print("<td>用户姓名</td>");
    out.print("<td>用户密码</td>");
    out.print("<td>用户性别</td>");
    out.print("<td>用户邮箱</td>");
    out.print("</tr>");
    for (Users users:userList) {
        out.print("<tr>");
        out.print("<td>"+users.getUserId()+"</td>");
        out.print("<td>"+users.getUserName()+"</td>");
        out.print("<td>"+users.getPassword()+"</td>");
        out.print("<td>"+users.getSex()+"</td>");
        out.print("<td>"+users.getEmail()+"</td>");
        out.print("</tr>");
    }
    out.print("</table>");
}
```

#### 3. 修改UserDao

```java
// 查询用户信息
public List findAll() {
    PreparedStatement ps = null;
    Connection conn = null;
    ResultSet rs = null;
    List<Users> userList = new ArrayList<Users>();
    try {
        // 2、获取连接
        conn = JdbcUtil.getConnection();
        // 3、获取数据库操作对象
        String sql = "select * from users";
        ps = conn.prepareStatement(sql);
        rs = ps.executeQuery();
        while (rs.next()) {
            Integer userId = rs.getInt("userId");
            String userName = rs.getString("userName");
            String password = rs.getString("password");
            String sex = rs.getString("sex");
            String email = rs.getString("email");
            Users users = new Users(userId, userName, password, sex, email);
            userList.add(users);
        }
    } catch(SQLException e) {
        e.printStackTrace();
    } finally {
        JdbcUtil.close(conn, ps, rs);
    }
    return userList;
}
```

### 导航栏
--- 
#### 1. 新建index.html
```html
<html>
<head>
    <meta charset="UTF-8">
    <title>Title</title>
</head>
<frameset rows="15%,85%">
  <frame name="top" src="top.html"/>
  <frameset cols="30%,70%">
    <frame name="left"  src="left.html"/>
    <frame name="right"/>
  </frameset>
</frameset>
</html>
```
#### 2. 新建top.html
```html
<html>
<head>
    <meta charset="UTF-8">
    <title>Title</title>
</head>
<body style="background-color: green">
  <center>
    <font style="color: red; font-size: 40px">在线考试管理系统</font>
  </center>
</body>
</html>
```

#### 3. 新建left.html
```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Title</title>
</head>
<body>
  <ul>
    <li>用户信息管理</li>、
      <ol>
        <li><a href="user_add.html" target="right">用户信息注册</a></li>
        <li><a href="user/find" target="right">用户信息查询</a></li>
      </ol>
    <li>试题信息管理</li>
    <li>考试管理</li>
  </ul>
</body>
</html>
```

### UserDeleteServlet
---

#### 1. 修改UserFindServlet
```java
@Override
protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    UserDao dao;
    PrintWriter out;
    // 1【调用DAO】将查询命令推送到数据服务器上，得到所有用户信息【List】
    dao = new UserDao();
    List<Users> userList = dao.findAll();
    // 2【调用响应对象】将用户信息结合《table》标签命令以二进制形式写入到响应体
    response.setContentType("text/html;charset=utf-8");
    out = response.getWriter();
    out.print("<table border='2' align='center'>");
    out.print("<tr>");
    out.print("<td>用户编号</td>");
    out.print("<td>用户姓名</td>");
    out.print("<td>用户密码</td>");
    out.print("<td>用户性别</td>");
    out.print("<td>用户邮箱</td>");
    out.print("<td>操作</td>");
    out.print("</tr>");
    for (Users users:userList) {
        out.print("<tr>");
        out.print("<td>"+users.getUserId()+"</td>");
        out.print("<td>"+users.getUserName()+"</td>");
        out.print("<td>"+users.getPassword()+"</td>");
        out.print("<td>"+users.getSex()+"</td>");
        out.print("<td>"+users.getEmail()+"</td>");
        out.print("<td><a href='user/delete?userId="+users.getUserId()+"'>删除用户</a></td>");
        out.print("</tr>");
    }
    out.print("</table>");
}
```
#### 2. 修改UserDAO，新增删除方法
```java
// 根据用户编号删除用户信息
public int delete(String userId) {
    Connection conn = null;
    PreparedStatement ps = null;
    int result = 0;
    try {
        // 2、获取连接
        conn = JdbcUtil.getConnection();
        // 将自动提交机制修改为手动提交
        conn.setAutoCommit(false);
        // 3、获取数据库操作对象
        String sql = "delete from users where userId=?";
        ps = conn.prepareStatement(sql);
        ps.setString(1, userId);
        result = ps.executeUpdate();
        conn.commit();
    } catch(Exception e) {
        // 回滚事务
        if(conn != null) {
            try {
                conn.rollback();
            } catch (SQLException e1) {
                e1.printStackTrace();
            }
        }
        e.printStackTrace();
    } finally {
        JdbcUtil.close(conn, ps, null);
    }
    return result;
}
```

#### 3. 新增UserDeleteServlet
```java
@Override
protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    String userId;
    UserDao dao = new UserDao();
    int result = 0;
    PrintWriter out = null;
    // 1.【调用请求对象】读取【请求头】参数（用户编号）
    userId = request.getParameter("userId");
    // 2.【调用DAO】将用户编号填充到delete命令并发送到数据库服务器
    result = dao.delete(userId);
    // 3.【调用响应对象】将处理结果以二进制写入到响应体，交给浏览器
    response.setContentType("text/html; charset=utf-8");
    out = response.getWriter();
    if (result == 1) {
        out.print("<font style='color:red; font-size:40px'>用户信息删除成功</font>");
    } else {
        out.print("<font style='color:red; font-size:40px'>用户信息删除失败</font>");
    }
}
```
### 登录验证
---
<img src="images/servlet_04.png" width=100%/>

#### 1. 新建login.html
```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Title</title>
</head>
<body>
  <center>
    <form action="/examsystem/user/login" method="post">
      <table border="2">
        <tr>
          <td>登录名</td>
          <td><input type="text" name="userName"/></td>
        </tr>
        <tr>
          <td>密码</td>
          <td><input type="password" name="password"/></td>
        </tr>
        <tr>
          <td><input type="submit" value="登录"/></td>
          <td><input type="reset"/></td>
        </tr>
      </table>
    </form>
  </center>
</body>
</html>
```
#### 2. 修改UserDao，新增login方法
```java
// 登录验证
public int login(String userName, String password) {
    PreparedStatement ps = null;
    Connection conn = null;
    ResultSet rs = null;
    int result = 0;
    try {
        // 2、获取连接
        conn = JdbcUtil.getConnection();
        // 3、获取数据库操作对象
        String sql = "select count(*) from users where userName=? and password=?";
        ps = conn.prepareStatement(sql);
        ps.setString(1, userName);
        ps.setString(2, password);
        rs = ps.executeQuery();
        while (rs.next()) {
            result = rs.getInt("count(*)");
        }
    } catch(SQLException e) {
        e.printStackTrace();
    } finally {
        JdbcUtil.close(conn, ps, rs);
    }
    return result;
}
```
#### 3. 新增login_error.html
```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Title</title>
</head>
<body>
<center>
  <font style="color:red; font-size: 30px">登录信息不存在，请重新登录</font>
  <form action="/examsystem/user/login" method="post">
    <table border="2">
      <tr>
        <td>登录名</td>
        <td><input type="text" name="userName"/></td>
      </tr>
      <tr>
        <td>密码</td>
        <td><input type="password" name="password"/></td>
      </tr>
      <tr>
        <td><input type="submit" value="登录"/></td>
        <td><input type="reset"/></td>
      </tr>
    </table>
  </form>
</center>
</body>
</html>
```
#### 4. 新建LoginServlet
```java
@Override
protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    String userName,password;
    UserDao dao = new UserDao();
    int result = 0;
    // 1. 调用请求对象对请求体使用utf-8字符集进行重新编辑
    request.setCharacterEncoding("utf-8");
    // 2. 调用请求对象读取请求体参数信息
    userName = request.getParameter("userName");
    password = request.getParameter("password");
    // 3. 调用DAO将查询验证信息推送到数据库服务器上
    result = dao.login(userName, password);
    // 4. 调用响应对象，根据验证码结果将不同资源文件地址写入到响应体，交给浏览器
    if (result == 1) {
        // 用户存在
        response.sendRedirect("/examsystem/index.html");
    } else {
        response.sendRedirect("/examsystem/login_error.html");
    }
}
```
#### 5. 修改web.xml
```xml
<servlet>
    <servlet-name>LoginServlet</servlet-name>
    <servlet-class>com.c1221.controller.LoginServlet</servlet-class>
</servlet>
<servlet-mapping>
    <servlet-name>LoginServlet</servlet-name>
    <url-pattern>/user/login</url-pattern>
</servlet-mapping>
```
### 欢迎资源文件
---
#### 1. 前提

用户可以记住网站名，但是不会记住网站资源文件名

#### 2. 默认欢迎资源文件

用户发送了一个针对某个网站的【默认请求】时，此时由Http服务器自动从当前网站返回的资源文件。
* 正常请求：http://localhost:8080/examsystem/index.html
* 默认请求：http://localhost:8080/examsystem

#### 3. Tomcat对默认欢迎资源文件定位规则

1）规则位置：Tomcat安装位置/conf/web.xml

2）规则命令：
```xml
<welcome-file-list>
    <welcome-file>index.html</welcome-file>
    <welcome-file>index.htm</welcome-file>
    <welcome-file>index.jsp</welcome-file>
</welcome-file-list>
```

#### 4. 设置当前网站的默认欢迎资源文件规则

1）规则位置：网站/web/WEB-INF/web.xml

2) 规则命令：
```xml
<welcome-file-list>
    <welcome-file>login.html</welcome-file>
</welcome-file-list>
```

### Http状态码
---
#### 1. 介绍

1）由三位数字组成的一个符号。  
2）Http服务器在推送响应包之前，根据本次请求处理情况将Http状态码写入到响应包中【状态行】上。  
3）如果Http服务器针对本次请求，返回了对应的资源文件。通过Http状态码通知浏览器应该如何处理这个结果。  
4）如果Http服务器针对本次请求，无法返回对应的资源文件。通过Http状态码向浏览器解释不能提供服务的原因。  

#### 2. 分类

1）组成：100～599，分为5个大类

2）1XX
最有特征的是100：通知浏览器本次返回的资源文件并不是一个独立的资源文件，需要浏览器在接受响应包之后，继续向Http服务器所要依赖。
<img src="images/servlet_05.png" width=100%/>

3）2XX  
最有特征的是200：通知浏览器本次返回的资源文件是一个完整独立资源文件，浏览器在接收到之后不需要所要其他关联文件。  

4）3XX：  
最有特征的是302：通知浏览器本次返回的不是一个资源文件内容而是一个资源文件地址，需要浏览器根据这个地址自动发起请求来所要这个资源文件。

response.sendRedirect("资源文件地址")写入到响应头中location，而这个行为导致Tomcat将302状态码写入到状态行。

5）4XX  
* 404：通知浏览器，由于在服务器没有定位到被访问的资源文件，因此无法提供帮助。
* 405：通知浏览器，在服务器已经定位到被访问的资源文件（Servlet），但是这个Servlet对于浏览器采用的请求方式不能处理

6）5XX

500：通知浏览器，在服务端已经定位到被访问的资源文件（Servlet），这个Servlet可以接收浏览器采用请求方式，但是Servlet在处理请求期间，由于Java异常导致处理失败。

### 做个Servlet之间的调用规则
---
<img src="images/servlet_06.png" width=100%/>

#### 1. 前提条件

某些来自于浏览器发送请求，往往需要服务端中多个Servlet协同处理。但是浏览器一次只能访问一个Servlet，导致用户需要手动通过浏览器发起多次请求才能得到服务。这样增加用户获得服务难度，导致用户放弃访问当前网站。

#### 2. 提高用户使用感受规则

无论本次请求涉及到多少个Servlet，用户只需要【手动】通知浏览器发起一次请求即可。

#### 3. 多个Servlet之间调用规则

1）重定向解决方案

2）请求转发解决方案

### 重定向解决方案
--- 

<img src="images/servlet_07.png" width=100%/>

#### 1. 工作原理

用户第一次通过【手动方式】通知浏览器返回OneServlet。OneServlet工作完毕后，将TwoServlet地址写入到响应头location属性中，导致Tomcat将302状态码写入到状态行。

在浏览器接收到响应之后，会读取302状态。此时浏览器自动根据响应头中location属性地址发起第二次请求，访问TwoServlet去完成请求中剩余任务。

#### 2. 实现命令

response.sendRedirect("请求地址")，将地址写入到响应包中响应头中的location属性。

#### 3. 特征

1）请求地址：既可以把当前网站内部的资源文件地址发送给浏览器（/网站名/资源文件名），也可以把其他网站资源文件地址发送给浏览器（http://ip地址：端口号/网站名称/资源文件名)。

2）请求次数：浏览器至少发送两次请求，但是只有第一次请求是用户手动发送。后续请求都是浏览器自动发送的。

3）请求方式：重定向解决方案中，通过地址栏通知浏览器发起下一次请求，因此通过重定向解决方案调用的资源文件接收的请求方式一定是【get】。

4）缺点：重定向解决方案需要在浏览器与服务器之间进行多次往返，大量时间消耗在往返次数上，增加用户等待服务时间。

<div style="margin: 0px;">
    备案号：
    <a href="https://beian.miit.gov.cn/" target="_blank">
        <!-- <img src="https://api.azpay.cn/808/1.png" style="height: 20px;"> -->沪ICP备2022002183号-1
    </a >
</div>

