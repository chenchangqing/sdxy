# 1.面试问题集锦

## 1. weak和assign的区别

### 一、什么情况使用 weak 关键字？

1. 在 ARC 中，在有可能出现循环引用的时候，往往要通过让其中一端使用 weak 来解决，比如： delegate 代理属性。
2. 自身已经对它进行一次强引用，没有必要再强引用一次，此时也会使用 weak ，自定义 IBOutlet 控件属性一般也使用 weak ；当然，也可以使用 strong 。

### 二、区别

#### 2.1. 修饰变量类型的区别

1. weak 只可以修饰对象。如果修饰基本数据类型，编译器会报错-“Property with ‘weak’ attribute must be of object type”。
2. assign 可修饰对象，和基本数据类型。当需要修饰对象类型时，MRC时代使用 unsafe_unretained 。当然， unsafe_unretained 也可能产生野指针，所以它名字是 unsafe_ 。

#### 2.2. 是否产生野指针的区别

1. weak 不会产生野指针问题。因为 weak 修饰的对象释放后（引用计数器值为0），指针会自动被置nil，之后再向该对象发消息也不会崩溃。 weak是安全的。
2.  assign 如果修饰对象，会产生野指针问题；如果修饰基本数据类型则是安全的。修饰的对象释放后，指针不会自动被置空，此时向对象发消息会崩溃。

### 三、相同

都可以修饰对象类型，但是 assign 修饰对象会存在问题。

### 四、总结

assign 适用于基本数据类型如 int，float，struct 等值类型，不适用于引用类型。因为值类型会被放入栈中，遵循先进后出原则，由系统负责管理栈内存。而引用类型会被放入堆中，需要我们自己手动管理内存或通过 ARC 管理。weak 适用于 delegate 和 block 等引用类型，不会导致野指针问题，也不会循环引用，非常安全。

### 五、参考文章

