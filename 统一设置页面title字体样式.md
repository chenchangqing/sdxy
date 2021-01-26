# 统一设置页面title字体样式

## 方案实现

给UINavigationBar增加setTitleFont方法的扩展。

```swift
extension UINavigationBar {
    
    /// Set Navigation Bar title, title color and font.
    ///
    /// - Parameters:
    ///   - font: title font
    ///   - color: title text color (default is .black).
    public func setTitleFont(_ font: UIFont, color: UIColor = .black) {
        var attrs = [NSAttributedString.Key: Any]()
        attrs[.font] = font
        attrs[.foregroundColor] = color
        self.titleTextAttributes = attrs
    }
}
```

## 如何使用

在创建UINavigationController的时候，手动设置title字体样式。

```swift
navVc.navigationBar.setTitleFont(.appMediuFont(16))
```

[统一设置导航栏背景颜色、标题颜色和大小、状态栏文本颜色](https://www.jianshu.com/p/b46fe4cdad02)