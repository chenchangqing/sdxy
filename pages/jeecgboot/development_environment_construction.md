# 开发环境搭建

## 下载源码

* JeecgBoot: https://github.com/jeecgboot/JeecgBoot
* Forked JeecgBoot: https://github.com/chenchangqing/JeecgBoot

## MySQL

1. 卸载conda mysql: conda uninstall mysql
2. 启动mysql: mysql.server start

## Postgresql

1. 新建bysj_dev数据库。
2. 在bysj_dev执行脚本jeecgboot-postgresql17.sql.

## 更新数据源配置

1. datasource：
	```
	url: jdbc:postgresql://127.0.0.1:5432/bysj_dev?stringtype=unspecified
	username: admin
	password: 
	driver-class-name: org.postgresql.Driver
	```
2. 设置Redis密码：
	```
	password: YourStrongPassword123!
	```
## 启动后端

```
cd jeecg-module-system/jeecg-system-start
mvn spring-boot:run
```

## 增加Debug启动

```
{
    "version": "0.2.0",
    "configurations": [
        {
            "type": "java",
            "name": "JeecgSystemApplication",
            "request": "launch",
            "mainClass": "org.jeecg.JeecgSystemApplication",
            "projectName": "jeecg-system-start",
            "vmArgs": "-Dfile.encoding=UTF-8",
            "env": {
                "JAVA_HOME": "/Library/Java/JavaVirtualMachines/jdk-17.jdk/Contents/Home"
            },
            "javaExec": "/Library/Java/JavaVirtualMachines/jdk-17.jdk/Contents/Home/bin/java"
        }
    ]
}
```

## 打包启动jar

```
mvn install -f "/Users/admin/Code/selfexam/JeecgBoot/jeecg-boot/jeecg-module-system/jeecg-system-start/pom.xml" -P dev
```

## Box文档

* https://developer.box.com/platform/authentication-methods/
* Box Authentication: https://github.com/box/box-java-sdk/blob/main/docs/Authentication.md#authenticate-user
* Box Approval: https://developer.box.com/guides/authorization/platform-app-approval
* Box Community: https://community.box.com/box-platform-5

## 创建bysj模块

```
// 注意： windows下可直接复制执行， Linux/Macos下  ^ 修改成  \

mvn archetype:generate \
   -DgroupId=org.jeecgframework.boot3 \
   -DartifactId=jeecg-module-byzj \
   -Dversion=3.9.0 \
   -DarchetypeGroupId=org.jeecgframework.archetype \
   -DarchetypeArtifactId=jeecg-boot-archetype \
   -DarchetypeVersion=3.0
```

## Tableau JavaScript API

https://www.tableau.com/zh-tw/developer/learning/tableau-javascript-api


