# 包管理

## YAML
---
```c
name: flutter_in_action
description: First Flutter Application.

version: 1.0.0+1

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^0.1.2

dev_dependencies:
  flutter_test:
    sdk: flutter
    
flutter:
  uses-material-design: true
```

## Pub仓库
--- 
Pub（https://pub.dev/ ）是 Google 官方的 Dart Packages 仓库，类似于 node 中的 npm仓库、Android中的 jcenter。我们可以在 Pub 上面查找我们需要的包和插件，也可以向 Pub 发布我们的包和插件。

## 示例
---

1.将“english_words” 添加到依赖项列表，如下：
```
dependencies:
  flutter:
    sdk: flutter
  # 新添加的依赖
  english_words: ^4.0.0
```
2.下载包。在Android Studio的编辑器视图中查看pubspec.yaml时（图2-13），单击右上角的 Pub get 。  
3.引入english_words包。
```c
import 'package:english_words/english_words.dart';
```
4.使用english_words包来生成随机字符串。
```c
// 生成随机字符串
final wordPair = WordPair.random();
```

## 其他依赖方式
---
1.依赖本地包
```c
dependencies:
	pkg1:
        path: ../../code/pkg1
```
2.依赖Git
```c
dependencies:
  pkg1:
    git:
      url: git://github.com/xxx/pkg1.git
```
3.使用path参数指定相对位置
```c
dependencies:
  package1:
    git:
      url: git://github.com/flutter/packages.git
      path: packages/package1 
```
依赖方式:https://www.dartlang.org/tools/pub/dependencies 

[包管理](https://book.flutterchina.club/chapter2/flutter_package_mgr.html)
