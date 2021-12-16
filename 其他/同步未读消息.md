# 同步未读消息

## 需求

1. 只有用户已经登录才同步未读消息。
2. 当收到消息推送，触发同步。
3. 当App停留在前台，每个60s，并且停留在指定页面（首页、我的），触发同步。
4. 当指定页面（首页、我的）第一次显示，触发同步。
5. 当离开指定页面（首页、我的）超过60s再回来，触发同步。

## 一、先实现需求4、5

为vc增加rx的扩展序列`visibleDetail`，当vc显示或者离开时会发出“是否显示”、“是否第一次显示”、“离开时间”的元组信号。通过对`visibleDetail`的订阅，当发出信号时，去判断是否第一次，如果是就触发一次同步，如果不是，再判断离开时间是否超过60s，如果超过也需要触发一次同步。

## 1.1 如何为vc增加扩展序列`visibleDetail`

首先增加vc生命周期的基本扩展，[代码来源](https://www.hangge.com/blog/cache/detail_1943.html)。

```swift
public extension Reactive where Base: UIViewController {

    public var viewDidAppear: ControlEvent<Bool> {
        let source = self.methodInvoked(#selector(Base.viewDidAppear))
            .map { $0.first as? Bool ?? false }
        return ControlEvent(events: source)
    }
     
    public var viewWillDisappear: ControlEvent<Bool> {
        let source = self.methodInvoked(#selector(Base.viewWillDisappear))
            .map { $0.first as? Bool ?? false }
        return ControlEvent(events: source)
    }
     
    // 表示视图是否显示的可观察序列，当VC显示状态改变时会触发
    public var isVisible: Observable<Bool> {
        let viewDidAppearObservable = self.base.rx.viewDidAppear.map { _ in true }
        let viewWillDisappearObservable = self.base.rx.viewWillDisappear
            .map { _ in false }
        return Observable<Bool>.merge(viewDidAppearObservable,
                                      viewWillDisappearObservable)
    }

    ......
}
```
继续给vc增加进入/离开时间的属性扩展，用于记录页面的进入/离开的时间撮。
```swift
private var enterStampKey: Void?
private var leaveStampKey: Void?

public extension UIViewController {
    /// 离开时间撮
    var leaveStamp: TimeInterval? {
        set(newValue) {
            objc_setAssociatedObject(self, &leaveStampKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
        get {
            return objc_getAssociatedObject(self, &leaveStampKey) as? TimeInterval
        }
    }
    /// 进入时间撮
    var enterStamp: TimeInterval? {
        set(newValue) {
            objc_setAssociatedObject(self, &enterStampKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
        get {
            return objc_getAssociatedObject(self, &enterStampKey) as? TimeInterval
        }
    }
}
```
有了以上两个扩展，这个时候就可以为vc增加rx扩展序列`visibleDetail`了,可以看下面的实现，`visibleDetail`依赖于`isVisible`,每当页面进入/离开会记录时间撮，同时该序列返回的类型是元组，第一个元素是“是否显示”，第一个元素是“是否第一次显示”，第三个元素是“离开时间”。
```swift
public extension Reactive where Base: UIViewController {
    
    /// 显示详情
    /// - Parameters: 参数
    ///   - visible：是否显示
    ///   - isFirst：是否第一次显示
    ///   - leaveTime：离开时间，单位s，默认返回0
    typealias VisibleDetail = (visible: Bool,isFirst: Bool, leaveTime: Int)

    var visibleDetail: Observable<VisibleDetail> {
        
        return self.base.rx.isVisible.map { (isVisible) -> VisibleDetail in
            
            if isVisible {
                let isFirst = self.base.enterStamp == nil// 是否第一次显示
                var leaveTime: Int = 0// 离开时间
                self.base.enterStamp = Date().timeIntervalSince1970
                if let enterStamp = self.base.enterStamp, let leaveStamp = self.base.leaveStamp, enterStamp > leaveStamp {
                    leaveTime = Int(enterStamp - leaveStamp)
                }
                return (true, isFirst, leaveTime)
            } else {
                self.base.leaveStamp = Date().timeIntervalSince1970
                return (false, false, 0)
            }
        }
    }
}
```
## 1.2 增加SynMessageTool单例

SynMessageTool是一个单例，提供了一个start、stop方法，start方法需要传入一个vc，意思是消息同步是需要根据vc的生命周期来控制的，当vc第一次显示或者离开vc超过60s再回来就触发同步。

```swift
/// 同步未读消息，发出通知
public class SynMessageTool {
    
    public static let shared = SynMessageTool()
    /// SynMessage订阅取消
    private var disposable: Disposable?
    
    /// 同步消息（数字）
    /// - Parameters:
    ///   - messageVc: 同步消息关联vc
    public func start(messageVc: UIViewController?) {
        
        // 传vc才同步消息
        guard let vc = messageVc else {
            return
        }
        // 停止订阅
        stop()
        
        GWLog("----- vc is \(vc.classForCoder) -----")
        /// 页面触发同步序列
        let synMessageObservable = vc.rx.visibleDetail.flatMap { (detail) -> Observable<Int> in
            if detail.isFirst {
                GWLog("----- 第一次显示 -----")
                return HomeViewModel.getUnreadCount
            }
            else if detail.leaveTime > 60 {
                GWLog("----- 非第一次显示，但是离开时间超过60s -----")
                return HomeViewModel.getUnreadCount
            }
            return Observable<Int>.of()
        }
        
        GWLog("----- 开始SynMessage订阅 ------")
        disposable = synMessageObservable.subscribe(onNext: { count in
            
            GWLog("----- 当前消息数数\(count) ------")
            // 发通知
            NotificationCenter.default.post(name: .synMessageCount, object: count, userInfo: ["count":count])
        }, onDisposed: {
            GWLog("----- 释放SynMessage订阅 ------")
        })
    }
    
    public func stop() {
        
        disposable?.dispose()
    }
}
```
## 二、实现需求3

需求：当App停留在前台，每个60s，并且停留在指定页面（首页、我的），触发同步。

这里需要使用到[AppTimer](../AppTimer的使用.html)及vc的rx扩展序列`isVisible`,将AppTimer的到达60s的序列与`isVisible`通过`Observable.combineLatest`组合成一个新的序列，再通过flatMap转换成我们需要的序列，当然这里需要判断“页面是否正在显示”，如果显示才会触发同步。`start`方法修改如下：
```swift
/// 同步消息（数字）
/// - Parameters:
///   - messageVc: 同步消息关联vc
public func start(messageVc: UIViewController?) {
    
    // 传vc才同步消息
    guard let vc = messageVc else {
        return
    }
    // 停止订阅
    stop()
    // 同步消息序列
    var synMessageObservable: Observable<Int>!
    
    GWLog("----- vc is \(vc.classForCoder) -----")
    /// 页面触发同步序列
    let synMessageObservableByVc = vc.rx.visibleDetail.flatMap { (detail) -> Observable<Int> in
        if detail.isFirst {
            GWLog("----- 第一次显示 -----")
            return HomeViewModel.getUnreadCount
        }
        else if detail.leaveTime > 60 {
            GWLog("----- 非第一次显示，但是离开时间超过60s -----")
            return HomeViewModel.getUnreadCount
        }
        return Observable<Int>.of()
    }
    /// 计时器序列
    let synMessageObservableByTimer = Observable.combineLatest(AppTimer.shared.reach60sObservable,vc.rx.isVisible).flatMap { (tuple) -> Observable<Int> in
        GWLog("----- AppTimer 触发同步 -----")
        if tuple.1 {
            return HomeViewModel.getUnreadCount
        }
        return Observable<Int>.of()
    }
    synMessageObservable = Observable.merge(synMessageObservableByVc,synMessageObservableByTimer)
    
    GWLog("----- 开始SynMessage订阅 ------")
    disposable = synMessageObservable.subscribe(onNext: { count in
        
        GWLog("----- 当前消息数数\(count) ------")
        // 发通知
        NotificationCenter.default.post(name: .synMessageCount, object: count, userInfo: ["count":count])
    }, onDisposed: {
        GWLog("----- 释放SynMessage订阅 ------")
    })
}
```
## 三、实现需求2

需求：当收到消息推送，触发同步。

SynMessageTool只需要增加一个立即同步的方法，在收到通知的地方调用即可。
```swift
/// 立即同步
public func immediatelyStart() {
    
    immediatelySynDisposable = HomeViewModel.getUnreadCount.subscribe(onNext: {[weak self] count in
        GWLog("----- immediately:当前消息数数\(count) ------")
        // 发通知
        NotificationCenter.default.post(name: .synMessageCount, object: count, userInfo: ["count":count])
        // 释放订阅
        self?.immediatelyStop()
    }, onDisposed: {
        GWLog("----- immediately:释放SynMessage订阅 ------")
    })
}
```
## 四、实现需求1

需求：只有用户已经登录才同步未读消息。

只需要在`start`和`immediatelyStart`方法中加入如下登录判断即可。
```swift
// 登录后才同步消息
guard UserManager.isLogin else {
    return
}
```
## 五、完整代码
```swift
/// 同步未读消息，发出通知
public class SynMessageTool {
    
    public static let shared = SynMessageTool()
    /// SynMessage订阅取消
    private var disposable: Disposable?
    /// 确保同步一次后取消
    private var immediatelySynDisposable: Disposable?
    
    /// 同步消息（数字）
    /// - Parameters:
    ///   - messageVc: 同步消息关联vc
    public func start(messageVc: UIViewController?) {
        
        // 登录后才同步消息
        guard UserManager.isLogin else {
            return
        }
        // 传vc才同步消息
        guard let vc = messageVc else {
            return
        }
        // 停止订阅
        stop()
        // 同步消息序列
        var synMessageObservable: Observable<Int>!
        
        GWLog("----- vc is \(vc.classForCoder) -----")
        /// 页面触发同步序列
        let synMessageObservableByVc = vc.rx.visibleDetail.flatMap { (detail) -> Observable<Int> in
            if detail.isFirst {
                GWLog("----- 第一次显示 -----")
                return HomeViewModel.getUnreadCount
            }
            else if detail.leaveTime > 60 {
                GWLog("----- 非第一次显示，但是离开时间超过60s -----")
                return HomeViewModel.getUnreadCount
            }
            return Observable<Int>.of()
        }
        /// 计时器序列
        let synMessageObservableByTimer = Observable.combineLatest(AppTimer.shared.reach60sObservable,vc.rx.isVisible).flatMap { (tuple) -> Observable<Int> in
            GWLog("----- AppTimer 触发同步 -----")
            if tuple.1 {
                return HomeViewModel.getUnreadCount
            }
            return Observable<Int>.of()
        }
        synMessageObservable = Observable.merge(synMessageObservableByVc,synMessageObservableByTimer)
        
        GWLog("----- 开始SynMessage订阅 ------")
        disposable = synMessageObservable.subscribe(onNext: { count in
            
            GWLog("----- 当前消息数数\(count) ------")
            // 发通知
            NotificationCenter.default.post(name: .synMessageCount, object: count, userInfo: ["count":count])
        }, onDisposed: {
            GWLog("----- 释放SynMessage订阅 ------")
        })
    }
    
    public func stop() {
        
        disposable?.dispose()
    }
    
    /// 立即同步
    public func immediatelyStart() {
        
        // 登录后才同步消息
        guard UserManager.isLogin else {
            return
        }
        immediatelySynDisposable = HomeViewModel.getUnreadCount.subscribe(onNext: {[weak self] count in
            GWLog("----- immediately:当前消息数数\(count) ------")
            // 发通知
            NotificationCenter.default.post(name: .synMessageCount, object: count, userInfo: ["count":count])
            // 释放订阅
            self?.immediatelyStop()
        }, onDisposed: {
            GWLog("----- immediately:释放SynMessage订阅 ------")
        })
    }
    
    /// 立即停止
    public func immediatelyStop() {
        immediatelySynDisposable?.dispose()
    }
}
```

