# JDBC工具类
---
* 23.12.18 22:46更新
* 23.12.19 23:32更新

## DBUtil

```java
/**
 * JDBC工具类，简化JDBC编程
 */
public class DBUtil {

	private static ResourceBundle bundle = ResourceBundle.getBundle("resources/jdbc");
	// com.mysql.jdbc.Driver
	private static String driver = bundle.getString("driver");
	// jdbc:mysql://localhost:3306/mysql
	private static String url = bundle.getString("url");
	private static String user = bundle.getString("user");
	private static String password = bundle.getString("password");
	/**
	 * 工具类中的构造方法都是私有的
	 * 因为工具类当中的方法都是静态的，不需要new对象，直接采用类名调用
	 */
	private DBUtil(){}

	// 静态代码块在类加载时执行，并且只执行一次
	static {
		try {
			Class.forName(driver);
		} catch (ClassNotFoundException e) {
			e.printStackTrace();
		}
	}

	// 这个对象实际上在服务器中只有一个
	private static ThreadLocal<Connection> local = new ThreadLocal<>();

	/**
	 * 获取数据库连接对象
	 * 
	 * @return 连接对象
	 * @throws SQLException
	 */
	public static Connection getConnection() throws SQLException {
		Connection conn = local.get();
		if (conn == null) {
			conn = DriverManager.getConnection(url, user, password);
			local.set(conn);
		}
		return conn;
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
				// Tomcat服务器是支持县城池的，也就是说一个人用过了t1线程，t1线程还有可能被其他用户使用。
				local.remove();
			} catch(SQLException e) {
				e.printStackTrace();
			}
		}
	}
} 
```

## 模糊查询

```java
/**
 * 测试DBUtil是否好用
 * 模糊查询怎么写
 */
public class JDBCTest09 {
	public static void main(String[] args) {
		Connection conn = null;
		PreparedStatement ps = null;
		ResultSet rs = null;
		try {
			// 获取连接
			conn = DBUtil.getConnection();
			// 获取预编译的数据库操作对象

			// 错误的写法
			/*String sql = "select ename from emp where ename like '_?%'";
			ps = conn.prepareStatement(sql);
			ps.setString(1, "A");*/

			String sql = "select ename from emp where ename like ?";
			ps = conn.prepareStatement(sql);
			ps.setString(1, "_A%");
			ps.executeQuery();
			while(rs.next()) {
				System.out.println(rs.getString("ename"));
			}
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			DBUtil.close(conn, ps, rs);
		}
	}
}
```

## 增

```java
/**
 * 插入账户信息
 * @param act 账户信息
 * @return 1 表示插入成功
 */
public int insert(Account act) {
	Connection conn = null;
	PreparedStatement ps = null;
	int count = 0;
	try {
		conn = DBUtil.getConnection();
		String sql = "insert into t_act(actno, balance) values (?, ?)";
		ps = conn.prepareStatement(sql);
		ps.setString(1, act.getActno);
		ps.setDouble(2, act.getBalance());
		count = ps.executeUpdate();
	} catch (SQLException e) {
		throw new RuntimeException(e);
	} finally {
		DBUtil.close(conn, ps, null);
	}
	return count;
}
```

## 删
```java
/**
 * 根据逐渐删除账户
 * @param id 主键
 * @return
 */ 
public int deleteById(Long id) {
	Connection conn = null;
	PreparedStatement ps = null;
	int count = 0;
	try {
		conn = DBUtil.getConnection();
		String sql = "delete from t_act where id = ?";
		ps = conn.prepareStatement(sql);
		ps.setLong(1, id);
		count = ps.executeUpdate();
	} catch (SQLException e) {
		throw new RuntimeException(e);
	} finally {
		DBUtil.close(conn, ps, null);
	}
}
```

## 改
```java
/**
 * 更新账户
 * @param act
 * @return 
 */
public int update(Account act) {
	Connection conn = null;
	PreparedStatement ps = null;
	int count = 0;
	try {
		conn = DBUtil.getConnection();
		String sql = "update t_act set balance = ?, actno = ? where id = ?";
		ps = conn.prepareStatement(sql);
		ps.setDouble(1, act.getBalance());
		ps.setString(2, act.getActno());
		ps.setLong(3, act.getId());
		count = ps.executeUpdate();
	} catch (SQLException e) {
		throw new RuntimeException(e);
	} finally {
		DBUtil.close(conn, ps, null);
	}
	return count;
}
```

## 查
```java
/**
 * 根据账号查询账户
 * @param actno
 * @return
 */
public Account selectByActno(String actno) {
	Connection conn = null;
	PreparedStatement ps = null;
	ResultSet rs = null;
	Account act = null;
	try {
		conn = DBUtil.getConnection();
		String sql = "select id, balance from t_act where actno = ?";
		ps = conn.prepareStatement(sql);
		ps.setString(1, actno);
		rs = ps.executeQuery();
		if (rs.next()) {
			Long id = rs.getLong("id");
			Double balance = rs.getDouble("balance");
			// 将结果集封装成java对象
			act = new Account();
			act.setId(id);
			act.setActno(actno);
			act.setBalance(balance);
		}
	} catch (SQLException e) {
		throw new RuntimeException(e);
	} finally {
		DBUtil.close(conn, ps, null);
	}
	return act;
}


/**
 * 获取所有账户
 * @return
 */
public List<Account> selectAll() {
	Connection conn = null;
	PreparedStatement ps = null;
	ResultSet rs = null;
	List<Account> list = new ArrayList<>();
	try {
		conn = DBUtil.getConnection();
		String sql = "select id, actno, balance from t_act";
		ps = conn.prepareStatement(sql);
		rs = ps.executeQuery();
		where (rs.next()) {
			Long id = rs.getLong("id");
			String actno = rs.getString("actno");
			Double balance = rs.getDouble("balance");
			// 将结果集封装成java对象
			Account act = new Account();
			act.setId(id);
			act.setActno(actno);
			act.setBalance(balance);
			list.add(act);
		}
	} catch (SQLException e) {
		throw new RuntimeException(e);
	} finally {
		DBUtil.close(conn, ps, null);
	}
	return list;
}
```

## 视频

* start://www.bilibili.com/video/BV1Z3411C7NZ?p=67