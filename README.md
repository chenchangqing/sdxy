# GoMoon

24.8.8新增

## 创建项目

### 检查flutter版本：
```
localhost:flutter chenchangqing$ flutter --version
Flutter 3.3.10 • channel stable • https://github.com/flutter/flutter.git
Framework • revision 135454af32 (1 year, 8 months ago) • 2022-12-15 07:36:55 -0800
Engine • revision 3316dd8728
Tools • Dart 2.18.6 • DevTools 2.15.0
```
### 创建flutter项目：
```
localhost:flutter chenchangqing$ flutter create go_moon
Creating project go_moon...
Running "flutter pub get" in go_moon...                             4.0s
Wrote 127 files.

All done!
In order to run your application, type:

  $ cd go_moon
  $ flutter run

Your application code is in go_moon/lib/main.dart.
```
### 打开项目

使用Android Studio打开项目，然后运行：
<img src="flutter/images/flutter_go_moon_01.png" width=100%/>

## 新增首页

### 新增图片

新建`assets/images`文件夹，导入下图：
<img src="flutter/images/flutter_go_moon_02.png" width=100%/>

在`.yaml`配置`assets`，注意空格
```
# To add assets to your application, add an assets section, like this:
assets:
 - assets/images/
```
拷贝图片路径：
<img src="flutter/images/flutter_go_moon_03.png" width=100%/>

### 创建`pages/home_page.dart`

```c
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
              image: DecorationImage(
                  fit: BoxFit.fitHeight,
                  image: AssetImage("assets/images/flutter_go_moon_02.png")
              )
          ),
        )
    );
  }
}
```

### 修改`main.dart`

```c
import 'package:flutter/material.dart';
import 'package:go_moon/pages/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}
```
### 抽取背景组件方法
<img src="flutter/images/flutter_go_moon_04.png" width=100%/>
<img src="flutter/images/flutter_go_moon_05.png" width=100%/>
```c
@override
Widget build(BuildContext context) {
    return Scaffold(
        body: _astroImageWidget()
    );
}

Container _astroImageWidget() {
return Container(
    decoration: const BoxDecoration(
        image: DecorationImage(
            fit: BoxFit.fitHeight,
            image: AssetImage("assets/images/flutter_go_moon_02.png")
        )
    ),
  );
}
```

## 新增标题
```
Widget _pageTitle() {
  return const Text(
    "#GoMoon",
    style: TextStyle(
        color: Colors.white, fontSize: 70, fontWeight: FontWeight.w800),
  );
}
```


### 格式化代码

<img src="flutter/images/flutter_go_moon_06.png" width=100%/>
修改flutter设置：
<img src="flutter/images/flutter_go_moon_07.png" width=100%/>

### 增加Container

<img src="flutter/images/flutter_go_moon_08.png" width=100%/>
```c
class HomePage extends StatelessWidget {
  late double _deviceHeight, _deviceWidth;

  HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        body: SafeArea(
      child: Container(
        color: Colors.red,
        height: _deviceHeight,
        width: _deviceWidth,
        child: _pageTitle(),
      ),
    ));
  }
  ...
}
```
修改main.dart
<img src="flutter/images/flutter_go_moon_09.png" width=100%/>
>快捷添加父组件：`option+enter`

### 增加左右边距

<img src="flutter/images/flutter_go_moon_10.png" width=100%/>

```c
padding: EdgeInsets.symmetric(horizontal: _deviceWidth * 0.05),
```

## 新增下拉

```c
  ...
  Widget _destionationDropDownWidget() {
    List<DropdownMenuItem<String>> _items = [
      'James Webb Station',
      'Preneure Station',
    ]
        .map(
          (e) => DropdownMenuItem(
            child: Text(e),
            value: e,
          ),
        )
        .toList();
    return Container(
      child: DropdownButton(
        onChanged: (_) {},
        items: _items,
      ),
    );
  }
}
```

### 增加Column

<img src="flutter/images/flutter_go_moon_11.png" width=100%/>

```c
Column(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  mainAxisSize: MainAxisSize.max,
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [_pageTitle(), _destionationDropDownWidget()],
)
```

### 优化方法

<img src="flutter/images/flutter_go_moon_12.png" width=100%/>
```c
  ...
  Widget _destionationDropDownWidget() {
    List<String> _items = [
      'James Webb Station',
      'Preneure Station',
    ];

    return Container(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: _deviceWidth * 0.05),
        width: _deviceWidth,
        decoration: BoxDecoration(
            color: const Color.fromRGBO(53, 53, 53, 1.0),
            borderRadius: BorderRadius.circular(10)),
        child: DropdownButton(
          value: _items.first,
          onChanged: (_) {},
          items: _items
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e),
                  ))
              .toList(),
          underline: Container(),
          dropdownColor: const Color.fromRGBO(53, 53, 53, 1.0),
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
  ...
```

### 创建下拉组件

新建widgets文件夹，在widgets中，新建custom_dropdown_button_class.dart
```c
import 'package:flutter/material.dart';

class CustomDropDownButtonClass extends StatelessWidget {
  List<String> values;
  double width;

  CustomDropDownButtonClass(
      {super.key, required this.values, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: width * 0.05),
      width: width,
      decoration: BoxDecoration(
          color: const Color.fromRGBO(53, 53, 53, 1.0),
          borderRadius: BorderRadius.circular(10)),
      child: DropdownButton(
        value: values.first,
        onChanged: (_) {},
        items: values
            .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e),
                ))
            .toList(),
        underline: Container(),
        dropdownColor: const Color.fromRGBO(53, 53, 53, 1.0),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
```
修改`home_page.dart`：
<img src="flutter/images/flutter_go_moon_13.png" width=100%/>
<img src="flutter/images/flutter_go_moon_14.png" width=100%/>

### 下拉组件布局

<img src="flutter/images/flutter_go_moon_15.png" width=100%/>
<img src="flutter/images/flutter_go_moon_16.png" width=100%/>
```c
  Widget _travellersInfomationWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CustomDropDownButtonClass(
            values: const ['1', '2', '3', '4', '5'],
            width: _deviceWidth * 0.45),
        CustomDropDownButtonClass(
            values: const ['Economy', 'Business', 'First', 'Private'],
            width: _deviceWidth * 0.40),
      ],
    );
  }

  Widget _bookRideWidget() {
    return Container(
      height: _deviceWidth * 0.25,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _destionationDropDownWidget(),
          _travellersInfomationWidget()
        ],
      ),
    );
  }
```
<img src="flutter/images/flutter_go_moon_18.png" width=100%/>

## 新增按钮

<img src="flutter/images/flutter_go_moon_18.png" width=100%/>
```c
  Widget _rideButton() {
    return Container(
      padding: EdgeInsets.only(bottom: _deviceHeight * 0.01),
      width: _deviceWidth,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: MaterialButton(
        onPressed: () {},
        child: const Text(
          "Book Ride!",
          style: TextStyle(color: Colors.black),
        ),
      ),
    );
  }
```

## 增加背景

<img src="flutter/images/flutter_go_moon_19.png" width=100%/>
最终UI：
<img src="flutter/images/flutter_go_moon_20.png" width=30%/>

## 项目地址

https://gitee.com/learnany/flutter/blob/master/go_moon.zip

<div style="margin: 0px;">
    备案号：
    <a href="https://beian.miit.gov.cn/" target="_blank">
        <!-- <img src="https://api.azpay.cn/808/1.png" style="height: 20px;"> -->沪ICP备2022002183号-1
    </a >
</div>

