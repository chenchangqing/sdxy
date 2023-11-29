# 3.如何显示百度用户定位

### 七、如何显示百度用户定位？

分析百度地图还是无法显示用户定位，经过查看百度Demo工程，必须完成以下步骤：

#### 第1步：初始化定位SDK,设置`showsUserLocation=true`
```swift
BMKLocationAuth.sharedInstance()?.checkPermision(withKey: appKey, authDelegate: self)
```

#### 第2步：打开用户定位，并且确保定位成功
```swift
//开启定位服务
locationManager.startUpdatingHeading()
locationManager.startUpdatingLocation()
```
#### 第3步：在定位代理中更新用户位置
```swift
//MARK:BMKLocationManagerDelegate
/**
 @brief 该方法为BMKLocationManager提供设备朝向的回调方法
 @param manager 提供该定位结果的BMKLocationManager类的实例
 @param heading 设备的朝向结果
 */
func bmkLocationManager(_ manager: BMKLocationManager, didUpdate heading: CLHeading?) {
    NSLog("用户方向更新")
    userLocation.heading = heading
    mapView.updateLocationData(userLocation)
}

/**
 @brief 连续定位回调函数
 @param manager 定位 BMKLocationManager 类
 @param location 定位结果，参考BMKLocation
 @param error 错误信息。
 */
func bmkLocationManager(_ manager: BMKLocationManager, didUpdate location: BMKLocation?, orError error: Error?) {
    if let _ = error?.localizedDescription {
        NSLog("locError:%@;", (error?.localizedDescription)!)
    }
    NSLog("用户定位更新")
    userLocation.location = location?.location
    //实现该方法，否则定位图标不出现
    mapView.updateLocationData(userLocation)
}
```
#### 第4步：在定位代理实现定位授权
```swift
func bmkLocationManager(_ manager: BMKLocationManager, doRequestAlwaysAuthorization locationManager: CLLocationManager) {
    locationManager.requestAlwaysAuthorization()
}
```

下面我们集成百度定位SDK，在验证上面的步骤是否可以正确显示百度定位？

### 八、集成百度定位

#### 第1步：这里使用Cocoapod的配置，参考[百度定位SDK-代码](https://github.com/jiangfangsheng/BMKLocationKit)，以下是CQMapSDK.podspec关键配置：
```ruby
s.static_framework = true
s.swift_version = '5.0'
s.ios.deployment_target = '9.0'

s.source_files = 'CQMapSDK/Classes/**/*',"framework/*.framework/Headers/*.h"
s.public_header_files = "framework/*.framework/Headers/*.h"
s.vendored_frameworks = "framework/*.framework"
s.frameworks = "CoreLocation", "Foundation", "UIKit", "SystemConfiguration", "AdSupport", "Security", "CoreTelephony"
s.libraries = "sqlite3.0","c++"
s.requires_arc = true
s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
```
增加了以上代码，执行`pod update`

#### 第2步：定义定位相关协议：LocationProtocol、LocationManagerProtocol、LocationManagerDelegateProtocol

定位成功，返回的定位数据协议：

```swift
/// 定位数据
public protocol LocationProtocol: NSObjectProtocol {

    /// 位置数据
    var location: CLLocation? { get }
    
    /// 初始化LocationProtocol实例
    /// - Parameter loc: CLLocation对象
    init(location loc: CLLocation?)
}
```

定位管理代理协议：

