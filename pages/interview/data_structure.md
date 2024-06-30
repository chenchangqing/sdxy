# 数据结构

* 24.6.30 update

## 用数组实现栈

```c
/// 用数组实现栈
class Stack {
    var stack: [AnyObject]
    var isEmpty: Bool { stack.isEmpty }
    var peek: AnyObject? { stack.last }
    
    init() {
        stack = [AnyObject]()
    }
    
    func push(object: AnyObject) {
        stack.append(object)
    }
    
    func pop() -> AnyObject? {
        if (!isEmpty) {
            return stack.removeLast()
        } else {
            return nil
        }
    }
}
```

## 字典和集合

给出一个整型数组和一个目标值，判断数组中是否有两个数之和等于目标值。

```c
func twoSum(nums: [Int], _ target: Int) -> Bool {
    var set = Set<Int>()
    for num in nums {
        if set.contains(target - num) {
            return true
        }
        set.insert(num)
    }
    return false
}
```

给定一个整型数组中有且仅有两个数之和等于目标值，求这两个数在数组中的序列号。

```c
func twoSum2(nums: [Int], _ target: Int) -> [Int] {
    var dict = [Int: Int]()
    for (i, num) in nums.enumerated() {
        if let lastIndex = dict[target - num] {
            return [lastIndex, i]
        } else {
            dict[num] = i
        }
    }
    fatalError("No valid output")
}
```

## 字符串

给出一个字符串，要求将其按照单词顺序进行反转。比如，如果是“the sky is blue”，那么反转后的结果是“blue is sky the”。

```c
fileprivate func _swap<T>(_ chars: inout [T], _ p: Int, _ q: Int) {
    (chars[p], chars[q]) = (chars[q], chars[p])
}

fileprivate func _reverse<T>(_ chars: inout [T], _ start: Int, _ end: Int) {
    var start = start, end = end
    while start < end {
        _swap(&chars, start, end)
        start += 1
        end -= 1
    }
}

func reverseWords(s: String?) -> String? {
    guard let s = s else { return nil }
    var chars = Array(s), start = 0
    _reverse(&chars, 0, chars.count - 1)
    for i in 0 ..< chars.count {
        if i == chars.count - 1 || chars[i+1] == " " {
            _reverse(&chars, start, i)
            start = i + 2
        }
    }
    return String(chars)
}
```

## 链表

给出一个链表和一个值x，要求将链表中所有小于x的值放在左边，所有大于或等于x的值放到右边，并且原链表的结点顺序不能变。

```c
func partition(_ head: ListNode?, _ x: Int) -> ListNode? {
    let prevDummy = ListNode(0), postDummy = ListNode(0)
    var prev = prevDummy, post = postDummy
    var node = head
    while node != nil {
        if node!.val < x {
            prev.next = node
            prev = node!
        } else {
            post.next = node
            post = node!
        }
        node = node!.next
    }
    post.next = nil
    prev.next = postDummy.next
    return prevDummy.next
}
```

删除链表中倒数第n个节点，例：1，2，3，4，5，n = 2，返回1，2，3，5。

```c
func removeNthFromEnd(head: ListNode?, _ n: Int) -> ListNode? {
    guard let head = head else {
        return nil
    }
    let dumy = ListNode(0)
    dumy.next = head
    var prev: ListNode? = dumy
    var post: ListNode? = dumy
    for _ in 0 ..< n {
        if post == nil {
            break
        }
        post = post!.next
    }
    while post != nil && post!.next != nil {
        prev = prev!.next
        post = post!.next
    }
    prev!.next = prev!.next!.next
    return dumy.next
}
```

## 栈和队列

```c
/// 栈协议
protocol Stack {
    associatedtype Element
    var isEmpty: Bool { get }
    var size: Int { get }
    var peek: Element? { get }
    mutating func push(_ newElement: Element)
    mutating func pop() -> Element?
}
/// 栈实现
struct IntegerStack: Stack {
    typealias Element = Int
    private var stack = [Element]()
    var isEmpty: Bool { stack.isEmpty }
    var size: Int { stack.count }
    var peek: Int? { stack.last }
    
    mutating func push(_ newElement: Int) {
        stack.append(newElement)
    }
    
    mutating func pop() -> Int? {
        stack.popLast()
    }
}
/// 队列协议
protocol Queue {
    associatedtype Element
    var isEmpty: Bool { get }
    var size: Int { get }
    var peek: Element? { get }
    mutating func enqueue(_ newElement: Element)
    mutating func dequeue() -> Element?
}
/// 队列实现
struct IntegerQueue: Queue {
    typealias Element = Int
    private var left = [Element]()
    private var right = [Element]()
    var isEmpty: Bool { left.isEmpty && right.isEmpty }
    var size: Int { left.count + right.count }
    var peek: Int? { left.isEmpty ? right.first : left.last }
    mutating func enqueue(_ newElement: Int) {
        right.append(newElement)
    }
    mutating func dequeue() -> Int? {
        if left.isEmpty {
            left = right.reversed()
            right.removeAll()
        }
        return left.popLast()
    }
}
```

