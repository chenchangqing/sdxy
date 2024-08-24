# 可滚动组件简介

[可滚动组件简介](https://book.flutterchina.club/chapter6/intro.html#_6-1-%E5%8F%AF%E6%BB%9A%E5%8A%A8%E7%BB%84%E4%BB%B6%E7%AE%80%E4%BB%8B)  
[CustomScrollView和NestedScrollView的详细介绍](https://www.bilibili.com/video/BV1c7411o7Ss/?spm_id_from=333.337.search-card.all.click&vd_source=0e0265662467c6caea699dd58aec6891)  
[在Flutter中创建有意思的滚动效果 - Sliver系列](https://juejin.cn/post/6844903901720739848)

## Sliver布局模型
---

### 1. 布局模型

* 基于 RenderBox 的盒模型布局。
* 基于 Sliver ( RenderSliver ) 按需加载列表布局。

### 2. 主要作用

Sliver 可以包含一个或多个子组件。加载子组件并确定每一个子组件的布局和绘制信息，实现按需加载模型。

### 3. 三个角色

* Scrollable ：用于处理滑动手势，确定滑动偏移，滑动偏移变化时构建 Viewport 。
* Viewport：显示的视窗，即列表的可视区域；
* Sliver：视窗里显示的元素。

### 4. 角色关系

* 三者所占用的空间重合。
* Sliver 父组件为 Viewport，Viewport的 父组件为 Scrollable。

### 5. 布局过程

1. Scrollable 监听到用户滑动行为后，根据最新的滑动偏移构建 Viewport 。
2. Viewport 将当前视口信息和配置信息通过 SliverConstraints 传递给 Sliver。
3. Sliver 中对子组件（RenderBox）按需进行构建和布局，然后确认自身的位置、绘制等信息，保存在 geometry 中（一个 SliverGeometry 类型的对象）。

### 6. cacheExtent

预渲染的高度，在可视区域之外，如果 RenderBox 进入这个区域内，即使它还未显示在屏幕上，也是要先进行构建，默认值是 250。

## Scrollable
---
用于处理滑动手势，确定滑动偏移，滑动偏移变化时构建 Viewport，我们看一下其关键的属性：
```c
Scrollable({
  ...
  this.axisDirection = AxisDirection.down,//滚动方向。
  this.controller,
  this.physics,
  required this.viewportBuilder, //后面介绍
})
```

### 1. physics

ScrollPhysics类型的对象，响应用户操作：
* 用户滑动完抬起手指后，继续执行动画。
* 滑动到边界时，如何显示。

ScrollPhysics的子类：
* ClampingScrollPhysics：列表滑动到边界时将不能继续滑动，通常在Android 中 配合 GlowingOverscrollIndicator（实现微光效果的组件） 使用。
* BouncingScrollPhysics：iOS 下弹性效果。

### 2. controller

ScrollController对象，默认的PrimaryScrollController，控制滚动位置和监听滚动事件。

### 3. viewportBuilder

构建 Viewport 的回调。当用户滑动时，Scrollable 会调用此回调构建新的 Viewport，同时传递一个 ViewportOffset 类型的 offset 参数，该参数描述 Viewport 应该显示那一部分内容。

## Viewport
---
显示 Sliver。
```c
Viewport({
  Key? key,
  this.axisDirection = AxisDirection.down,
  this.crossAxisDirection,
  this.anchor = 0.0,
  required ViewportOffset offset, // 用户的滚动偏移
  // 类型为Key，表示从什么地方开始绘制，默认是第一个元素
  this.center,
  this.cacheExtent, // 预渲染区域
  //该参数用于配合解释cacheExtent的含义，也可以为主轴长度的乘数
  this.cacheExtentStyle = CacheExtentStyle.pixel, 
  this.clipBehavior = Clip.hardEdge,
  List<Widget> slivers = const <Widget>[], // 需要显示的 Sliver 列表
})
```

### 1. offset

该参数为Scrollable 构建 Viewport 时传入，它描述了 Viewport 应该显示那一部分内容。

### 2. cacheExtent 和 cacheExtentStyle

* CacheExtentStyle 是一个枚举，有 pixel 和 viewport 两个取值。
* 当 cacheExtentStyle 值为 pixel 时，cacheExtent 的值为预渲染区域的具体像素长度；
* 当值为 viewport 时，cacheExtent 的值是一个乘数，表示有几个 viewport 的长度，最终的预渲染区域的像素长度为：cacheExtent * viewport 的积。

## Sliver
---

### 1. 主要作用

对子组件进行构建和布局，比如 ListView 的 Sliver 需要实现子组件（列表项）按需加载功能，只有当列表项进入预渲染区域时才会去对它进行构建和布局、渲染。

### 2. RenderSliver

Sliver 对应的渲染对象类型是 RenderSliver。
* RenderSliver 和 RenderBox 都继承自 RenderObject 类。
* RenderSliver 和 RenderBox 约束信息分别是 BoxConstraints 和 SliverConstraints。

## 通用配置
---
scrollDirection（滑动的主轴）、reverse（滑动方向是否反向）、controller、physics 、cacheExtent ，这些属性最终会透传给对应的 Scrollable 和 Viewport，这些属性我们可以认为是可滚动组件的通用属性。

> reverse表示是否按照阅读方向相反的方向滑动，如：scrollDirection值为Axis.horizontal 时，即滑动发现为水平，如果阅读方向是从左到右（取决于语言环境，阿拉伯语就是从右到左）。reverse为true时，那么滑动方向就是从右往左。
