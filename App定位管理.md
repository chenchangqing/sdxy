# App定位管理

项目中商城及爱车分别使用到了系统定位，故将定位管理类从地图中抽离出来。

定位管理作为单例，提供“开始定位”、“停止定位”、“定位是否可用”、“检索地址”等方法。

细节：开始定位的时候，需要使用到`PrivacyManager`的异步请求权限的方法，第一次使用的时候，会有询问弹窗，用户决定授权后，会继续定位，否则定位失败。

2021.1.21:新增`func startLocating(subLocManager: SubCLLocationManager)`,支持同时调用多次定位,定位完成`subLocManager`的`locatingCompletion`会被调用。

```swift
import UIKit
import CoreLocation

/// 系统定位的子类
public class SubCLLocationManager: CLLocationManager {
    /// 定位完成
    public var locatingCompletion: ((CLLocation?) -> Void)?
    
    public override init() {
        super.init()
        desiredAccuracy = kCLLocationAccuracyBest
    }
}

/// 自定义定位代理
public protocol LocationManagerDelegate: NSObjectProtocol {
    /// 更新定位
    /// - Parameter location: 系统定位
    func onLocationUpdated(location: CLLocation)
    /// 定位失败
    func onLocationFailure()
}

public extension LocationManagerDelegate {
    
    func onLocationUpdated(location: CLLocation) { }
    
    func onLocationFailure() { }
}

/// 自定义定位管理
public class LocationManager: NSObject {
    /// 代理
    public weak var delegate: LocationManagerDelegate?
    /// 系统用户定位
    public var userLocation: CLLocation?
    /// 系统定位管理
    private let locationManager = SubCLLocationManager()
    private var tempManagers = [SubCLLocationManager]()
    /// 单例
    public static let shared = LocationManager()
    /// 开始定位
    public func startLocating() {
        startLocating(subLocManager: locationManager)
    }
    /// 开始定位
    /// - Parameter subLocManager: 指定定位管理
    public func startLocating(subLocManager: SubCLLocationManager) {
        
        tempManagers.append(subLocManager)
        PrivacyManager.asynRequestAccess(.location) {[weak self] (status) in
            switch status {
            case .authorized:
                subLocManager.delegate = self
                subLocManager.startUpdatingLocation()
                break
            default:
                subLocManager.delegate = self
                subLocManager.locatingCompletion?(nil)
                self?.delegate?.onLocationFailure()
                self?.remove(manager: subLocManager)
                break
            }
        }
    }
    /// 停止定位
    public func stopLocating() {
        stopLocating(subLocManager: locationManager)
    }
    /// 停止定位
    /// - Parameter subLocManager: 指定定位管理
    public func stopLocating(subLocManager: SubCLLocationManager) {
        subLocManager.stopUpdatingLocation()
        remove(manager: subLocManager)
    }
    /// 移除指定定位管理
    /// - Parameter manager: 指定定位管理
    private func remove(manager: SubCLLocationManager) {
        if let index = tempManagers.firstIndex(of: manager) {
            tempManagers.remove(at: index)
        }
    }
    /// 定位是否可用
    /// - Returns: 是否可用
    public func locationServiceEnable() -> Bool {
        return PrivacyManager.synRequestAccess(.location) == .authorized
    }
    /// 检索地址
    /// - Parameter location: 定位
    /// - Returns: 地址
    public func reverseGeocodeLocation(_ location: CLLocation, completionHandler: ((String?) -> Void)?) {
        CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) -> Void in

            if error != nil {
                GWLog("----- 检索地址失败 -----")
                completionHandler?(nil)
            } else {
                
                let pm = CLPlacemark(placemark: placemarks![0] as CLPlacemark)
                
                var address: String = ""
                
                func addSymbol() -> String {
                    if !address.isEmpty {
                        address += ","
                    }
                    return address
                }

                if let subThoroughtare = pm.subThoroughfare // 门牌号
                {
                    address = addSymbol() + subThoroughtare
                }
                if let thoroughfare = pm.thoroughfare // 街道
                {
                    address = addSymbol() + thoroughfare
                }
                if let subLocality = pm.subLocality // 区
                {
                    address = addSymbol() + subLocality
                }
                if let locality = pm.locality // 市
                {
                    address = addSymbol() + locality
                }
                if let administrativeArea = pm.administrativeArea // 省（州）
                {
                    address = addSymbol() + administrativeArea
                }
                if let country = pm.country  // 国家
                {
                    address = addSymbol() + country
                }
                GWLog("----- 检索地址：\(address) -----")
                completionHandler?(address)
            }
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    
    /// 定位回调
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let lastLocation = locations.last else {
            GWLog("----- 定位失败:没有找到最后一个位置 -----")
            delegate?.onLocationFailure()
            if let manager = manager as? SubCLLocationManager {
                manager.locatingCompletion?(nil)
            }
            return
        }
        GWLog("----- 定位成功:latitude-\(lastLocation.coordinate.latitude),longitude-\(lastLocation.coordinate.longitude) -----")
        userLocation = lastLocation
        delegate?.onLocationUpdated(location: lastLocation)
        if let manager = manager as? SubCLLocationManager {
            manager.locatingCompletion?(lastLocation)
        }
    }
    /// 定位失败
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let error = error as? CLError, error.code == .denied {
            GWLog("----- 用户拒绝定位 -----")
            if let manager = manager as? SubCLLocationManager {
                stopLocating(subLocManager: manager)
            }
        }
        GWLog("----- 定位失败:\(error) -----")
        delegate?.onLocationFailure()
        if let manager = manager as? SubCLLocationManager {
            manager.locatingCompletion?(nil)
        }
    }
}
```
附：
> 
* [placemark](https://www.cnblogs.com/guitarandcode/p/5783805.html)