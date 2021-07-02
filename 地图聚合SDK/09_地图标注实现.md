# 9.地图标注实现

### 十五、地图标注实现

#### 第1步：新增标注协议、标注view协议

AnnotationProtocol（通用标注协议）、AnnotationViewProtocol（通用标注view协议）、PinAnnotationViewProtocol（大头针标注view协议）

```swift
/// 标注协议
public protocol AnnotationProtocol: NSObjectProtocol {
    
    /// 标注view中心坐标
    var coordinate: CLLocationCoordinate2D? { get set}

    /// annotation标题
    var title: String? { get set }

    /// annotation副标题
    var subtitle: String? { get set }
    
    /// 具体地图标注实现
    var annotationImpl: Any? { get }
    
    /// 构造方法
    /// - Parameter annotationImpl: 具体地图标注实现
    init(annotationImpl: Any?)
}
/// 标注view协议
public protocol AnnotationViewProtocol: NSObjectProtocol {
    
    /// 是否允许弹出callout
    var canShowCallout: Bool { get set }
    
    /// 显示在默认弹出框右侧的view
    var rightCalloutAccessoryView: UIView? { get set }
    
    /// 是否支持拖动
    var draggable: Bool { get set }
    
    /// 具体地图标注view实现
    var annotationViewImpl: UIView? { get }
    
    /// 构造方法
    /// - Parameter annotationViewImpl: 具体地图标注view实现
    init(annotationViewImpl: UIView?)
    
}
/// 大头针标注view颜色
public enum PinAnnotationColor: Int {
    ///< 红色大头针
    case red
    ///< 绿色大头针
    case green
    ///< 紫色大头针
    case purple
}

/// 大头针标注view协议
public protocol PinAnnotationViewProtocol: AnnotationViewProtocol {
    
    /// 大头针的颜色
    var pinColor: PinAnnotationColor { get set }

    /// 添加到地图时是否使用下落动画效果
    var animatesDrop: Bool { get set }
}
```

#### 第2步：新增标注实现、标注view实现

GaodePointAnnotation（高德标注）、GaodePinAnnotationView（高德大头针）

BaiduPointAnnotation（百度标注）、BaiduPinAnnotationView（百度大头针）

PointAnnotation（通用标注）、PinAnnotationView（通用大头针）

