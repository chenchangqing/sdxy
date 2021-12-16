### 2.使用中间件

* [CTMediator](https://github.com/casatwy/CTMediator)

本文只介绍ObjC如何使用CTMediator。

#### 一、新建业务组件Target

通过下载CTMediator的Demo，每个组件都会有一个Target的类，用于提供对外方法的实现。

Target类的命名规则：“Target_[lib name]”，例如：Target_A，A是组件名称，Target是固定不变的。

Target方法命名规则：“Action_[method name]”，例如：Action_ViewController，ViewController是方法名称，Action是固定不变的。

```swift
@implementation Target_testlib

- (UIViewController *)Action_OneKeyLoginVC:(NSDictionary *)params
{
    typedef void (^CallbackType)(NSString *);
    CallbackType callback = params[@"callback"];
    if (callback) {
        callback(@"success");
    }
    UTOneKeyLoginVC *viewController = [[UTOneKeyLoginVC alloc] init];
    return viewController;
}

@end
```

#### 二、新建业务组件对外接口

CTMediator是通过Target-Action的方式实现，所以我们只需要给CTMediator增加Category，在Category写组件对外的方法和实现即可。

在git服务器创建中间件仓库，通过`pod lib create [中间件名称]`创建中间件工程。

编辑podspec文件，增加`s.dependency 'CTMediator'`，然后执行`pod install`，完成CTMediator的依赖。

通过新增CTMediator的分类，实现组件对外的接口。

分类的命名：CTMediator+[lib name]，例如：CTMediator+testlib.h。

方法的命名：[lib name]_[method name]，例如：utlogin_OneKeyLoginVCWithCallback。

为CTMediator增加分类，编写业务组件的接口方法：

```swift
@implementation CTMediator (utlogin)

/// 一键登录页面
/// @param callback 回调
- (UIViewController *)utlogin_OneKeyLoginVCWithCallback:(void(^)(NSString *result))callback;
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    params[@"callback"] = callback;
    return [self performTarget:@"utlogin" action:@"OneKeyLoginVC" params:params shouldCacheTarget:NO];
}

@end
```

这样就完成了组件对外的接口了，宿主工程可以通过依赖中间件直接调用到组件的Target_testlib的实现。

#### 三、新建宿主工程

使用xcode创建宿主工程，在通过`pod init`创建Podfile文件。

[using-cocoapods](https://guides.cocoapods.org/using/using-cocoapods.html)

编辑Podfile文件：
```ruby
# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

source '私有仓库地址'
source 'https://github.com/CocoaPods/Specs.git'

target 'utopia' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  use_modular_headers!

  # Pods for utopia
  pod 'testlib'#业务组件
  pod 'testmediatro'#中间件

end
```

执行`pod install`。


