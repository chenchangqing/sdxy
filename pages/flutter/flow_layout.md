# 流式布局

[源码](https://gitee.com/learnany/flutter/blob/master/lib/wrap_layout.dart) [流式布局](https://book.flutterchina.club/chapter4/wrap_and_flow.html#_4-5-%E6%B5%81%E5%BC%8F%E5%B8%83%E5%B1%80-wrap%E3%80%81flow)

超出屏幕显示范围会自动折行的布局称为流式布局。

## Wrap
---
下面是Wrap的定义:
```c
Wrap({
  ...
  this.direction = Axis.horizontal,
  this.alignment = WrapAlignment.start,
  this.spacing = 0.0,
  this.runAlignment = WrapAlignment.start,
  this.runSpacing = 0.0,
  this.crossAxisAlignment = WrapCrossAlignment.start,
  this.textDirection,
  this.verticalDirection = VerticalDirection.down,
  List<Widget> children = const <Widget>[],
})
```
* spacing：主轴方向子widget的间距
* runSpacing：纵轴方向的间距
* runAlignment：纵轴方向的对齐方式

下面看一个示例子：
```c
Wrap(
   spacing: 8.0, // 主轴(水平)方向间距
   runSpacing: 4.0, // 纵轴（垂直）方向间距
   alignment: WrapAlignment.center, //沿主轴方向居中
   children: <Widget>[
     Chip(
       avatar: CircleAvatar(backgroundColor: Colors.blue, child: Text('A')),
       label: Text('Hamilton'),
     ),
     Chip(
       avatar: CircleAvatar(backgroundColor: Colors.blue, child: Text('M')),
       label: Text('Lafayette'),
     ),
     Chip(
       avatar: CircleAvatar(backgroundColor: Colors.blue, child: Text('H')),
       label: Text('Mulligan'),
     ),
     Chip(
       avatar: CircleAvatar(backgroundColor: Colors.blue, child: Text('J')),
       label: Text('Laurens'),
     ),
   ],
)
```

## Flow
---

主要用于一些需要自定义布局策略或性能要求较高(如动画中)的场景。