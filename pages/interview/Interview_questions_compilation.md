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

## category实现方式

* `category`的作用：a）分散功能，b）声明私有方法；
* `category`与`extension`:
    * `category`是运行期决议的，不可以添加属性。
    * `extension`是编译期决议的，可以添加属性，一般为了私有化。
* `category`和原来类中存在相同方法，`category`的方法更加靠前，运行期优先被查找和调用。
* `category`可以使用`runtime`关联对象来实现添加实例变量。

**参考**：

* [深入理解Objective-C：Category](https://tech.meituan.com/2015/03/03/diveintocategory.html)
* [iOS Category 源码解析](https://tbfungeek.github.io/2020/01/06/iOS-Category-%E6%BA%90%E7%A0%81%E8%A7%A3%E6%9E%90/)
* [iOS：Category为什么不能直接添加成员变量却能添加方法](https://juejin.cn/post/6844904114619416583)
* [ios动态添加属性的几种方法](https://blog.csdn.net/shengyumojian/article/details/44919695)
* [iOS-分类Category详解和关联对象](https://www.cnblogs.com/junhuawang/p/14041163.html)
* [ios Category](https://cloud.tencent.com/developer/article/1336981)
* [Monkey-Patching iOS with Objective-C Categories Part II: Adding Instance Properties](https://blog.carbonfive.com/monkey-patching-ios-with-objective-c-categories-part-ii-adding-instance-properties/)

## 方法交换

1. `Swizzling`需要在`+(void)load`中添加。
2. `Swizzling`应该总是在`dispatch_once`中执行。
3. `Swizzling`在`+load`中执行时，不要调用`[super load]`。如果多次调用了`[super load]`，可能会出现“Swizzle无效”的假象。

**场景**：

1. 统计VC加载次数。
2. 防止UI控件短时间多次激活事件。
3. 防奔溃处理：数组越界问题。
4. 适配iOS13的模态的的样式问题。

**参考**：

* [iOS开发·runtime原理与实践: 方法交换篇(Method Swizzling)(iOS“黑魔法”，埋点统计，禁止UI控件连续点击，防奔溃处理)](https://juejin.cn/post/6844903601681203214)
* [iOS 小技能：Method Swizzling （交换方法的IMP）](https://cloud.tencent.com/developer/article/2078908)

## weak实现

`weak`是`Runtime`维护了一个`hash`(哈希)表，用于存储指向某个对象的所有`weak`指针。weak表其实是一个`hash`（哈希）表，Key是所指对象的地址，Value是weak指针的地址（这个地址的值是所指对象指针的地址）数组。

**参考**：

* [iOS底层原理：weak的实现原理](https://juejin.cn/post/6844904101839372295)
* [老生常谈的iOS- weak原理，你真的懂得还是为了应付面试](https://www.cnblogs.com/mysweetAngleBaby/p/16341648.html)
* [D4-007-weak对象存储原理和销毁为什么会置nil（上）](https://www.bilibili.com/video/BV1PZ4y1H7Gs/?spm_id_from=333.999.0.0&vd_source=0e0265662467c6caea699dd58aec6891)
* [D4-008-weak对象存储原理和销毁为什么会置nil（下）](https://www.bilibili.com/video/BV1hT4y1g7pA/?spm_id_from=333.337.search-card.all.click&vd_source=0e0265662467c6caea699dd58aec6891)

## 监控卡顿

**卡顿原因**：

* 复杂UI、图文混排的绘制量过大；
* 在主线程上做网络同步请求；
* 在主线程做大量的`IO`操作；
* 运算量过大，`CPU`持续高占用；
* 死锁和主子线程抢锁。

**监控卡顿**：

1. 创建一个`CFRunLoopObserverContext`观察者；
2. 监听`kCFRunLoopBeforeSources`到`kCFRunLoopBeforeWaiting`再到`kCFRunLoopAfterWaiting`的状态。
3. 开启子线程，利用信号量计算这几个状态切换的时间，间隔时间如果超过50ms，卡顿计数+1。
4. 如果卡顿计数超过大于等于5次，触发卡顿上报线程调用栈。

**参考**：

* [iOS 之如何利用 RunLoop 原理去监控卡顿?](https://cloud.tencent.com/developer/article/1824227)

## block实现

`block`是个结构图，拥有`isa`指针。

**捕获机制**：

* 全局变量，捕获指针，修改可以生效。
* 局部变量，捕获值，修改不生效。

**`block`类型**：

* 全局`block`
* 栈`block`
* 堆`block`

**`__block`**：

依然是个结构体，拥有`isa`指针，局部变量被包装成了一个对象，里面有个成员变量，指向了局部变量，所以`block`修改这个变量是有效果的。

**参考**：

* [OC中block的底层实现原理](https://juejin.cn/post/6844904040954871815)

## 五大区

* 栈区：运行期分配，例如：局部变量、函数参数等。
* 堆区：运行期分配，例如：alloc、new的对象。
* 全局区：编译期分配，例如：static修饰变量。
* 常量区：编译期分配，例如：string的引用，但是string的指针是堆区
* 代码区：编译期分配，存放程序的代码。

**参考**：

* [iOS-底层原理 24：内存五大区](https://juejin.cn/post/6949587150090272804)

## 性能优化（启动等）

* 启动优化
* 卡顿优化
* 耗电优化
* 包体积优化

## TCP三次握手，四次挥手

**三次握手**：

1. 客户端发送`[SYN] Seq=x`；
2. 服务端发送`[SYN, ACK] Seq=y Ack=x+1`；
3. 客户端发送`[ACK] Seq=y+1`;

**四次挥手**：

1. 客户端发送`[FIN] Seq=x`；
2. 服务端发送`[FIN, ACK] Ack=x+1`；
3. 服务端发送`[FIN] Seq=y`;
4. 客户端发送`[ACK] Ack=y+1`;
5. 等待`2MSL`，服务端无响应，说明服务端已关闭，这时，客户端也关闭。

**参考**：

* [一文彻底搞懂 TCP三次握手、四次挥手过程及原理](https://juejin.cn/post/6844904070000410631)
* [使用WireShark查看TCP的三次握手](https://blog.csdn.net/sanqima/article/details/108025304)

## 通知

**本地通知**：

1. 请求权限；
2. 创建通知内容；
3. 创建通知触发
4. 创建请求；
5. 将请求添加到通知中心。

**远程通知**：

1. 请求权限；
2. 上传token至业务服务器；
3. 业务服务器使用`token`向苹果`APNS`服务器提交请求；

* [活久见的重构 - iOS 10 UserNotifications 框架解析](https://onevcat.com/2016/08/notification/)

## 对象在什么时候释放？

* `Runloop`状态为休眠或退出。
* `weak`引用的对象在`dealloc`中释放。
* 离开自动释放池作用域。

## ipa文件结构

* Frameworks：App引入的动态库；
* Assets.car；
* 可执行文件：MachO文件；
* 资源文件：xx.bundle；
* 签名文件：_CodeSignature

**参考**：

* [iOS 包体积优化2 - 如何分析ipa包？](https://juejin.cn/post/7185080113304698941)

## 动态库和静态库

静态库：链接时完整地拷贝至可执行文件中，被多次使用就有多份冗余拷贝。利用静态函数库编译成的文件比较大，因为整个 函数库的所有数据都会被整合进目标代码中，他的优点就显而易见了，即编译后的执行程序不需要外部的函数库支持，因为所有使用的函数都已经被编译进去了。当然这也会成为他的缺点，因为如果静态函数库改变了，那么你的程序必须重新编译。

动态库：链接时不复制，程序运行时由系统动态加载到内存，供程序调用，系统只加载一次，多个程序共用，节省内存。由于函数库没有被整合进你的程序，而是程序运行时动态的申请并调用，所以程序的运行环境中必须提供相应的库。动态函数库的改变并不影响你的程序，所以动态函数库的升级比较方便。

**参考**：

* [iOS静态库与动态库的使用](https://github.com/qingfengiOS/Summary/blob/master/iOS%E9%9D%99%E6%80%81%E5%BA%93%E4%B8%8E%E5%8A%A8%E6%80%81%E5%BA%93%E7%9A%84%E4%BD%BF%E7%94%A8.md)

## 事件传递

1. 点击一个UIView或产生一个触摸事件A，这个触摸事件A会被添加到由UIApplication管理的事件队列中（即，首先接收到事件的是UIApplication）。
2. UIApplication会从事件对列中取出最前面的事件（此处假设为触摸事件A），把事件A传递给应用程序的主窗口（keyWindow）。
3. 窗口会在视图层次结构中找到一个最合适的视图来处理触摸事件。

**参考**：

* [史上最详细的iOS之事件的传递和响应机制-原理篇](https://www.jianshu.com/p/2e074db792ba)

## 面向对象编程特征有哪些？

- “抽象”，把现实世界中的某一类东西，提取出来，用程序代码表示；
- “封装”，把过程和数据包围起来，对数据的访问只能通过已定义的界面；
- “继承”，一种联结类的层次模型；
- “多态”，允许不同类的对象对同一消息做出响应。

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

## 常见设计模式有哪些？

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

https://youle.zhipin.com/questions/4c09e5e18447d9dbtnV809W7FlQ~.html

引用计数小于1的时候释放的。在ARC环境下我们不能直接去操作引用计数的值，但是我们可以跟踪是否有strong指针指向、如果没有strong指针指向、则立即销毁。 这里有一个地方值得关注的事自动缓存池，他会延迟销毁时机，但是实际上也是延迟执行re lease而已。

## 异步上传实现

* 分块上传；
* `Socket`监听；

**参考**：

* [Java实现带进度条的文件上传：原理、方法与代码实例](https://blog.51cto.com/u_14540126/10078939)

## https是什么？

1. 客户端向服务器发送 HTTPS 请求。
2. 服务器将公钥证书发送给客户端。
3. 客户端验证服务器的证书。
4. 如果验证通过，客户端生成一个用于会话的对称密钥。
5. 客户端使用服务器的公钥对对称密钥进行加密，并将加密后的密钥发送给服务器。
6. 服务器使用私钥对客户端发送的加密密钥进行解密，得到对称密钥。
7. 服务器和客户端使用对称密钥进行加密和解密数据传输。

**参考**：

* [HTTPS 的加密过程及其工作原理](https://xie.infoq.cn/article/007a9bd16f44303fbd8b40689)

## 对称加密和非对称加密的区别？

## OC和Swift如何互相调用？

## 是否编写过单元测试？

## 如何管理依赖库？

## 组件化开发方式有哪些？

## 请求相关证书

## 轮播图实现原理

## 如何存放敏感信息？

## 如何使用Git？