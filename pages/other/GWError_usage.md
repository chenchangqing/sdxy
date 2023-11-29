
# GWError的使用

根据业务，在项目中可以对`GWClientError`或`GWSeverError`增加case，自定义错误。

## 解决问题

1. 客户端请求接口，我们需要弹出指定的提示，例如：“no network（没有网络）”、“network error（服务器错误）”。
2. 客户端请求接口，对指定的错误码返回自定的错误，例如：动态不存在的时候，服务器会返回712200，我们需要按需求自定义提示。
3. 编写校验逻辑的时候，我们可以根据不同的情况自定义不同的Error抛出，这样我们可以通过catch对错误统一处理。

## GWError

`GWError`是对`GWClientError`、`GWSeverError`、`MoyaError`的包装，也就是引发错误的来源是被包装的三种自定义错误：

```swift
public enum GWError: Swift.Error {
    // Moya错误
    case moya(MoyaError)
    // 客户端错误
    case client(GWClientError)
    // 服务端错误
    case server(GWSeverError)
}
```
`GWError`分别实现了`LocalizedError`、`CustomNSError`：
```swift
extension GWError: LocalizedError {
    // 错误描述
    public var errorDescription: String? {
        switch self {
        case let .moya(error):
            return error.gwErrorDescription ?? GWI18n.R.string.localizable.base_net_erroe()
        case let .client(error):
            return error.errorDescription
        case let .server(error):
            return error.errorDescription
        }
    }
}

extension GWError: CustomNSError { /// The domain of the error.
    public static var errorDomain: String = "com.gwm.error"

    // 错误码
    public var errorCode: Int {
        switch self {
        case let .moya(error):
            return error.errorCode
        case let .client(error):
            return error.errorCode
        case let .server(error):
            return error.errorCode
        }
    }

    // 错误信息
    public var errorUserInfo: [String: Any] {
        var userInfo: [String: Any] = [:]
        userInfo[NSLocalizedDescriptionKey] = errorDescription
        userInfo[NSUnderlyingErrorKey] = underlyingError
        return userInfo
    }

    // 内部错误
    internal var underlyingError: Swift.Error? {
        switch self {
        case let .moya(error): return error
        case let .client(error): return error
        case let .server(error): return error
        }
    }
}
```
为了兼容老代码，保留了`statusCode`、`message`、`code`三个属性：
```swift
// 状态码
public var statusCode: Int? {
    switch self {
    case let .moya(error):
        return error.response?.statusCode
    case let .client(error):
        return error.statusCode
    case let .server(error):
        return error.statusCode
    }
}

// 错误提示
public var message: String {
    errorDescription ?? ""
}

// 错误码
public var code: String {
    switch self {
    case let .moya(error):
        return String(error.errorCode)
    case let .client(error):
        return String(error.code)
    case let .server(error):
        return String(error.code)
    }
}
```

## GWClientError

`GWClientError`是客户端错误，可以是校验逻辑中的任何一种异常的封装，同样分别实现了`LocalizedError`、`CustomNSError`，目前有如下定义：。
```swift
public enum GWClientError: Swift.Error {
    // 没有网络
    case noNetwork
    // 网络异常
    case networkException
    // 禁言错误
    case muted
    // 提交评论失败
    case postComment
    
    // 状态码
    public var statusCode: Int? {
        // ...
    }
    
    // 错误提示
    public var message: String {
        // ...
    }
    
    // 错误码
    public var code: String {
        // ...
    }
}
extension GWClientError: LocalizedError {
    
    // 错误描述
    public var errorDescription: String? {
        // ...
    }
}

extension GWClientError: CustomNSError {/// The domain of the error.
    
    public static var errorDomain: String = "com.gwm.error.client"

    // 错误码
    public var errorCode: Int {
        // ...
    }

    // 错误信息
    public var errorUserInfo: [String: Any] {
        // ...
    }
}
```

## GWSeverError

`GWSeverError`是服务端错误，是服务端异常的封装，同样分别实现了`LocalizedError`、`CustomNSError`，目前定义如下：
```swift
public enum GWSeverError: Swift.Error {
    // 资讯评论不存在(回复评论)
    case newsCommentNotExist
    // 动态评论不存在(回复评论)
    case dynamicCommentNotExist
    // 动态评论不存在(查询评论)
    case dynamicCommentNotExistOnQuery
    // 动态不存在
    case dynamicNotExist
    // 结果异常
    case resultException(code: Int, msg: String?, statusCode: Int?)

    // 业务异常
    static let businessErrors: [GWSeverError] = [
        // ...
    ]
    // 根据code匹配业务异常
    static func getError(code: Int, msg: String?, statusCode: Int?) -> GWSeverError {
        // ...
    }
    
    // 状态码
    public var statusCode: Int? {
        // ...
    }
    
    // 错误提示
    public var message: String {
        // ...
    }
    
    // 错误码
    public var code: String {
        // ...
    }
}
```
实现了`CustomNSError`的`errorCode`,`errorCode`应该和服务端错误code保持一致：
```swift
extension GWSeverError: LocalizedError {
    
    // 错误描述
    public var errorDescription: String? {
        // ...
    }
}

extension GWSeverError: CustomNSError {/// The domain of the error.
    
    public static var errorDomain: String = "com.gwm.error.server"

    // 错误码
    public var errorCode: Int {
        switch self {
        // 资讯评论不存在(回复评论)
        case .newsCommentNotExist:
            return 710009
        // 动态评论不存在(回复评论)
        case .dynamicCommentNotExist:
            return 712123
        // 动态评论不存在(查询评论)
        case .dynamicCommentNotExistOnQuery:
            return 712197
        // 动态不存在
        case .dynamicNotExist:
            return 712200
        case .resultException(let code, msg: _, statusCode: _):
            return code
        }
    }

    // 错误信息
    public var errorUserInfo: [String: Any] {
        // ...
    }
}
```
## 服务端通用错误

当服务端返回的错误码不匹配我们约定的errorCode时，我们统一使用`resultException`这个服务器错误，`resultException`有`code`、`msg`、`statusCode`三个关联属性。
```swift
// 业务异常
static let businessErrors: [GWSeverError] = [
    .newsCommentNotExist,
    .dynamicCommentNotExist,
    .dynamicNotExist,
    .dynamicCommentNotExistOnQuery
]
// 根据code匹配业务异常
static func getError(code: Int, msg: String?, statusCode: Int?) -> GWSeverError {
    if let customError = businessErrors.filter({ $0.errorCode == code }).first {
        return customError
    }
    return .resultException(code: code, msg: msg, statusCode: statusCode)
}
```

## 如何使用

客户端错误的使用，下面是没有网络的时候返回了`noNetwork`异常：

```swift
if NetworkReachabilityManager()?.isReachable == false {
    failedCallBack?(.client(.noNetwork))
    return nil
}
```
服务端错误的使用，下面是判断评论不存在返回了`newsCommentNotExist`异常：
```swift
}, onError: { (error) in
    // 匹配自定义错误
    if let gwError = error as? GWError {
        if gwError.code == GWSeverError.newsCommentNotExist.code {
            observer.onError(GWError.server(.newsCommentNotExist))
            observer.onCompleted()
            return
        }
    }
    observer.onError(GWError.client(.postComment))
    observer.onCompleted()
})
```