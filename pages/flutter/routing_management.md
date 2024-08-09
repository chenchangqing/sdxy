# 路由管理

## 一个简单示例
--- 
1. 创建一个新路由，命名“NewRoute”。
	```c
	class NewRoute extends StatelessWidget {
	  @override
	  Widget build(BuildContext context) {
	    return Scaffold(
	      appBar: AppBar(
	        title: Text("New route"),
	      ),
	      body: Center(
	        child: Text("This is new route"),
	      ),
	    );
	  }
	}
	```
2. 我们添加了一个打开新路由的按钮，点击该按钮后就会打开新的路由页面。
	```c
	Column(
	  mainAxisAlignment: MainAxisAlignment.center,
	  children: <Widget>[
	    ... //省略无关代码
	    TextButton(
	      child: Text("open new route"),
	      onPressed: () {
	        //导航到新路由   
	        Navigator.push( 
	          context,
	          MaterialPageRoute(builder: (context) {
	            return NewRoute();
	          }),
	        );
	      },
	    ),
	  ],
	 )
	 ```

## MaterialPageRoute
---

MaterialPageRoute继承自PageRoute类，PageRoute类是一个抽象类，表示占有整个屏幕空间的一个模态路由页面。

MaterialPageRoute 是 Material组件库提供的组件，它可以针对不同平台，实现与平台页面切换动画风格一致的路由切换动画。

MaterialPageRoute 构造函数的各个参数的意义：
```c
MaterialPageRoute({
	WidgetBuilder builder,
	RouteSettings settings,
	bool maintainState = true,
	bool fullscreenDialog = false,
})
```
* builder：是一个回调函数，返回值是一个widget，也就是我们跳转的页面。
* settings：包含路由的配置信息，如路由名称、是否初始路由（首页）。
* maintainState：一个已经不可见(被上面的盖住完全看不到啦~)的组件，是否还需要保存状态。
* fullscreenDialog：表示新的路由页面是否是一个全屏的模态对话框。

## Navigator
---

Navigator是一个路由管理的组件，它提供了打开和退出路由页方法。

1. Future push(BuildContext context, Route route)
	将给定的路由入栈（即打开新的页面），返回值是一个Future对象，用以接收新路由出栈（即关闭）时的返回数据。
2. bool pop(BuildContext context, [ result ])
	将栈顶路由出栈，result 为页面关闭时返回给上一个页面的数据。
3. 实例方法
	Navigator.push(BuildContext context, Route route)等价于Navigator.of(context).push(Route route)。

## 路由传值
---
传值：
```c
Navigator.pop(context, "我是返回值")
```
获取值：
```c
() async {
  // 打开`TipRoute`，并等待返回结果
  var result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) {
        return TipRoute(
          // 路由参数
          text: "我是提示xxxx",
        );
      },
    ),
  );
  //输出`TipRoute`路由返回结果
  print("路由返回值: $result");
}
```
## 命名路由
---

### 1. 路由表

它是一个Map，key为路由的名字，是个字符串；value是个builder回调函数，用于生成相应的路由widget。
```c
Map<String, WidgetBuilder> routes;
```

### 2. 注册路由表

MaterialApp添加routes属性:
```c
MaterialApp(
  title: 'Flutter Demo',
  theme: ThemeData(
    primarySwatch: Colors.blue,
  ),
  //注册路由表
  routes:{
   "new_page":(context) => NewRoute(),
    ... // 省略其他路由注册信息
  } ,
  home: MyHomePage(title: 'Flutter Demo Home Page'),
);
```
将home注册为命名路由:
```c
MaterialApp(
  title: 'Flutter Demo',
  initialRoute:"/", //名为"/"的路由作为应用的home(首页)
  theme: ThemeData(
    primarySwatch: Colors.blue,
  ),
  //注册路由表
  routes:{
   "new_page":(context) => NewRoute(),
   "/":(context) => MyHomePage(title: 'Flutter Demo Home Page'), //注册首页路由
  } 
);
```
### 3. 打开新路由页

可以使用Navigator 的pushNamed方法：
```c
Future pushNamed(BuildContext context, String routeName,{Object arguments})
```
调用：
```c
onPressed: () {
  Navigator.pushNamed(context, "new_page");
  //Navigator.push(context,
  //  MaterialPageRoute(builder: (context) {
  //  return NewRoute();
  //}));  
},
```

### 4. 命名路由参数传递
传递参数:
```c
Navigator.of(context).pushNamed("new_page", arguments: "hi");
```
获取路由参数:
```c
@override
Widget build(BuildContext context) {
	//获取路由参数  
	var args=ModalRoute.of(context).settings.arguments;
	//...省略无关代码
}
```
### 5. 带参数的路由

```c
MaterialApp(
  ... //省略无关代码
  routes: {
   "tip2": (context){
     return TipRoute(text: ModalRoute.of(context)!.settings.arguments);
   },
 }, 
);
```

## 路由生成钩子
---
MaterialApp有一个onGenerateRoute属性，它在打开命名路由时可能会被调用，之所以说可能，是因为当调用Navigator.pushNamed(...)打开命名路由时，如果指定的路由名在路由表中已注册，则会调用路由表中的builder函数来生成路由组件；如果路由表中没有注册，才会调用onGenerateRoute来生成路由。onGenerateRoute回调签名如下：
```c
Route<dynamic> Function(RouteSettings settings)
```
有了onGenerateRoute回调，要实现上面控制页面权限的功能就非常容易：我们放弃使用路由表，取而代之的是提供一个onGenerateRoute回调，然后在该回调中进行统一的权限控制，如：
```c
MaterialApp(
  ... //省略无关代码
  onGenerateRoute:(RouteSettings settings){
	  return MaterialPageRoute(builder: (context){
		   String routeName = settings.name;
       // 如果访问的路由页需要登录，但当前未登录，则直接返回登录页路由，
       // 引导用户登录；其他情况则正常打开路由。
     }
   );
  }
);
```
onGenerateRoute onUnknownRoute区别：onGenerateRoute 无法生成路由，会触发OnUnknownRoute 属性来处理该场景。

>注意，onGenerateRoute 只会对命名路由生效。也就是需要调用`Navigator.pushNamed`。

[路由管理](https://book.flutterchina.club/chapter2/flutter_router.html)  
[Flutter 路由原理解析](https://juejin.cn/post/6844903798398255111)  
[Flutter 中的 onUnknownRoute 是什么](https://www.likecs.com/ask-339645.html#sc=2528.5)