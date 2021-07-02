# 10.地图多边形实现

### 十六、地图多边形实现

#### 第1步：新增地图覆盖物协议、地图覆盖物Renderer协议

OverlayProtocol（地图覆盖物协议）、OverlayRendererProtocol（地图覆盖物Renderer协议）

```swift
/// 地图覆盖物协议，所有地图的覆盖物需要实现
public protocol OverlayProtocol: NSObjectProtocol {
    
    /// 具体地图覆盖物实现
    var overlayImpl: Any? { get }
    
    /// 构造方法
    /// - Parameter annotationImpl: 具体地图覆盖物实现
    init(overlayImpl: Any?)
    
}
/// 地图覆盖物Renderer协议
public protocol OverlayRendererProtocol: NSObjectProtocol {
    
    /// 填充颜色,默认是kMAOverlayRendererDefaultFillColor
    var fillColor: UIColor { get set }

    /// 笔触颜色,默认是kMAOverlayRendererDefaultStrokeColor
    var strokeColor: UIColor { get set }
    
    ///笔触宽度, 单位屏幕点坐标，默认是0
    var lineWidth: CGFloat { get set }
    
    /// 具体地图标注view实现
    var overRendererImpl: Any? { get }
    
    /// 构造方法
    /// - Parameter overRendererImpl: 具体地图覆盖物Renderer实现
    init(overRendererImpl: Any?)
    
}
```

#### 第2步：新增地图多边形实现、地图多边形Renderer实现

GaodePolygon（高德地图多边形）、GaodePolygonRenderer（高德地图多边形Renderer）

BaiduPolygon（百度地图多边形）、BaiduPolygonRenderer（百度地图多边形Renderer）

Polygon（通用多边形）、PolygonRenderer（通用多边形Renderer）

```swift
/// 高德地图多边形
public class GaodePolygon: MAPolygon {
    
    /// 聚合多边形区域l
    weak var polygon: Polygon?
}
/// 高德地图多边形Renderer
public class GaodePolygonRenderer: MAPolygonRenderer {
    
}
/// 百度多边形
public class BaiduPolygon: BMKPolygon {
    
    /// 聚合多边形区域l
    weak var polygon: Polygon?
}
/// 百度多边形Renderer
public class BaiduPolygonRenderer: BMKPolygonView {

}
/// 通用多边形
public class Polygon: NSObject, OverlayProtocol {
    
    /// 具体地图覆盖物实现
    private(set) public var overlayImpl: Any?
    
    /// 高德覆盖物
    private var gaodePolygon: GaodePolygon? {
        if let overlay = overlayImpl as? GaodePolygon {
            return overlay
        }
        return nil
    }
    
    /// 百度覆盖物
    private var baiduPolygon: BaiduPolygon? {
        if let overlay = overlayImpl as? BaiduPolygon {
            return overlay
        }
        return nil
    }
    
    /// 构造方法
    /// - Parameter overlayImpl: 具体地图覆盖物实现
    public required init(overlayImpl: Any?) {
        super.init()
        self.overlayImpl = overlayImpl
        gaodePolygon?.polygon = self
        baiduPolygon?.polygon = self
    }

}
/// 通用多边形Renderer
public class PolygonRenderer: NSObject, OverlayRendererProtocol {
    
    /// 填充颜色,默认是kMAOverlayRendererDefaultFillColor
    public var fillColor: UIColor {
        get {
            if let overRenderer = gaodeOverRenderer {
                return overRenderer.fillColor
            }
            if let overRenderer = baiduOverRenderer {
                return overRenderer.fillColor
            }
            return .red
        }
        set {
            if let overRenderer = gaodeOverRenderer {
                overRenderer.fillColor = newValue
            }
            if let overRenderer = baiduOverRenderer {
                overRenderer.fillColor = newValue
            }
        }
    }

    /// 笔触颜色,默认是kMAOverlayRendererDefaultStrokeColor
    public var strokeColor: UIColor {
        get {
            if let overRenderer = gaodeOverRenderer {
                return overRenderer.strokeColor
            }
            if let overRenderer = baiduOverRenderer {
                return overRenderer.strokeColor
            }
            return .red
        }
        set {
            if let overRenderer = gaodeOverRenderer {
                overRenderer.strokeColor = newValue
            }
            if let overRenderer = baiduOverRenderer {
                overRenderer.strokeColor = newValue
            }
        }
    }
    
    ///笔触宽度, 单位屏幕点坐标，默认是0
    public var lineWidth: CGFloat {
        get {
            if let overRenderer = gaodeOverRenderer {
                return overRenderer.lineWidth
            }
            if let overRenderer = baiduOverRenderer {
                return overRenderer.lineWidth
            }
            return 0
        }
        set {
            if let overRenderer = gaodeOverRenderer {
                overRenderer.lineWidth = newValue
            }
            if let overRenderer = baiduOverRenderer {
                overRenderer.lineWidth = newValue
            }
        }
    }
    
    /// 具体地图覆盖物实现
    public private(set) var overRendererImpl: Any?
    
    /// 高德地图覆盖物
    private var gaodeOverRenderer: GaodePolygonRenderer? {
        return overRendererImpl as? GaodePolygonRenderer
    }
    
    /// 百度地图覆盖物
    private var baiduOverRenderer: BaiduPolygonRenderer? {
        return overRendererImpl as? BaiduPolygonRenderer
    }
    
    /// 构造方法
    /// - Parameter overRendererImpl: 具体地图覆盖物Renderer实现
    public required init(overRendererImpl: Any?) {
        self.overRendererImpl = overRendererImpl
    }

}
```

