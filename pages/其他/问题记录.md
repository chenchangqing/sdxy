# 问题记录

## iOS 13.1.3下，修复UITextView富文本点击产生多次回调

创建富文本

```swift
// 删除
let result = NSMutableAttributedString(string: " \(GWLocalized.delete)")
let range = NSRange(location: 0, length: result.string.count)
result.addAttribute(NSAttributedString.Key.link, value: "Delete://", range: range)

result.addAttribute(NSAttributedString.Key.font, value: UIFont(regularFontWithSize: level == 1 ? 16 : 14)!, range: range)
textView?.tintColor = UIColor(hexString: "#848484")
```

点击富文本

```swift
// 点击事件
func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
    
    // fix:iphone 7 plus 13.1.3活动的评论，点击删除，弹出三个关闭框
    var recognizedTapGesture = false
    for ges in textView.gestureRecognizers ?? [] {
        if let tapGes = ges as? UITapGestureRecognizer, tapGes.state == .ended {
            recognizedTapGesture = true
        }
    }
    if !recognizedTapGesture {
        return true
    }
    
    if URL.scheme == "Delete" {
        
        let commentId = reactor?.currentState.comment.commentId
        let level = reactor?.currentState.level
        reactor?.action.onNext(.deleteComment(commentId: commentId, level: level))
        
    }
    return true
}
```
