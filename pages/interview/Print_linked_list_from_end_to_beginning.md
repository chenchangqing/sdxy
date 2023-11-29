# 从尾到头打印链表

**题目：输入一个链表的头节点，从尾到头反过来打印出每个节点的值链表节点定义如下：**
```c
struct ListNode
{
	int m_nKey;
	ListNode* m_pNext;
};
```
看到这道题后，很多人的第一反应是从头到尾输出将会比较简单，于是我们很自然地想到把链表中链接节点的指针反转过来，改变链表的方向，然后就可以从头到尾输出了。但该方法会改变原来链表的结构。是否允许在打印链表的时候修改链表的结构？这取决于面试官的要求，因此在面试的时候我们要询问清楚面试官的要求。

>面试小提示：在面试中，如果我们打算修改输入的数据，则最好先问面试官是不是允许修改。

通常打印是一个只读操作，我们不希望打印时修改内容。假设面试官也要求这个题目不能改变链表的结构。

接下来我们想到解决这个问题肯定要遍历链表。遍历的顺序是从头到尾，可输出的顺序却是从尾到头。也就是说，第一个遍历到的节点最后一个输出，而最后一个遍历到的节点第一个输出。这就是典型的“后进先出”，我们可以用栈实现这种顺序。每经过一个节点的时候，把该节点放到一个栈中。当遍历完整个链表后，再从栈顶开始逐个输出节点的值，此时输出的节点的顺序己经反转过来了。这种思路的实现代码如下：

```c
#include "..\Utilities\List.h"
#include <stack>

void PrintListReversingly_Iteratively(ListNode* pHead)
{
    std::stack<ListNode*> nodes;

    ListNode* pNode = pHead;
    while(pNode != nullptr)
    {
        nodes.push(pNode);
        pNode = pNode->m_pNext;
    }

    while(!nodes.empty())
    {
        pNode = nodes.top();
        printf("%d\t", pNode->m_nValue);
        nodes.pop();
    }
}
```
既然想到了用栈来实现这个函数，而递归在本质上就是一个栈结构，于是很自然地又想到了用递归来实现。要实现反过来输出链表，我们每访问到一个节点的时候，先递归输出它后面的节点，再输出该节点自身，这样链表的输出结果就反过来了。

基于这样的思路，不难写出如下代码：

```c
void PrintListReversingly_Recursively(ListNode* pHead)
{
    if(pHead != nullptr)
    {
        if (pHead->m_pNext != nullptr)
        {
            PrintListReversingly_Recursively(pHead->m_pNext);
        }
 
        printf("%d\t", pHead->m_nValue);
    }
}
```

上面的基于递归的代码看起来很简洁，但有一个问题：当链表非常长的时候，就会导致函数调用的层级很深，从而有可能导致函数调用栈溢出。显然用栈基于循环实现的代码的鲁棒性要好一些。更多关于循环和递归的讨论，详见本书的2.4.1节。

> 剑指 Offer P58，本题完整的源代码：https://github.com/zhedahht/CodingInterviewChinese2/tree/master/06_PrintListInReversedOrder