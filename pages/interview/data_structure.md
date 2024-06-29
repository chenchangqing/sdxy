# 数据结构

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


