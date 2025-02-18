# 输入框及表单

[源码](https://gitee.com/learnany/flutter/blob/master/lib/LoginInput.dart)  [输入框及表单](https://book.flutterchina.club/chapter3/input_and_form.html)

## TextField参数
---
controller：编辑框的控制器，通过它可以设置/获取编辑框的内容、选择编辑内容、监听编辑文本改变事件。大多数情况下我们都需要显式提供一个controller来与文本框交互。如果没有提供controller，则TextField内部会自动创建一个。

focusNode：用于控制TextField是否占有当前键盘的输入焦点。它是我们和键盘交互的一个句柄（handle）。

InputDecoration：用于控制TextField的外观显示，如提示文本、背景颜色、边框等。

keyboardType：用于设置该输入框默认的键盘输入类型。

textInputAction：键盘动作按钮图标(即回车键位图标)，它是一个枚举值，有多个可选值。

style：正在编辑的文本样式。

textAlign: 输入框内编辑文本在水平方向的对齐方式。

autofocus: 是否自动获取焦点。

obscureText：是否隐藏正在编辑的文本，如用于输入密码的场景等，文本内容会用“•”替换。

maxLines：输入框的最大行数，默认为1；如果为null，则无行数限制。

maxLength和maxLengthEnforcement ：maxLength代表输入框文本的最大长度，设置后输入框右下角会显示输入的文本计数。maxLengthEnforcement决定当输入文本长度超过maxLength时如何处理，如截断、超出等。

toolbarOptions：长按或鼠标右击时出现的菜单，包括 copy、cut、paste 以及 selectAll。

onChange：输入框内容改变时的回调函数；注：内容改变事件也可以通过controller来监听。

onEditingComplete和onSubmitted：这两个回调都是在输入框输入完成时触发，比如按了键盘的完成键（对号图标）或搜索键（🔍图标）。不同的是两个回调签名不同，onSubmitted回调是ValueChanged<String>类型，它接收当前输入内容做为参数，而onEditingComplete不接收参数。

inputFormatters：用于指定输入格式；当用户输入内容改变时，会根据指定的格式来校验。

enable：如果为false，则输入框会被禁用，禁用状态不接收输入和事件，同时显示禁用态样式（在其decoration中定义）。

cursorWidth、cursorRadius和cursorColor：这三个属性是用于自定义输入框光标宽度、圆角和颜色的。

## 示例
---
### 1. 布局
```c
Column(
  children: <Widget>[
    TextField(
      autofocus: true,
      decoration: InputDecoration(
        labelText: "用户名",
        hintText: "用户名或邮箱",
        prefixIcon: Icon(Icons.person)
      ),
    ),
    TextField(
      decoration: InputDecoration(
        labelText: "密码",
        hintText: "您的登录密码",
        prefixIcon: Icon(Icons.lock)
      ),
      obscureText: true,
    ),
  ],
);
```
### 2. 获取输入内容
```c
//定义一个controller
TextEditingController _unameController = TextEditingController();
TextField(
    autofocus: true,
    controller: _unameController, //设置controller
    ...
)
print(_unameController.text)
```
### 3. 监听文本变化
```c
TextField(
    autofocus: true,
    onChanged: (v) {
      print("onChange: $v");
    }
)
```
或
```c
@override
void initState() {
  //监听输入改变  
  _unameController.addListener((){
    print(_unameController.text);
  });
}
```
### 4. 控制焦点
### 5. 监听焦点状态改变事件
### 6. 自定义样式
## 表单Form
---
### 1. Form
### 2. FormField
### 3. FormState