* [iOS开发中 weak 和 assign 的区别](https://www.jianshu.com/p/e9a46253f587)

## 2. 为什么要用 Copy 修饰 Block 

### 一、栈区和堆区概念

1. 内存的栈区：由编译器自动分配释放，存放函数的参数值，局部变量的值等。 其操作方式类似于数据结构中的栈。
2. 内存的堆区：一般由程序员分配释放，若程序员不释放，程序结束时可能由OS回收。注意它与数据结构中的堆是两回事， 分配方式倒是类似于链表。

### 二、Block 的三种类型

iOS 内存分布，一般分为：栈区、堆区、全局区、常量区、代码区。其实 Block 也是一个 Objective-C 对象，常见的有以下三种 Block ：

1. NSGlobalBlock：全局的静态 Block 没有访问外部变量。
2. NSStackBlock：保存在栈中的 Block ，没有用copy去修饰并且访问了外部变量，会在函数调用结束被销毁（需要在MRC）。
3. NSMallocBlock：保存在堆中的 Block ， 此类型 Block 是用 Copy 修饰出来的 Block ，它会随着对象的销毁而销毁，只要对象不销毁，我们就可以调用的到在堆中的 Block 。

### 三、回答

Block 引用了普通外部变量，都是创建在栈区的；对于分配在栈区的对象，我们很容易会在释放之后继续调用，导致程序奔溃，所以我们使用的时候需要将栈区的对象移到堆区，来延长该对象的生命周期。对于这个问题，得区分 MRC 环境和 ARC 环境：

* 对于 MRC 环境，使用 Copy 修饰 Block，会将栈区的 Block 拷贝到堆区。
* 对于 ARC 环境，使用 Strong、Copy 修饰 Block，都会将栈区的 Block 拷贝到堆区。
* 所以，Block 不是一定要用 Copy 来修饰的，在 ARC 环境下面 Strong 和 Copy 修饰效果是一样的。

### 四、参考文章

* [iOS block 为什么用copy修饰](https://www。jianshu。com/p/de1beba9958e)
* [为什么要用copy修饰Block](https://www。jianshu。com/p/3b9b90d5be0b)
* [·iOS 面试题·Block 的原理，Block 的属性修饰词为什么用 copy，使用 Block 时有哪些要注意的？](https://www。jianshu。com/p/4db3b4f1d522)

## 3. 怎么用 Copy 关键字？

1. NSString、NSArray、NSDictionary 等等经常使用 Copy 关键字。因为他们有对应的可变类型：NSMutableString、NSMutableArray、NSMutableDictionary，他们之间可能进行赋值操作，为确保对象中的字符串值不会无意间变动，应该在设置新属性值时拷贝一份。
2. Block 也经常使用 Copy 关键字。Block 使用 Copy 是从 MRC 遗留下来的“传统”，在 MRC 中，方法内部的 Block 是在栈区的，使用 Copy 可以把它放到堆区。

## 4. 这个写法会出什么问题：`@property (copy) NSMutableArray *array;`

1. 添加，删除，修改数组内的元素的时候，程序会因为找不到对应的方法而崩溃.因为 copy 就是复制一个不可变 NSArray 的对象；

	比如下面的代码就会发生崩溃

	```swift
	// .h文件
	// http://weibo.com/luohanchenyilong/
	// https://github.com/ChenYilong
	// 下面的代码就会发生崩溃
	@property (nonatomic， copy) NSMutableArray *mutableArray;
	// .m文件
	// http://weibo.com/luohanchenyilong/
	// https://github.com/ChenYilong
	// 下面的代码就会发生崩溃
	NSMutableArray *array = [NSMutableArray arrayWithObjects:@1，@2，nil];
	self.mutableArray = array;
	[self.mutableArray removeObjectAtIndex:0];
	```

	接下来就会奔溃：

	```swift
	-[__NSArrayI removeObjectAtIndex:]: unrecognized selector sent to instance 0x7fcd1bc30460
	```
2. 使用了 atomic 属性会严重影响性能；
	>该属性使用了互斥锁（atomic 的底层实现，老版本是自旋锁，iOS10开始是互斥锁--spinlock底层实现改变了。），会在创建时生成一些额外的代码用于帮助编写多线程程序，这会带来性能问题，通过声明 nonatomic 可以节省这些虽然很小但是不必要额外开销。

## 5. 如何让自己的类用 copy 修饰符？如何重写带 copy 关键字的 setter？

>若想令自己所写的对象具有拷贝功能，则需实现 NSCopying 协议。如果自定义的对象分为可变版本与不可变版本，那么就要同时实现 NSCopying 与 NSMutableCopying 协议。

具体步骤：

1. 需声明该类遵从 NSCopying 协议
2. 实现 NSCopying 协议。该协议只有一个方法:
	```swift
	- (id)copyWithZone:(NSZone *)zone;
	```
	
案例：

.h文

```swift
// 件
// http://weibo.com/luohanchenyilong/
// https://github.com/ChenYilong
// 以第一题《风格纠错题》里的代码为例
typedef NS_ENUM(NSInteger， CYLSex) {
    CYLSexMan，
    CYLSexWoman
};
@interface CYLUser : NSObject<NSCopying>

@property (nonatomic， readonly， copy) NSString *name;
@property (nonatomic， readonly， assign) NSUInteger age;
@property (nonatomic， readonly， assign) CYLSex sex;

- (instancetype)initWithName:(NSString *)name age:(NSUInteger)age sex:(CYLSex)sex;
+ (instancetype)userWithName:(NSString *)name age:(NSUInteger)age sex:(CYLSex)sex;
- (void)addFriend:(CYLUser *)user;
- (void)removeFriend:(CYLUser *)user;
@end
```	

// .m文件

```swift
// http://weibo.com/luohanchenyilong/
// https://github.com/ChenYilong
//

@implementation CYLUser {
   NSMutableSet *_friends;
}

- (void)setName:(NSString *)name {
   _name = [name copy];
}

- (instancetype)initWithName:(NSString *)name
                        age:(NSUInteger)age
                        sex:(CYLSex)sex {
   if(self = [super init]) {
       _name = [name copy];
       _age = age;
       _sex = sex;
       _friends = [[NSMutableSet alloc] init];
   }
   return self;
}

- (void)addFriend:(CYLUser *)user {
   [_friends addObject:user];
}

- (void)removeFriend:(CYLUser *)user {
   [_friends removeObject:user];
}

- (id)copyWithZone:(NSZone *)zone {
   CYLUser *copy = [[[self class] allocWithZone:zone]
                    initWithName:_name
                    age:_age
                    sex:_sex];
   copy->_friends = [_friends mutableCopy];
   return copy;
}

- (id)deepCopy {
   CYLUser *copy = [[[self class] alloc]
                    initWithName:_name
                    age:_age
                    sex:_sex];
   copy->_friends = [[NSMutableSet alloc] initWithSet:_friends
                                            copyItems:YES];
   return copy;
}

@end
```

至于如何重写带 copy 关键字的 setter这个问题，

如果抛开本例来回答的话，如下：
```swift
- (void)setName:(NSString *)name {
    //[_name release];
    _name = [name copy];
}
```

那如何确保 name 被 copy？在初始化方法(initializer)中做：
```swift
- (instancetype)initWithName:(NSString *)name 
   							 age:(NSUInteger)age 
   							 sex:(CYLSex)sex {
    if(self = [super init]) {
    	_name = [name copy];
    	_age = age;
    	_sex = sex;
    	_friends = [[NSMutableSet alloc] init];
    }
    return self;
}
```

## 6. @property 的本质是什么？ivar、getter、setter 是如何生成并添加到这个类中的

**@property 的本质是什么？**

>@property = ivar + getter + setter;

下面解释下：

>“属性” (property)有两大概念：ivar（实例变量）、存取方法（access method ＝ getter + setter）。

“属性” (property)作为 Objective-C 的一项特性，主要的作用就在于封装对象中的数据。 Objective-C 对象通常会把其所需要的数据保存为各种实例变量。实例变量一般通过“存取方法”(access method)来访问。其中，“获取方法” (getter)用于读取变量值，而“设置方法” (setter)用于写入变量值。这个概念已经定型，并且经由“属性”这一特性而成为 Objective-C 2.0 的一部分。 而在正规的 Objective-C 编码风格中，存取方法有着严格的命名规范。 正因为有了这种严格的命名规范，所以 Objective-C 这门语言才能根据名称自动创建出存取方法。其实也可以把属性当做一种关键字，其表示:
>编译器会自动写出一套存取方法，用以访问给定类型中具有给定名称的变量。 所以你也可以这么说：
>@property = getter + setter;

例如下面这个类：

```swift
@interface Person : NSObject
@property NSString *firstName;
@property NSString *lastName;
@end
```

上述代码写出来的类与下面这种写法等效

```swift
@interface Person : NSObject
- (NSString *)firstName;
- (void)setFirstName:(NSString *)firstName;
- (NSString *)lastName;
- (void)setLastName:(NSString *)lastName;
@end
```

**源码分析**

property在runtime中是 objc_property_t 定义如下:
```swift
typedef struct objc_property *objc_property_t;
```

而 objc_property 是一个结构体，包括name和attributes，定义如下：
```swift
struct property_t {
    const char *name;
    const char *attributes;
};
```

而attributes本质是 objc_property_attribute_t，定义了property的一些属性，定义如下：
```swift
/// Defines a property attribute
typedef struct {
    const char *name;           /**< The name of the attribute */
    const char *value;          /**< The value of the attribute (usually empty) */
} objc_property_attribute_t;
```
而attributes的具体内容是什么呢？其实，包括：类型，原子性，内存语义和对应的实例变量。

例如：我们定义一个string的property@property (nonatomic， copy) NSString *string;，通过 property_getAttributes(property)获取到attributes并打印出来之后的结果为T@"NSString"，C，N，V_string

其中T就代表类型，可参阅[Type Encodings](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html#//apple_ref/doc/uid/TP40008048-CH100-SW1)，C就代表Copy，N代表nonatomic，V就代表对应的实例变量。

**ivar、getter、setter 是如何生成并添加到这个类中的?**

>“自动合成”( autosynthesis)

完成属性定义后，编译器会自动编写访问这些属性所需的方法，此过程叫做“自动合成”(autosynthesis)。需要强调的是，这个过程由编译 器在编译期执行，所以编辑器里看不到这些“合成方法”(synthesized method)的源代码。除了生成方法代码 getter、setter 之外，编译器还要自动向类中添加适当类型的实例变量，并且在属性名前面加下划线，以此作为实例变量的名字。在前例中，会生成两个实例变量，其名称分别为 _firstName 与 _lastName。也可以在类的实现代码里通过 @synthesize 语法来指定实例变量的名字.
```swift
@implementation Person
@synthesize firstName = _myFirstName;
@synthesize lastName = _myLastName;
@end
```

我为了搞清属性是怎么实现的，曾经反编译过相关的代码，他大致生成了五个东西

1. OBJC_IVAR_$类名$属性名称 ：该属性的“偏移量” (offset)，这个偏移量是“硬编码” (hardcode)，表示该变量距离存放对象的内存区域的起始地址有多远。
2. setter 与 getter 方法对应的实现函数
3. ivar_list ：成员变量列表
4. method_list ：方法列表
5. prop_list ：属性列表

也就是说我们每次在增加一个属性，系统都会在 ivar_list 中添加一个成员变量的描述，在 method_list 中增加 setter 与 getter 方法的描述，在属性列表中增加一个属性的描述，然后计算该属性在对象中的偏移量，然后给出 setter 与 getter 方法对应的实现，在 setter 方法中从偏移量的位置开始赋值，在 getter 方法中从偏移量开始取值，为了能够读取正确字节数，系统对象偏移量的指针类型进行了类型强转。

## 7. @protocol 和 category 中如何使用 @property

1. 在 protocol 中使用 property 只会生成 setter 和 getter 方法声明,我们使用属性的目的,是希望遵守我协议的对象能实现该属性
2. category 使用 @property 也是只会生成 setter 和 getter 方法的声明,如果我们真的需要给 category 增加属性的实现,需要借助于运行时的两个函数：
	1. objc_setAssociatedObject
	2. objc_getAssociatedObject

## 8. runtime 如何实现 weak 属性

要实现 weak 属性，首先要搞清楚 weak 属性的特点：
>weak 此特质表明该属性定义了一种“非拥有关系” (nonowning relationship)。为这种属性设置新值时，设置方法既不保留新值，也不释放旧值。此特质同 assign 类似， 然而在属性所指的对象遭到摧毁时，属性值也会清空(nil out)。

那么 runtime 如何实现 weak 变量的自动置nil？
>runtime 对注册的类， 会进行布局，对于 weak 对象会放入一个 hash 表中。 用 weak 指向的对象内存地址作为 key，当此对象的引用计数为0的时候会 dealloc，假如 weak 指向的对象内存地址是a，那么就会以a为键， 在这个 weak 表中搜索，找到所有以a为键的 weak 对象，从而设置为 nil。

## 9. @property中有哪些属性关键字？/ @property 后面可以有哪些修饰符？
1. 原子性--- nonatomic 特质
2. 读/写权限---readwrite(读写)、readonly (只读)
3. 内存管理语义---assign、strong、 weak、unsafe_unretained、copy
4. 方法名---getter=<name> 、setter=<name>
	getter=<name>的样式：
	```swift
	@property (nonatomic, getter=isOn) BOOL on;
	```
	setter=<name>一般用在特殊的情境下，比如：

	在数据反序列化、转模型的过程中，服务器返回的字段如果以 init 开头，所以你需要定义一个 init 开头的属性，但默认生成的 setter 与 getter 方法也会以 init 开头，而编译器会把所有以 init 开头的方法当成初始化方法，而初始化方法只能返回 self 类型，因此编译器会报错。

	这时你就可以使用下面的方式来避免编译器报错：
	```swift
	@property(nonatomic, strong, getter=p_initBy, setter=setP_initBy:)NSString *initBy;
	```

	另外也可以用关键字进行特殊说明，来避免编译器报错：
	```swift
	@property(nonatomic, readwrite, copy, null_resettable) NSString *initBy;
	- (NSString *)initBy __attribute__((objc_method_family(none)));
	```
5. 不常用的：nonnull,null_resettable,nullable

## 10. weak属性需要在dealloc中置nil么？

不需要。
>在ARC环境无论是强指针还是弱指针都无需在 dealloc 设置为 nil ， ARC 会自动帮我们处理

## 11. @synthesize和@dynamic分别有什么作用？

1. @property有两个对应的词，一个是 @synthesize，一个是 @dynamic。如果 @synthesize和 @dynamic都没写，那么默认的就是@syntheszie var = _var;
2. @synthesize 的语义是如果你没有手动实现 setter 方法和 getter 方法，那么编译器会自动为你加上这两个方法。
3. @dynamic 告诉编译器：属性的 setter 与 getter 方法由用户自己实现，不自动生成。（当然对于 readonly 的属性只需提供 getter 即可）。假如一个属性被声明为 @dynamic var，然后你没有提供 @setter方法和 @getter 方法，编译的时候没问题，但是当程序运行到 instance.var = someVar，由于缺 setter 方法会导致程序崩溃；或者当运行到 someVar = var 时，由于缺 getter 方法同样会导致崩溃。编译时没问题，运行时才执行相应的方法，这就是所谓的动态绑定。

## 12. ARC下，不显式指定任何属性关键字时，默认的关键字都有哪些？

1. 对应基本数据类型默认关键字是
	* atomic
	* readwrite
	* assign
2. 对于普通的 Objective-C 对象
	* atomic
	* readwrite
	* strong

## 13. 用@property声明的NSString（或NSArray，NSDictionary）经常使用copy关键字，为什么？如果改用strong关键字，可能造成什么问题？

1. 因为父类指针可以指向子类对象,使用 copy 的目的是为了让本对象的属性不受外界影响,使用 copy 无论给我传入是一个可变对象还是不可对象,我本身持有的就是一个不可变的副本.
2. 如果我们使用是 strong ,那么这个属性就有可能指向一个可变对象,如果这个可变对象在外部被修改了,那么会影响该属性.

copy 此特质所表达的所属关系与 strong 类似。然而设置方法并不保留新值，而是将其“拷贝” (copy)。 当属性类型为 NSString 时，经常用此特质来保护其封装性，因为传递给设置方法的新值有可能指向一个 NSMutableString 类的实例。这个类是 NSString 的子类，表示一种可修改其值的字符串，此时若是不拷贝字符串，那么设置完属性之后，字符串的值就可能会在对象不知情的情况下遭人更改。所以，这时就要拷贝一份“不可变” (immutable)的字符串，确保对象中的字符串值不会无意间变动
成实例变量的规则是什么？假如property名为foo，存在一个名为_foo的实例变量，那么还会自动合成新变量么？

1. 如果指定了成员变量的名称,会生成一个指定的名称的成员变量
2. 如果这个成员已经存在了就不再生成了
3. 如果是 @synthesize foo; 还会生成一个名称为foo的成员变量，也就是说
	>如果没有指定成员变量的名称会自动生成一个属性同名的成员变量
4. 如果是 @synthesize foo = _foo; 就不会生成成员变量了。

## 14. 在有了自动合成属性实例变量之后，@synthesize还有哪些使用场景？

回答这个问题前，我们要搞清楚一个问题，什么情况下不会autosynthesis（自动合成）？
	1. 同时重写了 setter 和 getter 时
	2. 重写了只读属性的 getter 时
	3. 使用了 @dynamic 时
	4. 在 @protocol 中定义的所有属性
	5. 在 category 中定义的所有属性
	6. 重写（overridden）的属性


1. 当你在子类中重写（overridden）了父类中的属性，你必须 使用 @synthesize 来手动合成ivar。
2. 当你同时重写了 setter 和 getter 时，系统就不会生成 ivar（实例变量/成员变量）。这时候有两种选择：
	* 手动创建 ivar
	* 使用@synthesize foo = _foo; ，关联 @property 与 ivar。

## 15. objc中向一个nil对象发送消息将会发生什么？

在 Objective-C 中向 nil 发送消息是完全有效的——只是在运行时不会有任何作用:

1. 如果一个方法返回值是一个对象，那么发送给nil的消息将返回0(nil)。例如：
	```swift
	Person * motherInlaw = [[aPerson spouse] mother];
	```
	如果 spouse 对象为 nil，那么发送给 nil 的消息 mother 也将返回 nil。
2. 如果方法返回值为指针类型，其指针大小为小于或者等于sizeof(void*)，float，double，long double 或者 long long 的整型标量，发送给 nil 的消息将返回0。
3. 如果方法返回值为结构体,发送给 nil 的消息将返回0。结构体中各个字段的值将都是0。
4. 如果方法的返回值不是上述提到的几种情况，那么发送给 nil 的消息的返回值将是未定义的。
	具体原因如下：
	```swift
	objc是动态语言，每个方法在运行时会被动态转为消息发送，即：objc_msgSend(receiver, selector)。
	```

objc在向一个对象发送消息时，runtime库会根据对象的isa指针找到该对象实际所属的类，然后在该类中的方法列表以及其父类方法列表中寻找方法运行，然后在发送消息的时候，objc_msgSend方法不会返回值，所谓的返回内容都是具体调用时执行的。 那么，回到本题，如果向一个nil对象发送消息，首先在寻找对象的isa指针时就是0地址返回了，所以不会出现任何错误。

## 16. objc中向一个对象发送消息[obj foo]和objc_msgSend()函数之间有什么关系？

该方法编译之后就是objc_msgSend()函数调用.

```swift
((void ()(id, SEL))(void )objc_msgSend)((id)obj, sel_registerName("foo"));
```

## 17. 什么时候会报unrecognized selector的异常？

简单来说：
>当调用该对象上某个方法,而该对象上没有实现这个方法的时候， 可以通过“消息转发”进行解决。

简单的流程如下，在上一题中也提到过：
>objc是动态语言，每个方法在运行时会被动态转为消息发送，即：objc_msgSend(receiver, selector)。

objc在向一个对象发送消息时，runtime库会根据对象的isa指针找到该对象实际所属的类，然后在该类中的方法列表以及其父类方法列表中寻找方法运行，如果，在最顶层的父类中依然找不到相应的方法时，程序在运行时会挂掉并抛出异常unrecognized selector sent to XXX 。但是在这之前，objc的运行时会给出三次拯救程序崩溃的机会：

1. Method resolution

	objc运行时会调用+resolveInstanceMethod:或者 +resolveClassMethod:，让你有机会提供一个函数实现。如果你添加了函数，那运行时系统就会重新启动一次消息发送的过程，否则 ，运行时就会移到下一步，消息转发（Message Forwarding）。
2. Fast forwarding
	
	如果目标对象实现了 -forwardingTargetForSelector:，Runtime 这时就会调用这个方法，给你把这个消息转发给其他对象的机会。 只要这个方法返回的不是nil和self，整个消息发送的过程就会被重启，当然发送的对象会变成你返回的那个对象。否则，就会继续Normal Fowarding。 这里叫Fast，只是为了区别下一步的转发机制。因为这一步不会创建任何新的对象，但下一步转发会创建一个NSInvocation对象，所以相对更快点。
3. Normal forwarding
	
	这一步是Runtime最后一次给你挽救的机会。首先它会发送 -methodSignatureForSelector: 消息获得函数的参数和返回值类型。如果 -methodSignatureForSelector: 返回nil，Runtime则会发出 -doesNotRecognizeSelector: 消息，程序这时也就挂掉了。如果返回了一个函数签名，Runtime就会创建一个NSInvocation对象并发送 -forwardInvocation: 消息给目标对象。

## 18. 一个objc对象如何进行内存布局？（考虑有父类的情况）

* 所有父类的成员变量和自己的成员变量都会存放在该对象所对应的存储空间中.
* 每一个对象内部都有一个isa指针,指向他的类对象,类对象中存放着本对象的
	1. 对象方法列表（对象能够接收的消息列表，保存在它所对应的类对象中）
	2. 成员变量的列表,
	3. 属性列表

它内部也有一个isa指针指向元对象(meta class),元对象内部存放的是类方法列表,类对象内部还有一个superclass的指针,指向他的父类对象。

## 19. 一个objc对象的isa的指针指向什么？有什么作用？

isa 顾名思义 is a 表示对象所属的类。

isa 指向他的类对象，从而可以找到对象上的方法。

同一个类的不同对象，他们的 isa 指针是一样的

## 20. 下面的代码输出什么？
```swift
@implementation Son : Father
- (id)init
{
   self = [super init];
   if (self) {
       NSLog(@"%@", NSStringFromClass([self class]));
       NSLog(@"%@", NSStringFromClass([super class]));
   }
   return self;
}
@end
```

都输出 Son

## 21. runtime如何通过selector找到对应的IMP地址？（分别考虑类方法和实例方法）

每一个类对象中都一个方法列表，方法列表中记录着方法的名称、方法实现、以及参数类型，其实selector 本质就是方法名称，通过这个方法名称就可以在方法列表中找到对应的方法实现。

参考 NSObject 上面的方法：

```swift
- (IMP)methodForSelector:(SEL)aSelector;
+ (IMP)instanceMethodForSelector:(SEL)aSelector;
```

## 22. 使用runtime Associate方法关联的对象，需要在主对象dealloc的时候释放么？

>无论在MRC下还是ARC下均不需要。

## 23. objc中的类方法和实例方法有什么本质区别和联系？

类方法：

类方法是属于类对象的
类方法只能通过类对象调用
类方法中的self是类对象
类方法可以调用其他的类方法
类方法中不能访问成员变量
类方法中不能直接调用对象方法

实例方法：

实例方法是属于实例对象的
实例方法只能通过实例对象调用
实例方法中的self是实例对象
实例方法中可以访问成员变量
实例方法中直接调用实例方法
实例方法中也可以调用类方法(通过类名)






