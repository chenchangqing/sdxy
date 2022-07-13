# 3.加载图片资源

#### NSBundle+Resource.h

```swift
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSBundle (Resource)
/**
 获取资源的bundle
 @param className framework中的类名
 @param bundleName 资源bundle的名字
 */

+ (instancetype)resourceBundleWithClassName:(NSString *)className
                               bundleName:(NSString *)bundleName;
/**
 获取资源的bundle,默认bundle为当前类所在的bundle
 @param bundleName 资源bundle的名字
 */
+ (instancetype)resourceBundleWithBundleName:(NSString *)bundleName;

/**
 根据path来加载bundle
 获取资源的bundle
 @param frameworkName 为资源所在的framework的名字
 @param bundleName 资源bundle的名字
 */
+ (instancetype)resourceBundleWithFramework:(NSString *)frameworkName
                               bundleName:(NSString *)bundleName;

/**
 这个方法会直接给出 framework的bundle
 @param className framework中的任意类名
 */
+ (instancetype)getFrameworkBundleWithClassName:(NSString *)className;

/**
 这个方法会直接给出 framework的bundle
 @param frameworkName framework的名称
 */
+ (instancetype)getFrameworkBundleWithFramework:(NSString *)frameworkName;

/**
 加载main bundle下 资源bundle
 @param bundleName 资源bundle名字
 */
+ (instancetype)getMainBundleWithResourceBundle:(NSString *)bundleName;

@end

NS_ASSUME_NONNULL_END
```

#### NSBundle+Resource.m

```swift
#import "NSBundle+Resource.h"

@implementation NSBundle (Resource)

+ (instancetype)resourceBundleWithClassName:(NSString *)className
                               bundleName:(NSString *)bundleName{
    if (!className) {
        NSAssert(!className, @"获取资源路径bundle时，类名为空");
        return nil;
    }
    NSBundle *frameworkBundle = [NSBundle bundleForClass:NSClassFromString(className)];
    if (!frameworkBundle) {
        NSAssert(!className, @"获取资源路径bundle时，获取framework的bundle为空");
        return nil;
    }
    NSURL *frameworkBundleUrl = [frameworkBundle URLForResource:bundleName withExtension:@"bundle"];
    if (!frameworkBundleUrl) {
        NSAssert(!className, @"获取资源路径bundle时，获取frameworkbundleURL为空");
        return nil;
    }
    return [self bundleWithURL:frameworkBundleUrl];
    
}

+ (instancetype)resourceBundleWithBundleName:(NSString *)bundleName{

    return [self resourceBundleWithClassName:NSStringFromClass(self) bundleName:bundleName];
    
}

+ (instancetype)resourceBundleWithFramework:(NSString *)frameworkName
                               bundleName:(NSString *)bundleName{
    
    NSURL *frameworksURL = [[NSBundle mainBundle] URLForResource:@"Frameworks" withExtension:nil];
    if (!frameworkName) {
        
         NSAssert(!frameworkName, @"获取资源路径bundle时，frameworkName为空");
    }
    NSURL* libFrameworkURL = [frameworksURL URLByAppendingPathComponent:frameworkName];
    libFrameworkURL = [libFrameworkURL URLByAppendingPathExtension:@"framework"];
    NSBundle *libFrameworkBundle = [NSBundle bundleWithURL:libFrameworkURL];
    if (!libFrameworkBundle) {
          NSAssert(!libFrameworkBundle, @"获取资源路径bundle时，获取framework的bundle为空");
    }
    NSURL* libResourceBundleUrl = [libFrameworkBundle URLForResource:bundleName withExtension:@"bundle"];
    
    return [self bundleWithURL:libResourceBundleUrl];
    
}

+ (instancetype)getFrameworkBundleWithClassName:(NSString *)className{
    
    if (!className) {
        NSAssert(!className, @"获取资源路径bundle时，类名为空");
        return nil;
    }
    NSBundle *frameworkBundle = [self bundleForClass:NSClassFromString(className)];
    
    return frameworkBundle;
    
}


+ (instancetype)getFrameworkBundleWithFramework:(NSString *)frameworkName{
    
    NSURL *frameworksURL = [[NSBundle mainBundle] URLForResource:@"Frameworks" withExtension:nil];
    if (!frameworkName) {
        
        NSAssert(!frameworkName, @"获取资源路径bundle时，frameworkName为空");
    }
    NSURL* libFrameworkURL = [frameworksURL URLByAppendingPathComponent:frameworkName];
    libFrameworkURL = [libFrameworkURL URLByAppendingPathExtension:@"framework"];
    NSBundle *libFrameworkBundle = [self bundleWithURL:libFrameworkURL];
    return libFrameworkBundle;
}

+ (instancetype)getMainBundleWithResourceBundle:(NSString *)bundleName{
    
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSURL *resourceUrl = [mainBundle URLForResource:bundleName withExtension:@"bundle"];
    return [self bundleWithURL:resourceUrl];
}

@end
```

