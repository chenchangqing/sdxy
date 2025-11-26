# 布局类组件介绍

[布局类组件介绍](https://book.flutterchina.club/chapter4/intro.html#_4-1-%E5%B8%83%E5%B1%80%E7%B1%BB%E7%BB%84%E4%BB%B6%E7%AE%80%E4%BB%8B)

布局类组件都会包含一个或多个子组件，不同的布局类组件对子组件排列（layout）方式不同。

## 布局类
---
### 1. LeafRenderObjectWidget

非容器类组件基类，Widget树的叶子节点，用于没有子节点的widget，通常基础组件都属于这一类，如Image。

### 2. SingleChildRenderObjectWidget	

单子组件基类，包含一个子Widget，如：ConstrainedBox、DecoratedBox等。

### 3. MultiChildRenderObjectWidget

多子组件基类，包含多个子Widget，一般都有一个children参数，接受一个Widget数组。如Row、Column、Stack等。

### 4. 继承关系

Widget > RenderObjectWidget > (Leaf/SingleChild/MultiChild)RenderObjectWidget 。

## RenderObjectWidget
---

子类必须实现创建、更新RenderObject的方法。RenderObject是最终布局、渲染UI界面的对象，实现布局算法。Stack（层叠布局）对应的RenderObject对象就是RenderStack，而层叠布局的实现就在RenderStack中。