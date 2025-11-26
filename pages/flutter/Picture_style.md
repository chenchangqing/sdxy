# 图片样式

[源码](https://gitee.com/learnany/flutter/blob/master/lib/imagestyle.dart)  [图片及ICON](https://book.flutterchina.club/chapter3/img_and_icon.html#_3-3-1-%E5%9B%BE%E7%89%87)  [图片资源](https://www.vcg.com/creative/1365017698)  [使用flutter加载本地图片报错](https://zhuanlan.zhihu.com/p/47465069)

## 图片
--- 

Flutter 中，我们可以通过Image组件来加载并显示图片，Image的数据源可以是asset、文件、内存以及网络。

### 1. ImageProvider

ImageProvider 是一个抽象类，主要定义了图片数据获取的接口load()，从不同的数据源获取图片需要实现不同的ImageProvider ，如AssetImage是实现了从Asset中加载图片的 ImageProvider，而NetworkImage 实现了从网络加载图片的 ImageProvider。

### 2. Image

Image widget 有一个必选的image参数，它对应一个 ImageProvider。下面我们分别演示一下如何从 asset 和网络加载图片。

1）先配置.yaml，再从asset中加载图片：

```c
Image(
  image: AssetImage("images/avatar.png"),
  width: 100.0
);
```
或
```c
Image.asset("images/avatar.png",
  width: 100.0,
)
```

2) 从网络加载图片：
```c
Image(
  image: NetworkImage(
      "https://avatars2.githubusercontent.com/u/20411648?s=460&v=4"),
  width: 100.0,
)
```
或
```c
Image.network(
  "https://avatars2.githubusercontent.com/u/20411648?s=460&v=4",
  width: 100.0,
)
```

3）参数

## ICON