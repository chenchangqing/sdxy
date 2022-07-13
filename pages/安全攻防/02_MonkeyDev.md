# 2.MonkeyDev

##### 一、安装

[安装步骤](https://github.com/AloneMonkey/MonkeyDev/wiki/%E5%AE%89%E8%A3%85)

[xcode 12 Types.xcspec not found #266](https://github.com/AloneMonkey/MonkeyDev/issues/266)

[MonkeyDev插件的安装](https://www.cnblogs.com/wuxianyu/p/14177252.html)

##### 二、运行工程

使用Monkey创建工程，导入.app包之后，配置好工程证书后，点击运行发现如下错误：
```
error: Signing for “monkeyTestDylib” requires a development team
```

解决办法：

1. 选中“monkeytestDylib”Target->Build Settings->搜索Code Sign Style->Manual。
2. Development Team再设置下。

[源码](https://gitee.com/chenchangqing/monkeytest)