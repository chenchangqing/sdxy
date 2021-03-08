# 1.WebView与iOS原生的交互

## 一、WKWebView的代理方法

### 1.1 WKNavigationDelegate

该代理提供的方法，可以用来追踪加载过程（页面开始加载、加载完成、加载失败）、决定是否执行跳转。

```swift
// 页面开始加载时调用
optional func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!)
// 当内容开始返回时调用
optional func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!)
// 页面加载完成之后调用
optional func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!)
// 页面加载失败时调用
optional func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error)
```

页面跳转的代理方法有三种，分为（收到跳转与决定是否跳转两种）：

```swift
// 接收到服务器跳转请求之后调用
optional func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!)
// 在收到响应后，决定是否跳转
optional func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void)
// 在发送请求之前，决定是否跳转
optional func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void)
```

### 1.2 WKUIDelegate

```swift
optional func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView?
```
下面代理方法全都是与界面弹出提示框相关的，针对于web界面的三种提示框（警告框、确认框、输入框）分别对应三种代理方法。下面只列举了警告框的方法。

```swift
optional func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void)
```

### 1.3 WKScriptMessageHandler

WKScriptMessageHandler其实就是一个遵循的协议，它能让网页通过JS把消息发送给OC。其中协议方法。

```swift
// 从web界面中接收到一个脚本时调用
func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage)
```

从协议中我们可以看出这里使用了两个类WKUserContentController和WKScriptMessage。WKUserContentController可以理解为调度器，WKScriptMessage则是携带的数据。

### 1.4 WKUserContentController

WKUserContentController有两个核心方法，也是它的核心功能。

```swift
// js注入，即向网页中注入我们的js方法，这是一个非常强大的功能，开发中要慎用。
open func addUserScript(_ userScript: WKUserScript)
// 添加供js调用oc的桥梁。这里的name对应WKScriptMessage中的name，多数情况下我们认为它就是方法名。
open func add(_ scriptMessageHandler: WKScriptMessageHandler, name: String)
```
### 1.5 WKScriptMessage

WKScriptMessage就是js通知oc的数据。其中有两个核心属性用的很多。

```swift
open var name: String { get }
```
对应`func add(_ scriptMessageHandler: WKScriptMessageHandler, name: String)`添加的name。

```swift
open var body: Any { get }
```
携带的核心数据。js调用时只需`window.webkit.messageHandlers.#name#.postMessage()`

这里的name就是我们添加的name，是不是感觉很爽，就是这么简单，下面我们就来具体实现。

## 二、自定义CQWebView

```swift
class CQWebView: UIView {
	// 增加webView属性
	private lazy var webView: WKWebView = {
	        
	    let conf = WKWebViewConfiguration()
	    conf.preferences.javaScriptEnabled = true
	    conf.selectionGranularity = WKSelectionGranularity.character
	    conf.allowsInlineMediaPlayback = true
	    
	    let webView = WKWebView(frame: .zero, configuration: conf)
	    ...
	    return webView
	}()
}
```
## 2.1 增加js/oc交互方法
```swift   
class CQWebView: UIView {
	...
	// 增加js消息监听
	func adddScriptMessageHandler(forName name: String) {
	    webView.configuration.userContentController.add(self, name: name)
	}
	// 移除js消息监听
	func removeScriptMessageHandler(forName name: String) {
	    webView.configuration.userContentController.removeScriptMessageHandler(forName: name)
	}
	// oc执行js
	func evaluateJavaScript(_ javaScriptString: String, completionHandler: ((Any?, Error?) -> Void)? = nil) {
	    webView.evaluateJavaScript(javaScriptString, completionHandler: completionHandler)
	}
}
```
## 2.2 增加代理属性
```swift
// WebView代理
@objc protocol CQWebViewDelegate {
    // 接收 js 发来的消息
    @objc optional func webView(_ webView: CQWebView, didReceiveMessage name: String, body: Any)
}
class CQWebView: UIView {
	...
	weak var delegate: CQWebViewDelegate?
}
```
## 2.3 实现WKScriptMessageHandler
```swift
// js 和 swift 的交互
extension CQWebView: WKScriptMessageHandler {
    
    // 接收 js 发来的消息
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        delegate?.webView?(self, didReceiveMessage: message.name, body: message.body)
    }
}
```

## 三、JS调用Swift

### 2.1 完整html
```html
<!doctype html>
<html>
<head>
<meta charset="UTF-8">
<title>Untitled Document</title>
</head>

<body>
    <h1 id='h'></h1>
    <a href="javascript:jsCallSwift({'msg':'#test msg'})">js调用swift</a>
</body>

<script>
    // js调用swift
    function jsCallSwift(obj) {
        // 向 swift 发送数据，这里的‘msgBridge’就是 swift 中添加的消息通道的 name
        window.webkit.messageHandlers.msgBridge.postMessage(obj);
    }

    // swift调用js
    function swiftCallJs(msg){
        document.getElementById('h').innerText+=msg;
    }
</script>

</html>
```
### 3.2 增加对js消息的监听

只需要调用`CQWebView`的`adddScriptMessageHandler`方法。

```swift
class ViewController: UIViewController {
    
    // MARK: - Properties
    
    private lazy var webView: CQWebView = {
        
        let webView = CQWebView(frame: .zero)
        webView.delegate = self
        webView.adddScriptMessageHandler(forName: "msgBridge")
        ...
        return webView
    }()
}
```

### 3.2 实现对js消息的处理

```swift
extension ViewController: CQWebViewDelegate {
    
    func webView(_ webView: CQWebView, didReceiveMessage name: String, body: Any) {
        
        switch name {
        case "msgBridge":
            ...
            break
        default:
            break
        }
    }
}
```

## 四、Swift调用JS

### 4.1 evaluateJavaScript方法使用

在html的js中已经定义了`swiftCallJs`方法等待调用，只需要调用`CQWebView`的evaluateJavaScript方法即可。
```swift
//swift 调 js函数
webView.evaluateJavaScript("swiftCallJs('\( dic["msg"]  as! String)')", completionHandler: {
    (any, error) in
    if (error != nil) {
        print(error ?? "err")
    }
})
```

### 4.2 WKWebView加载JS
```swift
NSString *js = @"";
// 根据JS字符串初始化WKUserScript对象
WKUserScript *script = [[WKUserScript alloc] initWithSource:js injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
// 根据生成的WKUserScript对象，初始化WKWebViewConfiguration
WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
[config.userContentController addUserScript:script];
```

## 参考文章

* [源码](https://gitee.com/chenchangqing/cqweb-view)
* [Safari调试iOS中的JS](https://www.jianshu.com/p/bc5d33a0d043)
* [iOS WKWebView 加载本地html文件（swift）](https://my.oschina.net/u/2399303/blog/1610638)
* [学习-WebKit(WKScriptMessageHandler)](https://www.jianshu.com/p/df34a82959ea)
* [iOS下OC与JS的交互(WKWebview-MessageHandler实现)](https://www.jianshu.com/p/ab58df0bd1a1)
* [自己动手打造基于 WKWebView 的混合开发框架（二）——js 向 Native 一句话传值并反射出 Swift 对象执行指定函数](https://lvwenhan.com/ios/461.html)
* [WkWebKit - javascript on loaded page finds window.webkit is undefined](https://stackoverflow.com/questions/32771215/wkwebkit-javascript-on-loaded-page-finds-window-webkit-is-undefined)
* [WKWebview使用二三事](https://www.colabug.com/2020/0314/7120535/)