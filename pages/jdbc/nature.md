# JDBC本质

## JDBC是什么？

Java Database Connectivity（Java语言连接数据库）。

## JDBC的本质是什么？

JDBC是SUN公司制定的一套接口（interface）。接口都有调用者和实现者，面向接口调用、面向接口写实现类，这都属于面向接口编程。java.sql.*，这个软件包下有很多的接口。

## 为什么要面向接口编程？

解耦合：降低程序的耦合度，提供程序的扩展力。多态机制就是非常典型的面向抽象编程，而不是面向具体编程。

我们建议：
```java
Animal a = new Cat();
Animal b = new Dog();

// 喂养的方法
public void feed(Animal a) {
	// 面向父类型编程
}
```

我们不建议：
```java
Cat a = new Cat();
Dog b = new Dog();

// 喂养的方法
public void feed(Cat a) {
	// 面向实现类编程
}
```

## 为什么SUN制定一套JDBC接口呢？

因为每一个数据库的底层实现原理不一样，Oracle数据库有自己的原理，MYSQL数据库也有自己的原理，MS SQLServer数据库也有自己的原理，每个数据库都有自己独特的实现原理。