```swift
/// 高德标注
public class GaodePointAnnotation: MAPointAnnotation {
    
    /// 聚合标注
    weak var annotation: PointAnnotation?
}
/// 高德大头针标准view
public class GaodePinAnnotationView: MAPinAnnotationView {
    
}
/// 百度标注
public class BaiduPointAnnotation: BMKPointAnnotation {
    
    /// 聚合标注
    weak var annotation: PointAnnotation?
}
/// 百度大头针标准view
public class BaiduPinAnnotationView: BMKPinAnnotationView {

}
/// 标注实现
public class PointAnnotation: NSObject, AnnotationProtocol {
    
    /// 标注view中心坐标
    public var coordinate: CLLocationCoordinate2D? {
        get {
            if let annotation = gaodeAnnotation {
                return annotation.coordinate
            }
            if let annotation = baiduAnnotation {
                return annotation.coordinate
            }
            return nil
        }
        set {
            if let coordinate = newValue, let annotation = gaodeAnnotation {
                annotation.coordinate = coordinate
            }
            if let coordinate = newValue, let annotation = baiduAnnotation {
                annotation.coordinate = coordinate
            }
        }
    }
    
    /// annotation标题
    public var title: String? {
        get {
            if let annotation = gaodeAnnotation {
                return annotation.title
            }
            if let annotation = baiduAnnotation {
                return annotation.title
            }
            return nil
        }
        set {
            if let title = newValue, let annotation = gaodeAnnotation {
                annotation.title = title
            }
            if let title = newValue, let annotation = baiduAnnotation {
                annotation.title = title
            }
        }
    }
    
    /// annotation副标题
    public var subtitle: String? {
        get {
            if let annotation = gaodeAnnotation {
                return annotation.subtitle
            }
            if let annotation = baiduAnnotation {
                return annotation.subtitle
            }
            return nil
        }
        set {
            if let subtitle = newValue, let annotation = gaodeAnnotation {
                annotation.subtitle = subtitle
            }
            if let subtitle = newValue, let annotation = baiduAnnotation {
                annotation.subtitle = subtitle
            }
        }
    }
    
    /// 具体地图标注实现
    private(set) public var annotationImpl: Any?
    
    /// 高德标注
    private var gaodeAnnotation: GaodePointAnnotation? {
        if let annotation = annotationImpl as? GaodePointAnnotation {
            return annotation
        }
        return nil
    }
    
    /// 百度标注
    private var baiduAnnotation: BaiduPointAnnotation? {
        if let annotation = annotationImpl as? BaiduPointAnnotation {
            return annotation
        }
        return nil
    }
    
    /// 构造方法
    /// - Parameter annotationImpl: 具体地图标注实现
    public required init(annotationImpl: Any?) {
        super.init()
        self.annotationImpl = annotationImpl
        gaodeAnnotation?.annotation = self
        baiduAnnotation?.annotation = self
    }
}
/// 通用大头针标注view
public class PinAnnotationView: NSObject, PinAnnotationViewProtocol {
    
    /// 是否允许弹出callout
    public var canShowCallout: Bool {
        get {
            if let annotationView = gaodeAnnotationView {
                return annotationView.canShowCallout
            }
            if let annotationView = baiduAnnotationView {
                return annotationView.canShowCallout
            }
            return false
        }
        set {
            if let annotationView = gaodeAnnotationView {
                annotationView.canShowCallout = newValue
            }
            if let annotationView = baiduAnnotationView {
                annotationView.canShowCallout = newValue
            }
        }
    }
    
    /// 显示在默认弹出框右侧的view
    public var rightCalloutAccessoryView: UIView? {
        get {
            if let annotationView = gaodeAnnotationView {
                return annotationView.rightCalloutAccessoryView
            }
            if let annotationView = baiduAnnotationView {
                return annotationView.rightCalloutAccessoryView
            }
            return nil
        }
        set {
            if let annotationView = gaodeAnnotationView {
                annotationView.rightCalloutAccessoryView = newValue
            }
            if let annotationView = baiduAnnotationView {
                annotationView.rightCalloutAccessoryView = newValue
            }
        }
    }
    
    /// 是否支持拖动
    public var draggable: Bool {
        get {
            if let annotationView = gaodeAnnotationView {
                return annotationView.isDraggable
            }
            if let annotationView = baiduAnnotationView {
                return annotationView.isDraggable
            }
            return false
        }
        set {
            if let annotationView = gaodeAnnotationView {
                annotationView.isDraggable = newValue
            }
            if let annotationView = baiduAnnotationView {
                annotationView.isDraggable = newValue
            }
        }
    }
    
    /// 大头针的颜色
    public var pinColor: PinAnnotationColor {
        get {
            if let annotationView = gaodeAnnotationView {
                return PinAnnotationColor(rawValue: annotationView.pinColor.rawValue) ?? .red
            }
            if let annotationView = baiduAnnotationView {
                return PinAnnotationColor(rawValue: Int(annotationView.pinColor)) ?? .red
            }
            return .red
        }
        set {
            if let annotationView = gaodeAnnotationView, let pinColor = MAPinAnnotationColor(rawValue: newValue.rawValue) {
                annotationView.pinColor = pinColor
            }
            if let annotationView = baiduAnnotationView {
                annotationView.pinColor = BMKPinAnnotationColor(newValue.rawValue)
            }
        }
    }

    /// 添加到地图时是否使用下落动画效果
    public var animatesDrop: Bool {
        get {
            if let annotationView = gaodeAnnotationView {
                return annotationView.animatesDrop
            }
            if let annotationView = baiduAnnotationView {
                return annotationView.animatesDrop
            }
            return false
        }
        set {
            if let annotationView = gaodeAnnotationView {
                annotationView.animatesDrop = newValue
            }
            if let annotationView = baiduAnnotationView {
                annotationView.animatesDrop = newValue
            }
        }
    }
    
    /// 具体地图标注view实现
    private(set) public var annotationViewImpl: UIView?
    
    /// 高德地图标注view
    private var gaodeAnnotationView: MAPinAnnotationView? {
        return annotationViewImpl as? MAPinAnnotationView
    }
    
    /// 百度地图标注view
    private var baiduAnnotationView: BMKPinAnnotationView? {
        return annotationViewImpl as? BMKPinAnnotationView
    }
    
    /// 构造方法
    /// - Parameter annotationViewImpl: 具体地图标注view实现
    public required init(annotationViewImpl: UIView?) {
        self.annotationViewImpl = annotationViewImpl
    }
}
```