#### 第3步：地图工厂标准修改及实现
```swift
/// 地图工厂标准
public protocol MapFactoryProtocol: NSObjectProtocol {
    
    ......
    
    /// 根据经纬度坐标数据生成闭合多边形
    /// - Parameters:
    ///   - coordinates: 经纬度坐标点数据,coords对应的内存会拷贝,调用者负责该内存的释放
    ///   - count: 经纬度坐标点数组个数
    /// - Returns: 新生成的多边形
    func getPolygon(coordinates: UnsafeMutablePointer<CLLocationCoordinate2D>, count: UInt) -> Polygon
    
    /// 根据指定的多边形生成一个多边形Renderer
    /// - Parameter overlay: 指定的多边形数据对象
    /// - Returns: 新生成的多边形Renderer
    func getPolygonRenderer(overlay: OverlayProtocol) -> OverlayRendererProtocol
}
/// 高德地图工厂
class GaodeMapFactory: NSObject, MapFactoryProtocol {
    
    ......
    
    /// 根据经纬度坐标数据生成闭合多边形
    /// - Parameters:
    ///   - coordinates: 经纬度坐标点数据,coords对应的内存会拷贝,调用者负责该内存的释放
    ///   - count: 经纬度坐标点数组个数
    /// - Returns: 新生成的多边形
    func getPolygon(coordinates: UnsafeMutablePointer<CLLocationCoordinate2D>, count: UInt) -> Polygon {
        let polygonImpl = GaodePolygon(coordinates: coordinates, count: count)
        return Polygon(overlayImpl: polygonImpl)
    }
    
    /// 根据指定的多边形生成一个多边形Renderer
    /// - Parameter overlay: 指定的多边形数据对象
    /// - Returns: 新生成的多边形Renderer
    func getPolygonRenderer(overlay: OverlayProtocol) -> OverlayRendererProtocol {
        
        var polygonImpl = GaodePolygon()
        if let overlayImplParam = overlay.overlayImpl as? GaodePolygon {
            polygonImpl = overlayImplParam
        }
        let polygonRendererImpl = GaodePolygonRenderer(overlay: polygonImpl)
        return PolygonRenderer(overRendererImpl: polygonRendererImpl)
    }
}
/// 百度地图工厂
class BaiduMapFactory: NSObject, MapFactoryProtocol {
    ......
    
    /// 根据经纬度坐标数据生成闭合多边形
    /// - Parameters:
    ///   - coordinates: 经纬度坐标点数据,coords对应的内存会拷贝,调用者负责该内存的释放
    ///   - count: 经纬度坐标点数组个数
    /// - Returns: 新生成的多边形
    func getPolygon(coordinates: UnsafeMutablePointer<CLLocationCoordinate2D>, count: UInt) -> Polygon {
        let polygonImpl = BaiduPolygon(coordinates: coordinates, count: count)
        return Polygon(overlayImpl: polygonImpl)
    }
    
    /// 根据指定的多边形生成一个多边形Renderer
    /// - Parameter overlay: 指定的多边形数据对象
    /// - Returns: 新生成的多边形Renderer
    func getPolygonRenderer(overlay: OverlayProtocol) -> OverlayRendererProtocol {
        
        var polygonImpl = BaiduPolygon()
        if let overlayImplParam = overlay.overlayImpl as? BaiduPolygon {
            polygonImpl = overlayImplParam
        }
        let polygonRendererImpl = BaiduPolygonRenderer(overlay: polygonImpl)
        return PolygonRenderer(overRendererImpl: polygonRendererImpl)
    }
}
```

