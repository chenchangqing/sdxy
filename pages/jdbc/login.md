# JDBC登录

### 实现功能

需求：模拟用户登陆功能的实现。

业务描述：程序运行的时候，提供一个输入的入口，可以让用户输入用户名和密码。用户输入用户名和密码之后，提交信息，Java程序收集到用户信息，Java程序连接数据哭验证用户名和密码是否合法，合法，显示登录成功，不合法，显示登录失败。

### 数据准备

在实际开发中，表的设计会使用专业的建模工具，我们这里安装一个建模工具，PowerDesigner，使用PD工具来进行数据库表的设计。

### 编写程序

```java
import java.sql.*;
import java.util.*;

public class JDBCTest05 {
	public static void main(String[] args) {
		// 初始化一个界面
		Map<String, String> userLoginInfo = initUI();
		// 验证用户名和密码
		boolean loginSuccess = login(userLoginInfo);
		// 最后输出结果
		System.out.println(loginSuccess ? "登录成功" : "登录失败")
	}

	/**
	 * 用户登录
	 * @param userLoginInfo 用户登录信息
	 * @return false表示失败， true表示成功
	 */
	private static boolean login(Map<String, String> userLoginInfo) {
		// JDBC代码
		
		// 使用资源绑定器绑定属性配置文件
		ResourceBundle bundle = ResourceBundle.getBundle("jdbc");
		String driver = bundle.getString("driver");
		String url = bundle.getString("url");
		String user = bundle.getString("user");
		String user = bundle.getString("password");

		Connection conn = null;
		Statement stmt = null;
		ResultSet rs = null;
		String loginName = userLoginInfo.get("loginName");
		String loginPwd = userLoginInfo.get("loginPwd");
		boolean loginSuccess = false;
		try {
			// 1、注册驱动
			Class.forName(driver);
			// 2、获取连接
			conn = DriverManager.getConnection(url, user, password);
			// 3、获取数据库操作对象
			stmt = conn.createStatement();
			// 4、执行SQL语句
			String sql = "select * from t user where loginName = '"+ loginName +"' and loginPwd = '"+ loginPwd +"'";
			rs = stmt.executeQuery(sql);
			// 5、处理结果集
			if(rs.next()) {
				loginSuccess = true;
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
			if (stmt != null) {
				try {
					stmt.close()
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
		return loginSuccess;
	}

	/**
	 * 初始化用户界面
	 * @return 用户输入的用户名和密码登录信息
	 */
	private static Map<String, String> initUI() {
		Scanner s = new Scanner(System.in);

		System.out.println("用户名：");
		String loginName = s.nextLine();

		System.out.println("密码：");
		String loginPwd = s.nextLine();

		Map<String, String> userLoginInfo = new HashMap<>();
		userLoginInfo.put("loginName", loginName);
		userLoginInfo.put("loginPwd", loginPwd);

		return userLoginInfo;
	}

}
```

### SQL注入

随意输入用户名，密码输入`fsjdlf' or '1' = '1'`；，用户登录成功，这种现象称为SQL注入。

1.导致SQL注入的根本原因是什么？

用户输入的信息中含有sql语句的关键字，并且这些关键字参与了sql语句的变异过程，导致sql语句的原意被扭曲，进而达到sql注入。

2.解决SQL注入的问题？

只要用户提供的信息不参与SQL语句的编译过程，问题就解决了。即使用户提供的信息中含有SQL语句的关键字，但是没有参与编译，不起作用。

3.代码修改

