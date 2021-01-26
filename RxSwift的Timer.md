# RxSwift的Timer

```swift
// MARK: - 消息功能
private let queryUnreadMsgTimerStopped = BehaviorRelay(value: false)

// 开启计时器
private func startQueryUnreadMsgTimer() {
    guard let reactor = self.reactor else {
        return
    }
    // 定时请求未读消息
    queryUnreadMsgTimerStopped.accept(false)
    Observable<Int>.interval(DispatchTimeInterval.seconds(60), scheduler: MainScheduler.instance).startWith(0).takeWhile{_ in
        UserManager.isLogin
    }.map{_ in
        GWHHomeReactor.Action.queryUnreadCount
    }.takeUntil(queryUnreadMsgTimerStopped.asObservable().filter{ $0 }).bind(to: reactor.action).disposed(by: disposeBag)
}

// 关闭计时器
private func stopQueryUnreadMsgTimer() {
    queryUnreadMsgTimerStopped.accept(true)
}
```

