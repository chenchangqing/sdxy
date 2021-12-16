# 资源包装类

资源：项目中使用的图片、颜色、字体、常量、多语言等。

为了方便管理项目资源，UtilCore组件新增了几个资源包装类，后续请确保项目统一使用包装类调用资源。

如果只在业务组件中使用，请为以下几个包装类分别做扩展，确保资源调用的高度统一。

## 解决的问题

* 明确项目中所有使用的字体、颜色、图片等，资源统一管理，为后续主题做铺垫。
* 如果项目全部替换为通过包装类使用资源，那么一旦某个颜色、图片不用了，可以直接删除包装类的定义，再删除具体的资源，减少垃圾资源的存在。
* 代码风格统一，调用简单清晰。

## GWColor.swift
```swift
public extension UIColor {
    /// 根据模式（正常/暗黑）渲染颜色
    /// - Parameters:
    ///   - normal: 正常Hex
    ///   - dark: 暗黑Hex
    /// - Returns: 颜色
    static func renderColor(_ color: GWDynamicColor) -> UIColor {
        var result: UIColor?
        if #available(iOS 13, *) {
            result = UIColor(dynamicProvider: { (traitCollection) -> UIColor in
                (traitCollection.userInterfaceStyle == .dark ? UIColor(hexString: color.dark) ?? UIColor.white : UIColor(hexString: color.normal)) ?? UIColor.white
            })
        } else {
            result = UIColor(hexString: color.normal)
        }
        return result ?? UIColor.white
    }
}
/**
 颜色包装类
 - UtilCore及其它业务组件通用的颜色在这里定义
 - 通过使用包装类方便管理颜色
 - 业务组件可以通过Extensions去扩展自己的颜色
 - 使用：GWConstant.xC7C3C3
 */
/// 动态颜色类型
public typealias GWDynamicColor = (normal: String, dark: String)

public enum GWColor {
    public static let xC7C3C3 = UIColor.renderColor(GWDynamicColor("#C7C3C3", "#C7C3C3"))
    public static let x2F2F2F = UIColor.renderColor(GWDynamicColor("#2F2F2F", "#2F2F2F"))
    public static let xF6F6F6 = UIColor.renderColor(GWDynamicColor("#F6F6F6", "#F6F6F6"))
    public static let x2D78FF = UIColor.renderColor(GWDynamicColor("#2D78FF", "#2D78FF"))
    // ...
}
```
## GWConstant.swift
```swift
/**
 常量包装类
 - UtilCore及其它业务组件通用的常量在这里定义
 - 通过使用包装类方便管理常量
 - 业务组件可以通过Extensions去扩展自己的常量
 - 使用：GWConstant.xxx
 */
public struct GWConstant {
    
}
```
## GWFont.swift
```swift
/**
 字体包装类
 - UtilCore及其它业务组件通用的字体在这里定义
 - 通过使用包装类方便管理字体
 - 业务组件可以通过Extensions去扩展自己的字体
 - 使用：GWLocalized.r11
 */
public struct GWFont {
    
    public static let r11 = UIFont.appRegularFontWith(size: 11)
    public static let r12 = UIFont.appRegularFontWith(size: 12)
    public static let r14 = UIFont.appRegularFontWith(size: 14)
    public static let r16 = UIFont.appRegularFontWith(size: 16)
    public static let r20 = UIFont.appRegularFontWith(size: 20)
    public static let m20 = UIFont(mediumFontWithSize: 20)
}
```
## GWImage.swift
```swift
/**
 图片包装类
 - UtilCore及其它业务组件通用的图片在这里定义
 - 通过使用包装类方便管理图片
 - 业务组件可以通过Extensions去扩展自己的图片
 - 使用：GWImage.ruNoContent
 */
public struct GWImage {
    
    // MARK: - UIView+Empty
    
    /// 俄罗斯·没数据
    static var ruNoContent: UIImage? {
        UIImage(inUtilCore: "img_russia_common_no_content")
    }
    /// 俄罗斯·无网络
    static var ruNoNetwork: UIImage? {
        UIImage(inUtilCore: "img_russia_common_no_network")
    }
    /// 泰国·没数据
    static var thNoContent: UIImage? {
        UIImage(inUtilCore: "no_content")
    }
    /// 泰国·无网络
    static var thNoNetwork: UIImage? {
        UIImage(inUtilCore: "no_network")
    }
    /// 泰国·服务器错误
    static var thServerError: UIImage? {
        UIImage(inUtilCore: "load_failure")
    }
}
```
## GWLocalized.swift
```swift
/**
 多语言包装类
 - UtilCore及其它业务组件通用的多语言在这里定义
 - 通过使用包装类方便管理多语言
 - 业务组件可以通过Extensions去扩展自己的多语言
 - 使用：GWLocalized.loading
 */
public struct GWLocalized {
    /// 提交中
    public static var loading: String {
        GWI18n.R.string.localizable.base_loading()
    }
    /// Yes
    public static var yes: String {
        GWI18n.R.string.localizable.base_yes()
    }
    /// No
    public static var no: String {
        GWI18n.R.string.localizable.base_no()
    }
    /// 无网络
    public static var noNetwork: String {
        GWI18n.R.string.localizable.base_net_lost()
    }
    /// 发布
    public static var publish: String {
        GWI18n.R.string.localizable.re_publish()
    }
    /// 确认
    public static var confirm: String {
        GWI18n.R.string.localizable.base_sure()
    }
    /// 取消
    public static var cancel: String {
        GWI18n.R.string.localizable.base_cancel()
    }
}
```