```java
import java.sql.*;
import java.util.*;

public class JDBCTest06 {
	public static void main(String[] args) {
		// 初始化一个界面
		Map<String, String> userLoginInfo = initUI();
		// 验证用户名和密码
		boolean loginSuccess = login(userLoginInfo);
		// 最后输出结果
		System.out.println(loginSuccess ? "登录成功" : "登录失败")
	}

	/**
	 * 用户登录
	 * @param userLoginInfo 用户登录信息
	 * @return false表示失败， true表示成功
	 */
	private static boolean login(Map<String, String> userLoginInfo) {
		// JDBC代码
		
		// 使用资源绑定器绑定属性配置文件
		ResourceBundle bundle = ResourceBundle.getBundle("jdbc");
		String driver = bundle.getString("driver");
		String url = bundle.getString("url");
		String user = bundle.getString("user");
		String user = bundle.getString("password");

		Connection conn = null;
		PreparedStatement ps = null;// 这里使用PreparedStatement预编译的数据操作对象
		ResultSet rs = null;
		String loginName = userLoginInfo.get("loginName");
		String loginPwd = userLoginInfo.get("loginPwd");
		boolean loginSuccess = false;
		try {
			// 1、注册驱动
			Class.forName(driver);
			// 2、获取连接
			conn = DriverManager.getConnection(url, user, password);
			// 3、获取预编译的数据库操作对象
			String sql = "select * from t user where loginName = ? and loginPwd = ?";
			ps = conn.prepareStatement(sql);
			// 给占位符？传值（第1个问号下标是1，第2个问号下标是2，JDBC中所有下标从1开始）
			ps.setString(1, loginName);
			ps.setString(2, loginPwd);
			// 4、执行SQL语句
			// 程序执行到此处，会发送sql语句框子给DBMS，DBMS进行sql语句的预先编译
			rs = ps.executeQuery();
			// 5、处理结果集
			if(rs.next()) {
				loginSuccess = true;
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
			if (ps != null) {
				try {
					ps.close()
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
		return loginSuccess;
	}

	/**
	 * 初始化用户界面
	 * @return 用户输入的用户名和密码登录信息
	 */
	private static Map<String, String> initUI() {
		Scanner s = new Scanner(System.in);

		System.out.println("用户名：");
		String loginName = s.nextLine();

		System.out.println("密码：");
		String loginPwd = s.nextLine();

		Map<String, String> userLoginInfo = new HashMap<>();
		userLoginInfo.put("loginName", loginName);
		userLoginInfo.put("loginPwd", loginPwd);

		return userLoginInfo;
	}
}
```

4.对比一下Statement和PreparedStatement

- Statement存在sql注入问题，PreparedStatement解决sql注入问题。
- Statement编译一次执行一次，PreparedStatement是编译一次，可执行N次。PreparedStatement效率较高一些。
- PreparedStatement会在编译阶段做类型的安全检查

5.什么时候用Statement？

当需要拼接sql的时候使用Statement，例如实现排序；当仅仅传值的时候使用PrepareStatement。

```java
// 升序、降序
import java.sql.*;
import java.util.*;

public class JDBCTest07 {
	public static void main(String[] args) {
		// 用户在控制台输入desc就是降序，输入asc就是升序
		Scanner s = new Scanner(System.in);
		System.out.println("输入desc或asc，desc表示降序，asc表示升序");
		System.out.print("请输入：");
		String keyWords = s.nextLine();

		// 执行SQL
		Connection conn = null;
		Statement stmt = null;
		ResultSet rs = null;
		try {
			// 1、注册驱动
			Class.forName(driver);
			// 2、获取连接
			conn = DriverManager.getConnection(url, user, password);
			// 3、获取数据库操作对象
			stmt = conn.createStatement(sql);
			// 4、执行SQL语句
			String sql = "select ename from emp order by ename " + keyWords;
			rs = stmt.executeQuery(sql);
			// 5、处理结果集
			while(rs.next()) {
				System.out.println(rs.getString("ename"));
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
			if (stmt != null) {
				try {
					stmt.close()
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

### PreparedStatement完成增删改

```java
import java.sql.*;

public class JDBCTest08 {
	public static void main(String[] args) {
		// 用户在控制台输入desc就是降序，输入asc就是升序
		Scanner s = new Scanner(System.in);
		System.out.println("输入desc或asc，desc表示降序，asc表示升序");
		System.out.print("请输入：");
		String keyWords = s.nextLine();

		// 执行SQL
		Connection conn = null;
		PreparedStatement ps = null;
		try {
			// 1、注册驱动
			Class.forName(driver);
			// 2、获取连接
			conn = DriverManager.getConnection(url, user, password);
			// 3、获取数据库操作对象
			String sql = "insert into dept (deptno, dname, loc) values (?, ?, ?)";
			ps = conn.prepareStatement(sql);
			ps.setInt(1, 60);
			ps.setString(2, "销售部");
			ps.setString(3, "上海");

			// String sql = "delete from dept where deptno = ?"
			// ps = conn.prepareStatement(sql);
			// ps.setInt(1, 60);

			// String sql = "update dept set dname = ?, loc= ? where deptno = ?";
			// ps = conn.prepareStatement(sql);
			// ps.setString(1, "研发1部");
			// ps.setString(2, "北京");
			// ps.setInt(3, 60);

			// 4、执行SQL语句
			int count = ps.executeUpdate();
			System.out.println(count);
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
			if (ps != null) {
				try {
					ps.close()
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