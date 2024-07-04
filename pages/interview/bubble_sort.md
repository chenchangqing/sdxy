## 冒泡排序
24.7.4 update

排序步骤：

72 6 57 88 60 42 83 73 48 85  
6 57 72 60 42 83 73 48 85 88  
6 57 60 42 72 73 48 83 85   
6 57 42 60 72 48 73 83  
6 42 57 60 48 72 73  
6 57 42 48 60 72  
6 42 48 57 60 

代码实现：
```c
import Foundation

func bubbleSort (arr: inout [Int]) {
    for i in 0..<arr.count - 1 {
        for j in 0..<arr.count - 1 - i {
            if arr[j] > arr[j+1] {
                arr.swapAt(j, j+1)
            }
        }
    }
}

// 测试调用

func testSort () {
    // 生成随机数数组进行排序操作
    var list:[Int] = []
    for _ in 0...99 {
        list.append(Int(arc4random_uniform(100)))
    }
    print("\(list)")
    bubbleSort(arr:&list)
    print("\(list)")
}
```

参考链接：https://www.runoob.com/w3cnote/bubble-sort.html