#### 第3步：地图工厂标准修改及实现
```swift
/// 地图工厂标准
public protocol MapFactoryProtocol: NSObjectProtocol {
    
    ......
    
    /// 获取地图标注
    func getPointAnnotation() -> PointAnnotation
    
    /// 获取标注view
    /// - Parameters:
    ///   - annotation: 标注
    ///   - reuseIdentifier: 重用ID
    func getPinAnnotationView(annotation: AnnotationProtocol, reuseIdentifier: String) -> PinAnnotationViewProtocol
}
/// 百度地图工厂
class BaiduMapFactory: NSObject, MapFactoryProtocol {
    ......
    
    /// 获取地图标注
    func getPointAnnotation() -> PointAnnotation {
        let annotationImpl = BaiduPointAnnotation()
        return PointAnnotation(annotationImpl: annotationImpl)
    }
    
    /// 获取标注view
    /// - Parameters:
    ///   - annotation: 标注
    ///   - reuseIdentifier: 重用ID
    func getPinAnnotationView(annotation: AnnotationProtocol, reuseIdentifier: String) -> PinAnnotationViewProtocol {
        
        var annotationImpl = BaiduPointAnnotation()
        if let annotationImplParam = annotation.annotationImpl as? BaiduPointAnnotation {
            annotationImpl = annotationImplParam
        }
        let annotationViewImpl = BaiduPinAnnotationView(annotation: annotationImpl, reuseIdentifier: reuseIdentifier)
        return PinAnnotationView(annotationViewImpl: annotationViewImpl)
    }
}
/// 高德地图工厂
class GaodeMapFactory: NSObject, MapFactoryProtocol {
    ......
    
    /// 获取地图标注
    func getPointAnnotation() -> PointAnnotation {
        let annotationImpl = GaodePointAnnotation()
        return PointAnnotation(annotationImpl: annotationImpl)
    }
    
    /// 获取标注view
    /// - Parameters:
    ///   - annotation: 标注
    ///   - reuseIdentifier: 重用ID
    func getPinAnnotationView(annotation: AnnotationProtocol, reuseIdentifier: String) -> PinAnnotationViewProtocol {
        var annotationImpl = GaodePointAnnotation()
        if let annotationImplParam = annotation.annotationImpl as? GaodePointAnnotation {
            annotationImpl = annotationImplParam
        }
        let annotationViewImpl = GaodePinAnnotationView(annotation: annotationImpl, reuseIdentifier: reuseIdentifier)
        return PinAnnotationView(annotationViewImpl: annotationViewImpl)
    }
}
```

