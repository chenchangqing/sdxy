# 布局原理与约束

[源码](https://gitee.com/learnany/flutter/blob/master/lib/box_constraints2.dart) [布局原理与约束](https://book.flutterchina.club/chapter4/constraints.html#_4-2-%E5%B8%83%E5%B1%80%E5%8E%9F%E7%90%86%E4%B8%8E%E7%BA%A6%E6%9D%9F-constraints)

尺寸限制类容器用于限制容器大小，Flutter中提供了多种这样的容器，如ConstrainedBox、SizedBox、UnconstrainedBox、AspectRatio 等，本节将介绍一些常用的。

**任何时候子组件都必须先遵守父组件的约束。**

## Flutter布局模型
---

### 1. 两种布局模型

* 基于 RenderBox 的盒模型布局。
* 基于 Sliver ( RenderSliver ) 按需加载列表布局。

### 2. 布局流程

1. 上层组件向下层组件传递约束（constraints）条件。
2. 下层组件确定自己的大小，然后告诉上层组件。注意下层组件的大小必须符合父组件的约束。
3. 上层组件确定下层组件相对于自身的偏移和确定自身的大小（大多数情况下会根据子组件的大小来确定自身的大小）。

## BoxConstraints
---

BoxConstraints 是盒模型布局过程中父渲染对象传递给子渲染对象的约束信息。`BoxConstraints.tight(Size size)`：固定宽高，`BoxConstraints.expand()`：尽可能大。
```c
const BoxConstraints({
  this.minWidth = 0.0, //最小宽度
  this.maxWidth = double.infinity, //最大宽度
  this.minHeight = 0.0, //最小高度
  this.maxHeight = double.infinity //最大高度
})
```

## ConstrainedBox
---
对子组件添加额外的约束，可以设置`constraints`。
```c
ConstrainedBox(
  constraints: BoxConstraints(
    minWidth: double.infinity, //宽度尽可能大
    minHeight: 50.0 //最小高度为50像素
  ),
  child: Container(
    height: 5.0, 
    child: redBox ,
  ),
)
```

## SizedBox
---
用于给子元素指定固定的宽高。
```c
SizedBox(
  width: 80.0,
  height: 80.0,
  child: redBox
)
```

## ConstrainedBox与SizedBox关系
---
ConstrainedBox和SizedBox都是通过RenderConstrainedBox来渲染的，我们可以看到ConstrainedBox和SizedBox的createRenderObject()方法都返回的是一个RenderConstrainedBox对象
```c
@override
RenderConstrainedBox createRenderObject(BuildContext context) {
  return RenderConstrainedBox(
    additionalConstraints: ...,
  );
}
```

## 多重限制
---
```c
ConstrainedBox(
  constraints: BoxConstraints(minWidth: 60.0, minHeight: 60.0), //父
  child: ConstrainedBox(
    constraints: BoxConstraints(minWidth: 90.0, minHeight: 20.0),//子
    child: redBox,
  ),
)
```
或
```c
ConstrainedBox(
  constraints: BoxConstraints(minWidth: 90.0, minHeight: 20.0),
  child: ConstrainedBox(
    constraints: BoxConstraints(minWidth: 60.0, minHeight: 60.0),
    child: redBox,
  )
)
```
显示效果相同，90x60。我们发现有多重限制时，对于minWidth和minHeight来说，是取父子中相应数值较大的。实际上，只有这样才能保证父限制与子限制不冲突。

## UnconstrainedBox
--- 
```c
ConstrainedBox(
  constraints: BoxConstraints(minWidth: 60.0, minHeight: 100.0),  //父
  child: UnconstrainedBox( //“去除”父级限制
    child: ConstrainedBox(
      constraints: BoxConstraints(minWidth: 90.0, minHeight: 20.0),//子
      child: redBox,
    ),
  )
)
```
上面代码中，如果没有中间的UnconstrainedBox，那么根据上面所述的多重限制规则，那么最终将显示一个90×100的红色框。但是由于UnconstrainedBox “去除”了父ConstrainedBox的限制，则最终会按照子ConstrainedBox的限制来绘制redBox，即90×20。

但是，读者请注意，UnconstrainedBox对父组件限制的“去除”并非是真正的去除：上面例子中虽然红色区域大小是90×20，但上方仍然有80的空白空间。也就是说父限制的minHeight(100.0)仍然是生效的，只不过它不影响最终子元素redBox的大小，但仍然还是占有相应的空间，可以认为此时的父ConstrainedBox是作用于子UnconstrainedBox上，而redBox只受子ConstrainedBox限制。
