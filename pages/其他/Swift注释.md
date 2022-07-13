# Swift注释

快捷键：
光标放在方法那一行，option + command + / 可以自动生成相应的注释

单行注释：
```swift
// 你要注释的内容
```

多行注释：
```swift
/*
  你要注释的内容
*/
```

多行嵌套注释：
```swift
/*这是第一个多行注释的开头
/*这是第二个被嵌套的多行注释*/
这是第一个多行注释的结尾*/
```

文档注释：
```swift
/// - Parameters: 参数
///   - item1: This is item1
///   - item2: This is item2
/// - Returns: the result string. 返回值
/// - Throws: `MyError.BothNilError` if both item1 and item2 are nil. 抛出异常
/// - Author: liuyubobobo 作者

-  无序列表 
1. 有序列表
```  代码
#  标题
* _  用于斜体
** 粗体
```

其它：
```swift
// MARK: - Methods
// TODO: changeColor()
// FIXME: Support Swift 2.2
```

附：
>[Swift5.1—注释](https://www.jianshu.com/p/805c018286fc)
>[Swift 注释规范和文档注释](https://blog.csdn.net/qq_14920635/article/details/89676810)