# 数组中重复的数字2

> ## 题目二，不修改数组找出重复的数字。

**在一个长度为n+1的数组里的所有数字部在1~n的范面内，所以数组中至少有一个数字是重复的，请找出数组中任意一个重复的数字，但不能修改输入的数组。例如，如果输入长度为8的数组{2,3,5,4,3,2,6,7}，那么对应的输出是重复的数字2或者3。**

这一题看起来和上面的面试题类似。由于题目要求不能修改输入的数组，我们可以创建一个长度为n+1的辅助数组，然后逐一把原数组的每个数字复制到辅助数组。如果原数组中被复制的数字是m，则把它复制到辅助数组中下标为m的位置。这样很容易就能发现哪个数字是重复的。由于需要创建一个数组，该方案需要O(n)的辅助空间。

接下来我们尝试避免使用O(n)的辅助空间。为什么数组中会有重复的数字？假如没有重复的数字，那么在从1~n的范围里只有n个数字。由于数组里包含超过n个数字，所以一定包含了重复的数字。看起来在某范围里数字的个数对解决这个问题很重要。

我们把从1~n的数字从中间的数字m分为两部分，前面一半为1~m，后面一半为m+1~n。如果1~m的数字的数目超过m,那么这一半的区间里一定包含重复的数字；否则，另一半m+1~n的区间里一定包含重复的数字。我们可以继续把包含重复数字的区间一分为二，直到找到一个重复的数字。这个过程和二分查找算法很类似，只是多了一步统计区间里数字的数目。

我们以长度为8的数组{2,3,5,4,3,2,6,7}为例分析查找的过程。根据题目要求，这个长度为8的所有数字都在1~7的范围内。中间的数字4把1~7的范围分为两段，一段是1~4，另一段是5~7。接下来我们统计1～4这4个数字在数组中出现的次数，它们一共出现了5次，因此这4个数字中一定有重复的数字。

接下来我们再把1~4的范围一分为二，一段是1、2两个数字，另一段是3、4两个数字。数字1或者2在数组中一共出现了两次。我们再统计数字3或者4在数组中出现的次数，它们一共出现了三次。这意味着3、4两个数字中一定有一个重复了。我们再分别统计这两个数字在数组中出现的次数。接着我们发现数字3出现了两次，是一个重复的数字。

上述思路可以用如下代码实现：
```c
int countRange(const int* numbers, int length, int start, int end);

// 参数:
//        numbers:     一个整数数组
//        length:      数组的长度
// 返回值:             
//        正数  - 输入有效，并且数组中存在重复的数字，返回值为重复的数字
//        负数  - 输入无效，或者数组中没有重复的数字
int getDuplication(const int* numbers, int length)
{
    if(numbers == nullptr || length <= 0)
        return -1;

    int start = 1;
    int end = length - 1;
    while(end >= start)
    {
        // 0000 0010 >> 左移1位 0000 0101
        int middle = ((end - start) >> 1) + start;
        int count = countRange(numbers, length, start, middle);// 查找落在二分左区间内个数
        //cout << "start=" << start << endl << "middle=" << middle << endl << "end=" << end << endl<< "count=" << count << endl;
        if(end == start)// 二分不动了，停止，判断这个值count值
        {
            if(count > 1)
                return start;
            else
                break;
        }

        if(count > (middle - start + 1))// 如果落在左区间的个数大于区间范围，则这里面一定有重复，否则就去右区间看看
            end = middle;
        else
            start = middle + 1;
    }
    return -1;
}

int countRange(const int* numbers, int length, int start, int end)
{
    if(numbers == nullptr)
        return 0;

    int count = 0;
    for(int i = 0; i < length; i++)
        if(numbers[i] >= start && numbers[i] <= end)
            ++count;
    return count;
}
```
上述代码按照二分查找的思路，如果输入长度为n的数组，那么函数countRange将被调用O(logn)次，每次需要O(n)的时间，因此总的时间复杂度是O(nlogn)，空间复杂度为O(1)。和最前面提到的需要O(n)的辅助空间的算法相比，这种算法相当于以时间换空间。

需要指出的是，这种算法不能保证找出所有重复的数字。例如，该算法不能找出数组{2,3,5,4,3,2,6,7}中重复的数字2。这是因为在1~2的范围里有1和2两个数字，这个范围的数字也出现2次，此时我们用该算法不能确定是每个数字各出现一次还是某个数字出现了两次。

从上述分析中我们可以看出，如果面试官提出不同的功能要求（找出任意一个重复的数字、找出所有重复的数字)或者性能要求（时间效率优先、空间效率优先)，那么我们最终选取的算法也将不同。这也说明在面试中和面试官交流的重要性，我们一定要在动手写代码之前弄清楚面试官的需求。

> 剑指 Offer P41，本题完整的源代码：https://github.com/zhedahht/CodingInterviewChinese2/tree/master/03_02_DuplicationInArrayNoEdit