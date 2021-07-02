#### 解决问题
1. 统一的异常占位处理
2. 代码复用性

---

#### 一、占位图封装

```swift
import Foundation
import GWI18n
import MJRefresh

extension UIView {
    private enum RuntimeKey {
        static let emptyView = UnsafeRawPointer(bitPattern: "emptyView".hashValue)
    }
}

public extension UIView {
    enum EmptyType {
        case custom(image: UIImage?, title: String?, top: CGFloat = 0) // 自定义
        case empty(Bool = true) // 无数据
        case netError // 无网络
        case serverError // 服务器错误
    }
    
    func showEmptyData(type: EmptyType = .empty(), reloadBlock: ((UIButton) -> Void)? = nil) {
        var emptyView: EmptyDataView!
        
        switch type {
        case let .empty(showReloadBt):
            emptyView = EmptyDataView(frame: CGRect(x: 0, y: 0, width: self.width, height: self.height))
            emptyView.logo_ImgV.image = UIImage(inUtilCore: "no_content")
            emptyView.desc_Lb.text = GWI18n.R.string.localizable.base_date_empty()
            if !showReloadBt {
                emptyView.reload_Btn.isHidden = true
            } else {
                emptyView.reload_Btn.isHidden = false
            }
        case .netError:
            emptyView = EmptyDataView(frame: CGRect(x: 0, y: 0, width: self.width, height: self.height))
            emptyView.logo_ImgV.image = UIImage(inUtilCore: "no_network")
            emptyView.desc_Lb.text = GWI18n.R.string.localizable.base_net_lost()
        case .serverError:
            emptyView = EmptyDataView(frame: CGRect(x: 0, y: 0, width: self.width, height: self.height))
            emptyView.logo_ImgV.image = UIImage(inUtilCore: "load_failure")
            emptyView.desc_Lb.text = GWI18n.R.string.localizable.base_loading_failed()
        case let .custom(image, title, top):
            emptyView = EmptyDataView(frame: CGRect(x: 0, y: top, width: self.width, height: self.height - top))
            emptyView.logo_ImgV.image = image
            emptyView.desc_Lb.text = title
        }
        emptyView.backgroundColor = .white
        emptyView.reload_block = reloadBlock
        emptyView.reload_Btn.setTitle(GWI18n.R.string.localizable.base_re_load(), for: .normal)
        
        if let scrollView = self as? UIScrollView {
            scrollView.mj_footer?.isHidden = true
        }
        self.emptyDataView = emptyView
    }
    
    func hideEmptyData() {
        if let scrollView = self as? UIScrollView {
            scrollView.mj_footer?.isHidden = false
        }
        self.emptyDataView = nil
    }
    
    private var emptyDataView: EmptyDataView? {
        set(newValue) {
            self.emptyDataView?.removeFromSuperview()
            objc_setAssociatedObject(self, RuntimeKey.emptyView!, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            guard let newView = newValue else {
                return
            }
            self.addSubview(newView)
            self.bringSubviewToFront(newView)
        }
        get {
            return objc_getAssociatedObject(self, RuntimeKey.emptyView!) as? EmptyDataView
        }
    }
}
```

#### 二、使用方法

```
/// 请求失败时显示默认占位图
self.tableView.showEmptyData(type: .netError) { [weak self] _ in
    /// 重新请求
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
        /// 隐藏占位图
        self?.tableView.hideEmptyData()
    }
}
```

#### 三、使用方法（新增）

基于GWNetwork的GWError重构，当网络请求时，如果没有网络会立马返回noNetwork的错误，所有增加传入error显示异常占位的方法:

```swift
// 根据错误显示占位
func showEmptyData(error: Swift.Error, reloadBlock: ((UIButton) -> Void)? = nil) {
    
    if let gwError = error as? GWError {
        // 服务器报错
        var emptyType: UIView.EmptyType = .serverError
        switch gwError {
        case let .client(cError):
            // 无网络
            if cError == .noNetwork {
                emptyType = .netError
            }
            break
        default:
            break
        }
        self.showEmptyData(type: emptyType, reloadBlock: reloadBlock)
    } else {
    
        self.showEmptyData(type: .serverError, reloadBlock: reloadBlock)
    }
}
```

如何使用：

```swift
}).catchError {[weak tableView, weak self] (error) -> Observable<Mutation> in
 
 	GWSwiftSpinner.hide()
 	tableView?.endLoadMore()
 	GWToast(error.localizedDescription)
 	// 空视图显示
 	tableView?.showEmptyData(error: error, reloadBlock: { (_) in
    	self?.action.onNext(.setup(messageTypeId: messageTypeId, page: page, tableView: tableView))
 	})
 	return PublishSubject<Mutation>()
}
```



