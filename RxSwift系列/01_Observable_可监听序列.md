# 1.Observable - 可监听序列

![](../images/rxswift_01.png)

## 一、Observable 介绍

`Observable` 作为 `Rx` 的根基，我们首先对它要有一些基本的了解。

[iOS-RxSwift-Tutorials](https://gitee.com/chenchangqing/iOS-RxSwift-Tutorials)

### 1.1 Observable<T>

* `Observable<T>` 这个类就是 `Rx` 框架的基础，我们可以称它为可观察序列。它的作用就是可以异步地产生一系列的 `Event`（事件），即一个 `Observable<T>` 对象会随着时间推移不定期地发出 `event(element : T)` 这样一个东西。
* 而且这些 `Event` 还可以携带数据，它的泛型 `<T>` 就是用来指定这个 `Event` 携带的数据的类型。
* 有了可观察序列，我们还需要有一个 `Observer`（订阅者）来订阅它，这样这个订阅者才能收到 `Observable<T>` 不时发出的 `Event`。

### 1.2 Event

查看 `RxSwift` 源码可以发现，事件 `Event` 的定义如下：

```swift
public enum Event<Element> {
    /// Next element is produced.
    case next(Element)
 
    /// Sequence terminated with an error.
    case error(Swift.Error)
 
    /// Sequence completed successfully.
    case completed
}
```
可以看到 `Event` 就是一个枚举，也就是说一个 `Observable` 是可以发出 3 种不同类型的 `Event` 事件：

* `next`：`next` 事件就是那个可以携带数据 `<T>` 的事件，可以说它就是一个“最正常”的事件。

## 参考文章

* 原文出自：www.hangge.com  转载请保留原文链接：https://www.hangge.com/blog/cache/detail_1922.html
* [RxSwift中文文档](https://beeth0ven.github.io/RxSwift-Chinese-Documentation/)