```swift
/// 地图定位管理代理协议
public protocol LocationManagerDelegateProtocol : NSObjectProtocol {

    /// 为了适配app store关于新的后台定位的审核机制（app store要求如果开发者只配置了使用期间定位，则代码中不能出现申请后台定位的逻辑），当开发者在plist配置NSLocationAlwaysUsageDescription或者NSLocationAlwaysAndWhenInUseUsageDescription时，需要在该delegate中调用后台定位api：[locationManager requestAlwaysAuthorization]。开发者如果只配置了NSLocationWhenInUseUsageDescription，且只有使用期间的定位需求，则无需在delegate中实现逻辑。
    /// - Parameters:
    ///   - manager: 定位 LocationManagerProtocol 实现类。
    ///   - locationManager: 系统 CLLocationManager 类 。
    func locationManager(_ manager: LocationManagerProtocol, doRequestAlwaysAuthorization locationManager: CLLocationManager)
    
    /// 当定位发生错误时，会调用代理的此方法。
    /// - Parameters:
    ///   - manager: 定位 LocationManagerProtocol 实现类。
    ///   - error: 返回的错误，参考 CLError
    func locationManager(_ manager: LocationManagerProtocol, didFailWithError error: Error?)
    
    /// 连续定位回调函数。
    /// - Parameters:
    ///   - manager: 定位 LocationManagerProtocol 实现类。
    ///   - location:  定位结果
    ///   - error: 错误信息。
    func locationManager(_ manager: LocationManagerProtocol, didUpdate location: LocationProtocol?, orError error: Error?)
    
    /// 提供设备朝向的回调方法。
    /// - Parameters:
    ///   - manager: 定位 LocationManagerProtocol 实现类。
    ///   - heading: 设备的朝向结果
    func locationManager(_ manager: LocationManagerProtocol, didUpdate heading: CLHeading?)
}

extension LocationManagerDelegateProtocol {
    
    func locationManager(_ manager: LocationManagerProtocol, doRequestAlwaysAuthorization locationManager: CLLocationManager) {
        
    }
    
    func locationManager(_ manager: LocationManagerProtocol, didFailWithError error: Error?){
        
    }
    
    func locationManager(_ manager: LocationManagerProtocol, didUpdate location: LocationProtocol?, orError error: Error?){
        
    }
    
    func locationManager(_ manager: LocationManagerProtocol, didUpdate heading: CLHeading?){
        
    }
}
```

定位管理协议：

```swift
/// 地图定位管理协议
public protocol LocationManagerProtocol: NSObjectProtocol {
    
    /// 实现了 LocationManagerDelegateProtocol 协议的类指针。
    var delegate: LocationManagerDelegateProtocol? { get set }
    
    /// 开始连续定位。调用此方法会cancel掉所有的单次定位请求。
    func startUpdatingLocation()

    
    /// 停止连续定位。调用此方法会cancel掉所有的单次定位请求，可以用来取消单次定位。
    func stopUpdatingLocation()

    
    /// 开始设备朝向事件回调。
    func startUpdatingHeading()

    
    /// r停止设备朝向事件回调。
    func stopUpdatingHeading()
}
```

#### 第3步：百度定位SDK实现类：BaiduLocation、BaiduLocationManager、BMKLocationManagerDelegateImpl

