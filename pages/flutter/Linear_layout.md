# 线性布局

[源码](https://gitee.com/learnany/flutter/blob/master/lib/linear_layout.dart)  [线性布局](https://book.flutterchina.club/chapter4/row_and_column.html#_4-3-1-%E4%B8%BB%E8%BD%B4%E5%92%8C%E7%BA%B5%E8%BD%B4)

## 主轴和纵轴
---
主轴：Row的主轴是水平方向，因为Row是沿水平方向布局；Column的主轴是垂直方向，同理；

纵轴：Row的纵轴是垂直方向，而Column的纵轴是水平方向。

## Row
---

Row可以沿水平方向排列其子widget。定义如下：
```c
Row({
  ...  
  TextDirection textDirection,    
  MainAxisSize mainAxisSize = MainAxisSize.max,    
  MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
  VerticalDirection verticalDirection = VerticalDirection.down,  
  CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
  List<Widget> children = const <Widget>[],
})
```
* textDirection：Row是沿着水平方向布局，那么就存在，从左到右还是从右到左，textDirection就是决定这个布局方向。
* mainAxisSize：水平方向上是否占用最大空间。
* mainAxisAlignment：水平方向的对齐方式，与textDirection共同决定。
* verticalDirection：垂直方向对齐方向。
* crossAxisAlignment：垂直方向的对齐方式，与verticalDirection共同决定。

示例：
```c
Column(
  //测试Row对齐方式，排除Column默认居中对齐的干扰
  crossAxisAlignment: CrossAxisAlignment.start,
  children: <Widget>[
    Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(" hello world "),
        Text(" I am Jack "),
      ],
    ),
    Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(" hello world "),
        Text(" I am Jack "),
      ],
    ),
    Row(
      mainAxisAlignment: MainAxisAlignment.end,
      textDirection: TextDirection.rtl,
      children: <Widget>[
        Text(" hello world "),
        Text(" I am Jack "),
      ],
    ),
    Row(
      crossAxisAlignment: CrossAxisAlignment.start,  
      verticalDirection: VerticalDirection.up,
      children: <Widget>[
        Text(" hello world ", style: TextStyle(fontSize: 30.0),),
        Text(" I am Jack "),
      ],
    ),
  ],
)
```
解释：第一个Row很简单，默认为居中对齐；第二个Row，由于mainAxisSize值为MainAxisSize.min，Row的宽度等于两个Text的宽度和，所以对齐是无意义的，所以会从左往右显示；第三个Row设置textDirection值为TextDirection.rtl，所以子组件会从右向左的顺序排列，而此时MainAxisAlignment.end表示左对齐，所以最终显示结果就是图中第三行的样子；第四个 Row 测试的是纵轴的对齐方式，由于两个子 Text 字体不一样，所以其高度也不同，我们指定了verticalDirection值为VerticalDirection.up，即从低向顶排列，而此时crossAxisAlignment值为CrossAxisAlignment.start表示底对齐。

## Column
---
Column可以在垂直方向排列其子组件。













