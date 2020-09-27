## 1. _objc_msgForward函数是做什么的，直接调用它将会发生什么？
>_objc_msgForward是 IMP 类型，用于消息转发的：当向一个对象发送一条消息，但它并没有实现的时候，_objc_msgForward会尝试做消息转发。

## 2. 能否向编译后得到的类中增加实例变量？能否向运行时创建的类中添加实例变量？为什么？

* 不能向编译后得到的类中增加实例变量；
* 能向运行时创建的类中添加实例变量；

解释下：
* 因为编译后的类已经注册在 runtime 中，类结构体中的 objc_ivar_list 实例变量的链表 和 instance_size 实例变量的内存大小已经确定，同时runtime 会调用 class_setIvarLayout 或 class_setWeakIvarLayout 来处理 strong weak 引用。所以不能向存在的类中添加实例变量；
* 运行时创建的类是可以添加实例变量，调用 class_addIvar 函数。但是得在调用 objc_allocateClassPair 之后，objc_registerClassPair 之前，原因同上。

## 3. runloop和线程有什么关系？

总的说来，Run loop，正如其名，loop表示某种循环，和run放在一起就表示一直在运行着的循环。实际上，run loop和线程是紧密相连的，可以这样说run loop是为了线程而生，没有线程，它就没有存在的必要。Run loops是线程的基础架构部分， Cocoa 和 CoreFundation 都提供了 run loop 对象方便配置和管理线程的 run loop （以下都以 Cocoa 为例）。每个线程，包括程序的主线程（ main thread ）都有与之相应的 run loop 对象。

1. 主线程的run loop默认是启动的。
	iOS的应用程序里面，程序启动后会有一个如下的main()函数
	```swift
	int main(int argc, char * argv[]) {
	   @autoreleasepool {
	       return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
	   }
	}
	```
	重点是UIApplicationMain()函数，这个方法会为main thread设置一个NSRunLoop对象，这就解释了：为什么我们的应用可以在无人操作的时候休息，需要让它干活的时候又能立马响应。
2. 对其它线程来说，run loop默认是没有启动的，如果你需要更多的线程交互则可以手动配置和启动，如果线程只是去执行一个长时间的已确定的任务则不需要。

3. 在任何一个 Cocoa 程序的线程中，都可以通过以下代码来获取到当前线程的 run loop 
```swift
NSRunLoop *runloop = [NSRunLoop currentRunLoop];
```

## 4. runloop的mode作用是什么？

model 主要是用来指定事件在运行循环中的优先级的，分为：
* NSDefaultRunLoopMode（kCFRunLoopDefaultMode）：默认，空闲状态
* UITrackingRunLoopMode：ScrollView滑动时
* UIInitializationRunLoopMode：启动时
* NSRunLoopCommonModes（kCFRunLoopCommonModes）：Mode集合

苹果公开提供的 Mode 有两个：
1. NSDefaultRunLoopMode（kCFRunLoopDefaultMode）
2. NSRunLoopCommonModes（kCFRunLoopCommonModes）


## 5. 以+ scheduledTimerWithTimeInterval...的方式触发的timer，在滑动页面上的列表时，timer会暂定回调，为什么？如何解决？

RunLoop只能运行在一种mode下，如果要换mode，当前的loop也需要停下重启成新的。利用这个机制，ScrollView滚动过程中NSDefaultRunLoopMode（kCFRunLoopDefaultMode）的mode会切换到UITrackingRunLoopMode来保证ScrollView的流畅滑动：只能在NSDefaultRunLoopMode模式下处理的事件会影响ScrollView的滑动。

如果我们把一个NSTimer对象以NSDefaultRunLoopMode（kCFRunLoopDefaultMode）添加到主运行循环中的时候, ScrollView滚动过程中会因为mode的切换，而导致NSTimer将不再被调度。

同时因为mode还是可定制的，所以：

Timer计时会被scrollView的滑动影响的问题可以通过将timer添加到NSRunLoopCommonModes（kCFRunLoopCommonModes）来解决。代码如下：

```swift
//将timer添加到NSDefaultRunLoopMode中
[NSTimer scheduledTimerWithTimeInterval:1.0
     target:self
     selector:@selector(timerTick:)
     userInfo:nil
     repeats:YES];
//然后再添加到NSRunLoopCommonModes里
NSTimer *timer = [NSTimer timerWithTimeInterval:1.0
     target:self
     selector:@selector(timerTick:)
     userInfo:nil
     repeats:YES];
[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
```

## 6. 猜想runloop内部是如何实现的？

一般来讲，一个线程一次只能执行一个任务，执行完成后线程就会退出。如果我们需要一个机制，让线程能随时处理事件但并不退出，通常的代码逻辑 是这样的：

```swift
function loop() {
    initialize();
    do {
        var message = get_next_message();
        process_message(message);
    } while (message != quit);
}
```

或使用伪代码来展示下:

