# 8.地图新增缩放等级

### 十四、地图新增缩放等级

#### 第1步：修改地图协议
```swift
/// 地图协议
public protocol MapViewProtocol: NSObjectProtocol {
    ......
    /// 缩放级别（默认3-19，有室内地图时为3-20）
    var zoomLevel: CGFloat { get set }

    /// 最小缩放级别
    var minZoomLevel: CGFloat { get set }

    /// 最大缩放级别（有室内地图时最大为20，否则为19）
    var maxZoomLevel: CGFloat { get set }
}
```

#### 第2步：修改地图实现

##### 高德地图
```swift
/// 高德地图
class GaodeMapView: NSObject, MapViewProtocol {
    ......
    /// 缩放级别（默认3-19，有室内地图时为3-20）
    var zoomLevel: CGFloat {
        get {
            mapView.zoomLevel
        }
        set {
            mapView.zoomLevel = newValue
        }
    }

    /// 最小缩放级别
    var minZoomLevel: CGFloat {
        get {
            mapView.minZoomLevel
        }
        set {
            mapView.minZoomLevel = newValue
        }
    }

    /// 最大缩放级别（有室内地图时最大为20，否则为19）
    var maxZoomLevel: CGFloat {
        get {
            mapView.maxZoomLevel
        }
        set {
            mapView.maxZoomLevel = newValue
        }
    }
}

```
##### 百度地图
```swift
/// 百度地图
class BaiduMapView: NSObject, MapViewProtocol {
    ......
    /// 缩放级别（默认3-19，有室内地图时为3-20）
    var zoomLevel: CGFloat {
        get {
            CGFloat(mapView.zoomLevel)
        }
        set {
            mapView.zoomLevel = Float(newValue)
        }
    }

    /// 最小缩放级别
    var minZoomLevel: CGFloat {
        get {
            CGFloat(mapView.minZoomLevel)
        }
        set {
            mapView.minZoomLevel = Float(newValue)
        }
    }

    /// 最大缩放级别（有室内地图时最大为20，否则为19）
    var maxZoomLevel: CGFloat {
        get {
            CGFloat(mapView.maxZoomLevel)
        }
        set {
            mapView.maxZoomLevel = Float(newValue)
        }
    }
}
```