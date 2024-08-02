# 面试问题整理

## 消息转发

**消息发送的本质**：

`objc_msgSend(id _Nullable self, SEL _Nonnull op, ...)`。

**消息发送步骤**：

1. 首先检查这个`Selector`是不是要忽略。比如Mac OS X开发，有了垃圾回收就不会理会`retain`，`release`这些函数。
2. 检测这个`Selector`的target是不是nil，OC允许我们对一个nil对象执行任何方法不会Crash，因为运行时会被忽略掉。
3. 如果上面两步都通过了，就开始查找这个类的实现IMP，先从cache里查找，如果找到了就运行对应的函数去执行相应的代码。
4. 如果cache中没有找到就找类的方法列表中是否有对应的方法。
5. 如果类的方法列表中找不到就到父类的方法列表中查找，一直找到NSObject类为止。
6. 如果没有找到，Runtime 会发送 `+resolveInstanceMethod:` 或者 `+resolveClassMethod:`尝试去 resolve 这个消息。
7. 如果 resolve 方法返回 NO，`Runtime` 就发送 -forwardingTargetForSelector: 允许你把这个消息转发给另一个对象。
8. 如果没有新的目标对象返回，`Runtime`就会发送`-methodSignatureForSelector:` 和 `-forwardInvocation:` 消息。你可以发送 `-invokeWithTarget:` 消息来手动转发消息或者发送`-doesNotRecognizeSelector:`抛出异常。

**消息转发应用**：

* 预防没有方法实现而会导致的崩溃。
* 预防苹果系统API迭代造成API不兼容的崩溃。
* 模拟多继承。

**参考**：

