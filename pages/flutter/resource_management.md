# 资源管理

常见类型的 assets 包括静态数据（例如JSON文件）、配置文件、图标和图片等。

## 指定 assets
---

在pubspec.yaml中配置：
```c
flutter:
  assets:
    - assets/my_icon.png
    - assets/background.png
```
assets指定应包含在应用程序中的文件， 每个 asset 都通过相对于pubspec.yaml文件所在的文件系统路径来标识自身的路径。

## Asset 变体（variant）
---
例如，如果应用程序目录中有以下文件:
```c
…/pubspec.yaml
…/graphics/my_icon.png
…/graphics/background.png
…/graphics/dark/background.png
…etc.
```
然后pubspec.yaml文件中只需包含:
```c
flutter:
  assets:
    - graphics/background.png
```
那么这两个graphics/background.png和graphics/dark/background.png 都将包含在您的 asset bundle中。前者被认为是_main asset_ （主资源），后者被认为是一种变体（variant）。

在选择匹配当前设备分辨率的图片时，Flutter会使用到 asset 变体（见下文）。

## 加载 assets
---
### 1. 加载文本assets
rootBundle：全局静态对象。
```c
Future<String> loadAsset() async {
  return await rootBundle.loadString('assets/config.json');
}
```
DefaultAssetBundle:
```
DefaultAssetBundle.of(context)
```
### 2. 加载图片

1) 声明分辨率相关的图片 assets

2) 加载图片
```c
Widget build(BuildContext context) {
  return DecoratedBox(
    decoration: BoxDecoration(
      image: DecorationImage(
        image: AssetImage('graphics/background.png'),
      ),
    ),
  );
}
```
AssetImage 并非是一个widget， 它实际上是一个ImageProvider，有些时候你可能期望直接得到一个显示图片的widget，那么你可以使用Image.asset()方法，如：
```c
Widget build(BuildContext context) {
  return Image.asset('graphics/background.png');
}
```

3) 依赖包中的资源图片

```c
AssetImage('icons/heart.png', package: 'my_icons'
```
或
```c
Image.asset('icons/heart.png', package: 'my_icons')
```

4) 打包包中的 assets

### 3. 特定平台 assets

1）设置APP图标

2）更新启动页

## 平台共享 assets
---
Flutter 提供了一种Flutter和原生之间共享资源的方式。

[资源管理](https://book.flutterchina.club/chapter2/flutter_assets_mgr.html)

