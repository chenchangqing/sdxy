# Animdo

* 24.8.9 created

## 创建工程

```
localhost:flutter chenchangqing$ flutter create animdo
Creating project animdo...
Running "flutter pub get" in animdo...                           2,408ms
Wrote 127 files.

All done!
In order to run your application, type:

  $ cd animdo
  $ flutter run

Your application code is in animdo/lib/main.dart.
```

## Use AnimatedContainer

圆形缩放动画：

```c
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double _buttonRadius = 100;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        clipBehavior: Clip.none,
        children: [_pageBackground(), _circularAnimationButton()],
      ),
    );
  }

  Widget _pageBackground() {
    return Container(
      color: Colors.blue,
    );
  }

  Widget _circularAnimationButton() {
    return Center(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _buttonRadius += _buttonRadius == 200 ? -100 : 100;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(seconds: 2),
          curve: Curves.bounceInOut,
          height: _buttonRadius,
          width: _buttonRadius,
          decoration: BoxDecoration(
              color: Colors.purple, borderRadius: BorderRadius.circular(100)),
          child: const Center(
            child: Text(
              "Basic",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
```

## Use TweenAnimationBuilder

背景放大至屏幕大小动画：

`_HomePageState`增加属性:
```
final Tween<double> _backgroudScale = Tween<double>(begin: 0.0, end: 1.0);
```
修改方法`_pageBackground`:
```c
  Widget _pageBackground() {
    return TweenAnimationBuilder(
      tween: _backgroudScale,
      curve: Curves.easeInOutCubicEmphasized,
      duration: Duration(seconds: 2),
      builder: (_context, double _scale, _child) {
        return Transform.scale(
          scale: _scale,
          child: _child,
        );
      },
      child: Container(
        color: Colors.blue,
      ),
    );
  }
```

## Use AnimationController

✨自转：

1、新增`_starIconAnimationController`属性：
<image src="images/flutter_animdo_01.png" width=100%/>
```c
class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  double _buttonRadius = 100;

  final Tween<double> _backgroudScale = Tween<double>(begin: 0.0, end: 1.0);

  late AnimationController _starIconAnimationController;

  @override
  void initState() {
    super.initState();
    _starIconAnimationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 4));
    _starIconAnimationController.repeat();
  }
  ...
```
2、新增`_starIcon`方法：
<image src="images/flutter_animdo_02.png" width=100%/>
```c
  ...
  Widget _starIcon() {
    return AnimatedBuilder(
      animation: _starIconAnimationController!.view,
      builder: (_buildContext, _child) {
        return Transform.rotate(
          angle: _starIconAnimationController!.value * 2 * pi,
          child: _child,
        );
      },
      child: const Icon(
        Icons.star,
        size: 100,
        color: Colors.white,
      ),
    );
  }
}
```

## 源码

https://gitee.com/learnany/flutter/blob/master/animdo.zip