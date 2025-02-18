# 1.地图显示

### 参考链接

* [百度地图SDK](https://lbsyun.baidu.com/index.php?title=iossdk)
* [百度定位SDK](https://lbsyun.baidu.com/index.php?title=ios-locsdk)
* [高德地图SDK](https://lbs.amap.com/api/ios-sdk/summary)
* [高德定位SDK](https://lbs.amap.com/api/ios-location-sdk/summary/)
* [高德地图Doc](https://a.amap.com/lbs/static/unzip/iOS_Navi_Doc/index.html)
* [用高德地图API 通过详细地址获得经纬度](https://www.itdaan.com/blog/2015/04/14/7a2cd7adc01d5e23714111f39840e5ac.html)
* [Web服务API简介](https://lbs.amap.com/api/webservice/summary)
* [IOS高德3D地图画多边形，以及判断某一经纬度是否在该多边形内](https://www.jianshu.com/p/fb1177cac1ec)

### 一、集成百度地图

第1步：[注册和获取密钥](https://lbsyun.baidu.com/index.php?title=iossdk/guide/create-project/ak)

第2步：[CocoaPods 自动配置](https://lbsyun.baidu.com/index.php?title=iossdk/guide/create-project/cocoapods)，在.podspec文件中增加依赖
```
s.dependency 'BaiduMapKit', '6.3.0'
```

### 二、集成高德地图

第1步：[获取Key](https://lbs.amap.com/api/ios-sdk/guide/create-project/get-key)

第2步：[CocoaPods 自动配置](https://lbs.amap.com/api/ios-sdk/guide/create-project/cocoapods)，在.podspec文件中增加依赖
```
s.dependency 'AMap3DMap', '7.9.0'
```

### 三、抽象工厂

特点->比工厂方法产品种类多。

| |抽象产品|具体产品|抽象工厂|具体工厂|
|:-|:-|:-|:-|:-|
|简单工厂|-|1|-|N|
|工厂方法|1|N|1|N|
|抽象工厂|N|N|1|N|


### 四、地图SDK角色分析

抽象产品：MapViewProtocol、MapLocationProtocol

具体产品：BaiduMapView、GaodeMapView、BaiduMapLocation、GaodeMapLocation

抽象工厂：MapFactoryProtocol

具体工厂：BaiduMapFactory、GaodeMapFactory

地图引擎：MapEngine

### 五、显示地图

#### 第1步：抽象地图协议
```swift
/// 地图协议
public protocol MapViewProtocol: NSObjectProtocol {
    /// 初始化
    /// - Parameter frame:
    init(frame: CGRect)
    /// 获取地图
    func getView() -> UIView
}
```
#### 第2步：定义具体地图

##### 高德地图
```swift
import MAMapKit

/// 高德地图
class GaodeMapView: NSObject, MapViewProtocol {

    private var mapView: MAMapView!
    /// 初始化
    /// - Parameter frame:
    required init(frame: CGRect) {
        super.init()
        mapView = MAMapView(frame: frame)
    }
    /// 获取地图
    func getView() -> UIView {
        return mapView
    }
}
```
##### 百度地图
```swift
import BaiduMapAPI_Map

/// 百度地图
class BaiduMapView: NSObject, MapViewProtocol {

    private var mapView: BMKMapView!
    /// 初始化
    /// - Parameter frame:
    required init(frame: CGRect) {
        super.init()
        mapView = BMKMapView(frame: frame)
    }
    /// 获取地图
    func getView() -> UIView {
        return mapView
    }
}
```

#### 第3步：抽象工厂
```swift
/// 地图工厂标准
public protocol MapFactoryProtocol: NSObjectProtocol {
    /// 初始化
    /// - Parameter appKey: 第三方地图AppKey
    init(appKey: String)
    /// 获取地图
    /// - Parameter frame: 
    func getMapView(frame: CGRect) -> MapViewProtocol
}
```
#### 第4步：定义具体地图工厂
##### 高德地图工厂
```swift
import MAMapKit

/// 高德地图工厂
class GaodeMapFactory: NSObject, MapFactoryProtocol {
    /// 初始化
    /// - Parameter appKey: 第三方地图AppKey
    required init(appKey: String) {
        super.init()
        AMapServices.shared()?.apiKey = appKey
    }
    /// 获取地图
    /// - Parameter frame:
    func getMapView(frame: CGRect) -> MapViewProtocol {
        return GaodeMapView(frame: frame)
    }
}
```
##### 百度地图工厂
```swift
import BaiduMapAPI_Map

/// 高德地图工厂
class BaiduMapFactory: NSObject, MapFactoryProtocol {
    private let mapManager = BMKMapManager()
    /// 初始化
    /// - Parameter appKey: 第三方地图AppKey
    required init(appKey: String) {
        super.init()
        let result = mapManager.start(appKey, generalDelegate: self)
        if !result {
            print("manager start failed!!!")
        }
    }
    /// 获取地图
    /// - Parameter frame:
    func getMapView(frame: CGRect) -> MapViewProtocol {
        return BaiduMapView(frame: frame)
    }
}
```
##### 百度地图工厂需要实现下创建协议
```swift
extension BaiduMapFactory: BMKGeneralDelegate {
    
    func onGetNetworkState(_ iError: Int32) {
        if iError == 0 {
            print("联网成功")
        } else {
            print("onGetNetworkState:\(iError)")
        }
    }
    
    func onGetPermissionState(_ iError: Int32) {
        if iError == 0 {
            print("授权成功")
        } else {
            print("onGetPermissionState:\(iError)")
        }
    }
}
```
#### 第5步：定义地图引擎

通过读取工厂配置，获取激活的地图工厂。

注意：`CQConfigManager`可以读取config.xml,获取当前激活的地图工厂，这样可以不修改代码，无缝切换百度/高德地图。
```swift
/// 地图引擎
public class MapEngine: NSObject {
    
    /// 根据配置获取地图工厂
    /// - Returns: 地图工厂
    public func getFactory() -> MapFactoryProtocol? {
        let mapPlatform = CQConfigManager.shared.config.mapPlatform
        if let factoryName = mapPlatform?.factoryName, let appKey = mapPlatform?.appKey {
            // 百度地图工厂
            if factoryName == "BaiduMapFactory" {
                return BaiduMapFactory(appKey: appKey)
            }
            // 高德地图工厂
            if factoryName == "GaodeMapFactory" {
                return GaodeMapFactory(appKey: appKey)
            }
        }
        return nil
    }
}
```
#### 第6步：显示地图
注意：`CQMapSDK`是地图SDK，包含以上的源代码，而ViewController则是Demo工程的页面。
```swift
import CQMapSDK

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // 显示地图
        let engine = MapEngine()
        let factory = engine.getFactory()
        if let mapView = factory?.getMapView(frame: view.bounds) {
            view.addSubview(mapView.getView())
        }
    }
}
```