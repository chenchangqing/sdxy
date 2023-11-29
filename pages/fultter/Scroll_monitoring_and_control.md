# 滚动监听及控制

[源码](https://gitee.com/learnany/flutter/blob/master/lib/scroll_controller_route2.dart) [滚动监听及控制](https://book.flutterchina.club/chapter6/scroll_controller.html#_6-4-%E6%BB%9A%E5%8A%A8%E7%9B%91%E5%90%AC%E5%8F%8A%E6%8E%A7%E5%88%B6)

## ScrollController
---
ScrollController构造函数如下：
```c
ScrollController({
  double initialScrollOffset = 0.0, //初始滚动位置
  this.keepScrollOffset = true,//是否保存滚动位置
  ...
})
```
* offset：可滚动组件当前的滚动位置。
* jumpTo(double offset)、animateTo(double offset,...)：这两个方法用于跳转到指定的位置，它们不同之处在于，后者在跳转时会执行一个动画，而前者不会。

### 1. 滚动监听
ScrollController间接继承自Listenable，我们可以根据ScrollController来监听滚动事件，如：
```c
controller.addListener(()=>print(controller.offset))
```

### 2. 实例
我们创建一个ListView，当滚动位置发生变化时，我们先打印出当前滚动位置，然后判断当前位置是否超过1000像素，如果超过则在屏幕右下角显示一个“返回顶部”的按钮，该按钮点击后可以使ListView恢复到初始位置；如果没有超过1000像素，则隐藏“返回顶部”按钮。代码如下：
```c
class ScrollControllerTestRoute extends StatefulWidget {
  @override
  ScrollControllerTestRouteState createState() {
    return ScrollControllerTestRouteState();
  }
}

class ScrollControllerTestRouteState extends State<ScrollControllerTestRoute> {
  ScrollController _controller = ScrollController();
  bool showToTopBtn = false; //是否显示“返回到顶部”按钮

  @override
  void initState() {
    super.initState();
    //监听滚动事件，打印滚动位置
    _controller.addListener(() {
      print(_controller.offset); //打印滚动位置
      if (_controller.offset < 1000 && showToTopBtn) {
        setState(() {
          showToTopBtn = false;
        });
      } else if (_controller.offset >= 1000 && showToTopBtn == false) {
        setState(() {
          showToTopBtn = true;
        });
      }
    });
  }

  @override
  void dispose() {
    //为了避免内存泄露，需要调用_controller.dispose
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("滚动控制")),
      body: Scrollbar(
        child: ListView.builder(
          itemCount: 100,
          itemExtent: 50.0, //列表项高度固定时，显式指定高度是一个好习惯(性能消耗小)
          controller: _controller,
          itemBuilder: (context, index) {
            return ListTile(title: Text("$index"),);
          }
        ),
      ),
      floatingActionButton: !showToTopBtn ? null : FloatingActionButton(
        child: Icon(Icons.arrow_upward),
        onPressed: () {
          //返回到顶部时执行动画
          _controller.animateTo(
            .0,
            duration: Duration(milliseconds: 200),
            curve: Curves.ease,
          );
        }
      ),
    );
  }
}
```

### 3. 滚动位置恢复

PageStorage是一个用于保存页面(路由)相关数据的组件，它并不会影响子树的UI外观，其实，PageStorage是一个功能型组件，它拥有一个存储桶（bucket），子树中的Widget可以通过指定不同的PageStorageKey来存储各自的数据或状态。

[使用PageStorage在页面切换时保存状态](https://blog.csdn.net/vitaviva/article/details/105313672)

### 4. ScrollPosition

ScrollPosition是用来保存可滚动组件的滚动位置的。一个ScrollController对象可以同时被多个可滚动组件使用，ScrollController会为每一个可滚动组件创建一个ScrollPosition对象，这些ScrollPosition保存在ScrollController的positions属性中（List<ScrollPosition>）。ScrollPosition是真正保存滑动位置信息的对象，offset只是一个便捷属性：
```c
double get offset => position.pixels;
```

### 5. ScrollController控制原理

## 滚动监听
---

### 1. 滚动通知

Flutter Widget树中子Widget可以通过发送通知（Notification）与父(包括祖先)Widget通信。

### 2. 实例
```c
import 'package:flutter/material.dart';

class ScrollNotificationTestRoute extends StatefulWidget {
  @override
  _ScrollNotificationTestRouteState createState() =>
      _ScrollNotificationTestRouteState();
}

class _ScrollNotificationTestRouteState
    extends State<ScrollNotificationTestRoute> {
  String _progress = "0%"; //保存进度百分比

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      //进度条
      // 监听滚动通知
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification notification) {
          double progress = notification.metrics.pixels /
              notification.metrics.maxScrollExtent;
          //重新构建
          setState(() {
            _progress = "${(progress * 100).toInt()}%";
          });
          print("BottomEdge: ${notification.metrics.extentAfter == 0}");
          return false;
          //return true; //放开此行注释后，进度条将失效
        },
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            ListView.builder(
              itemCount: 100,
              itemExtent: 50.0,
              itemBuilder: (context, index) => ListTile(title: Text("$index")),
            ),
            CircleAvatar(
              //显示进度百分比
              radius: 30.0,
              child: Text(_progress),
              backgroundColor: Colors.black54,
            )
          ],
        ),
      ),
    );
  }
}
```