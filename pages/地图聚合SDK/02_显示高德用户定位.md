# 2.显示高德用户定位

### 六、显示高德用户定位

[显示定位蓝点](https://lbs.amap.com/api/ios-sdk/guide/create-map/location-map)

#### 第1步：地图协议增加显示用户定位属性
`......`省略部分代码
```swift
/// 地图协议
public protocol MapViewProtocol: NSObjectProtocol {
    ......
    /// 设定是否显示定位图层
    var showsUserLocation: Bool { get set }
}
/// 高德地图
class GaodeMapView: NSObject, MapViewProtocol {
	......
    /// 设定是否显示定位图层
    var showsUserLocation: Bool = false {
        didSet {
            mapView.showsUserLocation = showsUserLocation
        }
    }
}
/// 百度地图
class BaiduMapView: NSObject, MapViewProtocol {
	.......
    /// 设定是否显示定位图层
    var showsUserLocation: Bool = false {
        didSet {
            mapView.showsUserLocation = showsUserLocation
        }
    }
}
```
#### 第2步：测试代码
```swift
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        ......
        if let mapView = factory?.getMapView(frame: view.bounds) {
        	// 显示用户定位
            mapView.showsUserLocation = true
            view.addSubview(mapView.getView())
        }
    }
}
增加如上代码后，高德/百度都没有显示用户定位。
```
#### 发现问题1:

[MAMapKit] 要在iOS 11及以上版本使用定位服务, 需要在Info.plist中添加NSLocationAlwaysAndWhenInUseUsageDescription和NSLocationWhenInUseUsageDescription字段。

解决办法：info.plist新增：
```
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>CQMapSDK需要使用定位服务</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>CQMapSDK需要使用定位服务</string>
```

#### 发现问题2:

App Transport Security has blocked a cleartext HTTP (http://) resource load since it is insecure. Temporary exceptions can be configured via your app's Info.plist file.

解决办法：info.plist新增：
```
<key>NSAppTransportSecurity</key>
<dict>
	<key>NSAllowsArbitraryLoads</key>
	<true/>
</dict>
```

#### 发现问题3:

[MAMapKit] 要在iOS 11及以上版本使用后台定位服务, 需要实现mapViewRequireLocationAuth: 代理方法

解决办法：实现mapViewRequireLocationAuth

1.定义地图代理协议
```swift
/// 地图代理协议
public protocol MapViewDelegateProtocol: NSObjectProtocol {
    
}

public extension MapViewDelegateProtocol {
    
}
```

2.新增高德地图代理实现
```swift
import MAMapKit

/// 高德地图代理实现
class MAMapViewDelegateImpl: NSObject, MAMapViewDelegate {
    
    weak var delegate: MapViewDelegateProtocol?
    /**
     * @brief 当plist配置NSLocationAlwaysUsageDescription或者NSLocationAlwaysAndWhenInUseUsageDescription，并且[CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined，会调用代理的此方法。
     * 此方法实现调用后台权限API即可（ 该回调必须实现 [locationManager requestAlwaysAuthorization] ）; since 6.8.0
     * - Parameter locationManager:  地图的CLLocationManager。
     */
    func mapViewRequireLocationAuth(_ locationManager: CLLocationManager!) {
        locationManager.requestAlwaysAuthorization()
    }
}
```

3.高德地图实现增加代理
```swift
/// 高德地图
class GaodeMapView: NSObject, MapViewProtocol {

	......
    private var mapDelegate = MAMapViewDelegateImpl()
    ......
    /// 地图代理
    var delegate: MapViewDelegateProtocol? {
        didSet {
            if let delegate = delegate {
                mapDelegate.delegate = delegate
                mapView.delegate = mapDelegate
            }
        }
    }
    ......
}
```

4.测试用户定位显示
```swift
class ViewController: UIViewController {

    override func viewDidLoad() {
    	......
        if let mapView = factory?.getMapView(frame: view.bounds) {
            ......
            // 设置代理
            mapView.delegate = self
            ......
        }
    }
}
```
现在使用高德地图就可以正常显示用户定位啦！