```swift
int main(int argc, char * argv[]) {
 //程序一直运行状态
 while (AppIsRunning) {
      //睡眠状态，等待唤醒事件
      id whoWakesMe = SleepForWakingUp();
      //得到唤醒事件
      id event = GetEvent(whoWakesMe);
      //开始处理事件
      HandleEvent(event);
 }
 return 0;
}
```

## 7. objc使用什么机制管理对象内存？

通过 retainCount 的机制来决定对象是否需要释放。 每次 runloop 的时候，都会检查对象的 retainCount，如果 retainCount 为 0，说明该对象没有地方需要继续使用了，可以释放掉了。

## 8. ARC通过什么方式帮助开发者管理内存？

ARC相对于MRC，不是在编译时添加retain/release/autorelease这么简单。应该是编译期和运行期两部分共同帮助开发者管理内存。
在编译期，ARC用的是更底层的C接口实现的retain/release/autorelease，这样做性能更好，也是为什么不能在ARC环境下手动retain/release/autorelease，同时对同一上下文的同一对象的成对retain/release操作进行优化（即忽略掉不必要的操作）；ARC也包含运行期组件，这个地方做的优化比较复杂，但也不能被忽略。

## 8. 不手动指定autoreleasepool的前提下，一个autorealese对象在什么时刻释放？（比如在一个vc的viewDidLoad中创建）

1. 手动干预释放时机--指定 autoreleasepool 就是所谓的：当前作用域大括号结束时释放。
2. 系统自动去释放--不手动指定 autoreleasepool

Autorelease对象出了作用域之后，会被添加到最近一次创建的自动释放池中，并会在当前的 runloop 迭代结束时释放。

如果在一个vc的viewDidLoad中创建一个 Autorelease对象，那么该对象会在 viewDidAppear 方法执行前就被销毁了。

## 9. BAD_ACCESS在什么情况下出现？

访问了悬垂指针，比如对一个已经释放的对象执行了release、访问已经释放对象的成员变量或者发消息。 死循环


## 10. 苹果是如何实现autoreleasepool的？

autoreleasepool 以一个队列数组的形式实现,主要通过下列三个函数完成.

1. objc_autoreleasepoolPush
2. objc_autoreleasepoolPop
3. objc_autorelease

看函数名就可以知道，对 autorelease 分别执行 push，和 pop 操作。销毁对象时执行release操作。

## 11. 使用block时什么情况会发生引用循环，如何解决？

一个对象中强引用了 block，在 block 中又强引用了该对象，就会发生循环引用。

ARC 下的解决方法是：

1. 将该对象使用 __weak 修饰符修饰之后再在 block 中使用。 id weak weakSelf = self; 或者 weak __typeof(&*self)weakSelf = self 该方法可以设置宏 __weak ：不会产生强引用，指向的对象销毁时，会自动让指针置为 ni1

2. 使用 unsafe_unretained 关键字，用法与 __weak 一致。 unsafe_unretained 不会产生强引用，不安全，指向的对象销毁时，指针存储的地址值不变。
3. 也可以使用 __block 来解决循环引用问题，用法为： __block id weakSelf = self;，但不推荐使用。因为必须要调用该 block 方案才能生效，因为需要及时的将 __block 变量置为 nii。

## 12. 在block内如何修改block外部变量？

先描述下问题：

默认情况下，在block中访问的外部变量是复制过去的，即：写操作不对原变量生效。但是你可以加上 __block 来让其写操作生效，示例代码如下:

```swift
__block int a = 0;
void (^foo)(void) = ^{ 
   a = 1; 
};
foo(); 
//这里，a的值被修改为1
```

* "将 auto 从栈 copy 到堆"
* “将 auto 变量封装为结构体(对象)”

## 13. 使用系统的某些block api（如UIView的block版本写动画时），是否也考虑引用循环问题？

## 14. GCD的队列（dispatch_queue_t）分哪两种类型

1. 串行队列Serial Dispatch Queue
2. 并发队列Concurrent Dispatch Queue

## 15. 如何用GCD同步若干个异步调用？（如根据若干个url异步加载多张图片，然后在都下载完成后合成一张整图）

使用Dispatch Group追加block到Global Group Queue,这些block如果全部执行完毕，就会执行Main Dispatch Queue中的结束处理的block。

## 16. dispatch_barrier_async的作用是什么？

在并发队列中，为了保持某些任务的顺序，需要等待一些任务完成后才能继续进行，使用 barrier 来等待之前任务完成，避免数据竞争等问题。 dispatch_barrier_async 函数会等待追加到Concurrent Dispatch Queue并发队列中的操作全部执行完之后，然后再执行 dispatch_barrier_async 函数追加的处理，等 dispatch_barrier_async 追加的处理执行结束之后，Concurrent Dispatch Queue才恢复之前的动作继续执行。

打个比方：比如你们公司周末跟团旅游，高速休息站上，司机说：大家都去上厕所，速战速决，上完厕所就上高速。超大的公共厕所，大家同时去，程序猿很快就结束了，但程序媛就可能会慢一些，即使你第一个回来，司机也不会出发，司机要等待所有人都回来后，才能出发。 dispatch_barrier_async 函数追加的内容就如同 “上完厕所就上高速”这个动作。

