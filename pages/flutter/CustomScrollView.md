# CustomScrollView

[源码](https://gitee.com/learnany/flutter/blob/master/lib/custom_scrollview_route.dart) [CustomScrollView](https://book.flutterchina.club/chapter6/custom_scrollview.html#_6-10-customscrollview-%E5%92%8C-slivers)

## CustomScrollView
---
前面介绍的 ListView、GridView、PageView 都是一个完整的可滚动组件，所谓完整是指它们都包括Scrollable 、 Viewport 和 Sliver。假如我们想要在一个页面中，同时包含多个可滚动组件，且使它们的滑动效果能统一起来，比如：我们想将已有的两个沿垂直方向滚动的 ListView 成一个 ListView ，这样在第一ListView 滑动到底部时能自动接上第二 ListView，如果尝试写一个 demo：
```c
Widget buildTwoListView() {
    var listView = ListView.builder(
      itemCount: 20,
      itemBuilder: (_, index) => ListTile(title: Text('$index')),
    );
    return Column(
      children: [
        Expanded(child: listView),
        Divider(color: Colors.grey),
        Expanded(child: listView),
      ],
    );
  }
}
```
页面中有两个 ListView，各占可视区域一半高度，虽然能够显式出来，但每一个 ListView 只会响应自己可视区域中滑动，实现不了我们想要的效果。之所以会这样的原因是两个 ListView 都有自己独立的 Scrollable 、 Viewport 和 Sliver，既然如此，我们自己创建一个共用的 Scrollable 和 Viewport 对象，然后再将两个 ListView 对应的 Sliver 添加到这个共用的 Viewport 对象中就可以实现我们想要的效果了。如果这个工作让开发者自己来做无疑是比较麻烦的，因此 Flutter 提供了一个 CustomScrollView 组件来帮助我们创建一个公共的 Scrollable 和 Viewport ，然后它的 slivers 参数接受一个 Sliver 数组，这样我们就可以使用CustomScrollView 方面的实现我们期望的功能了：
```c
Widget buildTwoSliverList() {
  // SliverFixedExtentList 是一个 Sliver，它可以生成高度相同的列表项。
  // 再次提醒，如果列表项高度相同，我们应该优先使用SliverFixedExtentList 
  // 和 SliverPrototypeExtentList，如果不同，使用 SliverList.
  var listView = SliverFixedExtentList(
    itemExtent: 56, //列表项高度固定
    delegate: SliverChildBuilderDelegate(
      (_, index) => ListTile(title: Text('$index')),
      childCount: 10,
    ),
  );
  // 使用
  return CustomScrollView(
    slivers: [
      listView,
      listView,
    ],
  );
}
```
## Sliver
---
|Sliver名称|功能|对应的可滚动组件|
|----|----|----|
|SliverList|列表|ListView|
|SliverFixedExtentList|高度固定的列表|ListView，指定itemExtent时|
|SliverAnimatedList|添加/删除列表项可以执行动画|AnimatedList|
|SliverGrid|网格|GridView|
|SliverPrototypeExtentList|根据原型生成高度固定的列表|ListView，指定prototypeItem 时|
|SliverFillViewport|包含多个子组件，每个都可以填满屏幕|PageView|
除了和列表对应的 Sliver 之外还有一些用于对 Sliver 进行布局、装饰的组件，它们的子组件必须是 Sliver，我们列举几个常用的：
|Sliver名称|对应RenderBox|
|----|----|
|SliverPadding|Padding|
|SliverVisibility、SliverOpacity	|Visibility、Opacity|
|SliverFadeTransition|FadeTransition|
|SliverLayoutBuilder|LayoutBuilder|
还有一些其他常用的 Sliver：
|Sliver名称|说明|
|----|----|
|SliverAppBar|对应 AppBar，主要是为了在 CustomScrollView 中使用。|
|SliverToBoxAdapter|一个适配器，可以将 RenderBox 适配为 Sliver，后面介绍。|
|SliverPersistentHeader|滑动到顶部时可以固定住，后面介绍。|

## 示例
---
```c
// 因为本路由没有使用 Scaffold，为了让子级Widget(如Text)使用
// Material Design 默认的样式风格,我们使用 Material 作为本路由的根。
Material(
  child: CustomScrollView(
    slivers: <Widget>[
      // AppBar，包含一个导航栏.
      SliverAppBar(
        pinned: true, // 滑动到顶端时会固定住
        expandedHeight: 250.0,
        flexibleSpace: FlexibleSpaceBar(
          title: const Text('Demo'),
          background: Image.asset(
            "./imgs/sea.png",
            fit: BoxFit.cover,
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.all(8.0),
        sliver: SliverGrid(
          //Grid
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, //Grid按两列显示
            mainAxisSpacing: 10.0,
            crossAxisSpacing: 10.0,
            childAspectRatio: 4.0,
          ),
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              //创建子widget
              return Container(
                alignment: Alignment.center,
                color: Colors.cyan[100 * (index % 9)],
                child: Text('grid item $index'),
              );
            },
            childCount: 20,
          ),
        ),
      ),
      SliverFixedExtentList(
        itemExtent: 50.0,
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            //创建列表项
            return Container(
              alignment: Alignment.center,
              color: Colors.lightBlue[100 * (index % 9)],
              child: Text('list item $index'),
            );
          },
          childCount: 20,
        ),
      ),
    ],
  ),
);
```
* 头部SliverAppBar：SliverAppBar对应AppBar，两者不同之处在于SliverAppBar可以集成到CustomScrollView。SliverAppBar可以结合FlexibleSpaceBar实现Material Design中头部伸缩的模型，具体效果，读者可以运行该示例查看。
* 中间的SliverGrid：它用SliverPadding包裹以给SliverGrid添加补白。SliverGrid是一个两列，宽高比为4的网格，它有20个子组件。
* 底部SliverFixedExtentList：它是一个所有子元素高度都为50像素的列表。

## SliverToBoxAdapter
---
在实际布局中，我们通常需要往 CustomScrollView 中添加一些自定义的组件，而这些组件并非都有 Sliver 版本，为此 Flutter 提供了一个 SliverToBoxAdapter 组件，它是一个适配器：可以将 RenderBox 适配为 Sliver。比如我们想在列表顶部添加一个可以横向滑动的 PageView，可以使用 SliverToBoxAdapter 来配置：
```c
CustomScrollView(
  slivers: [
    SliverToBoxAdapter(
      child: SizedBox(
        height: 300,
        child: PageView(
          children: [Text("1"), Text("2")],
        ),
      ),
    ),
    buildSliverFixedList(),
  ],
);
```
注意，上面的代码是可以正常运行的，但是如果将 PageView 换成一个滑动方向和 CustomScrollView 一致的 ListView 则不会正常工作！原因是：CustomScrollView 组合 Sliver 的原理是为所有子 Sliver 提供一个共享的 Scrollable，然后统一处理指定滑动方向的滑动事件，如果 Sliver 中引入了其他的 Scrollable，则滑动事件便会冲突。上例中 PageView 之所以能正常工作，是因为 PageView 的 Scrollable 只处理水平方向的滑动，而 CustomScrollView 是处理垂直方向的，两者并未冲突，所以不会有问题，但是换一个也是垂直方向的 ListView 时则不能正常工作，最终的效果是，在ListView内滑动时只会对ListView 起作用，原因是滑动事件被 ListView 的 Scrollable 优先消费，CustomScrollView 的 Scrollable 便接收不到滑动事件了。

## SliverPersistentHeader
---
SliverPersistentHeader 的功能是当滑动到 CustomScrollView 的顶部时，可以将组件固定在顶部。