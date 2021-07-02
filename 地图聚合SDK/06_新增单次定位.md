# 6.新增单次定位

### 十一、新增单次定位

#### 第1步：定义定位回调
```
/// 单次定位回调
public typealias LocatingCompletionBlock = (LocationProtocol?, Error?) -> Void
```

#### 第2步：修改定位管理协议

```swift
/// 地图定位管理协议
public protocol LocationManagerProtocol: NSObjectProtocol {

    ......
    /// - Parameters:
    ///   - withReGeocode: 是否带有逆地理信息(获取逆地理信息需要联网)
    ///   - withNetworkState: 是否带有移动热点识别状态(需要联网)
    ///   - completionBlock: 单次定位完成后的Block
    ///   - return: 是否成功添加单次定位Request
    func requestLocation(withReGeocode code: Bool, withNetworkState state: Bool, completionBlock: @escaping LocatingCompletionBlock) -> Bool
}
```

#### 第3步：增加百度地图实现

```swift
/// 百度地图定位管理
class BaiduLocationManager: NSObject, LocationManagerProtocol {
    ......
    /// - Parameters:
    ///   - withReGeocode: 是否带有逆地理信息(获取逆地理信息需要联网)
    ///   - withNetworkState: 是否带有移动热点识别状态(需要联网)
    ///   - completionBlock: 单次定位完成后的Block
    ///   - return: 是否成功添加单次定位Request
    func requestLocation(withReGeocode code: Bool, withNetworkState state: Bool, completionBlock: @escaping LocatingCompletionBlock) -> Bool {
        
        let block: BMKLocatingCompletionBlock = { (bmkLocation, state, error) -> Void in
            let location = BaiduLocation(location: bmkLocation?.location)
            completionBlock(location, error)
        }
        return locationManager.requestLocation(withReGeocode: code, withNetworkState: state, completionBlock: block)
    }
}
```
### 十二、新增地图更多属性

#### 第1步：地图协议修改
```swift
/// 地图协议
public protocol MapViewProtocol: NSObjectProtocol {

    ......
    
    /// 当前地图的中心点，改变该值时，地图的比例尺级别不会发生变化
    var centerCoordinate: CLLocationCoordinate2D? { get set }

    /// 定位用户位置的模式
    var userTrackingMode: UserTrackingMode { get set }
    
    /// 动态更新我的位置数据
    /// - Parameter userLocation: 定位数据
    func updateLocationData(_ userLocation: UserLocationProtocol?)
}
```

#### 第2步：更新地图实现

##### 高德地图
```swift
/// 高德地图
class GaodeMapView: NSObject, MapViewProtocol {
    ......
    /// 当前地图的中心点，改变该值时，地图的比例尺级别不会发生变化
    var centerCoordinate: CLLocationCoordinate2D? {
        didSet {
            if let centerCoordinate = centerCoordinate {
                mapView.centerCoordinate = centerCoordinate
            }
        }
    }
    
    /// 定位用户位置的模式
    var userTrackingMode: UserTrackingMode = .none {
        didSet {
            switch userTrackingMode {
            case .none:/// 普通定位模式
                mapView.userTrackingMode = .none
                break
            case .heading:/// 定位方向模式
                mapView.userTrackingMode = .none
                break
            case .follow:/// 定位跟随模式
                mapView.userTrackingMode = .follow
                break
            case .followWithHeading:/// 定位罗盘模式
                mapView.userTrackingMode = .followWithHeading
                break
            }
        }
    }
    
    /// 动态更新我的位置数据
    /// - Parameter userLocation: 定位数据
    func updateLocationData(_ userLocation: UserLocationProtocol?) {
        
    }
}
```

##### 百度地图
```swift
/// 百度地图
class BaiduMapView: NSObject, MapViewProtocol {

    ......
    /// 当前地图的中心点，改变该值时，地图的比例尺级别不会发生变化
    var centerCoordinate: CLLocationCoordinate2D? {
        didSet {
            if let centerCoordinate = centerCoordinate {
                mapView.centerCoordinate = centerCoordinate
            }
        }
    }
    
    /// 定位用户位置的模式
    var userTrackingMode: UserTrackingMode = .none {
        didSet {
            switch userTrackingMode {
            case .none:/// 普通定位模式
                mapView.userTrackingMode = BMKUserTrackingModeNone
                break
            case .heading:/// 定位方向模式
                mapView.userTrackingMode = BMKUserTrackingModeHeading
                break
            case .follow:/// 定位跟随模式
                mapView.userTrackingMode = BMKUserTrackingModeFollow
                break
            case .followWithHeading:/// 定位罗盘模式
                mapView.userTrackingMode = BMKUserTrackingModeFollowWithHeading
                break
            }
        }
    }
    
    /// 动态更新我的位置数据
    /// - Parameter userLocation: 定位数据
    func updateLocationData(_ userLocation: UserLocationProtocol?) {
        guard let userLocation = userLocation else {
            return
        }
        let bmkUserLoc = BMKUserLocation()
        bmkUserLoc.location = userLocation.location
        mapView.updateLocationData(bmkUserLoc)
    }
}
```

#### 第3步：测试

单次定位完成设置定位为地图中心
```swift
/// 单次定位
private func singleRequestLocation() {
    
    _ = locationManager.requestLocation(withReGeocode: true, withNetworkState: true) {[weak self] (location, error) in
        if let error = error {
            print("单次定位失败：", error.localizedDescription)
        } else {
            let latitude = location?.location?.coordinate.latitude ?? 0
            let longitude  = location?.location?.coordinate.longitude ?? 0
            print("单次定位成功：altitude:\(latitude),longitude:\(longitude)")
            self?.userLocation.location = location?.location
            // 实现该方法，否则定位图标不出现
            if let userLocation = self?.userLocation {
                self?.mapView.updateLocationData(userLocation)
            }
            // 设置中心点
            self?.mapView.centerCoordinate = location?.location?.coordinate
        }
    }
}
```

#### 第4步：增加高德地图实现

注意：高德地图要实现单次定位，需要保证"Background Modes"中的"Location updates"处于选中状态。

```swift
/// 高德地图定位管理
class GaodeLocationManager: NSObject, LocationManagerProtocol {
    ......
    /// - Parameters:
    ///   - withReGeocode: 是否带有逆地理信息(获取逆地理信息需要联网)
    ///   - withNetworkState: 是否带有移动热点识别状态(需要联网)
    ///   - completionBlock: 单次定位完成后的Block
    ///   - return: 是否成功添加单次定位Request
    func requestLocation(withReGeocode code: Bool, withNetworkState state: Bool, completionBlock: @escaping LocatingCompletionBlock) -> Bool {
        let block: AMapLocatingCompletionBlock = { (amapLocation, regeocode, error) -> Void in
            let location = GaodeLocation(location: amapLocation)
            completionBlock(location, error)
        }
        return locationManager.requestLocation(withReGeocode: code, completionBlock: block)
    }
}

```