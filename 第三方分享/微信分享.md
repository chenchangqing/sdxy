# 微信分享

## 微信开发平台

https://open.weixin.qq.com/

## 官方Demo运行

1.在[资源下载页面](https://developers.weixin.qq.com/doc/oplatform/Downloads/iOS_Resource.html)下载好最新的[iOS开发工具包](https://res.wx.qq.com/op_res/_Q5kJ9eIC1z-APXT9YPj2uWc-8esYianDXmZnbU7nFSxL_YmuvcoREglWUsrwLInpC6oj7QQB7DhLiZnlcfpGg)和[范例代码](https://res.wx.qq.com/op_res/bud8ZUIdD-ay-tp773CkmKDdblXObskuY3kV-VRM_zjGSTHi5dI0DwNduRqIehjz)。

2.将下载好的“OpenSDK1.8.9”拷贝至“ReleaseSample”下。

3.打开SDKSample，删除显示红色的“SDKExport”，右键工程文件通过“Add Files ...”将“OpenSDK1.8.9”导入工程。

4.点击SDKSample，选中Target,在Frameworks下增加WebKit.framework。

5.更新可用的bundleID及证书，真机就可以运行了。

>当时最新的是（1.8.9版本，包含支付功能），这里选择包含支付版本的，因为官方Demo使用的是包含支付功能的。

>“范例代码”不包含SDK，所以需要手动导入；“范例代码”没有依赖WebKit.framework,也需要手动导入；真机运行，需要更新可用的bundleID及证书。

## 新建工程

1.点击File，选择New->Project->App，一直Next直到完成。

2.删除SceneDelegate，直接Move To Trash。

3.删除AppDelegate中关于Scene的报错代码。

4.删除Info.plist的UIApplicationSceneManifest及Value。

5.在AppDelegate中增加如下代码。
```swift
var window: UIWindow?
```
>没有第5步，工程运行会是黑屏，控制台会显示“The app delegate must implement the window property if it wants to use a main storyboard file.”。

## 集成OpenSDK（Swift）

[官方接入点指南](https://developers.weixin.qq.com/doc/oplatform/`Mobile_App/Access_Guide/iOS.html)

##### 1.首先新建Swift工程，工程名wechatshare，步骤如上。

##### 2.右键“wechatshare”group，通过“Add Files ...”将“OpenSDK1.8.9”导入工程。

>注意勾选“Copy items if needed”。

##### 3.新建Swift桥接OC的文件，有一下两种方式：

3.1. 新建一个OC文件自动创建`XXX-Bridging-Header.h`。

3.2. 右键“wechatshare”group，New File...->Header File->wechatshare-Bridging-Header.h，
然后点击Target->Build Settings->搜索Objective-C Bridging Header->填写wechatshare/wecha
tshare-Bridging-Header.h，这个是项目的相对路径。

##### 4.测试sdk的使用

4.1.配置真机证书，设置iOS Deployment Target为真机支持的系统版本，新建工程的时候这里是最新的iOS版本，可能手机不是最新的，这里修改下就好。

4.2.wechatshare-Bridging-Header.h增加如下代码
```swift
#import "WXApi.h"
```

4.3.AppDelegate.swift增加如下代码
```swift
class AppDelegate: UIResponder, UIApplicationDelegate, WXApiDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        WXApi.registerApp("", universalLink: "")
        return true
    }
}
```

4.4.运行工程，报错误：
```c
Undefined symbols for architecture arm64:
  "operator delete[](void*)", referenced from:
      +[WeChatApiUtil EncodeBase64:] in libWeChatSDK.a(WeChatApiUtil.o)
      +[WeChatApiUtil NsDataEncodeBase64:] in libWeChatSDK.a(WeChatApiUtil.o)
      +[WeChatApiUtil DecodeWithBase64:] in libWeChatSDK.a(WeChatApiUtil.o)
      +[WeChatApiUtil DecodeBase64:] in libWeChatSDK.a(WeChatApiUtil.o)
  "operator new[](unsigned long)", referenced from:
      +[WeChatApiUtil EncodeBase64:] in libWeChatSDK.a(WeChatApiUtil.o)
      +[WeChatApiUtil NsDataEncodeBase64:] in libWeChatSDK.a(WeChatApiUtil.o)
      +[WeChatApiUtil DecodeWithBase64:] in libWeChatSDK.a(WeChatApiUtil.o)
      +[WeChatApiUtil DecodeBase64:] in libWeChatSDK.a(WeChatApiUtil.o)
  "_OBJC_CLASS_$_WKWebView", referenced from:
      objc-class-ref in libWeChatSDK.a(WapAuthHandler.o)
  "_OBJC_CLASS_$_WKWebViewConfiguration", referenced from:
      objc-class-ref in libWeChatSDK.a(WapAuthHandler.o)
ld: symbol(s) not found for architecture arm64
clang: error: linker command failed with exit code 1 (use -v to see invocation)
```

4.5.修复报错：

开发者需要在工程中链接上:Security.framework，CoreGraphics.framework，WebKit.framework，libc++.tbd。

>官方文档是上没有写需要接入libc++.tbd，但是实际是需要的，要不然编译会遇到[错误](https://blog.csdn.net/Tudouyang/article/details/44306033)

##### 5.准备appid及universalLink

5.1.登录开发者者中心，确保app开启了Associated Domains的功能。

5.2.更新证书描述文件，确保包含了Associated Domains的功能。

5.4.在项目中配置applinks:xxxx。

5.5.去微信开发平台注册用户获得appid。

5.6.更新AppDelegate.swift
```swift
class AppDelegate: UIResponder, UIApplicationDelegate, WXApiDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        WXApi.registerApp("wx536bce0bc6a71ffd", universalLink: "https://huya.gq/demo.html")
        return true
    }
}
// 处理universallink
extension AppDelegate {
    
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        return WXApi.handleOpen(url, delegate: self)
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return WXApi.handleOpen(url, delegate: self)
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        return WXApi.handleOpenUniversalLink(userActivity, delegate: self)
    }
}
```

##### 6.分享超链接

6.1.在ViewController.swift增加如下代码，点击按钮触发分享：
```swift
/// 发送Link消息给微信
@IBAction @objc private func sendLinkContent() {
    let webpageObject = WXWebpageObject()
    webpageObject.webpageUrl = Constant.kLinkURL
    let message = WXMediaMessage()
    message.title = Constant.kLinkTitle;
    message.description = Constant.kLinkDescription;
    message.setThumbImage(UIImage(named: "res2.png")!)   //分享后展示图片，没有就显示大大的问号图片。
    message.mediaObject = webpageObject;
    let req = SendMessageToWXReq();
    req.bText = false;
    req.message = message;
    req.scene = Int32(WXSceneSession.rawValue);//WXSceneSession;
    WXApi.send(req) { (result) in}
}
```
6.2.发现报错：
```c
-canOpenURL: failed for URL: "weixinULAPI://" - error: "This app is not allowed to query for scheme weixinulapi"
```
6.3.解决报错
打开info.plist,增加如下代码：
```
<key>LSApplicationQueriesSchemes</key>
<array>
	<string>weixin</string>
	<string>weixinULAPI</string>
</array>
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>weixin</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>wx536bce0bc6a7****</string>
        </array>
    </dict>
</array>
```
6.4.接着报错：
```
*** Terminating app due to uncaught exception 'NSInvalidArgumentException', reason: '+[WXApi genExtraUrlByReq:withAppData:]: unrecognized selector sent to class 0x100286398'
```
6.5.[解决报错](https://www.jianshu.com/p/d2529fbecda2)

在你的工程文件中选择 Build Setting，在"Other Linker Flags"中加入"-ObjC -all_load"

##### [代码](https://gitee.com/chenchangqing/wechatshare)

