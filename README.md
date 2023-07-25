# Servlet考试管理系统

### 准备工作
---

1. 创建用户信息表Users

    ```sql
    CREATE TABLE Users(
        userId int primary key auto_increment, #用户编号
        userName varchar(50), #用户名称
        password varchar(50), #用户密码
        sex char(1), #用户性别 ‘男’ 或 ‘女’
        email varchar(50) # 用户邮箱
    );
    ```
2. 在src下新建com.c1221.entity.Users实体类
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
3. 在web下WEB-INF下创建lib文件夹，存放mysql提供的JDBC实现jar包
3. 在src下新建com.c1221.util.JdbcUtil工具类
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
1. 导入servlet-api.jar：https://blog.51cto.com/laoshifu/4839810
2. 修改web.xml
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
3. 在src下新建com.c1221.controller.UserAddServlet
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

<div style="margin: 0px;">
    备案号：
    <a href="https://beian.miit.gov.cn/" target="_blank">
        <!-- <img src="https://api.azpay.cn/808/1.png" style="height: 20px;"> -->沪ICP备2022002183号-1
    </a >
</div>

