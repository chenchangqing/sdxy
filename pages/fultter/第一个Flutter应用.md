# 第一个Flutter应用

## 模板代码分析
---

### 1. 导入包

```c
import 'package:flutter/material.dart';
```
此行代码作用是导入了 Material UI 组件库。

### 2. 应用入口
```c
void main() => runApp(MyApp());
```
启动Flutter应用：`main`调用`runApp`，`runApp`接受`MyApp`对象参数，`MyApp()`是 Flutter应用根组件。

### 3. 应用结构
```c
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //应用名称  
      title: 'Flutter Demo', 
      theme: ThemeData(
        //蓝色主题  
        primarySwatch: Colors.blue,
      ),
      //应用首页路由  
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}
```
* `MyApp`类代表`Flutter`应用，继承了`StatelessWidget`类，是一个widget。
* `Flutter`通过widget提供的`build`方法来构建UI界面。
* `MaterialApp`是Flutter APP框架，可以设置应用的名称、主题、语言、首页及路由列表等。
* `home`指定了App的首页，是一个widget。

## 首页
---

### 1. MyHomePage类

```c
class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
 ...
}
```

* `MyHomePage`是应用首页，它继承自StatefulWidget类，表示它是一个有状态的组件（Stateful widget）。
* `MyHomePage`没有提供`build`方法，但是它有`_MyHomePageState`状态类，`bulid`方法被挪到了这个状态类，

### 2. State类

* 组件的状态。
```c
int _counter = 0; //用于记录按钮点击的总次数
```
* 设置状态的自增函数。
```c
void _incrementCounter() {
  setState(() {
     _counter++;
  });
}
```
点击按钮+时会调用，通过`setState`通知`Flutter`状态修改了，然后重新执行`build`方法重新构建UI。

* 构建UI界面的build方法
```c
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text(widget.title),
    ),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('You have pushed the button this many times:'),
          Text(
            '$_counter',
            style: Theme.of(context).textTheme.headline4,
          ),
        ],
      ),
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: _incrementCounter,
      tooltip: 'Increment',
      child: Icon(Icons.add),
    ), 
  );
}
```
	* `Scaffold`是 Material 库中提供的页面脚手架。
	* `body`是具体的组件树。
	* `floatingActionButton`右下角的加号按钮。

现在，我们将整个计数器执行流程串起来：当右下角的`floatingActionButton`按钮被点击之后，会调用`_incrementCounter`方法。在`_incrementCounter`方法中，首先会自增`_counter`计数器（状态），然后`setState`会通知 Flutter 框架状态发生变化，接着，Flutter 框架会调用`build`方法以新的状态重新构建UI，最终显示在设备屏幕上。

### 3. `build`方法放在State的原因

**为什么要将`build`方法放在State中，而不是放在StatefulWidget中？**

* 状态访问不便。

	将build方法放在widget中，由于构建UI需要访问State的属性，例如上面的`_counter`，也就是说`build`方法需要依赖State ，并且公开`_counter`，这就会导致对状态的修改将会变的不可控。反之，`build`放在State中，可以直接访问状态，并且拿到`_counter`，这会非常方便。

* 继承`StatefulWidget`不便。

	子类在调用父类`build`方法时，需要依赖父类State类，这是不合理的，因为父类的状态是父类内部的实现细节，不应该暴露给子类。

[模板代码分析](https://book.flutterchina.club/chapter2/first_flutter_app.html#_2-1-1-%E5%88%9B%E5%BB%BAflutter%E5%BA%94%E7%94%A8%E6%A8%A1%E6%9D%BF)