给出一个文件的绝对路径，要求将其简化。举个例子，路径是“/home/”，简化后为“/home”；路径是“/a/./b/../../c”，简化后为“/c”。

```c
func simplifyPath(path: String) -> String {
    /// 用数组来实现栈的功能
    var pathStack = [String]()
    /// 拆分原路径
    let paths = path.components(separatedBy: "/")
    for path in paths {
        /// 对于“.”我们直接跳过
        guard path != "." else { continue }
        /// 对于“..”使用pop操作
        if path == ".." {
            if (pathStack.count > 0) {
                pathStack.removeLast()
            }
        /// 对于空数组的特殊情况
        } else if path != "" {
            pathStack.append(path)
        }
    }
    /// 将栈中的内容转化为优化后的新路径
    let res = pathStack.reduce("") { total, dir in "\(total)/\(dir)" }
    /// 注意空路径的结果是“/”
    return res.isEmpty ? "/" : res
}
```

用栈实现队列

```c
/// 用数组实现栈
class Stack {
    var stack: [AnyObject]
    var isEmpty: Bool { stack.isEmpty }
    var peek: AnyObject? { stack.last }
    var size: Int { stack.count }

    init() {
        stack = [AnyObject]()
    }

    func push(object: AnyObject) {
        stack.append(object)
    }

    func pop() -> AnyObject? {
        if (!isEmpty) {
            return stack.removeLast()
        } else {
            return nil
        }
    }
}

/// 用栈实现队列
struct MyQueue {
    var stackA: Stack
    var stackB: Stack
    
    var isEmpty: Bool {
        stackA.isEmpty && stackB.isEmpty
    }
    
    var peek: Any? {
        shift()
        return stackB.peek
    }
    
    var size: Int {
        stackA.size + stackB.size
    }
    
    init() {
        stackA = Stack()
        stackB = Stack()
    }
    
    fileprivate func shift() {
        if stackB.isEmpty {
            while !stackA.isEmpty {
                stackB.push(object: stackA.pop()!)
            }
        }
    }
    
    func enqueue(object: AnyObject) {
        stackA.push(object: object)
    }
    
    func dequeue() -> AnyObject? {
        shift()
        return stackB.pop()
    }
}
```

用队列实现栈
```c
struct Queue {
    private var left = [AnyObject]()
    private var right = [AnyObject]()
    var isEmpty: Bool { left.isEmpty && right.isEmpty }
    var size: Int { left.count + right.count }
    var peek: AnyObject? { left.isEmpty ? right.first : left.last }
    mutating func enqueue(_ newElement: AnyObject) {
        right.append(newElement)
    }
    mutating func dequeue() -> AnyObject? {
        if left.isEmpty {
            left = right.reversed()
            right.removeAll()
        }
        return left.popLast()
    }
}

/// 用队列实现栈
class MyStack {
    var queueA: Queue
    var queueB: Queue
    
    init() {
        queueA = Queue()
        queueB = Queue()
    }
    
    var isEmpty: Bool {
        queueA.isEmpty && queueB.isEmpty
    }
    
    var peek: AnyObject? {
        shift()
        let peekObj = queueA.peek
        queueB.enqueue(queueA.dequeue()!)
        swap()
        return peekObj
    }
    
    var size: Int {
        queueA.size
    }
    
    func push(object: AnyObject) {
        queueA.enqueue(object)
    }
    
    func pop() -> AnyObject? {
        shift()
        let popObject = queueA.dequeue()
        swap()
        return popObject
    }
    
    private func shift() {
        while queueA.size != 1 {
            queueB.enqueue(queueA.dequeue()!)
        }
    }
    
    private func swap() {
        (queueA, queueB) = (queueB, queueA)
    }
}
```
## 二叉树

```c
/// 节点
class TreeNode {
    var val: Int
    var left: TreeNode?
    var right: TreeNode?
    init(_ val: Int) {
        self.val = val
    }
}

/// 计算树的深度
func maxDepth(root: TreeNode?) -> Int {
    guard let root = root else { return 0 }
    return max(maxDepth(root: root.left), maxDepth(root: root.right)) + 1
}

/// 判断一个二叉树是否为二叉查找树
func isValidBST(root: TreeNode?) -> Bool {
    _helper(node: root, nil, nil)
}

private func _helper(node: TreeNode?, _ min: Int?, _ max: Int?) -> Bool {
    guard let node = node else { return true }
    /// 所有右子树的值都必须大于根节点的值
    if let min = min, node.val <= min {
        return false
    }
    /// 所有左子树的值都必须小于根节点的值
    if let max = max, node.val >= max {
        return false
    }
    return _helper(node: node.left, min, node.val) && _helper(node: node.right, node.val, max)
}

/// 用栈实现的前序遍历
func preorderTraversal(root: TreeNode?) -> [Int] {
    var res = [Int]()
    var stack = [TreeNode]()
    var node = root
    
    while !stack.isEmpty || node != nil {
        if node != nil {
            res.append(node!.val)
            stack.append(node!)
            node = node!.left
        } else {
            node = stack.removeLast().right
        }
    }
    return res
}
```





