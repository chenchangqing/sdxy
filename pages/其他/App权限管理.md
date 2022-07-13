# App权限管理

GWUtilCore组件增加PrivacyManager，统一App内权限获取。

## 自定义隐私类型

目前App只涉及3种权限,定义如下：

```swift
/*
 * 隐私权限类型
 1. 在Info.plist文件中配置应用所需权限；
 2. 在项目的Targets->Capabilities中开启相应开关，目前Siri、Health、NFC、HomeKit需要开启；
 3. 引入相关库；
 4. 使用代码获取对应的隐私权限。
 */
public enum PrivacyType {
    // 相机 Authorized Denied Unsupported Unkonw
    case camera
    // 相册 NotDetermined Authorized Denied Restricted Unkonw
    case photos
    // 定位 NotDetermined Unkonw Denied Authorized:AuthorizedAlways||AuthorizedWhenInUse
    case location
    
    public var title: String {
        ......
    }
    
    public var subTitle: String {
        ......
    }
    
    public static var all :[PrivacyType] {
        return [.location , .camera , .photos]
    }
}
```

## 自定义权限类型

将权限结果统一包装为自定义的类型，定义如下：

```swift
/// 获取隐私权限结果
public enum AuthorizationStatus{
    // 未知
    case unknow
    // 授权
    case authorized
    // 拒绝
    case denied
    // 不支持
    case unsupported
    // 未决定（相册，地理位置）
    case notDetermined
    
    public var title: String {
        ......
    }
    
    public var titleColor: UIColor? {
        ......
    }
}
```

## 隐私权限管理

`PrivacyManager`提供两个请求隐私权限的类方法,定义如下：

`synRequestAccess`方法为同步方法，可以同步获取指定隐私的权限。
```swift
/// 同步请求隐私权限
/// - Parameter type: 隐私权限类型
/// - Returns: 隐私权限
public static func synRequestAccess(_ type: PrivacyType) -> AuthorizationStatus {
    switch type {
    case .photos:
        return shared.requestAccessPhotos(nil)
    case .location:
        return shared.requestAccessLocation(nil)
    case .camera:
        return shared.requestAccessCamera(nil)
    }
}
```

`asynRequestAccess`方法为异步方法，通过传入`completionHandle`异步获取隐私的权限，如果是第一次会触发询问窗口，当用户决定后，`completionHandle`会将决定后的结果返回。

```swift
/// 异步请求隐私权限
/// - Parameters:
///   - type: 隐私权限类型
///   - completionHandle: 隐私权限结果代码块
public static func asynRequestAccess(_ type: PrivacyType , completionHandle: ((AuthorizationStatus) -> Void)?) {
    switch type {
    case .photos:
        _ = shared.requestAccessPhotos(completionHandle)
        break
    case .location:
        _ = shared.requestAccessLocation(completionHandle)
        break
    case .camera:
        _ = shared.requestAccessCamera(completionHandle)
        break
}
```

## 请求权限实现

```swift
extension PrivacyManager: CLLocationManagerDelegate {
    
    /// 在主线程回调隐私权限结果
    /// - Parameters:
    ///   - status: 隐私权限结果
    ///   - completionHandle: 隐私权限结果代码块
    private func response(status: AuthorizationStatus, completionHandle: ((AuthorizationStatus) -> Void)?) {
        DispatchQueue.main.async {
            completionHandle?(status)
        }
    }
    
    // MARK: 请求相机访问权限
    func requestAccessCamera(_ completionHandle: ((AuthorizationStatus) -> Void)?) -> AuthorizationStatus {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            if status == .notDetermined {
                if completionHandle != nil {
                    AVCaptureDevice.requestAccess(for: .video) {  [weak self] (granted) in
                        if granted{
                            self?.response(status: .authorized, completionHandle: completionHandle)
                        }
                        else {
                            self?.response(status: .denied, completionHandle: completionHandle)
                        }
                    }
                }
                return .notDetermined
            }
            else if status == .authorized{
                response(status: .authorized, completionHandle: completionHandle)
                return .authorized
            }
            else if status == .denied || status == .restricted{
                response(status: .denied, completionHandle: completionHandle)
                return .denied
            }
            else {
                response(status: .unknow, completionHandle: completionHandle)
                return .unknow
            }
        }
        else{
            response(status: .unsupported, completionHandle: completionHandle)
            return .unsupported
        }
    }
    
    // MARK: 请求相册权限
    func requestAccessPhotos(_ completionHandle: ((AuthorizationStatus) -> Void)?) -> AuthorizationStatus {
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .notDetermined {
            if completionHandle != nil {
    
                PHPhotoLibrary.requestAuthorization { [weak self] (status) in
                    if status == .notDetermined{
                        self?.response(status: .notDetermined, completionHandle: completionHandle)
                    }
                    else if status == .denied || status == .restricted {
                        self?.response(status: .denied, completionHandle: completionHandle)
                    }
                    else{
                        self?.response(status: .authorized, completionHandle: completionHandle)
                    }
                }
            }
            return .notDetermined
        }
        else if status == .authorized {
            response(status: .authorized, completionHandle: completionHandle)
            return .authorized
        }
        else if status == .denied || status == .restricted {
            response(status: .denied, completionHandle: completionHandle)
            return .denied
        }
        else{
            response(status: .unknow, completionHandle: completionHandle)
            return .unknow
        }
    }
    
    // MARK: 请求定位权限
    func requestAccessLocation(_ completionHandle: ((AuthorizationStatus) -> Void)?) -> AuthorizationStatus {
        let status = CLLocationManager.authorizationStatus()
        let serviceEnabled = CLLocationManager.locationServicesEnabled()
        if !serviceEnabled {
            return .unsupported
        }
        else if status == .notDetermined {
            if completionHandle != nil {
                PrivacyManager.shared.locationCompletionBlock = completionHandle
                let loc = CLLocationManager()
                loc.delegate = PrivacyManager.shared
                loc.requestWhenInUseAuthorization()
                loc.startUpdatingLocation()
                PrivacyManager.shared.locationManager = loc
            }
            return .notDetermined
        }
        else if status == .denied || status == .restricted {
            response(status: .denied, completionHandle: completionHandle)
            return .denied
        }
        else if status == .authorizedAlways || status == .authorizedWhenInUse{
            response(status: .authorized, completionHandle: completionHandle)
            return .authorized
        }
        else{
            response(status: .unknow, completionHandle: completionHandle)
            return .unknow
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            response(status: .notDetermined, completionHandle: PrivacyManager.shared.locationCompletionBlock)
            break
        case .denied, .restricted:
            response(status: .denied, completionHandle: PrivacyManager.shared.locationCompletionBlock)
            PrivacyManager.shared.locationCompletionBlock = nil
            break
        case .authorizedAlways, .authorizedWhenInUse:
            response(status: .authorized, completionHandle: PrivacyManager.shared.locationCompletionBlock)
            PrivacyManager.shared.locationCompletionBlock = nil
            break
        @unknown default:
            response(status: .unknow, completionHandle: PrivacyManager.shared.locationCompletionBlock)
            PrivacyManager.shared.locationCompletionBlock = nil
            break
        }
    }
}
```

