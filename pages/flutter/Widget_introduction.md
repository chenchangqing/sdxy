# Widget简介

##`Widget`概念
---
描述一个UI元素的配置信息，比如对于`Text`来讲，文本的内容、对齐方式、文本样式都是它的配置信息。

`Widget`类的声明：
```c
@immutable // 不可变的
abstract class`Widget`extends DiagnosticableTree {
  const Widget({ this.key });

  final Key? key;

  @protected
  @factory
  Element createElement();

  @override
  String toStringShort() {
    final String type = objectRuntimeType(this, 'Widget');
    return key == null ? type : '$type-$key';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.defaultDiagnosticsTreeStyle = DiagnosticsTreeStyle.dense;
  }

  @override
  @nonVirtual
  bool operator ==(Object other) => super == other;

  @override
  @nonVirtual
  int get hashCode => super.hashCode;

  static bool canUpdate(Widget oldWidget,`Widget`newWidget) {
    return oldWidget.runtimeType == newWidget.runtimeType
        && oldWidget.key == newWidget.key;
  }
  ...
}
```
* `@immutable`代表`Widget`是不可变的，限制Widget中的属性必须使用`final`修饰。
	为啥不允许属性修改呢？属性修改会重新创建新的Widget实例，这没有意义，还有就是可变属性应该交给State管理。
* `key`的作用是决定下一次`build`是否复用旧的`widget`，决定的条件在`canUpdate()`方法。
* `createElement`构建UI树时，生成对应节点的Element对象。一个`widget`可以对应多个Element。
* `canUpdate(...)`：是否用新的`widget`对象去更新旧UI树上所对应的Element对象的配置，返回false的话，会重新创建新的`Element`。

Widget类是一个抽象类，其中最核心的就是定义了createElement()接口。

## Flutter中的四棵树
---
Widget 只是描述一个UI元素的配置信息，那么真正的布局、绘制是由谁来完成的呢？Flutter 框架的的处理流程是这样的：

1. 根据`Widget`树生成一个 Element 树，Element 树中的节点都继承自 Element 类。
2. 根据 Element 树生成`Render`树（渲染树），渲染树中的节点都继承自RenderObject 类。
3. 根据渲染树生成 Layer 树，然后上屏显示，Layer 树中的节点都继承自 Layer 类。

真正的布局和渲染逻辑在`Render`树中，Element 是`Widget`和 RenderObject 的粘合剂，可以理解为一个中间代理。

## Widget类
---
### 1. StatelessWidget
* 继承`Widget`类，重写了`createElement()`方法，对应`StatelessElement`类。
* 用于不需要维护状态的场景，有一个`build`方法用来构建UI。

### 2. BuildContext
* `build`方法的`context`参数，表示当前`widget`在`widget`树中的上下文，每个`widget`对应一个`context`。
* `context`是当前`widget`在`widget`树中位置中执行”相关操作“的一个句柄。

### 3. StatefulWidget
* 对应`StatefulElement`，多了一个`createState()`方法。
* `StatefulElement`中可能会多次调用`createState()`来创建状态（State）对象。
* `createState()`用于创建和`StatefulWidget`相关的状态，它在`StatefulWidget`的生命周期中可能会被多次调用。
* 在`StatefulWidget`中，`State`对象和`StatefulElement`具有一一对应的关系。

## State
---
### 1. 简介
一个`StatefulWidget`类会对应一个`State`类，`State`表示与其对应的`StatefulWidget`要维护的状态。State 中的保存的状态信息可以：
1. 在`widget`构建时可以被同步读取。
2. 可以修改，然后手动调用其`setState()`方法，重新调用其`build`方法达到更新UI的目的。

State 中有两个常用属性：
1. `widget`，重新构建时可能会变化，但State实例只会在第一次插入到树中时被创建。
2. `context`，StatefulWidget对应的BuildContext。

### 2. State生命周期

* `initState`：当`widget`第一次插入到`widget`树时会被调用。
* `didChangeDependencies`：当State对象的依赖发生变化时会被调用。
* `build()`会在如下场景被调用：
	1. 在调用initState()之后。
	2. 在调用didUpdateWidget()之后。
	3. 在调用setState()之后。
	4. 在调用didChangeDependencies()之后。
	5. 在State对象从树中一个位置移除后（会调用deactivate）又重新插入到树的其他位置之后。
* `reassemble`：热重载(hot reload)时会被调用，此回调在Release模式下永远不会被调用。
* `didUpdateWidget`：在`widget`重新构建时，Flutter 框架会调用widget.canUpdate来检测`widget`树中同一位置的新旧节点，然后决定是否需要更新，如果widget.canUpdate返回true则会调用此回调。
* `deactivate`：当 State 对象从树中被移除时，会调用此回调。
* `dispose`：当 State 对象从树中被永久移除时调用。

## 在`widget`树中获取State对象
---
### 1. 通过Context获取

