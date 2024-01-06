# 自动配置
---
* 24.1.5 00:21 开始
* 24.1.5 01:13 更新
* 24.1.6 19:36 更新

## 自动版本仲裁机制

在pom.xml文件可以找到以上parent配置：

```xml
<parent>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-parent</artifactId>
    <version>2.3.4.RELEASE</version>
</parent>
```
点击`spring-boot-starter-parent`，可以看到：
```xml
<parent>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-dependencies</artifactId>
    <version>2.3.4.RELEASE</version>
</parent>
```
点击`spring-boot-dependencies`，可以看到：
```xml
<properties>
    <activemq.version>5.18.3</activemq.version>
    <angus-mail.version>2.0.2</angus-mail.version>
    <artemis.version>2.31.2</artemis.version>
    <aspectj.version>1.9.21</aspectj.version>
    <assertj.version>3.24.2</assertj.version>
    ...
    <xml-maven-plugin.version>1.1.0</xml-maven-plugin.version>
    <xmlunit2.version>2.9.1</xmlunit2.version>
    <yasson.version>3.0.3</yasson.version>
</properties>
```
在这里声明了几乎所有常用的jar依赖，称为自动版本仲裁机制。

## 修改mysql默认版本号

1. 点击：https://mvnrepository.com/
2. 搜索mysql，点击` mysql-connector-j`，找到需要的版本，比如：5.1.43
3. 修改`pom.xml`：

```xml
<properties>
    <mysql.version>5.1.43</mysql.version>
</properties>
<dependencies>
	<dependency>
		<groupId>org.springframework.boot</groupId>
		<artifactId>mysql-connector-java</artifactId>
	</dependency>
</dependencies>
```

## starter场景启动器

官方地址：https://docs.spring.io/spring-boot/docs/current/reference/html/using.html#using.build-systems.starters

* 官方starter：spring-boot-starter-*。
* 第三方starter：thirdpartyproject-spring-boot-starter。
* 只要引入starter，这个场景的所有常规需要的依赖我们都自动引入。
* 核心依赖：

```xml
<dependency>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter</artifactId>
  <version>2.3.4.RELEASE</version>
  <scope>compile</scope>
</dependency>
```

>查看依赖树：右键点击`artifactId`，点击Diagrams->Show Dependences。

## 自动配置

在spring-boot-starter-web-3.2.1.pom，自动配置了`Tomcat`starter，`SpringMVC`starter。

### Tomcat

```xml
<dependency>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter-tomcat</artifactId>
  <version>3.2.1</version>
  <scope>compile</scope>
</dependency>
```

### SpringMVC

```xml
<dependency>
  <groupId>org.springframework</groupId>
  <artifactId>spring-web</artifactId>
  <version>6.1.2</version>
  <scope>compile</scope>
</dependency>
<dependency>
  <groupId>org.springframework</groupId>
  <artifactId>spring-webmvc</artifactId>
  <version>6.1.2</version>
  <scope>compile</scope>
</dependency>
```

### 默认包扫描

https://docs.spring.io/spring-boot/docs/current/reference/html/using.html#using.structuring-your-code.using-the-default-package

默认扫描：主程序所在包及其下面的所有子包里面的组件都会被默认扫描进来。

修改包扫描路径：在`Application`类上增加注解：

```java
@SpringBootApplication(scanBasePackages="com.xxx")
```
或
```java
@SpringBootConfiguration
@EnableAutoConfiguration
@ComponentScan("com.xxx")
```

### 各种配置
* tomcat默认端口：server.port
* 文件上传：spring.servlet.multipart.max-file-size
* 配置都是绑定了java类，比入文件上传：MultipartProperties，并且这个java类在容器中存在对应对象。
* 所有配置都可以通过`application.properties`修改。
* 配置是按场景starter加载的。
* SpringBoot所有自动配置都在spring-boot-autoconfigure`。

> 点击`spring-boot-starter-web`，点击`spring-boot-starter`，找到`spring-boot-autoconfigure`


## 视频地址

* start：https://www.bilibili.com/video/BV19K4y1L7MT/?p=6
* end：https://www.bilibili.com/video/BV19K4y1L7MT/?p=7
