## 希尔排序

24.7.5 update

代码实现：

```java
public class ShellSort {
    //核心代码---开始
    public static void sort(Comparable[] arr) {
        int j;
        for (int gap = arr.length / 2; gap >  0; gap /= 2) {
            for (int i = gap; i < arr.length; i++) {
                Comparable tmp = arr[i];
                for (j = i; j >= gap && tmp.compareTo(arr[j - gap]) < 0; j -= gap) {
                    arr[j] = arr[j - gap];
                }
                arr[j] = tmp;
            }
        }
    }
    //核心代码---结束
    public static void main(String[] args) {

        int N = 2000;
        Integer[] arr = SortTestHelper.generateRandomArray(N, 0, 10);
        ShellSort.sort(arr);
        for( int i = 0 ; i < arr.length ; i ++ ){
            System.out.print(arr[i]);
            System.out.print(' ');
        }
    }
}
```

参考链接：https://www.runoob.com/data-structures/shell-sort.html