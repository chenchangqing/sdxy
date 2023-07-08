# JDBC事务

JDBC中的事务是自动提交的，什么事自动提交？

只要执行任意一条DML语句，则自动提交一次，这是JDBC默认的事务行为。但是在实际的业务中，通常都是N条DML语句共同联合才能完成的，必须保证他们这些DML语句在同一个事务中同时成功或者同时失败。

### 账户转账事务

sql脚本：

```
drop table if exists t_act;
create table t_act {
	actno int,
	balance double(7, 2)// 注意，7表示有效数字的个数，2表示小数位的个数。
};
insert into t_act(actno, balance) values (111, 20000);
insert into t_act(actno, balance) values (222, 0);
commit;
select * from t_act;
```

java代码：
```java
import java.sql.*;

public class JDBCTest08 {
	public static void main(String[] args) {

		Connection conn = null;
		PreparedStatement ps = null;
		try {
			// 1、注册驱动
			Class.forName(driver);
			// 2、获取连接
			conn = DriverManager.getConnection(url, user, password);
			// 将自动提交机制修改为手动提交
			conn.setAutoCommit(false);
			// 3、获取数据库操作对象
			String sql = "update t_act set balance = ? where actno = ?";
			ps = conn.prepareStatement(sql);
			// 4、执行SQL语句
			ps.setDouble(1, 10000);
			ps.setInt(2, 111);
			int count = ps.executeUpdate();
			ps.setDouble(1, 10000);
			ps.setInt(2, 222);
			count += ps.executeUpdate();
			System.out.println(count == 2 ? "转账成功" : "转账失败");
			// 程序能够走到这里说明以上程序没有异常，事务结束，手动提交事务
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
			// 6、释放资源
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
以上是单机事务，还有分布式事务。