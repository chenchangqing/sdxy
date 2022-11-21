# 排序算法

> ## 冒泡排序

```swift
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

testSort()
```

> ## 选择排序

```swift
/// 选择排序
///
/// - Parameter list: 需要排序的数组
func selectionSort(_ list: inout [Int]) -> Void {
    for j in 0..<list.count - 1 {
        var minIndex = j
        for i in j+1..<list.count {
            if list[minIndex] > list[i] {
                minIndex = i
            }
        }
        list.swapAt(j, minIndex)
    }
}
```

> ## 插入排序

```swift
func insertSort(list: inout [Int]) {
    for i in 1..<list.count {
        let temp = list[i]
        for j in (0...i).reversed() {
            if list[j] > temp {
                list.swapAt(j, j+1)
            }
        }
    }
}
```

> ## 希尔排序

```swift
public func insertSort(_ list: inout[Int], start: Int, gap: Int) {
    for i in stride(from: (start + gap), to: list.count, by: gap) {
        let currentValue = list[i]
        var pos = i
        while pos >= gap && list[pos - gap] > currentValue {
            list[pos] = list[pos - gap]
            pos -= gap
        }
        list[pos] = currentValue
    }
}

public func shellSort(_ list: inout [Int]) {
    var sublistCount = list.count / 2
    while sublistCount > 0 {
        for pos in 0..<sublistCount {
            insertSort(&list, start: pos, gap: sublistCount)
        }
        sublistCount = sublistCount / 2
    }
}

var arr = [64, 20, 50, 33, 72, 10, 23, -1, 4, 5]

shellSort(&arr)
```

> ## 快速排序

```swift
func quicksort<T: Comparable>(_ a: [T]) -> [T] {
  guard a.count > 1 else { return a }

  let pivot = a[a.count/2]
  let less = a.filter { $0 < pivot }
  let equal = a.filter { $0 == pivot }
  let greater = a.filter { $0 > pivot }

  return quicksort(less) + equal + quicksort(greater)
}
```

> ## 归并排序

```swift
func mergeSort(_ array: [Int]) -> [Int] {
  guard array.count > 1 else { return array }    // 1

  let middleIndex = array.count / 2              // 2

  let leftArray = mergeSort(Array(array[0..<middleIndex]))             // 3

  let rightArray = mergeSort(Array(array[middleIndex..<array.count]))  // 4

  return merge(leftPile: leftArray, rightPile: rightArray)             // 5
}
```

> ## 堆排序

```swift
func heapSort(_ array : inout Array<Int>){
    //1、构建大顶堆
    
    //从二叉树的一边的最后一个结点开始
    for i in (0...(array.count/2-1)).reversed() {
        //从第一个非叶子结点从下至上，从右至左调整结构
        SortSummary.adjustHeap(&array, i, array.count)
    }
    //2、调整堆结构+交换堆顶元素与末尾元素
    for j in (1...(array.count-1)).reversed() {
        //将堆顶元素与末尾元素进行交换
        array.swapAt(0, j)
        //重新对堆进行调整
        SortSummary.adjustHeap(&array, 0, j)
    }
}

//调整大顶堆（仅是调整过程，建立在大顶堆以构建的基础上）
func adjustHeap(_ array : inout Array<Int>, _ i : Int, _ length : Int){
    var i = i
    //取出当前元素i
    let tmp = array[i]
    var k = 2*i+1
    //从i结点的左子节点开始，也就是2i+1处开始
    while k < length {
        //如果左子节点小于右子节点，k指向右子节点
        if k+1<length && array[k]<array[k+1]{
            k += 1
        }
        //如果子节点大于父结点，将子节点值赋给父结点，不用进行交换
        if array[k]>tmp {
            array[i] = array[k]
            //记录当前结点
            i = k
        }else{
            break
        }
        //下一个结点
        k = k*2+1
    }
    //将tmp值放到最终的位置
    array[i] = tmp
}
```

> ## 参考

[Swift算法俱乐部-希尔排序](https://juejin.cn/post/6844903749702385671)  
[Swift算法俱乐部-归并排序](https://www.jianshu.com/p/3a5d24c28c85)  
[swift算法之排序：（四）堆排序](https://blog.csdn.net/lin1109221208/article/details/90694015)
[十大经典排序算法](https://www.runoob.com/w3cnote/ten-sorting-algorithm.html)  
[常用算法面试题](https://github.com/josercc/iOS-Interview/blob/master/%E5%B8%B8%E7%94%A8%E7%AE%97%E6%B3%95%E9%9D%A2%E8%AF%95%E9%A2%98.md)  
[Swift算法俱乐部-快速排序](https://juejin.cn/post/6844903750042140685)  
[Sort](https://github.com/gl-lei/algorithm/tree/master/Sort)