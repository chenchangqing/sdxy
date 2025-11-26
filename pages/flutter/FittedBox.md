# FittedBox

[源码](https://gitee.com/learnany/flutter/blob/master/lib/fitted_box2.dart) [空间适配（FittedBox）](https://book.flutterchina.club/chapter5/fittedbox.html#_5-6-1-fittedbox)

## FittedBox
---
```c
const FittedBox({
  Key? key,
  this.fit = BoxFit.contain, // 适配方式
  this.alignment = Alignment.center, //对齐方式
  this.clipBehavior = Clip.none, //是否剪裁
  Widget? child,
})
```
## 适配原理
---

1. FittedBox允许子组件无限大(0<=width<=double.infinity, 0<= height <=double.infinity)。
2. FittedBox 对子组件布局结束后就可以获得子组件真实的大小。
3. FittedBox 知道子组件的真实大小也知道他父组件的约束，那么FittedBox 就可以通过指定的适配方式（BoxFit 枚举中指定），让起子组件在 FittedBox 父组件的约束范围内按照指定的方式显示。

## 示例
---
```c
Widget build(BuildContext context) {
  return Center(
    child: Column(
      children: [
        wContainer(BoxFit.none),
        Text('Wendux'),
        wContainer(BoxFit.contain),
        Text('Flutter中国'),
      ],
    ),
  );
}

Widget wContainer(BoxFit boxFit) {
  return Container(
    width: 50,
    height: 50,
    color: Colors.red,
    child: FittedBox(
      fit: boxFit,
      // 子容器超过父容器大小
      child: Container(width: 60, height: 70, color: Colors.blue),
    ),
  );
}
```

## 单行缩放布局
---
```c
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children:  [
          wRow(' 90000000000000000 '),
          FittedBox(child: wRow(' 90000000000000000 ')),
          wRow(' 800 '),
          FittedBox(child: wRow(' 800 ')),
    		]
        .map((e) => Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: e,
            ))
        .toList();,
      ),
    );
  }

 // 直接使用Row
  Widget wRow(String text) {
    Widget child = Text(text);
    child = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [child, child, child],
    );
    return child;
  }
```