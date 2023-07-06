# JDBC编程
---

### JDBC编程六步

第一步：注册驱动（作用：告诉Java程序，即将要连接的是哪个品牌数据库）  
第二步：获取连接（表示JVM的进程和数据库进程之间的通道打开了，这属于进程之间的通信，重量级的，使用完毕之后一定要关闭连接）  
第三步：获取数据库操作对象（专门执行sql语句的对象）  
第四步：执行SQL语句（DML、DQL...）  
第五步：处理查询结果（只有当第四步执行的是select语句的时候，才有这第五步处理查询结果集）  
第六步：释放资源（使用完资源后一定要关闭资源）

### 编写测试类

```java
import java.sql.Driver;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Connection;
import java.sql.Statement;

public class JDBCTest01 {
	public static void main(String[] args) {
		Statement stmt = null;
		Connection conn = null;
		try {
			// 第一步：注册驱动（作用：告诉Java程序，即将要连接的是哪个品牌数据库）  
			Driver driver = new com.mysql.jdbc.Driver();
			DriverManager.registerDriver(driver);
			// 第二步：获取连接（表示JVM的进程和数据库进程之间的通道打开了，这属于进程之间的通信，重量级的，使用完毕之后一定要关闭连接）  
			String url = "jdbc:mysql://127.0.0.1:3306/node";
			String user = "root";
			String password = "333";
			conn = DriverManager.getConnection(url, user, password);
			System.out.println("数据库连接对象 = " + conn);
			// 第三步：获取数据库操作对象（专门执行sql语句的对象）  
			stmt = conn.createStatement();
			// 第四步：执行SQL语句（DML、DQL...）   
			// executeUpdate：专门执行DML语句的（insert delte update)
			// 返回值是“影响数据库中的记录条数” 

			// 增
			String sql = "insert into dept(deptno, dname, loc) values(50,'人事部','北京'";
			int count = stmt.executeUpdate(sql);
			System.out.println(count == 1 ? "保存成功" : "保存失败");

			// 删
			// String sql = "delete from dept where deptno = 40";
			// int count = stmt.executeUpdate(sql);
			// System.out.println(count == 1 ? "删除成功" : "删除失败");

			// 改
			// String sql = "update dept set dname = '销售部', loc = '天津' where deptno = 20";
			// int count = stmt.executeUpdate(sql);
			// System.out.println(count == 1 ? "修改成功" : "修改失败");

			// 第五步：处理查询结果（只有当第四步执行的是select语句的时候，才有这第五步处理查询结果集）  
		} catch(SQLException e) {
			e.printStackTrace();
		} finally {
			// 第六步：释放资源（使用完资源后一定要关闭资源）
			// 为了保证资源一定释放，在finally语句中关闭资源
			// 并且要遵循从小到大依次关闭
			// 分别对其try catch
			if (conn != null) {
				try {
					conn.close()
				} catch(SQLException e) {
					e.printStackTrace();
				}
			}
			if (conn != null) {
				try {
					conn.close()
				} catch(SQLException e) {
					e.printStackTrace();
				}
			}
		}
	}
}
```
执行：
```
javac *.java
java JDBCTest01
```
报错：
```
chenchangqingdeMacBook-Pro-2:jdbc chenchangqing$ java JDBCTest01
Exception in thread "main" java.lang.UnsupportedClassVersionError: com/mysql/jdbc/Driver : Unsupported major.minor version 52.0
	at java.lang.ClassLoader.defineClass1(Native Method)
	at java.lang.ClassLoader.defineClass(ClassLoader.java:800)
	at java.security.SecureClassLoader.defineClass(SecureClassLoader.java:142)
	at java.net.URLClassLoader.defineClass(URLClassLoader.java:449)
	at java.net.URLClassLoader.access$100(URLClassLoader.java:71)
	at java.net.URLClassLoader$1.run(URLClassLoader.java:361)
	at java.net.URLClassLoader$1.run(URLClassLoader.java:355)
	at java.security.AccessController.doPrivileged(Native Method)
	at java.net.URLClassLoader.findClass(URLClassLoader.java:354)
	at java.lang.ClassLoader.loadClass(ClassLoader.java:425)
	at sun.misc.Launcher$AppClassLoader.loadClass(Launcher.java:308)
	at java.lang.ClassLoader.loadClass(ClassLoader.java:358)
	at JDBCTest01.main(JDBCTest01.java:10)
```
配置的驱动使用的是JDK1.8，但是本地编译代码的JDK是1.7，升级本地JDK为1.8，问题解决。