* [iOS开发·runtime原理与实践: 消息转发篇(Message Forwarding) (消息机制，方法未实现+API不兼容奔溃，模拟多继承)](https://juejin.cn/post/6844903600968171533)

## KVO的底层实现？

当一个对象使用了`KVO`监听，iOS系统会修改这个对象的`isa`指针，改为指向一个全新的通过`Runtime`动态创建的子类，子类拥有自己的`set`方法实现，`set`方法实现内部会顺序调用`willChangeValueForKey`方法、原来的`setter`方法实现、`didChangeValueForKey`方法，而`didChangeValueForKey`方法内部又会调用监听器的`observeValueForKeyPath:ofObject:change:context:`监听方法。

手动触发：
```c
+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key
{
    BOOL automatic = YES;
    if ([key isEqualToString:@"name"]) {
        automatic = NO;
    } else {
        automatic = [super automaticallyNotifiesObserversForKey:key];
    }
    return automatic;
}

- (void)setName:(NSString *)name
{
    if (![_name isEqualToString:name]) {
        [self willChangeValueForKey:@"name"];
        _name = name;
        [self didChangeValueForKey:@"name"];
    } 
}
```
**参考**：

* [iOS底层原理总结 - 探寻KVO本质](https://juejin.cn/post/6844903593925935117)
* [iOS - 关于 KVO 的一些总结](https://juejin.cn/post/6844903972528979976)

## isa是什么？

isa是结构体指针，只要是OC对象都有isa，作用如下：

* 实例对象`instance`的`isa`指向类对象`class`。
* 类对象`class`的`isa`指向元类对象`meta-class`。
* `class`的`superclass`指向父类的`class`，如果没有父类，`superclass`指针为`nil`。
* `meta-class`的`superclass`指向父类的`meta-class`，基类的`meta-class`的`superclass`指向基类的`class`。
* `instance`调用对象方法的轨迹：`isa`找到`class`，方法不存在，就通过`superclass`找父类。
* `class`调用类方法的轨迹：`isa`找`meta-class`，方法不存在，就通过`superclass`找父类。

**参考**：

* [iOS 探究 OC对象、isa指针及KVO实现原理](https://juejin.cn/post/6939858821581897741)

## 自动释放池

`@autoreleasepool`在`main`函数中的c++代码：
```c
int main(int argc, const char * argv[]) {
    {
        void * atautoreleasepoolobj = objc_autoreleasePoolPush();

        // do whatever you want

        objc_autoreleasePoolPop(atautoreleasepoolobj);
    }
    return 0;
}
```
`AutoreleasePoolPage`的结构：
```c
class AutoreleasePoolPage {
    magic_t const magic;// 用于对当前 AutoreleasePoolPage 完整性的校验
    id *next;// 指向了下一个为空的内存地址
    pthread_t const thread;// 保存了当前页所在的线程
    AutoreleasePoolPage * const parent;// 实现双向链表的parent节点
    AutoreleasePoolPage *child;// 实现双向链表的child节点
    uint32_t const depth;
    uint32_t hiwat;
};
```
AutoreleasePoolPage 的大小都是 4096 字节，其中56bit用于存储成员变量，剩下的从哨兵的位置开始都是用来存对象地址的。

`objc_autoreleasePoolPush`方法：
```c
static inline void *push() {
   return autoreleaseFast(POOL_SENTINEL);
}

static inline id *autoreleaseFast(id obj)
{
   AutoreleasePoolPage *page = hotPage();
   if (page && !page->full()) {// 有hotpage，且不满
       return page->add(obj);
   } else if (page) {// 有hotpage，且已满
       return autoreleaseFullPage(obj, page);
   } else {// 没有hotpage
       return autoreleaseNoPage(obj);
   }
}
Objective-C
```
`objc_autoreleasePoolPop`方法：
```c
void objc_autoreleasePoolPop(void *ctxt) {
    AutoreleasePoolPage::pop(ctxt);
}

static inline void pop(void *token) {
    AutoreleasePoolPage *page = pageForPointer(token);
    id *stop = (id *)token;// 获取当前 token 所在的 AutoreleasePoolPage

    page->releaseUntil(stop);// 方法释放栈中的对象，直到 stop

    /**
     * 当前page一半都没满，说明剩余的page空间已经暂时够了，把多余的child page就可以全kill掉，释放空间；
     * 如果超过一半，就认为下一页page还有存在的必要，说不定添加的对象太多就能用的到，所以kill掉孙子page，有个儿子page就暂时够了。
     */
    if (page->child) {
        if (page->lessThanHalfFull()) {
            page->child->kill();
        } else if (page->child->child) {
            page->child->child->kill();
        }
    }
}
```
`autorelease`方法：调用上面提到的`autoreleaseFast`方法，将当前对象加到`AutoreleasePoolPage`中。

`RunLoop`和`autoreleasePool`：

1. 第1个Observer监听了`kCFRunLoopEntry`事件，会调用`objc_autoreleasePoolPush()`；
2. 第2个Observer:
	* 监听了`kCFRunLoopBeforeWaiting`事件，会调用`objc_autoreleasePoolPop()`、`objc_autoreleasePoolPush()`；
	* 监听了`kCFRunLoopBeforeExit`事件，会调用`objc_autoreleasePoolPop()`。

**参考**：

* [自动释放池的前世今生 ---- 深入解析 autoreleasepool](https://draveness.me/autoreleasepool/)
* [iOS autoreleasepool详解](https://blog.csdn.net/m0_55124878/article/details/125738636)
* [iOS内存管理(5)-autorelease原理和autorelease和runloop的结合使用](https://www.jianshu.com/p/5030e47c0766)
* [iOS——Autoreleasepool底层原理](https://blog.csdn.net/chabuduoxs/article/details/126326184)

## Runloop

* 顾名思义，运行循环，线程与`Runloop`是一一对应，`Runloop`运行可以是线程不退出。
* `Runloop`默认注册5个`Mode`：
	* `kCFRunLoopDefaultMode`：App的默认 Mode，通常主线程是在这个 Mode 下运行的。
	* `UITrackingRunLoopMode`：界面跟踪 Mode，用于 ScrollView 追踪触摸滑动，保证界面滑动时不受其他 Mode 影响。
	* `UIInitializationRunLoopMode`：在刚启动 App 时第进入的第一个 Mode，启动完成后就不再使用。
	* `GSEventReceiveRunLoopMode`：接受系统事件的内部 Mode，通常用不到。
	* `kCFRunLoopCommonModes`：这是一个占位的 Mode，没有实际作用。
* `Runloop`包含多个`Mode` ，每个`Mode`包含`Source`数组，`Observer`数组，`Timer`数组。
* `Runloop`状态：即将进入Loop、即将处理 Timer、即将处理 Source、即将进入休眠、即将退出Loop。
* `Runloop`的核心就是一个`mach_msg()`，`RunLoop`调用这个函数去接收消息，如果没有别人发送`port`消息过来，内核会将线程置于等待状态。
* `Runloop`与`AutoreleasePool`
	* `Runloop`进入循环时刻，创建自动释放池；
	* `Runloop`进入休眠，释放旧的池，创建新的池；
	* `Runloop`退出，释放自动释放池。
* `Runloop`与事件响应：苹果注册了一个 Source1 (基于 mach port 的) 用来接收系统事件，其回调函数为`__IOHIDEventSystemClientQueueCallback()`。
* `Runloop`与界面更新：苹果注册了一个 Observer 监听 BeforeWaiting(即将进入休眠) 和 Exit (即将退出Loop) 事件。
* `Runloop`应用：
	* `AFNetworking`单独创建了一个线程，并在这个线程中启动了一个`RunLoop`，执行后台请求任务。
	* `AsyncDisplayKit`在主线程的`RunLoop`中添加一个`Observer`，监听了`kCFRunLoopBeforeWaiting`和`kCFRunLoopExit`事件，在收到回调时，处理队列里的UI渲染任务。

**参考**：

* [深入理解RunLoop](https://blog.ibireme.com/2015/05/18/runloop/)
* [iOS多线程——RunLoop与GCD、AutoreleasePool](https://blog.csdn.net/u014205968/article/details/78323201?spm=1001.2014.3001.5501)
* [iOS之武功秘籍⑲: 内存管理与NSRunLoop](https://juejin.cn/post/6937300616184070174#heading-55)
* [一份走心的runloop源码分析](https://cloud.tencent.com/developer/article/1630860)
* [老司机出品——源码解析之RunLoop详解](https://cloud.tencent.com/developer/article/1192804)
* [Run Loop 记录与源码注释](https://github.com/Desgard/iOS-Source-Probe/blob/master/Objective-C/Foundation/Run%20Loop%20%E8%AE%B0%E5%BD%95%E4%B8%8E%E6%BA%90%E7%A0%81%E6%B3%A8%E9%87%8A.md)
* [从RunLoop来看iOS内核中消息的发送: mach_msg](从RunLoop来看iOS内核中消息的发送: mach_msg)
* [理解 iOS 的内存管理](https://blog.devtang.com/2016/07/30/ios-memory-management/)
* [CocoaPods 都做了什么？](https://draveness.me/cocoapods/)

## 方法交换

## weak实现

## 监控卡顿

## block实现

## 五大区

## 性能优化（启动等）

## 远程通知

## 异步上传实现

## 事件传递

## iOS打包后的文件结构

## 面向对象编程特征有哪些？
- “抽象”，把现实世界中的某一类东西，提取出来，用程序代码表示；
- “封装”，把过程和数据包围起来，对数据的访问只能通过已定义的界面；
- “继承”，一种联结类的层次模型；
- “多态”，允许不同类的对象对同一消息做出响应。

## OC和Swift如何互相调用？

## struct和class的区别？

https://juejin.cn/post/6844903799413276685

1. 类属于引用类型，结构体属于值类型
2. 类允许被继承，结构体不允许被继承
3. 类中的每一个成员变量都必须被初始化，否则编译器会报错，而结构体不需要，编译器会自动帮我们生成init函数，给变量赋一个默认值

## Swift设置访问权限如何设置？

https://juejin.cn/post/7012087397765054494

- open
- public 
- internal
- fileprivate
- private

## Swift中的逃逸闭包(@escaping )与非逃逸闭包(@noescaping)

https://juejin.cn/post/6844903951519727629

概念：一个接受闭包作为参数的函数，该闭包可能在函数返回后才被调用，也就是说这个闭包逃离了函数的作用域，这种闭包称为逃逸闭包。当你声明一个接受闭包作为形式参数的函数时，你可以在形式参数前写@escaping来明确闭包是允许逃逸。

概念：一个接受闭包作为参数的函数， 闭包是在这个函数结束前内被调用。

### 常见设计模式有哪些？

https://www.cnblogs.com/newsouls/archive/2011/07/28/DesignTemplage.html

- 单例模式
- 工厂模式

## 如何用GCD同步若干个异步调用？

https://cloud.tencent.com/developer/article/1521135

- 将几个线程加入到group中, 然后利用group_notify来执行最后要做的动作
- 利用GCD信号量dispatch_semaphore_t来实现

## 创建线程有几种方式？

- pthread 实现多线程操作
- NSThread实现多线程
- GCD 实现多线程
- NSOperation

## 对象在什么时候释放？

https://youle.zhipin.com/questions/4c09e5e18447d9dbtnV809W7FlQ~.html

引用计数小于1的时候释放的。在ARC环境下我们不能直接去操作引用计数的值，但是我们可以跟踪是否有strong指针指向、如果没有strong指针指向、则立即销毁。 这里有一个地方值得关注的事自动缓存池，他会延迟销毁时机，但是实际上也是延迟执行re lease而已。

## 是否编写过单元测试？

## 如何管理依赖库？
## 组件化开发方式有哪些？

## https是什么？

## 请求相关证书

## 轮播图实现原理

## 如何存放敏感信息？

## 对称加密和非对称加密的区别？

## 如何使用Git？

## 上传进度如何实现？