1. `findAncestorStateOfType`方法：
	```c
	// 查找父级最近的Scaffold对应的ScaffoldState对象
	ScaffoldState _state = context.findAncestorStateOfType<ScaffoldState>()!;
	// 打开抽屉菜单
	_state.openDrawer();
	```
2.  StatefulWidget中提供一个`of`静态方法来获取其`State`对象。
	```c
	// 直接通过of静态方法来获取ScaffoldState
    ScaffoldState _state=Scaffold.of(context);
    // 打开抽屉菜单
    _state.openDrawer();
    ```

### 2. 通过GlobalKey

1. 给目标StatefulWidget添加GlobalKey。
	```c
	//定义一个globalKey, 由于GlobalKey要保持全局唯一性，我们使用静态变量存储
	static GlobalKey<ScaffoldState> _globalKey= GlobalKey();
	...
	Scaffold(
	    key: _globalKey , //设置key
	    ...  
	)
	```
2. 通过GlobalKey来获取State对象
	```c
	_globalKey.currentState.openDrawer()
	```

## 通过 RenderObject 自定义 Widget
---
通过RenderObject定义组件的方式：
```c
class CustomWidget extends LeafRenderObjectWidget{
  @override
  RenderObject createRenderObject(BuildContext context) {
    // 创建 RenderObject
    return RenderCustomObject();
  }
  @override
  void updateRenderObject(BuildContext context, RenderCustomObject  renderObject) {
    // 更新 RenderObject
    super.updateRenderObject(context, renderObject);
  }
}

class RenderCustomObject extends RenderBox{

  @override
  void performLayout() {
    // 实现布局逻辑
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // 实现绘制
  }
}
```
1. 如果组件不会包含子组件，则我们可以直接继承自 LeafRenderObjectWidget。
	```c
	abstract class LeafRenderObjectWidget extends RenderObjectWidget {
	  const LeafRenderObjectWidget({ Key? key }) : super(key: key);

	  @override
	  LeafRenderObjectElement createElement() => LeafRenderObjectElement(this);
	}
	```
2. 重写了 createRenderObject 方法。该方法被组件对应的 Element 调用（构建渲染树时）用于生成渲染对象。
3. updateRenderObject 方法是用于在组件树状态发生变化但不需要重新创建 RenderObject 时用于更新组件渲染对象的回调。
4. RenderCustomObject 类是继承自 RenderBox，而 RenderBox 继承自 RenderObject，我们需要在 RenderCustomObject 中实现布局、绘制、事件响应等逻辑

## Flutter SDK内置组件库介绍
---

### 1. 基础组件
要使用基础组件库，需要先导入：
```c
import 'package:flutter/widgets.dart';
```
* `Text`：文本。
* `Row`、`Column`：在水平（Row）和垂直（Column）方向上创建灵活的布局。
* `Stack`：取代线性布局。
* `Container`：矩形视觉元素。

### 2. Material组件

Android系UI。

要使用 Material 组件，需要先引入它：
```c
import 'package:flutter/material.dart';
```
* Material 应用程序以MaterialApp (opens new window) 组件开始。
* Material 组件有Scaffold、AppBar、TextButton等。

### 3. Cupertino组件

iOS系UI。

* MaterialPageRoute：在路由切换时，如果是 Android 系统，它将会使用 Android 系统默认的页面切换动画(从底向上)；如果是 iOS 系统，它会使用 iOS 系统默认的页面切换动画（从右向左）。
* Cupertino 组件风格的页面：
	```c
	//导入cupertino `widget`库
	import 'package:flutter/cupertino.dart';

	class CupertinoTestRoute extends StatelessWidget  {
	  @override
	 `widget`build(BuildContext context) {
	    return CupertinoPageScaffold(
	      navigationBar: CupertinoNavigationBar(
	        middle: Text("Cupertino Demo"),
	      ),
	      child: Center(
	        child: CupertinoButton(
	            color: CupertinoColors.activeBlue,
	            child: Text("Press"),
	            onPressed: () {}
	        ),
	      ),
	    );
	  }
	}
	```

## 总结
---
* Flutter 的`widget`类型分为StatefulWidget 和 StatelessWidget 两种。
* 引入过多组件库会让你的应用安装包变大。
* 由于 Material 和 Cupertino 都是在基础组件库之上的，所以如果我们的应用中引入了这两者之一，则不需要再引入flutter/ widgets.dart了，因为它们内部已经引入过了。

[Widget 简介](https://book.flutterchina.club/chapter2/flutter_widget_intro.html#_2-2-1-widget-%E6%A6%82%E5%BF%B5)  
[Flutter中Widget 、Element、RenderObject角色深入分析](https://developer.huawei.com/consumer/cn/forum/topic/0202327746887030154)  
[Flutter State生命周期](https://www.bilibili.com/video/BV1ET4y1a7xY/?spm_id_from=333.788&vd_source=0e0265662467c6caea699dd58aec6891)  