（注意：使用 dispatch_barrier_async ，该函数只能搭配自定义并发队列 dispatch_queue_t 使用。不能使用： dispatch_get_global_queue ，否则 dispatch_barrier_async 的作用会和 dispatch_async 的作用一模一样。 ）

## 17. 苹果为什么要废弃dispatch_get_current_queue？

dispatch_get_current_queue函数的行为常常与开发者所预期的不同。 由于派发队列是按层级来组织的，这意味着排在某条队列中的块会在其上级队列里执行。 队列间的层级关系会导致检查当前队列是否为执行同步派发所用的队列这种方法并不总是奏效。dispatch_get_current_queue函数通常会被用于解决由不可以重入的代码所引发的死锁，然后能用此函数解决的问题，通常也可以用"队列特定数据"来解决。

## 18. 以下代码运行结果如何？

```swift
- (void)viewDidLoad {
   [super viewDidLoad];
   NSLog(@"1");
   dispatch_sync(dispatch_get_main_queue(), ^{
       NSLog(@"2");
   });
   NSLog(@"3");
}
```
只输出：1 。发生主线程锁死。

## 19. 如何手动触发一个value的KVO

所谓的“手动触发”是区别于“自动触发”：

自动触发是指类似这种场景：在注册 KVO 之前设置一个初始值，注册之后，设置一个不一样的值，就可以触发了。

想知道如何手动触发，必须知道自动触发 KVO 的原理：

键值观察通知依赖于 NSObject 的两个方法: willChangeValueForKey: 和 didChangevlueForKey: 。在一个被观察属性发生改变之前， willChangeValueForKey: 一定会被调用，这就 会记录旧的值。而当改变发生后， observeValueForKey:ofObject:change:context: 会被调用，继而 didChangeValueForKey: 也会被调用。如果可以手动实现这些调用，就可以实现“手动触发”了。

那么“手动触发”的使用场景是什么？一般我们只在希望能控制“回调的调用时机”时才会这么做。

## 20. 若一个类有实例变量 NSString *_foo ，调用setValue:forKey:时，可以以foo还是 _foo 作为key？

都可以

## 21. KVC的keyPath中的集合运算符如何使用？

1. 必须用在集合对象上或普通对象的集合属性上
2. 简单集合运算符有@avg， @count ， @max ， @min ，@sum
3. 格式 @"@sum.age"或 @"集合属性.@max.age"

## 22. KVC和KVO的keyPath一定是属性么？

KVC 支持实例变量，KVO 只能手动支持手动设定实例变量的KVO实现监听

## 23. 如何关闭默认的KVO的默认实现，并进入自定义的KVO实现？
1. [《如何自己动手实现 KVO》](https://tech.glowing.com/cn/implement-kvo/)
2. [KVO for manually implemented properties](https://stackoverflow.com/questions/10042588/kvo-for-manually-implemented-properties/10042641#10042641)

## 24. apple用什么方式实现对一个对象的KVO？

当你观察一个对象时，一个新的类会被动态创建。这个类继承自该对象的原本的类，并重写了被观察属性的 setter 方法。重写的 setter 方法会负责在调用原 setter 方法之前和之后，通知所有观察对象：值的更改。最后通过 isa 混写（isa-swizzling） 把这个对象的 isa 指针 ( isa 指针告诉 Runtime 系统这个对象的类是什么 ) 指向这个新创建的子类，对象就神奇的变成了新创建的子类的实例

## 25. IBOutlet连出来的视图属性为什么可以被设置成weak?

[Should IBOutlets be strong or weak under ARC?](https://stackoverflow.com/questions/7678469/should-iboutlets-be-strong-or-weak-under-arc)

文章告诉我们：
>因为既然有外链那么视图在xib或者storyboard中肯定存在，视图已经对它有一个强引用了。
不过这个回答漏了个重要知识，使用storyboard（xib不行）创建的vc，会有一个叫_topLevelObjectsToKeepAliveFromStoryboard 的私有数组强引用所有 top level 的对象，所以这时即便outlet声明成weak也没关系

## 26. IB中User Defined Runtime Attributes如何使用？

它能够通过KVC的方式配置一些你在interface builder 中不能配置的属性。当你希望在IB中作尽可能多得事情，这个特性能够帮助你编写更加轻量级的viewcontroller

## 27. 如何调试BAD_ACCESS错误

1. 重写object的respondsToSelector方法，现实出现EXEC_BAD_ACCESS前访问的最后一个object
2. 通过 Zombie
3. 设置全局断点快速定位问题代码所在行
4. Xcode 7 已经集成了BAD_ACCESS捕获功能：Address Sanitizer。

## 28. lldb（gdb）常用的调试命令？
1. breakpoint 设置断点定位到某一个函数
2. n 断点指针下一步
3. po打印对象