百度定位数据实现：
```swift
/// 百度定位数据
class BaiduLocation: NSObject, LocationProtocol {
    
    /// 位置数据
    private(set) var location: CLLocation?
    
    /// 初始化LocationProtocol实例
    /// - Parameter loc: CLLocation对象
    required init(location loc: CLLocation?) {
        super.init()
        location = loc
    }

}
```
百度定位管理代理实现：
```swift
/// 百度地图定位管理代理实现类
class BMKLocationManagerDelegateImpl: NSObject, BMKLocationManagerDelegate {
    
    weak var delegate: LocationManagerDelegateProtocol?
    private var managerProtocol: LocationManagerProtocol!
    
    init(managerProtocol: LocationManagerProtocol) {
        super.init()
        self.managerProtocol = managerProtocol
    }
    
    func bmkLocationManager(_ manager: BMKLocationManager, doRequestAlwaysAuthorization locationManager: CLLocationManager) {
        delegate?.locationManager(managerProtocol, doRequestAlwaysAuthorization: locationManager)
    }
    
    func bmkLocationManager(_ manager: BMKLocationManager, didFailWithError error: Error?) {
        delegate?.locationManager(managerProtocol, didFailWithError: error)
    }
    
    func bmkLocationManager(_ manager: BMKLocationManager, didUpdate location: BMKLocation?, orError error: Error?) {
        let bmkLocation = BaiduLocation(location: location?.location)
        delegate?.locationManager(managerProtocol, didUpdate: bmkLocation, orError: error)
    }
    
    func bmkLocationManager(_ manager: BMKLocationManager, didUpdate heading: CLHeading?) {
        delegate?.locationManager(managerProtocol, didUpdate: heading)
    }
}
```
百度定位管理：
```swift
/// 百度地图定位管理
class BaiduLocationManager: NSObject, LocationManagerProtocol {
    
    private lazy var delegateImpl: BMKLocationManagerDelegateImpl = {
        BMKLocationManagerDelegateImpl(managerProtocol: self)
    }()
    private lazy var locationManager: BMKLocationManager = {
        //初始化BMKLocationManager的实例
        let manager = BMKLocationManager()
        //设置定位管理类实例的代理
        manager.delegate = delegateImpl
        //设定定位坐标系类型，默认为 BMKLocationCoordinateTypeGCJ02
        manager.coordinateType = BMKLocationCoordinateType.BMK09LL
        //设定定位精度，默认为 kCLLocationAccuracyBest
        manager.desiredAccuracy = kCLLocationAccuracyBest
        //设定定位类型，默认为 CLActivityTypeAutomotiveNavigation
        manager.activityType = CLActivityType.automotiveNavigation
        //指定定位是否会被系统自动暂停，默认为NO
        manager.pausesLocationUpdatesAutomatically = false
        /**
         是否允许后台定位，默认为NO。只在iOS 9.0及之后起作用。
         设置为YES的时候必须保证 Background Modes 中的 Location updates 处于选中状态，否则会抛出异常。
         由于iOS系统限制，需要在定位未开始之前或定位停止之后，修改该属性的值才会有效果。
         */
        manager.allowsBackgroundLocationUpdates = false
        /**
         指定单次定位超时时间,默认为10s，最小值是2s。注意单次定位请求前设置。
         注意: 单次定位超时时间从确定了定位权限(非kCLAuthorizationStatusNotDetermined状态)
         后开始计算。
         */
        manager.locationTimeout = 10
        return manager
    }()

    /// 实现了 LocationManagerDelegateProtocol 协议的类指针。
    weak var delegate: LocationManagerDelegateProtocol? {
        didSet {
            delegateImpl.delegate = delegate
        }
    }
    
    /// 开始连续定位。调用此方法会cancel掉所有的单次定位请求。
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }

    /// 停止连续定位。调用此方法会cancel掉所有的单次定位请求，可以用来取消单次定位。
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }

    /// 开始设备朝向事件回调。
    func startUpdatingHeading() {
        locationManager.startUpdatingHeading()
    }

    /// r停止设备朝向事件回调。
    func stopUpdatingHeading() {
        locationManager.stopUpdatingHeading()
    }
}
```

#### 第4步：高德定位SDK实现类：GaodeLocation、GaodeLocationManager、AMapLocationManagerDelegateImpl，后续再做具体方法实现。

```swift
/// 高德定位数据
class GaodeLocation: NSObject, LocationProtocol {
    
    /// 位置数据
    private(set) var location: CLLocation?
    
    /// 初始化LocationProtocol实例
    /// - Parameter loc: CLLocation对象
    required init(location loc: CLLocation?) {
        super.init()
        location = loc
    }

}
/// 高德地图定位管理代理实现类
class AMapLocationManagerDelegateImpl: NSObject {
    
    weak var delegate: LocationManagerDelegateProtocol?
    private var managerProtocol: LocationManagerProtocol!
    
    init(managerProtocol: LocationManagerProtocol) {
        super.init()
        self.managerProtocol = managerProtocol
    }

}
/// 高德地图定位管理
class GaodeLocationManager: NSObject, LocationManagerProtocol {
    
    private lazy var delegateImpl: BMKLocationManagerDelegateImpl = {
        BMKLocationManagerDelegateImpl(managerProtocol: self)
    }()

    /// 实现了 LocationManagerDelegateProtocol 协议的类指针。
    weak var delegate: LocationManagerDelegateProtocol? {
        didSet {
            delegateImpl.delegate = delegate
        }
    }
    
    /// 开始连续定位。调用此方法会cancel掉所有的单次定位请求。
    func startUpdatingLocation() {
        
    }

    /// 停止连续定位。调用此方法会cancel掉所有的单次定位请求，可以用来取消单次定位。
    func stopUpdatingLocation() {
        
    }

    /// 开始设备朝向事件回调。
    func startUpdatingHeading() {
        
    }

    /// r停止设备朝向事件回调。
    func stopUpdatingHeading() {
        
    }
}
```
#### 第5步：新增及修改地图相关协议

