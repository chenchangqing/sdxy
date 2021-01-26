# 自定义错误

## Swift中的Error

官方解释
>A type representing an error value that can be thrown.

>Any type that declares conformance to the Error protocol can be used to represent an error in Swift’s error handling system. Because the Error protocol has no requirements of its own, you can declare conformance on any custom type you create.

```swift
protocol Error
```

Error在Swift中就是是个协议，而且不需要实现任何属性或者方法，因此任何声明符合Error协议的类型都可以用来表示Swift的错误。

## 使用枚举作为错误

通常错误都是有很多种，因此枚举类型是作为错误最适合不过，下面是官方给的例子：
```swift
enum IntParsingError: Error {
    case overflow
    case invalidInput(Character)
}
```

## 使用结构体作为错误

官方解释
>Sometimes you may want different error states to include the same common data, such as the position in a file or some of your application’s state. When you do, use a structure to represent errors. 

意思就是当不同错误会包含通用的属性，例如文件中的某些位置或应用的状态，这个时候就可以使用结构体作为错误了，下面还是官方的例子：
```swift
struct XMLParsingError: Error {
    enum ErrorKind {
        case invalidCharacter
        case mismatchedTag
        case internalError
    }

    let line: Int
    let column: Int
    let kind: ErrorKind
}

func parse(_ source: String) throws -> XMLDoc {
    // ...
    throw XMLParsingError(line: 19, column: 5, kind: .mismatchedTag)
    // ...
}
```

## 与NSError的关系

我们在Swift中自定义的Error是可以轻松通过as转为NSError的，但是我们支持NSError使用拥有localizedDescription、code、domain、UserInfo等属性的，只有实现了以下两个协议，转换后NSError的这些属性就可以生效。

## LocalizedError

用来桥接原来NSError中的localizedDescription。

```swift
public protocol LocalizedError : Error {

    var errorDescription: String? { get }
	// ...
}
```

## CustomNSError

用来桥接原来NSError中的code、domain、UserInfo。
```swift
public protocol CustomNSError : Error {

    /// The domain of the error.
    public static var errorDomain: String { get }

    /// The error code within the given domain.
    public var errorCode: Int { get }

    /// The user-info dictionary.
    public var errorUserInfo: [String : Any] { get }
}
```

附：
>* [苹果文档](https://developer.apple.com/documentation/swift/error)
>* [Swift：Corelocation处理didFailWithError中的NSError](http://codingdict.com/questions/72852)
>* [Swift Error 的介绍和使用](https://juejin.cn/post/6844903591912669192)
>* [Swift 3必看：Error与NSError的关系](https://www.jianshu.com/p/a36047852ccc)
>* [fatalError](https://swifter.tips/fatalerror/)