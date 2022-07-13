# 5.新增定位属性

### 十、新增定位属性

#### 第1步：修改定位管理协议
```swift
/// 地图定位管理协议
public protocol LocationManagerProtocol: NSObjectProtocol {
    
    ///设定期望的定位精度。单位米，默认为 kCLLocationAccuracyBest。定位服务会尽可能去获取满足desiredAccuracy的定位结果，但不保证一定会得到满足期望的结果。
    ///注意：设置为kCLLocationAccuracyBest或kCLLocationAccuracyBestForNavigation时，单次定位会在达到locationTimeout设定的时间后，将时间内获取到的最高精度的定位结果返回。
    ///⚠️ 当iOS14及以上版本，模糊定位权限下可能拿不到设置精度的经纬度
    var desiredAccuracy: CLLocationAccuracy { get set }
    
    ///设定定位的最小更新距离。单位米，默认为 kCLDistanceFilterNone，表示只要检测到设备位置发生变化就会更新位置信息。
    var distanceFilter: CLLocationDistance { get set }
    
    ///指定定位是否会被系统自动暂停。默认为NO。
    var pausesLocationUpdatesAutomatically: Bool { get set }
    
    ///是否允许后台定位。默认为NO。只在iOS 9.0及之后起作用。设置为YES的时候必须保证 Background Modes 中的 Location updates 处于选中状态，否则会抛出异常。由于iOS系统限制，需要在定位未开始之前或定位停止之后，修改该属性的值才会有效果。
    var allowsBackgroundLocationUpdates: Bool { get set }
    
    ///指定单次定位超时时间,默认为10s。最小值是2s。注意单次定位请求前设置。注意: 单次定位超时时间从确定了定位权限(非kCLAuthorizationStatusNotDetermined状态)后开始计算。
    var locationTimeout: Int { get set }

    ///指定单次定位逆地理超时时间,默认为5s。最小值是2s。注意单次定位请求前设置。
    var reGeocodeTimeout: Int { get set }
    ......
}
```
#### 第2步：修改高德百度实现
``` swift
///设定期望的定位精度。单位米，默认为 kCLLocationAccuracyBest。定位服务会尽可能去获取满足desiredAccuracy的定位结果，但不保证一定会得到满足期望的结果。
///注意：设置为kCLLocationAccuracyBest或kCLLocationAccuracyBestForNavigation时，单次定位会在达到locationTimeout设定的时间后，将时间内获取到的最高精度的定位结果返回。
///⚠️ 当iOS14及以上版本，模糊定位权限下可能拿不到设置精度的经纬度
var desiredAccuracy: CLLocationAccuracy = kCLLocationAccuracyBest {
    willSet {
        locationManager.desiredAccuracy = newValue
    }
}

///设定定位的最小更新距离。单位米，默认为 kCLDistanceFilterNone，表示只要检测到设备位置发生变化就会更新位置信息。
var distanceFilter: CLLocationDistance = kCLDistanceFilterNone {
    willSet {
        locationManager.distanceFilter = newValue
    }
}

///指定定位是否会被系统自动暂停。默认为NO。
var pausesLocationUpdatesAutomatically: Bool = false {
    willSet {
        locationManager.pausesLocationUpdatesAutomatically = newValue
    }
}

///是否允许后台定位。默认为NO。只在iOS 9.0及之后起作用。设置为YES的时候必须保证 Background Modes 中的 Location updates 处于选中状态，否则会抛出异常。由于iOS系统限制，需要在定位未开始之前或定位停止之后，修改该属性的值才会有效果。
var allowsBackgroundLocationUpdates: Bool = false {
    willSet {
        locationManager.allowsBackgroundLocationUpdates = newValue
    }
}

///指定单次定位超时时间,默认为10s。最小值是2s。注意单次定位请求前设置。注意: 单次定位超时时间从确定了定位权限(非kCLAuthorizationStatusNotDetermined状态)后开始计算。
var locationTimeout: Int = 10 {
    willSet {
        locationManager.locationTimeout = newValue
    }
}

///指定单次定位逆地理超时时间,默认为5s。最小值是2s。注意单次定位请求前设置。
var reGeocodeTimeout: Int = 5 {
    willSet {
        locationManager.reGeocodeTimeout = newValue
    }
}
```