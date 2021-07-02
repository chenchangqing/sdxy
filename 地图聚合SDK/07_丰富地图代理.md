# 7.丰富地图代理

### 十三、丰富地图代理

#### 第1步：修改地图代理协议
```swift
/// 地图代理协议
public protocol MapViewDelegateProtocol: NSObjectProtocol {
    
    ......
    
    /// 地图区域即将改变时会调用此接口
    /// - Parameters:
    ///   - mapView: 地图实例
    ///   - animated: 是否动画
    func mapView(_ mapView: MapViewProtocol, regionWillChangeAnimated animated: Bool)
    
    ///  地图区域改变完成后会调用此接口
    /// - Parameters:
    ///   - mapView: 地图实例
    ///   - animated: 是否动画
    ///   - wasUserAction: 标识是否是用户动作
    func mapView(_ mapView: MapViewProtocol, regionDidChangeAnimated animated: Bool, wasUserAction: Bool)
    
    /// 位置或者设备方向更新后，会调用此函数
    /// - Parameters:
    ///   - mapView: 地图实例
    ///   - userLocation: 用户定位信息(包括位置与设备方向等数据)
    ///   - updatingLocation: 标示是否是location数据更新, YES:location数据更新 NO:heading数据更新
    func mapView(_ mapView: MapViewProtocol, didUpdate userLocation: UserLocationProtocol, updatingLocation: Bool)
}
```

#### 第2步：修改地图代理实现

##### 高德地图
```swift
/// 高德地图代理实现
class MAMapViewDelegateImpl: NSObject, MAMapViewDelegate {
    
    ......
    
    func mapView(_ mapView: MAMapView!, regionWillChangeAnimated animated: Bool) {
        delegate?.mapView(mapViewProtocol, regionWillChangeAnimated: animated)
    }
    
    func mapView(_ mapView: MAMapView!, regionDidChangeAnimated animated: Bool, wasUserAction: Bool) {
        delegate?.mapView(mapViewProtocol, regionDidChangeAnimated: animated, wasUserAction: wasUserAction)
    }
    
    func mapView(_ mapView: MAMapView!, didUpdate userLocation: MAUserLocation!, updatingLocation: Bool) {
        let gaodeUserLocation = GaodeUserLocation()
        gaodeUserLocation.location = userLocation.location
        gaodeUserLocation.heading = userLocation.heading
        gaodeUserLocation.updating = userLocation.isUpdating
        delegate?.mapView(mapViewProtocol, didUpdate: gaodeUserLocation, updatingLocation: updatingLocation)
    }
}
```
###### 百度地图
```swift
/// 百度地图代理实现
class BMKMapViewDelegateImpl: NSObject, BMKMapViewDelegate {
    ......
    
    func mapView(_ mapView: BMKMapView!, regionWillChangeAnimated animated: Bool) {
        delegate?.mapView(mapViewProtocol, regionWillChangeAnimated: animated)
    }
    
    func mapView(_ mapView: BMKMapView!, regionDidChangeAnimated animated: Bool, reason: BMKRegionChangeReason) {
        let wasUserAction = reason == BMKRegionChangeReasonGesture
        delegate?.mapView(mapViewProtocol, regionDidChangeAnimated: animated, wasUserAction: wasUserAction)
    }

}
```