#### 第4步：地图协议修改及实现
```swift
/// 地图协议
public protocol MapViewProtocol: NSObjectProtocol {
    
    ......
    
    /// 向地图窗口添加一组Overlay，需要实现MAMapViewDelegate的-mapView:rendererForOverlay:函数来生成标注对应的Renderer
    /// - Parameter overlays: 要添加的overlay数组
    func addOverlays(overlays: [OverlayProtocol])
    
    /// 设置地图使其可以显示数组中所有的overlay, 如果数组中只有一个则直接设置地图中心为overlay的位置。
    /// - Parameters:
    ///   - overlays: 需要显示的overlays
    ///   - animated: 是否执行动画
    func showOverlays(overlays: [OverlayProtocol], animated: Bool)
}
/// 高德地图
class GaodeMapView: NSObject, MapViewProtocol {
    ......
    
    /// 向地图窗口添加一组Overlay，需要实现MAMapViewDelegate的-mapView:rendererForOverlay:函数来生成标注对应的Renderer
    /// - Parameter overlays: 要添加的overlay数组
    func addOverlays(overlays: [OverlayProtocol]) {
        var overlayImpls: [Any] = []
        for overlay in overlays {
            if let overlayImpl = overlay.overlayImpl {
                overlayImpls.append(overlayImpl)
            }
        }
        mapView.addOverlays(overlayImpls)
    }
    
    /// 设置地图使其可以显示数组中所有的overlay, 如果数组中只有一个则直接设置地图中心为overlay的位置。
    /// - Parameters:
    ///   - overlays: 需要显示的overlays
    ///   - animated: 是否执行动画
    func showOverlays(overlays: [OverlayProtocol], animated: Bool) {
        var overlayImpls: [Any] = []
        for overlay in overlays {
            if let overlayImpl = overlay.overlayImpl {
                overlayImpls.append(overlayImpl)
            }
        }
        mapView.showOverlays(overlayImpls, animated: animated)
    }
}
/// 高德地图代理实现
class MAMapViewDelegateImpl: NSObject, MAMapViewDelegate {
    
    ......
    
    func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
        if let polygonOverlay = overlay as? GaodePolygon, let poly = polygonOverlay.polygon {
            if let polygonRenderer = delegate?.mapView(mapViewProtocol, rendererFor: poly)?.overRendererImpl as? MAPolygonRenderer {
                return polygonRenderer
            }
        }
        return nil
    }
}
/// 百度地图
class BaiduMapView: NSObject, MapViewProtocol {
    ......
    
    /// 向地图窗口添加一组Overlay，需要实现MAMapViewDelegate的-mapView:rendererForOverlay:函数来生成标注对应的Renderer
    /// - Parameter overlays: 要添加的overlay数组
    func addOverlays(overlays: [OverlayProtocol]) {
        var overlayImpls: [BMKOverlay] = []
        for overlay in overlays {
            if let overlayImpl = overlay.overlayImpl as? BMKOverlay {
                overlayImpls.append(overlayImpl)
            }
        }
        mapView.addOverlays(overlayImpls)
    }
    
    /// 设置地图使其可以显示数组中所有的overlay, 如果数组中只有一个则直接设置地图中心为overlay的位置。
    /// - Parameters:
    ///   - overlays: 需要显示的overlays
    ///   - animated: 是否执行动画
    func showOverlays(overlays: [OverlayProtocol], animated: Bool) {
        var overlayImpls: [BMKOverlay] = []
        for overlay in overlays {
            if let overlayImpl = overlay.overlayImpl as? BMKOverlay {
                overlayImpls.append(overlayImpl)
            }
        }
    }
}
/// 百度地图代理实现
class BMKMapViewDelegateImpl: NSObject, BMKMapViewDelegate {
    
    ......
    
    func mapView(_ mapView: BMKMapView!, viewFor overlay: BMKOverlay!) -> BMKOverlayView! {
        if let polygonOverlay = overlay as? BaiduPolygon, let poly = polygonOverlay.polygon {
            if let polygonRenderer = delegate?.mapView(mapViewProtocol, rendererFor: poly)?.overRendererImpl as? BMKPolygonView {
                return polygonRenderer
            }
        }
        return nil
    }

}
```

