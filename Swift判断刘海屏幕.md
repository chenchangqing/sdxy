# Swift判断刘海屏幕

直接上代码

```swift
static var isFullScreen: Bool {
    if #available(iOS 11, *) {
          guard let w = UIApplication.shared.delegate?.window, let unwrapedWindow = w else {
              return false
          }
          
          if unwrapedWindow.safeAreaInsets.left > 0 || unwrapedWindow.safeAreaInsets.bottom > 0 {
              print(unwrapedWindow.safeAreaInsets)
              return true
          }
    }
    return false
}
```

首先,刘海屏在iOS 11之后才推出,而重中之重的是safeAreaInsets属性

以下分别是竖屏与横屏的时候,safeAreaInsets打印的值

```swift
UIEdgeInsets(top: 44.0, left: 0.0, bottom: 34.0, right: 0.0)
UIEdgeInsets(top: 0.0, left: 44.0, bottom: 21.0, right: 44.0)
```

其实单单判断bottom > 0 这个属性就完全可以解决问题了

```swift
static var kNavigationBarHeight: CGFloat {
   //return UIApplication.shared.statusBarFrame.height == 44 ? 88 : 64
   return isFullScreen ? 88 : 64
}
    
static var kBottomSafeHeight: CGFloat {
   //return UIApplication.shared.statusBarFrame.height == 44 ? 34 : 0
   return isFullScreen ? 34 : 0
}
```

当然如果只是想简单适配 特别是竖屏的话 下面这段代码其实就能解决很多问题

```swift
UIApplication.shared.statusBarFrame.height == 44
```