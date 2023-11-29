# 组件化开发

>## 如何优雅的使用CTMeditor？

我们项目会有多个组件，比如：个人中心（Me），登录（Login）等，现在我想实现如下的写法：
```swift
Mediator.shared.me
Mediator.shared.login
```
以me为例子，建立Me的结构体，为Me增加扩展，如果Base为Mediator类型，那么可以拥有debugEnvironment方法。
```swift
public struct Me<Base> {
    public let base: Base
    public init(_ base: Base) {
        self.base = base
    }
}
extension Me where Base: Mediator {

    public func debugEnvironment(_ env: String) -> Bool {
    	var deliverParams: [String: Any] = ["env": env]
        let result = base.performTarget("Me", action: "DebugEnvironment", params: deliverParams) as? [String: Any]
        return (result?["result"] as? Bool) ?? false
    }

}
```
扩展Mediator，为Mediator增加me的实例
```swift
public protocol MeProtocol {}

extension Mediator: MeProtocol {}

extension MeProtocol {
    public var me: Me<Self> {
        return Me(self)
    }

    public static var me: Me<Self>.Type {
        return Me.self
    }
}
```
通过以上操作就可以实现`Mediator.shared.me.debugEnvironment("dev")`的调用。

>## CTMeditor实现原理？

以`Mediator.shared.me.debugEnvironment("dev")`为例分析，通过这段代码Mediator可以找到Target是类名为`Target_Me`的实例，方法名是`debugEnvironment`，参数"dev"封装成了字典，通过Runtime的perform方法就可以调用到目标逻辑。

>## 蘑菇街组件化方案问题？

1）蘑菇街没有拆分远程调用和本地间调用。  
2）蘑菇街以远程调用的方式为本地间调用提供服务。  
3）蘑菇街的本地间调用无法传递非常规参数，复杂参数的传递方式非常丑陋。  
4）蘑菇街必须要在app启动时注册URL响应者。  
5）新增组件化的调用路径时，蘑菇街的操作相对复杂。  
6）蘑菇街没有针对target层做封装。

>## 组建化方案如何加载xib及其他资源文件？

通过Class找到Bundle，然后构建Nib的时候传入制定的bundle。

>## 参考链接

[iOS应用架构谈 组件化方案](https://casatwy.com/iOS-Modulization.html)  