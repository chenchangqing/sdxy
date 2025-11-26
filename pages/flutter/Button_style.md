# 按钮样式

[源码](https://gitee.com/learnany/flutter/blob/master/lib/btnstyle.dart)  [按钮](https://book.flutterchina.club/chapter3/buttons.html#_3-2-1-elevatedbutton) [flutter TextButton样式](https://blog.csdn.net/python4_1/article/details/120783115)

## ElevatedButton
---
```c
ElevatedButton(
  child: Text("normal"),
  onPressed: () {},
);
```

## TextButton
---
```c
TextButton(
  child: Text("normal"),
  onPressed: () {},
)
```

## OutlinedButton
---
```c
OutlineButton(
  child: Text("normal"),
  onPressed: () {},
)
```

## IconButton
---
```c
IconButton(
  icon: Icon(Icons.thumb_up),
  onPressed: () {},
)
```

## 带图标的按钮
---
```c
ElevatedButton.icon(
  icon: Icon(Icons.send),
  label: Text("发送"),
  onPressed: _onPressed,
),
OutlinedButton.icon(
  icon: Icon(Icons.add),
  label: Text("添加"),
  onPressed: _onPressed,
),
TextButton.icon(
  icon: Icon(Icons.info),
  label: Text("详情"),
  onPressed: _onPressed,
),
```