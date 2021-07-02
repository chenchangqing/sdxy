# AppTimer的使用

技术：RxSwift实现Timer。

场景：为了解决App多个组件（爱车、社区）分别使用Timer，造成资源浪费的问题，在GWCommonComponent写了一个AppTimer。

### 功能

* 在App启动时调用，跟随App生命周期，目前会发布1s,10s,60s的通知。
* 当App进入后台停止计时，当App将要进入前台重新开始计时。

### 如何使用

务必在每个国家的宿主工程AppLaunch（壳工程调用）。

```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    ......
    window?.rootViewController = tabBarController
    window?.makeKeyAndVisible()
    AppTimer.shared.start()
    return true
}
```

### 源码

```swift
import UIKit
import RxSwift
import GWUtilCore

/**
 跟随App生命周期的Timer
 业务：消息中心，爱车
 */
public class AppTimer {
    
    public static let shared = AppTimer()
    
    private let timer = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
    private var disposable: Disposable?
    /// AppTimer到1s的序列
    public let reach1sObservable = PublishSubject<Void>()
    /// AppTimer到10s的序列
    public let reach10sObservable = PublishSubject<Void>()
    /// AppTimer到60s的序列
    public let reach60sObservable = PublishSubject<Void>()
    
    init() {
        _ = NotificationCenter.default.rx.notification(UIApplication.willEnterForegroundNotification).subscribe(onNext: {[weak self] _ in
            GWLog("----- App进入前台 ------")
            self?.start()
        })
        _ = NotificationCenter.default.rx.notification(UIApplication.didEnterBackgroundNotification).subscribe(onNext: {[weak self] _ in
            GWLog("----- App进入后台 ------")
            self?.stop()
        })
    }
    
    /// 开启计时器
    public func start() {
        
        stop()
        GWLog("----- 开始AppTimer订阅 ------")
        disposable = timer.subscribe(onNext: {[weak self] count in
            
            GWLog("----- 当前时间\(count+1)s ------")
            
            // 1s通知
            NotificationCenter.default.post(name: NSNotification.Name.appTimerReach1s, object: nil)
            self?.reach1sObservable.onNext(())
            
            // 10s通知
            if (count + 1) % 10 == 0 {
                NotificationCenter.default.post(name: NSNotification.Name.appTimerReach10s, object: nil)
                self?.reach10sObservable.onNext(())
            }
            
            // 60s通知
            if (count + 1) % 60 == 0 {
                
                NotificationCenter.default.post(name: NSNotification.Name.appTimerReach60s, object: nil)
                self?.reach60sObservable.onNext(())
            }
        }, onDisposed: {
            GWLog("----- 释放AppTimer订阅 ------")
        })
    }
    
    /// 停止计时器
    public func stop() {
        
        disposable?.dispose()
    }
}
```