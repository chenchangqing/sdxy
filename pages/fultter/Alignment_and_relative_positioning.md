# 对齐与相对定位

[源码](https://gitee.com/learnany/flutter/blob/master/lib/align_layout.dart) [对齐与相对定位](https://book.flutterchina.club/chapter4/alignment.html#_4-7-%E5%AF%B9%E9%BD%90%E4%B8%8E%E7%9B%B8%E5%AF%B9%E5%AE%9A%E4%BD%8D-align)

## Align
---
Align 组件可以调整子组件的位置，定义如下：
```c
Align({
  Key key,
  this.alignment = Alignment.center,
  this.widthFactor,
  this.heightFactor,
  Widget child,
})
```
* alignment：需要一个AlignmentGeometry类型的值，表示子组件在父组件中的起始位置。
* AlignmentGeometry 是一个抽象类，它有两个常用的子类：Alignment和 FractionalOffset。
* widthFactor和heightFactor是用于确定Align 组件本身宽高的属性；它们是两个缩放因子，会分别乘以子元素的宽、高，最终的结果就是Align 组件的宽高。如果值为null，则组件的宽高将会占用尽可能多的空间。

## 示例
---
```c
Container(
  height: 120.0,
  width: 120.0,
  color: Colors.blue.shade50,
  child: Align(
    alignment: Alignment.topRight,
    child: FlutterLogo(
      size: 60,
    ),
  ),
)
```
或
```c
Align(
  widthFactor: 2,
  heightFactor: 2,
  alignment: Alignment.topRight,
  child: FlutterLogo(
    size: 60,
  ),
),
```
效果一样，FlutterLogo的宽高为 60，则Align的最终宽高都为2*60=120。

Alignment.topRight：
```c
//右上角
static const Alignment topRight = Alignment(1.0, -1.0);
```
可以看到它只是Alignment的一个实例。

## Alignment
---
Alignment继承自AlignmentGeometry，表示矩形内的一个点，他有两个属性x、y，分别表示在水平和垂直方向的偏移，Alignment定义如下：
```c
Alignment(this.x, this.y)
```
Alignment Widget会以矩形的中心点作为坐标原点。

Alignment可以通过其坐标转换公式将其坐标转为子元素的具体偏移坐标：
```
(Alignment.x*childWidth/2+childWidth/2, Alignment.y*childHeight/2+childHeight/2)
```

## FractionalOffset
---
FractionalOffset 继承自 Alignment，它和 Alignment唯一的区别就是坐标原点不同！FractionalOffset 的坐标原点为矩形的左侧顶点，这和布局系统的一致。FractionalOffset的坐标转换公式为：
```c
实际偏移 = (FractionalOffse.x * childWidth, FractionalOffse.y * childHeight)
```

## Center
---
Center组件其实是对齐方式确定（Alignment.center）了的Align。
```c
class Center extends Align {
  const Center({ Key? key, double widthFactor, double heightFactor, Widget? child })
    : super(key: key, widthFactor: widthFactor, heightFactor: heightFactor, child: child);
}
```