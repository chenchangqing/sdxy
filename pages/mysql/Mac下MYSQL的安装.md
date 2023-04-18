# Mac下MYSQL的安装

环境：macos 11.7.4

## 一、MYSQL下载
---

1、进入[官网](https://www.mysql.com/)，滑动至最下方，找到Downloads，点击MySQL Community Server。   
2、点击Archives，选择Product Version:5.7.31，选择Operating System:macOS。   
3、下载“macOS 10.14 (x86, 64-bit), Compressed TAR Archive”。   
4、解压缩：   
```c
cd /usr/local/
sudo mkdir src
sudo mv ~/Downloads/mysql-5.7.31-macos10.14-x86_64.tar.gz src
sudo tar -xzvf mysql-5.7.31-macos10.14-x86_64.tar.gz
sudo ln -sf mysql-5.7.31-macos10.14-x86_64 mysql
sudo chown -R chenchangqing:staff mysql*
```

## 二、配置环境变量
---

1、 `vi ~/.bash_profile`，在 ~/.bashrc 中添加如下配置项。
```c
MYSQL_HOME=/usr/local/mysql
export PATH=$PATH:$MYSQL_HOME/bin:$MYSQL_HOME/support-files
```
2、`source ~/.bash_profile`。   
3、`mysql --version`。
```c
chenchangqingdeMacBook-Pro-2:sdxy chenchangqing$ mysql --version
mysql  Ver 14.14 Distrib 5.7.31, for macos10.14 (x86_64) using  EditLine wrapper
```
4、错误分析：
```c
dyld: Symbol not found: __ZTTNSt3__118basic_stringstreamIcNS_11char_traitsIcEENS_9allocatorIcEEEE
  Referenced from: /usr/local/mysql/bin/mysql (which was built for Mac OS X 12.0)
  Expected in: /usr/lib/libc++.1.dylib
 in /usr/local/mysql/bin/mysql
Abort trap: 6
```
如果出现以上错误，说明下载的mysql版本和当前的macos系统不匹配，比如“macos 11.7.4”下载了“macOS 13 (x86, 64-bit), Compressed TAR Archive”，就会出现上面的[错误](https://stackoverflow.com/questions/49888517/cannot-launch-mysql-on-mac)。
```c
-bash: /usr/local/mysql/bin/mysql: Bad CPU type in executable。
```
如果出现以上错误，说明下载的mysql版本与当前macos系统不匹配CPU架构不匹配，比如“macos 11.7.4”下载了“macOS 12 (ARM, 64-bit), Compressed TAR Archive”，就会出现上面的错误。


## 三、初始化root
---
```c
chenchangqingdeMacBook-Pro-2:local chenchangqing$ mysqld --initialize-insecure
2023-03-24T17:25:46.055794Z 0 [Warning] TIMESTAMP with implicit DEFAULT value is deprecated. Please use --explicit_defaults_for_timestamp server option (see documentation for more details).
2023-03-24T17:25:46.057786Z 0 [Warning] Setting lower_case_table_names=2 because file system for /usr/local/mysql-5.7.31-macos10.14-x86_64/data/ is case insensitive
2023-03-24T17:25:46.237798Z 0 [Warning] InnoDB: New log files created, LSN=45790
2023-03-24T17:25:46.269409Z 0 [Warning] InnoDB: Creating foreign key constraint system tables.
2023-03-24T17:25:46.329085Z 0 [Warning] No existing UUID has been found, so we assume that this is the first time that this server has been started. Generating a new UUID: e99f3ed4-ca68-11ed-b222-0a4a56d116f7.
2023-03-24T17:25:46.340828Z 0 [Warning] Gtid table is not ready to be used. Table 'mysql.gtid_executed' cannot be opened.
2023-03-24T17:25:46.790867Z 0 [Warning] CA certificate ca.pem is self signed.
2023-03-24T17:25:46.937195Z 1 [Warning] root@localhost is created with an empty password ! Please consider switching off the --initialize-insecure option.
```
从输出可以看到，mysqld 已经帮我们创建了一个 root 用户，且该 root 用户的 password 为空。

## 四、启动MYSQL
---
```c
chenchangqingdeMacBook-Pro-2:local chenchangqing$ mysql.server start
Starting MySQL
. SUCCESS! 
```

## 五、登录root 
---
```c
chenchangqingdeMacBook-Pro-2:local chenchangqing$ mysql -uroot -p
Enter password: 
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 2
Server version: 5.7.31 MySQL Community Server (GPL)

Copyright (c) 2000, 2020, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> 
```

## 六、给root用户创建密码
---
```c
mysql> ALTER USER root@localhost IDENTIFIED WITH caching_sha2_password BY '123456';
-> ;
ERROR 1524 (HY000): Plugin 'caching_sha2_password' is not loaded
```
MySQL新版默认使用caching_sha2_password作为身份验证插件，而旧版是使用mysql_native_password。当连接MySQL时报错“plugin caching_sha2_password could not be loaded”时，可换回旧版插件。
```c
mysql> ALTER USER root@localhost IDENTIFIED WITH mysql_native_password BY '123456';
Query OK, 0 rows affected (0.00 sec)
mysql> FLUSH PRIVILEGES;
Query OK, 0 rows affected (0.00 sec)
mysql> quit
Bye
```

## 七、常用命令
---

1、启动MYSQL

```c
chenchangqingdeMacBook-Pro-2:local chenchangqing$ mysql.server start
Starting MySQL
 SUCCESS! 
```
2、停止MYSQL
```c
chenchangqingdeMacBook-Pro-2:local chenchangqing$ mysql.server stop
Shutting down MySQL
.. SUCCESS! 
```

3、重启MYSQL
```c
chenchangqingdeMacBook-Pro-2:local chenchangqing$ mysql.server restart
 ERROR! MySQL server PID file could not be found!
Starting MySQL
.
 SUCCESS! 
```

4、检查 MySQL 运行状态
```
chenchangqingdeMacBook-Pro-2:local chenchangqing$ mysql.server status
 SUCCESS! MySQL running (1725)
```

## 八、参考
---

https://learnku.com/articles/62379

https://blog.csdn.net/weixin_33728077/article/details/113902283

https://www.cnblogs.com/yjmyzz/p/how-to-install-mysql8-on-mac-using-tar-gz.html