#### 第4步：地图协议修改及实现
```swift
/// 地图协议
public protocol MapViewProtocol: NSObjectProtocol {
    ......
    
    /// 向地图窗口添加标注
    /// - Parameter annotation: 要添加的标注
    func addAnnotation(_ annotation: AnnotationProtocol)
    
    /// 向地图窗口添加一组标注，需要实现MAMapViewDelegate的-mapView:viewForAnnotation:函数来生成标注对应的View
    /// - Parameter annotations: 要添加的标注数组
    func addAnnotations(_ annotations: [AnnotationProtocol])
    
    /// 设置地图使其可以显示数组中所有的annotation, 如果数组中只有一个则直接设置地图中心为annotation的位置。
    /// - Parameters:
    ///   - annotations: 需要显示的annotation
    ///   - animated: 是否执行动画
    func showAnnotations(_ annotations: [AnnotationProtocol], animated: Bool)
    
    /// 从复用内存池中获取制定复用标识的annotation view
    /// - Parameter withIdentifier: 复用标识
    /// - Returns: annotation view
    func dequeueReusableAnnotationView(withIdentifier: String) -> PinAnnotationViewProtocol?
}
/// 高德地图
class GaodeMapView: NSObject, MapViewProtocol {
    ......
    
    /// 向地图窗口添加标注
    /// - Parameter annotation: 要添加的标注
    func addAnnotation(_ annotation: AnnotationProtocol) {
        if let annotationImpl = annotation.annotationImpl as? MAAnnotation {
            mapView.addAnnotation(annotationImpl)
        }
    }
    
    /// 向地图窗口添加一组标注，需要实现MAMapViewDelegate的-mapView:viewForAnnotation:函数来生成标注对应的View
    /// - Parameter annotations: 要添加的标注数组
    func addAnnotations(_ annotations: [AnnotationProtocol]) {
        var annotationImpls: [Any] = []
        for annotation in annotations {
            if let annotationImpl = annotation.annotationImpl {
                annotationImpls.append(annotationImpl)
            }
        }
        mapView.addAnnotations(annotationImpls)
    }
    
    /// 设置地图使其可以显示数组中所有的annotation, 如果数组中只有一个则直接设置地图中心为annotation的位置。
    /// - Parameters:
    ///   - annotations: 需要显示的annotation
    ///   - animated: 是否执行动画
    func showAnnotations(_ annotations: [AnnotationProtocol], animated: Bool) {
        var annotationImpls: [Any] = []
        for annotation in annotations {
            if let annotationImpl = annotation.annotationImpl {
                annotationImpls.append(annotationImpl)
            }
        }
        mapView.showAnnotations(annotationImpls, animated: animated)
    }
    
    /// 从复用内存池中获取制定复用标识的annotation view
    /// - Parameter withIdentifier: 复用标识
    /// - Returns: annotation view
    func dequeueReusableAnnotationView(withIdentifier: String) -> PinAnnotationViewProtocol? {
        if let annotationViewImpl = mapView.dequeueReusableAnnotationView(withIdentifier: withIdentifier) as? GaodePinAnnotationView {
            return PinAnnotationView(annotationViewImpl: annotationViewImpl)
        }
        return nil
    }
}
/// 高德地图代理实现
class MAMapViewDelegateImpl: NSObject, MAMapViewDelegate {
    
    ......
    
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        
        if let pointAnnotation = annotation as? GaodePointAnnotation, let anno = pointAnnotation.annotation {
            if let pinAnnotationView = delegate?.mapView(mapViewProtocol, viewFor: anno)?.annotationViewImpl as? MAAnnotationView {
                return pinAnnotationView
            }
            return nil
        }
        return nil
    }
}
/// 百度地图
class BaiduMapView: NSObject, MapViewProtocol {
    ......
    
    /// 向地图窗口添加标注
    /// - Parameter annotation: 要添加的标注
    func addAnnotation(_ annotation: AnnotationProtocol) {
        if let annotationImpl = annotation.annotationImpl as? BMKAnnotation {
            mapView.addAnnotation(annotationImpl)
        }
    }
    
    /// 向地图窗口添加一组标注，需要实现MAMapViewDelegate的-mapView:viewForAnnotation:函数来生成标注对应的View
    /// - Parameter annotations: 要添加的标注数组
    func addAnnotations(_ annotations: [AnnotationProtocol]) {
        var annotationImpls: [BMKAnnotation] = []
        for annotation in annotations {
            if let annotationImpl = annotation.annotationImpl as? BMKAnnotation {
                annotationImpls.append(annotationImpl)
            }
        }
        mapView.addAnnotations(annotationImpls)
    }
    
    /// 设置地图使其可以显示数组中所有的annotation, 如果数组中只有一个则直接设置地图中心为annotation的位置。
    /// - Parameters:
    ///   - annotations: 需要显示的annotation
    ///   - animated: 是否执行动画
    func showAnnotations(_ annotations: [AnnotationProtocol], animated: Bool) {
        var annotationImpls: [BMKAnnotation] = []
        for annotation in annotations {
            if let annotationImpl = annotation.annotationImpl as? BMKAnnotation {
                annotationImpls.append(annotationImpl)
            }
        }
        mapView.showAnnotations(annotationImpls, animated: animated)
    }
    
    /// 从复用内存池中获取制定复用标识的annotation view
    /// - Parameter withIdentifier: 复用标识
    /// - Returns: annotation view
    func dequeueReusableAnnotationView(withIdentifier: String) -> PinAnnotationViewProtocol? {
        if let annotationViewImpl = mapView.dequeueReusableAnnotationView(withIdentifier: withIdentifier) as? BaiduPinAnnotationView {
            return PinAnnotationView(annotationViewImpl: annotationViewImpl)
        }
        return nil
    }
}
/// 百度地图代理实现
class BMKMapViewDelegateImpl: NSObject, BMKMapViewDelegate {
    
    ......
    
    func mapView(_ mapView: BMKMapView!, viewFor annotation: BMKAnnotation!) -> BMKAnnotationView! {
        
        if let pointAnnotation = annotation as? BaiduPointAnnotation, let anno = pointAnnotation.annotation {
            if let pinAnnotationView = delegate?.mapView(mapViewProtocol, viewFor: anno)?.annotationViewImpl as? BMKAnnotationView{
                return pinAnnotationView
            }
        }
        return nil
    }

}
```

