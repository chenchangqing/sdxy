# 1.长城汽车Swift编程规约

## 前言

好的代码有一些特性：简明，自我解释，优秀的组织，良好的文档，良好的命名，优秀的设计以及可以被久经考验。参与长城系列APP开发的团队成员应严格遵照规约编写代码。规约会越来越完善，初期先按照以下规范。

第一次编辑时间:2020-01-28

## 核心原则

- **最重要的目标：每个元素都能够准确清晰的表达出它的含义**。做出 API 设计、声明后要检查在上下文中是否足够清晰明白。

- **清晰比简洁重要**。虽然 swift 代码可以被写得很简短，但是让代码尽量少不是 swift 的目标。简洁的代码来源于安全、强大的类型系统和其他一些语言特性减少了不必要的模板代码。而不是主观上写出最少的代码。

- **为每一个声明写注释文档**。编写文档过程中获得的理解可以对设计产生深远的影响，所以不要回避拖延。

> 如果你不能很好的描述 API 的功能，很可能这个 API 的设计就是有问题的。

## 命名规约

- ##### 不要使用约定命名样式代替访问控制

  如果要控制访问权限应该使用访问控制（internal、fileprivate、private），不用使用自定义的命名方式来区分，比如在方法前前下划线表示私有。
  只有在极端的情况下才会采用这种自定义命名表示。比如有一个方法只是为了某个模板调用才公开的，这种情况下本意是私有的，但是又必须声明成 public，可以使用自定义的命名惯例。

- ##### 代码中的命名严禁使用拼音与英文混合的方式，更不允许直接使用中文的方式。

  ```swift
  ✅
  var productDiskDataArray: Array?
  var productDiskDataString: String!
  
  ❌
  var chanpinDataArray: Array?
  var chanpinDataString: String!
  ```

- ##### 类, 结构体, 枚举, 协议命名使用 UpperCamelCase 风格，必须遵从驼峰形式。特别注意类名开头大写。

  ```swift
  ✅
  class GWElecFenceFlowLayout: UICollectionViewFlowLayout
  
  ❌
  class gwElecFenceFlowLayout: UICollectionViewFlowLayout
  ```

- ##### 资源文件按照匈牙利命名法。

  模块名+图片特征描述+状态  描述清晰有章法即可。

  ```swift
  ✅
  nav_add_normal@2X.png
  
  ❌
  navAddNormal@2X.png
  NAV_ADD_NORMAL@2x.png 
  ```

- ##### 方法名、参数名、成员变量、局部变量都统一使用 lowerCamelCase 风格，必须遵从驼峰形式。

  ```swift
  ✅
  func viewDidLoad()
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
  let automaticDimension: CGFloat
  let gradientShapeLayer = CAShapeLayer()
  
  ❌
  func ViewDidLoad()
  func tableView(_ tableV: UITableView, numberOfRowsInSection section: Int) -> Int
  var FILLCOLOR: CGColor?
  let gradientshapeLayer = CAShapeLayer()
  ```

- ##### 全局常量就正常变量一样使用匈牙利命名方式，不要在前面加上 g、k 或其他特别的格式。

  ```swift
  ✅
  let secondsPerMinute = 60
  
  ❌
  let SecondsPerMinute = 60
  let kSecondsPerMinute = 60
  let gSecondsPerMinute = 60
  let SECONDS_PER_MINUTE = 60
  ```

- ##### 杜绝完全不规范的缩写，避免望文不知义。

  ```swift
  ❌
  var abcAry: Array?
  ```

- ##### 保证英文拼写正确

  ```swift
  ❌
  class AysncDat: NSObject
  ```

- ##### 单例对象一般命名为 shared 或者 default。

  ```swift
  ✅
  /// 路由单例
  public static let shared = GWNavigator()
      
  /// 屏蔽实现方式(可根据具体使用情况灵活调整)
  private override init() {}
  ```

## 格式规约

