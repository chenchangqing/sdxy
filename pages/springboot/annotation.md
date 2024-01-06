# 注解
--- 
* 24.1.6 19:38 开始
* 24.1.6 21:13 更新

## @Configuration

告诉SpringBoot这是一个配置类，相当于配置文件。
```java
@Configuration
public class MyConfig {}
```

## proxyBeanMethods属性

* Full(proxyBeanMethods=true)：保证每个@Bean方法被调用多少次返回的组件都是单实例的。
* Lite(proxyBeanMethods=false)：每个@Bean方法被调用多少次返回的组件都是新创建的。
* 组件依赖必须使用Full模式，默认就是这个模式。

```java
@Configuration(proxyBeanMethods = false)
public class MyConfig {}
```
>不需要组件依赖时使用Lite模式，也就是说不需要创建新组件时使用Lite，使用Full模式来保证取得的组件为ioc中的同一组件，而这两个模式在getBean时都是从ioc容器中拿的同一个组件。

## @Bean
* 给容器中添加组件，以方法名作为组件的id，返回类型就是组件类型；
* 返回的值，就是组件在容器中的实例，默认单实例。

```java
@Configuration
public class MyConfig {
    @Bean 
    public User user01(){
        User zhangsan = new User("zhangsan", 18);
        return zhangsan;
    }
}
```

## 注册依赖
```java
@Configuration
public class MyConfig {
    @Bean 
    public User user01(){
        User zhangsan = new User("zhangsan", 18);
        zhangsan.setPet(tomcatPet());
        return zhangsan;
    }

    @Bean("tom")
    public Pet tomcatPet(){
        return new Pet("tomcat");
    }
}
```

## SpringMVC注解 

@Component、@Controller、@Service、@Repository

* 根据它们的源码可以看到，Controller、Service、Repository其本质就是Component。
* 它存在的本质只是给开发者看的，对Spring而言它们就都是Component。
* @Controller 控制层类，@Service 业务层类，@Repository 持久层类。
* @Component 无法归类到前3种时就称为组件。

原文：https://blog.csdn.net/nutony/article/details/118670662

## @Import

给容器中自动创建出这两个类型的组件、默认组件的名字就是全类名。
```java
@Import({User.class, DBHelper.class})
@Configuration(proxyBeanMethods = false)
public class MyConfig {}
```

@Import 高级用法： https://www.bilibili.com/video/BV1gW411W7wy?p=8

## @Conditional

* 该注解及其扩展来的注解的关键是实现Condition接口重写其matches方法。
* @Conditional，中派生了很多的子注解，它们可以添加在@Bean注解的方法上也可以放在配置类上，在方法上满足所需条件时则执行方法中内容并注册到IOC。
* 容器中如果不满足条件则不注册，在配置类中满足需求时则执行配置类中所有的@Bean方法并注册到 IOC。 
* 容器中如果不满足条件则不注册，以@ConditionalOnBean(name="tom")为例，当 IOC 容器中拥有id为tom的组件时才会满足条件，否则不满足条件。

```java
@Configuration(proxyBeanMethods = false)
public class MyConfig {
    @Bean
    @ConditionalOnBean(name = "tom")
	//@ConditionalOnMissingBean(name = "tom")
    public User user01(){
        User zhangsan = new User("zhangsan", 18);
        return zhangsan;
    }

    @Bean("tom")
    public Pet tomcatPet(){
        return new Pet("tomcat");
    }
}
```

## @ImportResource
配置文件：
```xml
======================beans.xml=========================
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:context="http://www.springframework.org/schema/context"
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd http://www.springframework.org/schema/context https://www.springframework.org/schema/context/spring-context.xsd">

    <bean id="haha" class="com.atguigu.boot.bean.User">
        <property name="name" value="zhangsan"></property>
        <property name="age" value="18"></property>
    </bean>

    <bean id="hehe" class="com.atguigu.boot.bean.Pet">
        <property name="name" value="tomcat"></property>
    </bean>
</beans>
```
加载配置文件：
```java
@ImportResource("classpath:beans.xml")
public class MyConfig {}
```
测试：
```java
boolean haha = run.containsBean("haha");
boolean hehe = run.containsBean("hehe");
System.out.println("haha："+haha);//true
System.out.println("hehe："+hehe);//true
```

## 配置绑定

### 原始方式
```java
public class getProperties {
    public static void main(String[] args) throws FileNotFoundException, IOException {
        Properties pps = new Properties();
        pps.load(new FileInputStream("a.properties"));
        Enumeration enum1 = pps.propertyNames();//得到配置文件的名字
        while(enum1.hasMoreElements()) {
            String strKey = (String) enum1.nextElement();
            String strValue = pps.getProperty(strKey);
            System.out.println(strKey + "=" + strValue);
            //封装到JavaBean。
        }
	}
}
```

### 第一种方式

@Component + @ConfigurationProperties：@Component@ConfigurationProperties(prefix = "mycar")声明在要绑定的类的上方。

```java
/**
 * 只有在容器中的组件，才会拥有SpringBoot提供的强大功能
 */
@Component
@ConfigurationProperties(prefix = "mycar")
public class Car {

    private String brand;
    private Integer price;

    public String getBrand() {
        return brand;
    }

    public void setBrand(String brand) {
        this.brand = brand;
    }

    public Integer getPrice() {
        return price;
    }

    public void setPrice(Integer price) {
        this.price = price;
    }

    @Override
    public String toString() {
        return "Car{" +
                "brand='" + brand + '\'' +
                ", price=" + price +
                '}';
    }
}
```

### 第二种方式
@EnableConfigurationProperties + @ConfigurationProperties：
1. @ConfigurationProperties(prefix = "mycar")声明在要绑定的类的上方；
2. 在配置类的上方声明@EnableConfigurationProperties(Car.class)，开启对应类的配置绑定功能，把Car这个组件自动注入到容器中。

```java
@EnableConfigurationProperties(Car.class)
// 1、开启Car配置绑定功能
// 2、把这个Car这个组件自动注册到容器中
// 说明一下为什么需要第二种方法：
// 如果@ConfigurationProperties是在第三方包中，
// 那么@component是不能注入到容器的，
// 只有@EnableConfigurationProperties才可以注入到容器。
public class MyConfig {}
```

## 视频地址

* start：https://www.bilibili.com/video/BV19K4y1L7MT/?p=8
* start：https://www.bilibili.com/video/BV19K4y1L7MT/?p=12
