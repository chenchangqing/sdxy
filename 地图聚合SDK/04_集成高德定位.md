# 4.集成高德定位

### 九、集成高德定位

#### 第1步：修改CQMapSDK.podspec

新增依赖`s.dependency 'AMapLocation', '2.6.8'`,执行`pod update`

#### 第2步：修改高德定位实现
```swift
import AMapLocationKit

/// 高德地图定位管理代理实现类
class AMapLocationManagerDelegateImpl: NSObject, AMapLocationManagerDelegate {
    
    weak var delegate: LocationManagerDelegateProtocol?
    private var managerProtocol: LocationManagerProtocol!
    
    init(managerProtocol: LocationManagerProtocol) {
        super.init()
        self.managerProtocol = managerProtocol
    }
    
    func amapLocationManager(_ manager: AMapLocationManager!, didFailWithError error: Error!) {
        delegate?.locationManager(managerProtocol, didFailWithError: error)
    }
    
    func amapLocationManager(_ manager: AMapLocationManager!, didUpdate location: CLLocation!) {
        let amapLocation = GaodeLocation(location: location)
        delegate?.locationManager(managerProtocol, didUpdate: amapLocation, orError: nil)
    }
    
    func amapLocationManager(_ manager: AMapLocationManager!, didUpdate newHeading: CLHeading!) {
        delegate?.locationManager(managerProtocol, didUpdate: newHeading)
    }

}
```
#### 第3步：更新定位管理
```swift

import AMapLocationKit

/// 高德地图定位管理
class GaodeLocationManager: NSObject, LocationManagerProtocol {
    
    private lazy var delegateImpl: AMapLocationManagerDelegateImpl = {
        AMapLocationManagerDelegateImpl(managerProtocol: self)
    }()
    
    private lazy var locationManager: AMapLocationManager = {
        //初始化BMKLocationManager的实例
        let manager = AMapLocationManager()
        //设置定位管理类实例的代理
        manager.delegate = delegateImpl
        //设定定位坐标系类型，默认为 BMKLocationCoordinateTypeGCJ02
        //manager.coordinateType = BMKLocationCoordinateType.BMK09LL
        //设定定位精度，默认为 kCLLocationAccuracyBest
        manager.desiredAccuracy = kCLLocationAccuracyBest
        //设定定位类型，默认为 CLActivityTypeAutomotiveNavigation
        //manager.activityType = CLActivityType.automotiveNavigation
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