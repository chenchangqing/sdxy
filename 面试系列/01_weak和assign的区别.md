# 1.weak和assign的区别

### 什么情况使用`weak`关键字？

1. 在`ARC`中,在有可能出现循环引用的时候，往往要通过让其中一端使用`weak`来解决,比如：`delegate`代理属性。
2. 自身已经对它进行一次强引用,没有必要再强引用一次,此时也会使用`weak`,自定义`IBOutlet`控件属性一般也使用`weak`；当然，也可以使用`strong`。

### 区别

修饰变量类型的区别

1. `weak`只可以修饰对象。如果修饰基本数据类型，编译器会报错-“Property with ‘weak’ attribute must be of object type”。
2. assign 可修饰对象，和基本数据类型。当需要修饰对象类型时，MRC时代使用`unsafe_unretained`。当然，`unsafe_unretained`也可能产生野指针，所以它名字是`unsafe_`。

是否产生野指针的区别

1. `weak`不会产生野指针问题。因为weak修饰的对象释放后（引用计数器值为0），指针会自动被置nil，之后再向该对象发消息也不会崩溃。 weak是安全的。
2. `assign`如果修饰对象，会产生野指针问题；如果修饰基本数据类型则是安全的。修饰的对象释放后，指针不会自动被置空，此时向对象发消息会崩溃。


### 相同

都可以修饰对象类型，但是`assign`修饰对象会存在问题。

### 总结

`assign`适用于基本数据类型如`int,float,struct`等值类型，不适用于引用类型。因为值类型会被放入栈中，遵循先进后出原则，由系统负责管理栈内存。而引用类型会被放入堆中，需要我们自己手动管理内存或通过`ARC`管理。
`weak`适用于`delegate`和`block`等引用类型，不会导致野指针问题，也不会循环引用，非常安全。

## 参考文章

* [iOS开发中 weak和assign的区别](https://www.jianshu.com/p/e9a46253f587)
* [《招聘一个靠谱的iOS》面试题参考答案](https://github.com/ChenYilong/iOSInterviewQuestions/blob/master/01《招聘一个靠谱的iOS》面试题参考答案/《招聘一个靠谱的iOS》面试题参考答案（上）.md#13-用property声明的nsstring或nsarraynsdictionary经常使用copy关键字为什么如果改用strong关键字可能造成什么问题)