#### 第5步：测试页面
```swift
class PointAnnotationViewController: UIViewController {
    
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
    private lazy var annotations: Array<PointAnnotation> = {
        var annotations = Array<PointAnnotation>()
        
        let coordinates: [CLLocationCoordinate2D] = [
            CLLocationCoordinate2D(latitude: 39.992520, longitude: 116.336170),
            CLLocationCoordinate2D(latitude: 39.978234, longitude: 116.352343),
            CLLocationCoordinate2D(latitude: 39.998293, longitude: 116.348904),
            CLLocationCoordinate2D(latitude: 40.004087, longitude: 116.353915),
            CLLocationCoordinate2D(latitude: 40.001442, longitude: 116.353915),
            CLLocationCoordinate2D(latitude: 39.989105, longitude: 116.360200),
            CLLocationCoordinate2D(latitude: 39.989098, longitude: 116.360201),
            CLLocationCoordinate2D(latitude: 39.998439, longitude: 116.324219),
            CLLocationCoordinate2D(latitude: 39.979590, longitude: 116.352792)]
        
        for (idx, coor) in coordinates.enumerated() {
            var anno = factory.getPointAnnotation()
            anno.coordinate = coor
            anno.title = String(idx)
            
            annotations.append(anno)
        }
        return annotations
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        view.addSubview(mapView.getView())
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        mapView.addAnnotations(annotations)
        mapView.showAnnotations(annotations, animated: false)
    }

}

extension PointAnnotationViewController: MapViewDelegateProtocol {
    
    func mapView(_ mapView: MapViewProtocol, viewFor annotation: AnnotationProtocol) -> PinAnnotationViewProtocol? {
        
        if annotation.isKind(of: PointAnnotation.self) {
            
            let pointReuseIndetifier = "pointReuseIndetifier"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: pointReuseIndetifier)
            if annotationView == nil {
                annotationView = factory.getPinAnnotationView(annotation: annotation, reuseIdentifier: pointReuseIndetifier)
            }
            annotationView!.canShowCallout = true
            annotationView!.animatesDrop = true
            annotationView!.draggable = true
            annotationView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            
            let idx = annotations.index(of: annotation as! PointAnnotation)
            annotationView!.pinColor = PinAnnotationColor(rawValue: (idx ?? 3) % 3)!
            return annotationView
        }
        return nil
    }
}
```