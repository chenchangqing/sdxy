# 层叠布局

[源码](https://gitee.com/learnany/flutter/blob/master/lib/stack_layout1.dart) [层叠布局](https://book.flutterchina.club/chapter4/stack.html#_4-6-%E5%B1%82%E5%8F%A0%E5%B8%83%E5%B1%80-stack%E3%80%81positioned)

子组件可以根据距父容器四个角的位置来确定自身的位置。层叠布局允许子组件按照代码中声明的顺序堆叠起来。

## Stack
---
```c
Stack({
  this.alignment = AlignmentDirectional.topStart,
  this.textDirection,
  this.fit = StackFit.loose,
  this.clipBehavior = Clip.hardEdge,
  List<Widget> children = const <Widget>[],
})
```
* alignment：决定如何去对齐没有定位（没有使用Positioned）或部分定位的子组件。
* textDirection：和Row、Wrap的textDirection功能一样，都用于确定alignment对齐的参考系。
* fit：此参数用于确定没有定位的子组件如何去适应Stack的大小。
* clipBehavior：此属性决定对超出Stack显示空间的部分如何剪裁。

## Positioned
---
```c
const Positioned({
  Key? key,
  this.left, 
  this.top,
  this.right,
  this.bottom,
  this.width,
  this.height,
  required Widget child,
})
```
left、top 、right、 bottom分别代表离Stack左、上、右、底四边的距离。width和height用于指定需要定位元素的宽度和高度。注意，Positioned的width、height 和其他地方的意义稍微有点区别，此处用于配合left、top 、right、 bottom来定位组件，举个例子，在水平方向时，你只能指定left、right、width三个属性中的两个，如指定left和width后，right会自动算出(left+width)，如果同时指定三个属性则会报错，垂直方向同理。

## 示例
---
```c
//通过ConstrainedBox来确保Stack占满屏幕
ConstrainedBox(
  constraints: BoxConstraints.expand(),
  child: Stack(
    alignment:Alignment.center , //指定未定位或部分定位widget的对齐方式
    children: <Widget>[
      Container(
        child: Text("Hello world",style: TextStyle(color: Colors.white)),
        color: Colors.red,
      ),
      Positioned(
        left: 18.0,
        child: Text("I am Jack"),
      ),
      Positioned(
        top: 18.0,
        child: Text("Your friend"),
      )        
    ],
  ),
);
```
由于第一个子文本组件Text("Hello world")没有指定定位，并且alignment值为Alignment.center，所以它会居中显示。第二个子文本组件Text("I am Jack")只指定了水平方向的定位(left)，所以属于部分定位，即垂直方向上没有定位，那么它在垂直方向的对齐方式则会按照alignment指定的对齐方式对齐，即垂直方向居中。对于第三个子文本组件Text("Your friend")，和第二个Text原理一样，只不过是水平方向没有定位，则水平方向居中。

我们给上例中的Stack指定一个fit属性，然后将三个子文本组件的顺序调整一下：
```c
Stack(
  alignment:Alignment.center ,
  fit: StackFit.expand, //未定位widget占满Stack整个空间
  children: <Widget>[
    Positioned(
      left: 18.0,
      child: Text("I am Jack"),
    ),
    Container(child: Text("Hello world",style: TextStyle(color: Colors.white)),
      color: Colors.red,
    ),
    Positioned(
      top: 18.0,
      child: Text("Your friend"),
    )
  ],
),
```
可以看到，由于第二个子文本组件没有定位，所以fit属性会对它起作用，就会占满Stack。由于Stack子元素是堆叠的，所以第一个子文本组件被第二个遮住了，而第三个在最上层，所以可以正常显示。