1.新增UserLocationProtocol
```swift
/// 用户定位协议
public protocol UserLocationProtocol: NSObjectProtocol {
    
    /// 位置更新状态，如果正在更新位置信息，则该值为YES
    var updating: Bool { get set }
    
    /// 位置信息，尚未定位成功，则该值为nil
    var location: CLLocation? { get set }
    
    /// heading信息，尚未定位成功，则该值为nil
    var heading: CLHeading? { get set }
    
    /// 定位标注点要显示的标题信息
    var title: String? { get set }
    
    /// 定位标注点要显示的子标题信息
    var subtitle: String? { get set }
}
```
2.修改MapViewProtocol
```swift
/// 地图协议
public protocol MapViewProtocol: NSObjectProtocol {
	......
    
    /// 设定是否显示定位图层
    var showsUserLocation: Bool { get set }

}
```
3.修改MapViewDelegateProtocol
```swift
/// 地图代理协议
public protocol MapViewDelegateProtocol: NSObjectProtocol {
    
    /// 当plist配置NSLocationAlwaysUsageDescription或者NSLocationAlwaysAndWhenInUseUsageDescription，并且[CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined，会调用代理的此方法。此方法实现调用后台权限API即可（ 该回调必须实现 [locationManager requestAlwaysAuthorization] ）; since 6.8.0
    /// - Parameter locationManager: 地图的CLLocationManager。
    func mapViewRequireLocationAuth(_ mapView: MapViewProtocol, locationManager: CLLocationManager)
}

public extension MapViewDelegateProtocol {
    func mapViewRequireLocationAuth(_ mapView: MapViewProtocol, locationManager: CLLocationManager) {
        
    }
}
```
#### 第6步：新增及修改百度地图相关协议实现
```swift
/// 百度用户定位
class BaiduUserLocation: NSObject, UserLocationProtocol {
    
    /// 位置更新状态，如果正在更新位置信息，则该值为YES
    var updating: Bool = false
    
    /// 位置信息，尚未定位成功，则该值为nil
    var location: CLLocation?
    
    /// heading信息，尚未定位成功，则该值为nil
    var heading: CLHeading?
    
    /// 定位标注点要显示的标题信息
    var title: String?
    
    /// 定位标注点要显示的子标题信息
    var subtitle: String?
}
/// 百度地图代理实现
class BMKMapViewDelegateImpl: NSObject, BMKMapViewDelegate {
    
    weak var delegate: MapViewDelegateProtocol?
    private weak var mapViewProtocol: MapViewProtocol!
    
    init(mapViewProtocol: MapViewProtocol) {
        super.init()
        self.mapViewProtocol = mapViewProtocol
    }

}
/// 百度地图
class BaiduMapView: NSObject, MapViewProtocol {

	.......
    private lazy var mapDelegate: BMKMapViewDelegateImpl = {
        BMKMapViewDelegateImpl(mapViewProtocol: self)
    }()
    
    /// 初始化
    /// - Parameter frame:
    required init(frame: CGRect) {
        super.init()
        mapView = BMKMapView(frame: frame)
        mapView.delegate = mapDelegate
    }
    ......
    
    /// 地图代理
    var delegate: MapViewDelegateProtocol? {
        didSet {
            if let delegate = delegate {
                mapDelegate.delegate = delegate
            }
        }
    }

    ......
    
    /// 动态更新我的位置数据
    /// - Parameter userLocation: 定位数据
    func updateLocationData(_ userLocation: UserLocationProtocol) {
        let bmkUserLoc = BMKUserLocation()
        bmkUserLoc.location = userLocation.location
        mapView.updateLocationData(bmkUserLoc)
    }
}
```
#### 第7步：新增及修改高德地图相关协议实现
```swift
/// 高德用户定位
class GaodeUserLocation: NSObject, UserLocationProtocol {
    
    /// 位置更新状态，如果正在更新位置信息，则该值为YES
    var updating: Bool = false
    
    /// 位置信息，尚未定位成功，则该值为nil
    var location: CLLocation?
    
    /// heading信息，尚未定位成功，则该值为nil
    var heading: CLHeading?
    
    /// 定位标注点要显示的标题信息
    var title: String?
    
    /// 定位标注点要显示的子标题信息
    var subtitle: String?
}
/// 高德地图代理实现
class MAMapViewDelegateImpl: NSObject, MAMapViewDelegate {
    
    weak var delegate: MapViewDelegateProtocol?
    private weak var mapViewProtocol: MapViewProtocol!
    
    init(mapViewProtocol: MapViewProtocol) {
        super.init()
        self.mapViewProtocol = mapViewProtocol
    }
    
    /// 当plist配置NSLocationAlwaysUsageDescription或者NSLocationAlwaysAndWhenInUseUsageDescription，并且[CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined，会调用代理的此方法。此方法实现调用后台权限API即可（ 该回调必须实现 [locationManager requestAlwaysAuthorization] ）; since 6.8.0
    /// - Parameter locationManager: 地图的CLLocationManager。
    func mapViewRequireLocationAuth(_ locationManager: CLLocationManager!) {
        delegate?.mapViewRequireLocationAuth(mapViewProtocol, locationManager: locationManager)
    }
}
/// 高德地图
class GaodeMapView: NSObject, MapViewProtocol {

	......
    private lazy var mapDelegate: MAMapViewDelegateImpl = {
        MAMapViewDelegateImpl(mapViewProtocol: self)
    }()
    
    /// 初始化
    /// - Parameter frame:
    required init(frame: CGRect) {
        super.init()
        mapView = MAMapView(frame: frame)
        mapView.delegate = mapDelegate
    }
    
    ......
    
    /// 地图代理
    var delegate: MapViewDelegateProtocol? {
        didSet {
            if let delegate = delegate {
                mapDelegate.delegate = delegate
            }
        }
    }
    
    ......
    
    /// 动态更新我的位置数据
    /// - Parameter userLocation: 定位数据
    func updateLocationData(_ userLocation: UserLocationProtocol) {
        
    }
}
```
#### 第8步：修改工厂协议及实现
```swift
/// 地图工厂标准
public protocol MapFactoryProtocol: NSObjectProtocol {
	......
    
    /// 获取定位管理对象
    func getLocationManager() -> LocationManagerProtocol
    
    /// 获取用户定位数据
    func getUserLocation() -> UserLocationProtocol
}
/// 高德地图工厂
class BaiduMapFactory: NSObject, MapFactoryProtocol {
	......
    
    /// 初始化
    /// - Parameter appKey: 第三方地图AppKey
    required init(appKey: String) {
        super.init()
        BMKLocationAuth.sharedInstance()?.checkPermision(withKey: appKey, authDelegate: self)
        ......
    }
    
    ......
    
    /// 获取定位管理对象
    func getLocationManager() -> LocationManagerProtocol {
        return BaiduLocationManager()
    }
    
    /// 获取用户定位数据
    func getUserLocation() -> UserLocationProtocol {
        return BaiduUserLocation()
    }
}
/// 高德地图工厂
class GaodeMapFactory: NSObject, MapFactoryProtocol {
    ......
    
    /// 获取定位管理对象
    func getLocationManager() -> LocationManagerProtocol {
        return GaodeLocationManager()
    }
    
    /// 获取用户定位数据
    func getUserLocation() -> UserLocationProtocol {
        return GaodeUserLocation()
    }
}
```
#### 第9步：验证百度地图显示定位
```swift
class ViewController: UIViewController {
    
    /// 地图实例
    private var mapView: MapViewProtocol!
    /// 用户定位实例
    private var userLocation: UserLocationProtocol!
    /// 定位管理实例
    private var locationManager: LocationManagerProtocol!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 获取地图工厂
        let engine = MapEngine()
        let factory = engine.getFactory()!
        
        // 开启定位
        userLocation = factory.getUserLocation()
        locationManager = factory.getLocationManager()
        locationManager.delegate = self
        locationManager.startUpdatingHeading()
        locationManager.startUpdatingLocation()
        
        // 显示地图
        mapView = factory.getMapView(frame: view.bounds)
        // 设置代理
        mapView.delegate = self
        // 显示用户定位(放在设置代理之后，确保可以调用locationManager.requestAlwaysAuthorization())
        mapView.showsUserLocation = true
        view.addSubview(mapView.getView())
    }
    ......
}

extension ViewController: MapViewDelegateProtocol {
    
    /// 当plist配置NSLocationAlwaysUsageDescription或者NSLocationAlwaysAndWhenInUseUsageDescription，并且[CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined，会调用代理的此方法。此方法实现调用后台权限API即可（ 该回调必须实现 [locationManager requestAlwaysAuthorization] ）; since 6.8.0
    /// - Parameter locationManager: 地图的CLLocationManager。
    func mapViewRequireLocationAuth(_ mapView: MapViewProtocol, locationManager: CLLocationManager) {
        locationManager.requestAlwaysAuthorization()
    }
}

extension ViewController: LocationManagerDelegateProtocol {
    
    
    /// 为了适配app store关于新的后台定位的审核机制（app store要求如果开发者只配置了使用期间定位，则代码中不能出现申请后台定位的逻辑），当开发者在plist配置NSLocationAlwaysUsageDescription或者NSLocationAlwaysAndWhenInUseUsageDescription时，需要在该delegate中调用后台定位api：[locationManager requestAlwaysAuthorization]。开发者如果只配置了NSLocationWhenInUseUsageDescription，且只有使用期间的定位需求，则无需在delegate中实现逻辑。
    /// - Parameters:
    ///   - manager: 定位 LocationManagerProtocol 实现类。
    ///   - locationManager: 系统 CLLocationManager 类 。
    func locationManager(_ manager: LocationManagerProtocol, doRequestAlwaysAuthorization locationManager: CLLocationManager) {
        locationManager.requestAlwaysAuthorization()
    }
    
    /// 当定位发生错误时，会调用代理的此方法。
    /// - Parameters:
    ///   - manager: 定位 LocationManagerProtocol 实现类。
    ///   - error: 返回的错误，参考 CLError
    func locationManager(_ manager: LocationManagerProtocol, didFailWithError error: Error?) {
        NSLog("定位失败")
    }
    
    /// 连续定位回调函数。
    /// - Parameters:
    ///   - manager: 定位 LocationManagerProtocol 实现类。
    ///   - location:  定位结果
    ///   - error: 错误信息。
    func locationManager(_ manager: LocationManagerProtocol, didUpdate location: LocationProtocol?, orError error: Error?) {
        
        if let _ = error?.localizedDescription {
            print("locError:(error?.localizedDescription)!")
        }
        print("用户定位更新")
        userLocation.location = location?.location
        //实现该方法，否则定位图标不出现
        mapView.updateLocationData(userLocation)
    }
    
    /// 提供设备朝向的回调方法。
    /// - Parameters:
    ///   - manager: 定位 LocationManagerProtocol 实现类。
    ///   - heading: 设备的朝向结果
    func locationManager(_ manager: LocationManagerProtocol, didUpdate heading: CLHeading?) {
        print(("用户方向更新"))
        userLocation.heading = heading
        mapView.updateLocationData(userLocation)
    }
}
```
这样就可以成功显示百度定位啦！