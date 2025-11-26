# 弹性布局

[源码](https://gitee.com/learnany/flutter/blob/master/lib/flex_box_layout.dart) [弹性布局](https://book.flutterchina.club/chapter4/flex.html#_4-4-%E5%BC%B9%E6%80%A7%E5%B8%83%E5%B1%80-flex)

弹性布局允许子组件按照一定比例来分配父容器空间。

## Flex
---
Flex继承自MultiChildRenderObjectWidget，对应的RenderObject为RenderFlex，RenderFlex中实现了其布局算法。
```c
Flex({
  ...
  required this.direction, //弹性布局的方向, Row默认为水平方向，Column默认为垂直方向
  List<Widget> children = const <Widget>[],
})
```

## Expanded
---
Expanded 只能作为 Flex 的孩子（否则会报错），它可以按比例“扩伸”Flex子组件所占用的空间。因为 Row和Column 都继承自 Flex，所以 Expanded 也可以作为它们的孩子。
```c
const Expanded({
  int flex = 1, 
  required Widget child,
})
```
flex参数为弹性系数，如果为 0 或null，则child是没有弹性的，即不会被扩伸占用的空间。如果大于0，所有的Expanded按照其 flex 的比例来分割主轴的全部空闲空间。下面我们看一个例子：
```c
class FlexLayoutTestRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        //Flex的两个子widget按1：2来占据水平空间  
        Flex(
          direction: Axis.horizontal,
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Container(
                height: 30.0,
                color: Colors.red,
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                height: 30.0,
                color: Colors.green,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: SizedBox(
            height: 100.0,
            //Flex的三个子widget，在垂直方向按2：1：1来占用100像素的空间  
            child: Flex(
              direction: Axis.vertical,
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 30.0,
                    color: Colors.red,
                  ),
                ),
                Spacer(
                  flex: 1,
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 30.0,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
```
示例中的Spacer的功能是占用指定比例的空间，实际上它只是Expanded的一个包装类，Spacer的源码如下：
```c
class Spacer extends StatelessWidget {
  const Spacer({Key? key, this.flex = 1})
    : assert(flex != null),
      assert(flex > 0),
      super(key: key);
  
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: const SizedBox.shrink(),
    );
  }
}
```