#### 第5步：测试页面
```swift
class PolygonViewController: UIViewController {
    
    /// 地图工厂
    private lazy var factory: MapFactoryProtocol = {
        let factory = MapEngine.shared.getFactory()!
        return factory
    }()
    
    /// 地图实例
    private lazy var mapView: MapViewProtocol = {
        // 显示地图
        let mapView = factory.getMapView(frame: view.bounds)
        // 设置代理
        mapView.delegate = self
        // 显示用户定位(放在设置代理之后，确保可以调用locationManager.requestAlwaysAuthorization())
        mapView.showsUserLocation = true
        // 跟踪模式
        mapView.userTrackingMode = .followWithHeading
        // 设置缩放
        mapView.zoomLevel = 16
        return mapView
    }()
    
    /// 标注数组
    private lazy var polygons: Array<Polygon> = {
        var polygons = Array<Polygon>()
        
        var polygonCoordinates: [CLLocationCoordinate2D] = [
            CLLocationCoordinate2D(latitude: 39.781892, longitude: 116.283413),
            CLLocationCoordinate2D(latitude: 39.787600, longitude: 116.391842),
            CLLocationCoordinate2D(latitude: 39.733187, longitude: 116.417932),
            CLLocationCoordinate2D(latitude: 39.704653, longitude: 116.338255)]
        
        let polygon = factory.getPolygon(coordinates: &polygonCoordinates, count: UInt(polygonCoordinates.count))
        polygons.append(polygon)
        
        return polygons
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        view.addSubview(mapView.getView())
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        mapView.addOverlays(overlays: polygons)
        mapView.showOverlays(overlays: polygons, animated: false)
    }

}

extension PolygonViewController: MapViewDelegateProtocol {
    
    func mapView(_ mapView: MapViewProtocol, rendererFor overlay: OverlayProtocol) -> OverlayRendererProtocol? {
        
        if overlay.isKind(of: Polygon.self) {
            
            let renderer = factory.getPolygonRenderer(overlay: overlay)
            renderer.lineWidth = 8.0
            renderer.strokeColor = UIColor.magenta
            renderer.fillColor = UIColor.yellow.withAlphaComponent(0.4)
            
            return renderer
        }
        return nil
    }
}
```