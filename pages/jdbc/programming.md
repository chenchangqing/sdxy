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
public class JDBCTest01 {
	public static void main(String[] args) {
		try {
			// 第一步：注册驱动（作用：告诉Java程序，即将要连接的是哪个品牌数据库）  
			Driver driver = new com.mysql.jdbc.Driver();
			DriverManager.registerDriver(driver);
			// 第二步：获取连接（表示JVM的进程和数据库进程之间的通道打开了，这属于进程之间的通信，重量级的，使用完毕之后一定要关闭连接）  
			String url = "jdbc:mysql://127.0.0.1:3306/node";
			String user = "root";
			String password = "333";
			Connection conn = DriverManager.getConnection(url, user, password);
			System.out.println("数据库连接对象 = " + conn);
			// 第三步：获取数据库操作对象（专门执行sql语句的对象）  
			// 第四步：执行SQL语句（DML、DQL...）  
			// 第五步：处理查询结果（只有当第四步执行的是select语句的时候，才有这第五步处理查询结果集）  
			// 第六步：释放资源（使用完资源后一定要关闭资源）
		} catch(SQLException e) {
			e.printStackTrace();
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