#### UIImage+Resource.h

```swift
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Resource)

/**
通过图片名称，图片bundle所在framework的类名和图片所在bundle 来加载图片
 @param imageName 图片名称
 @param className 图片所在framework中任意一个类的名称
 @param bundleName 图片所在 bundle
 */

+ (UIImage *)imageNamed:(NSString *)imageName className:(NSString *)className bundleName:(NSString *)bundleName;

/**
 通过图片名称，图片所在framework的类名 此时图片直接位于framework bundle下
 @param imageName 图片名称
 @param className 图片所在framework中任意一个类的名称
 */

+ (UIImage *)imageNamed:(NSString *)imageName className:(NSString *)className;


/**
 通过图片名称，图片所在framework的类名 此时图片直接位于framework bundle下
 @param imageName 图片名称
 @param frameworkName 图片所在framework中任意一个类的名称
 
 */

+ (UIImage *)imageNamed:(NSString *)imageName frameworkName:(NSString *)frameworkName;

/**
 通过图片名称，图片bundle所在framework 和 图片所在的bundle 来加载图片
 
 @param imageName 图片名称
 @param frameworkName 框架名称
 @param bundleName bundle 名字
 
 */
+ (UIImage *)imageNamed:(NSString *)imageName framework:(NSString *)frameworkName bundleName:(NSString *)bundleName;

/**
 加载main bundle下的图片
 @param imageName 图片名称
 @param bundleName bundle名称
 */
+ (UIImage *)imageNamed:(NSString *)imageName bundleName:(NSString *)bundleName;

@end

NS_ASSUME_NONNULL_END
```

#### UIImage+Resource.m

```swift
#import "UIImage+Resource.h"
#import "NSBundle+Resource.h"

@implementation UIImage (Resource)

+ (UIImage *)imageNamed:(NSString *)imageName className:(NSString *)className bundleName:(NSString *)bundleName{
    
    NSBundle *bundle = [NSBundle resourceBundleWithClassName:className bundleName:bundleName];
    UIImage *image = [UIImage imageNamed:imageName inBundle:bundle compatibleWithTraitCollection:nil];
    
    return image;
}

+ (UIImage *)imageNamed:(NSString *)imageName framework:(NSString *)frameworkName bundleName:(NSString *)bundleName{
    NSBundle *bundle = [NSBundle resourceBundleWithFramework:frameworkName bundleName:bundleName];
    UIImage *image = [UIImage imageNamed:imageName inBundle:bundle compatibleWithTraitCollection:nil];
    return image;
}

+ (UIImage *)imageNamed:(NSString *)imageName className:(NSString *)className{
    NSBundle *bundle = [NSBundle getFrameworkBundleWithClassName:className];
    UIImage *image = [UIImage imageNamed:imageName inBundle:bundle compatibleWithTraitCollection:nil];
    return image;
    
}

+ (UIImage *)imageNamed:(NSString *)imageName frameworkName:(NSString *)frameworkName{
    NSBundle *bundle = [NSBundle getFrameworkBundleWithFramework:frameworkName];
    UIImage *image = [UIImage imageNamed:imageName inBundle:bundle compatibleWithTraitCollection:nil];
    return image;
    
    
}

+ (UIImage *)imageNamed:(NSString *)imageName bundleName:(NSString *)bundleName{
    
    if (!imageName || !bundleName) {
        NSAssert(!imageName || !bundleName, @"image name 或者 bundle name 为空");
        return nil;
    }
    NSBundle *bundle = [NSBundle getMainBundleWithResourceBundle:bundleName];
    UIImage *image = [UIImage imageNamed:imageName inBundle:bundle compatibleWithTraitCollection:nil];
    
    return image;
    
}

@end
```