- ##### 括号

  非空的 block 花括号默认使用 [K&R](https://en.wikipedia.org/wiki/Indentation_style#K&R) style。比如：

  ```swift
  while (x == y) {
      something()
      somethingelse()
  }
  ```

  除了一些 Swift 特别要求的情况：

  - 左花括号（ { ）前的代码不会换行，除非超过前面提到的代码长度超过限制。
  - 左花括号后是一个换行，除非：
    - 后面要声明闭包的参数，改为在 in 关键字后面换行。
    - 符合[每行只声明一件事](#每行只声明一件事)里情况，忽略换行，把内容写在一行里。
    - 如果是空的 block ，直接声明为 `{ }`。

- - 如果右花括号（ } ）结束了一个声明，后面接上一个换行。比如如果右花括号后面跟的是 else ，那么后面就不会跟换行，而会写成这样 `} else {` 衔接。

- ##### 每行只声明一件事

  每行最多只声明一件事，每行结尾用换行分隔。**除非结尾跟的是一个总共只有一行声明的闭包**。

  ```swift
  ✅
  guard let value = value else { return 0 }
  
  defer { file.close() }
  
  switch someEnum {
  case .first: return 5
  case .second: return 10
  case .third: return 20
  }
  
  let squares = numbers.map { $0 * $0 }
  
  var someProperty: Int {
    get { return otherObject.property }
    set { otherObject.property = newValue }
  }
  
  var someProperty: Int { return otherObject.somethingElse() }
  
  required init?(coder aDecoder: NSCoder) { fatalError("no coder") }
  ```

  如果闭包是提前返回一个值，写在一行里可读性就会好一些。如果是一个正常的操作，可以视情况是否写在一行里。因为未来也有可能里面再增加代码的操作。

- ##### 代码换行
  - ##### 代码中的空格

    除了语言或者其他样式的要求，文字和注释之外，一个Unicode空格也只出现在以下地方:

  - ##### 条件关键字后面和跟着的括号

    ```swift
    ✅
    if (x == 0 && y == 0) || z == 0 {
      // ...
    }
    
    ❌
    if(x == 0 && y == 0) || z == 0 {
      // ...
    }
    ```

  - ##### 如果闭包中的代码在同一行，左花括号的前面、后面，右花括号的前面有空格

    ```swift
    ✅
    let nonNegativeCubes = numbers.map { $0 * $0 * $0 }.filter { $0 >= 0 }
    
    ❌ 
    let nonNegativeCubes = numbers.map { $0 * $0 * $0 } .filter { $0 >= 0 }
    
    ❌
    let nonNegativeCubes = numbers.map{$0 * $0 * $0}.filter{$0 >= 0}
    ```

  - ##### 在任何二元或三元运算符的两边

    还有以下的情况：

    - 使用于赋值，初始化变量、属性，默认参数的等号两边。

      ```swift
      ✅
      var x = 5
      
      func sum(_ numbers: [Int], initialValue: Int = 0) {
        // ...
      }
      
      ❌ 
      var x=5
      
      func sum(_ numbers: [Int], initialValue: Int=0) {
        // ...
      }
      ```

    - 表示在协议中表示合成类型的 & 两边。

      ```swift
      ✅
      func sayHappyBirthday(to person: NameProviding & AgeProviding) {
        // ...
      }
      
      ❌ 
      func sayHappyBirthday(to person: NameProviding&AgeProviding) {
        // ...
      }
      ```

    - 自定义运算符的两边。

      ```swift
      ✅
      static func == (lhs: MyType, rhs: MyType) -> Bool {
        // ...
      }
      
      ❌
      static func ==(lhs: MyType, rhs: MyType) -> Bool {
        // ...
      }
      ```

    - 表示返回值的 -> 两边。

      ```swift
      ✅
      func sum(_ numbers: [Int]) -> Int {
        // ...
      }
      
      ❌
      func sum(_ numbers: [Int])->Int {
        // ...
      }
      ```

    - **例外**：表示引用值、成员的点两边没有空格。

      ```swift
      ✅
      let width = view.bounds.width
      
      ❌
      let width = view . bounds . width
      ```

    - **例外**：表示区域范围的 ..< 和 …两边没有空格。

      ```swift
      ✅
      for number in 1...5 {
        // ...
      }
      
      ❌
      let substring = string[index..<string.endIndex]
      for number in 1 ... 5 {
        // ...
      }
      
      ❌
      let substring = string[index ..< string.endIndex]
      ```

  - ##### 参数列表、数组、tuple、字典里的逗号后面有一个空格

    ```swift
    ✅
    let numbers = [1, 2, 3]
    
    ❌
    let numbers = [1,2,3]
    let numbers = [1 ,2 ,3]
    let numbers = [1 , 2 , 3]
    ```

  - ##### 冒号的后面有一个空格

    ```swift
    ✅
    // 类型声明
    struct HashTable: Collection {
      // ...
    }
    
    struct AnyEquatable<Wrapped: Equatable>: Equatable {
      // ...
    }
    
    // 参数标签
    let tuple: (x: Int, y: Int)
    
    func sum(_ numbers: [Int]) {
      // ...
    }
    
    // 变量声明
    let number: Int = 5
    
    // 字典声明
    var nameAgeMap: [String: Int] = []
    
    // 字典字面量
    let nameAgeMap = ["Ed": 40, "Timmy": 9]
    ```

  - ##### 代码后的注释符号 // 与代码有两个空格距离

    ```swift
    ✅
    let initialFactor = 2  // Warm up the modulator.
    ❌
    let initialFactor = 2 //    Warm up the modulator.
    ```

  - ##### 表示字典、数组字面量的中括号外面有一个空格

    ```swift
    ✅
    let numbers = [1, 2, 3]
    ❌
    let numbers = [ 1, 2, 3 ]
    ```

  - ##### 禁止变量、属性水平对齐

    水平对齐是明确禁止的，除非是在写明显的表格数据时，省略对齐会损害可读性。引入水平对齐后，如果添加一个新的成员可能会需要其他成员再对齐一次，这给维护增加了负担。

    ```swift
    ✅
    struct DataPoint {
      var value: Int
      var primaryColor: UIColor
    }
    ❌
    struct DataPoint {
      var value:        Int
      var primaryColor: UIColor
    }
    ```

- ##### 空行逻辑

  - 在组织代码逻辑关系时，可以用空行隔开进行分组。
  - 函数结尾不空行
  - 函数内作用不同代码块空一行
  - 规范里其他地方要求有空行的地方。

- ##### 括号

  最顶级的 if、guard、while、switch 的条件不使用括号。

  ```swift
  ✅
  if x == 0 {
    print("x is zero")
  }
  
  if (x == 0 || y == 1) && z == 2 {
    print("...")
  }
  
  ❌
  if (x == 0) {
    print("x is zero")
  }
  
  if ((x == 0 || y == 1) && z == 2) {
    print("...")
  }
  ```

  在有复杂的条件表达式，只有作者和 review 的人同时认为省略括号不会影响代码的可读性才会省略。不能假设每个读者都完全了解对 swift 的运算符优先级，所以这种情况下的括号提示用户的计算优先级是合理的。

## 集合处理

- ##### 不要在 forin 循环里进行元素的 remove/add 操作。

  ```swift
  ❌
  var someInts:[Int] = [10, 20, 30]
  for index in someInts {
    someInts.insert(44 + index, at: index)
  }
  ```

## 并发处理

- 获取单例对象需要保证线程安全，其中的方法也要保证线程安全。 

- 创建线程或线程池时请指定有意义的线程名称，方便出错时回溯。 

  **推荐:**

  ```objc
  dispatch_queue_t gwhUpdateQueue = dispatch_queue_create("", DISPATCH_QUEUE_SERIAL);
  let queue = DispatchQueue(label: "com.gwh.app.update", attributes: .concurrent)
  ```

- 高并发时，同步调用应该去考量锁的性能损耗。能用无锁数据结构，就不要用锁;能锁区块，就不要锁整个方法体;能用对象锁，就不要用类锁。 

- 对多个资源、数据库表、对象同时加锁时，需要保持一致的加锁顺序，否则可能会造成死锁。

- 并发修改同一记录时，避免更新丢失，要么在应用层加锁，要么在缓存加锁，要么在数据库层使用乐观锁，使用 version 作为更新依据。

## 控制语句

- ##### 提前返回使用 guard

  ```swift
  ✅
  func discombobulate(_ values: [Int]) throws -> Int {
    guard let first = values.first else {
      throw DiscombobulationError.arrayWasEmpty
    }
    guard first >= 0 else {
      throw DiscombobulationError.negativeEnergy
    }
  
    var result = 0
    for value in values {
      result += invertedCombobulatoryFactory(of: value)
    }
    return result
  }
  ❌
  func discombobulate(_ values: [Int]) throws -> Int {
    if let first = values.first {
      if first >= 0 {
        var result = 0
        for value in values {
          result += invertedCombobulatoryFactor(of: value)
        }
        return result
      } else {
        throw DiscombobulationError.negativeEnergy
      }
    } else {
      throw DiscombobulationError.arrayWasEmpty
    }
  }
  ```

- ##### for-where 循环

  如果整个 for 循环在函数体顶部只有一个 if 判断，使用 for where 替换：

  ```swift
  ✅
  for item in collection where item.hasProperty {
    // ...
  }
  
  ❌
  for item in collection {
    if item.hasProperty {
      // ...
    }
  }
  ```

- ##### Switch 中的 fallthrough

  Switch 中如果有几个 case 都对应相同的逻辑，case 使用逗号连接条件，而不是使用 fallthrough：

  ```swift
  ✅
  switch value {
  case 1: print("one")
  case 2...4: print("two to four")
  case 5, 7: print("five or seven")
  default: break
  }
  
  ❌
  switch value {
  case 1: print("one")
  case 2: fallthrough
  case 3: fallthrough
  case 4: print("two to four")
  case 5: fallthrough
  case 7: print("five or seven")
  default: break
  }
  ```

  换句话说，不存在 case 中只有 fallthrough 的情况。如果 case 中有自己的代码逻辑再 fallthrough 是合理的。

## 注释规约

-   所使用的任何注释必须保持最新否则删除掉。代码修改的同时，注释也要进行相应的修改，尤其是参数、返回值、异常、核心逻辑等的修改。

-   类、类属性、类方法的注释必须使用 appledoc 规范，使用/**内容*/格式。option+command+/。对于注释的要求:第一、能够准确反应设计思想和代码逻辑;第二、能够描述业务含义，使别的程序员能够迅速了解到代码背后的信息。完全没有注释的大段代码对于阅读者形同天书，注释是给自己看的，即使隔很长时间，也能清晰理解当时的思路;注释也是给继任者看的，使其能够快速接替自己的工作。 好的命名、代码结构是自解释的，注释力求精简准确、表达到位。避免出现注释的一个极端:过多过滥的注释，代码的逻辑一旦修改，修改注释是相当大的负担。

## 补充规范

* 代码警告⚠️应该尽可能去除。除非明确为了提醒作用。


* 小代码块 保证逻辑的完整与连贯性

* 使用便于理解的API

* 无用注释与代码的删除尽量删除便于理解

* 优先使用工具类方法

* 服务器定义的字段为大写，客户端model 也应该使用小写

* 实现逻辑尽量才用普遍好理解的方法

* import头文件的排版, 当import超过7个

  ```swift
  ✅
  #import "GWHProductViewController.h"
  //model
  #import "GWHProductModel.h"
  #import "GWHCarModel.h"
  #import "GWHCommunityModel.h"
  //view
  #import "GWHProducPackageView.h"
  #import "GWHCarCell.h"
  #import "GWHCommunityCell.h"
  //tool
  #import <AVFoundation/AVFoundation.h>
  #import "MJRefresh.h"
  #import "NSDateFormatter+Utility.h"
  #import "Masonry.h"
  #import "HttpUtils+GWHNetTool.h"
  #import "GWHUserManager.h"
  //viewController
  #import "GWHServiceProductRecViewController.h"
  #import "GWHPageController.h"
  
  ❌
  #import "GWHProductViewController.h"
  #import "GWHProductModel.h"
  #import "GWHCarCell.h"
  #import "GWHCommunityCell.h"
  #import <AVFoundation/AVFoundation.h>
  #import "MJRefresh.h"
  #import "NSDateFormatter+Utility.h"
  #import "HttpUtils+GWHNetTool.h"
  #import "GWHUserManager.h"
  #import "GWHServiceProductRecViewController.h"
  #import "GWHCarModel.h"
  #import "GWHCommunityModel.h"
  #import "GWHProducPackageView.h"
  #import "Masonry.h"
  #import "GWHPageController.h"
  ```

## 代码提交逻辑

提交 commit 的类型

- feat: 其他

- fix: 修复bug

目前除了fix需要附带bug编号, 别的统一用feat.