### 类加载的方式注册驱动

```java
import java.sql.*;
import java.util.*;
public class JDBCTest02 {
	public static void main(String[] args) {
		try {
			// 注册驱动的第一种方式
			// DriverManager.registerDriver(new com.mysql.jdbc.Driver());

			// 注册驱动的第二种方式：常用的
			Class.forName("com.mysql.jdbc.Driver")
		} catch(SQLException e) {
			e.printStackTrace();
		} catch(ClassNotFoundException e) {
			e.printStackTrace();
		}
	}
}
```

### 从属性资源文件中读取连接数据库信息

创建jdbc.properties：

```
driver=com.mysql.jdbc.Driver
url=jdbc:mysql://localhost:3306/mysql
user=root
password=123456
```

```java
import java.sql.*;
import java.util.*;

public class JDBCTest03 {
	public static void main(String[] args) {
		// 使用资源绑定器绑定属性配置文件
		ResourceBundle bundle = ResourceBundle.getBundle("jdbc");
		String driver = bundle.getString("driver");
		String url = bundle.getString("url");
		String user = bundle.getString("user");
		String user = bundle.getString("password");

		Connection conn = null;
		Statement stmt = null;
		try {
			// 1、注册驱动
			Class.forName(driver);
			// 2、获取连接
			conn = DriverManager.getConnection(url, user, password);
			// 3、获取数据库操作对象
			stmt = conn.createStatement();
			// 4、执行SQL语句
			String sql = "update dept set dname = '销售部', loc = '天津' where deptno = 20";
			int count = stmt.executeUpdate(sql);
			System.out.println(count == 1 ? "修改成功" : "修改失败");
		} catch(SQLException e) {
			e.printStackTrace();
		} catch(ClassNotFoundException e) {
			e.printStackTrace();
		} finally {
			// 5、释放资源
		}
	}
} 
```

### 处理查询结果集

```java
import java.sql.*;
import java.util.*;

public class JDBCTest04 {
	public static void main(String[] args) {
		// 使用资源绑定器绑定属性配置文件
		ResourceBundle bundle = ResourceBundle.getBundle("jdbc");
		String driver = bundle.getString("driver");
		String url = bundle.getString("url");
		String user = bundle.getString("user");
		String user = bundle.getString("password");

		Connection conn = null;
		Statement stmt = null;
		ResultSet rs = null;
		try {
			// 1、注册驱动
			Class.forName(driver);
			// 2、获取连接
			conn = DriverManager.getConnection(url, user, password);
			// 3、获取数据库操作对象
			stmt = conn.createStatement();
			// 4、执行SQL语句
			String sql = "select empno, ename, sal from emp";
			rs = stmt.executeQuery(sql);
			// 5、处理结果集
			while(rs.next()) {
				
				String empno = rs.getString("empno");
				String ename = rs.getString("ename");
				String sal = rs.getString("sal");

				// 第二种方式取值
				// String empno = rs.getString(1);
				// String ename = rs.getString(2);
				// String sal = rs.getString(3);
				
				System.out.println(empno + "," + ename + "," + sal);
			}
		} catch(SQLException e) {
			e.printStackTrace();
		} catch(ClassNotFoundException e) {
			e.printStackTrace();
		} finally {
			// 6、释放资源
			if (rs != null) {
				try {
					rs.close()
				}catch(SQLException e) {
					e.printStackTrace();
				}
			}
			if (conn != null) {
				try {
					conn.close()
				} catch(SQLException e) {
					e.printStackTrace();
				}
			}
			if (conn != null) {
				try {
					conn.close()
				} catch(SQLException e) {
					e.printStackTrace();
				}
			}
		}
	}
} 
```