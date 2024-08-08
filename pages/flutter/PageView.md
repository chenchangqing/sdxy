# PageView

[源码](https://gitee.com/learnany/flutter/blob/master/lib/pageview_route.dart)  [PageView与页面缓存](https://book.flutterchina.club/chapter6/pageview.html#_6-7-pageview%E4%B8%8E%E9%A1%B5%E9%9D%A2%E7%BC%93%E5%AD%98)

## 构造方法
---
```c
PageView({
  Key? key,
  this.scrollDirection = Axis.horizontal, // 滑动方向
  this.reverse = false,
  PageController? controller,
  this.physics,
  List<Widget> children = const <Widget>[],
  this.onPageChanged,
  
  //每次滑动是否强制切换整个页面，如果为false，则会根据实际的滑动距离显示页面
  this.pageSnapping = true,
  //主要是配合辅助功能用的，后面解释
  this.allowImplicitScrolling = false,
  //后面解释
  this.padEnds = true,
})
```
## 示例
---
我们看一个 Tab 切换的实例，为了突出重点，我们让每个 Tab 页都只显示一个数字。
```c
// Tab 页面 
class Page extends StatefulWidget {
  const Page({
    Key? key,
    required this.text
  }) : super(key: key);

  final String text;

  @override
  _PageState createState() => _PageState();
}

class _PageState extends State<Page> {
  @override
  Widget build(BuildContext context) {
    print("build ${widget.text}");
    return Center(child: Text("${widget.text}", textScaleFactor: 5));
  }
}
```
我们创建一个 PageView：
```c
@override
Widget build(BuildContext context) {
  var children = <Widget>[];
  // 生成 6 个 Tab 页
  for (int i = 0; i < 6; ++i) {
    children.add( Page( text: '$i'));
  }

  return PageView(
    // scrollDirection: Axis.vertical, // 滑动方向为垂直方向
    children: children,
  );
}
```

## 页面缓存
---

allowImplicitScrolling设置为true可以缓存前后各一页数据。