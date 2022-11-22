# 链表

链表应该是面试时被提及最频繁的数据结构。链表的结构很简单，它由指针把若干个节点连接成链状结构。链表的创建、插入节点、删除节点等操作都只需要20行左右的代码就能实现，其代码量比较适合面试。而像哈希表、有向图等复杂数据结构，实现它们的一个操作需要的代码量都较大，很难在几十分钟的面试中完成。另外，由于链表是一种动态的数据结构，其需要对指针进行操作，因此应聘者需要有较好的编程功底才能写出完整的操作链表的代码。而且链表这种数据结构很灵活，面试官可以用链表来设计具有挑战性的面试题。基于上述几个原因，很多面试官都特别青睐与链表相关的题目。

我们说链表是一种动态数据结构，是因为在创建链表时，无须知道链表的长度。当插入一个节点时，我们只需要为新节点分配内存，然后调整指针的指向来确保新节点被链接到链表当中。内存分配不是在创建链表时一次性完成的，而是每添加一个节点分配一次内存。由于没有闲置的内存，链表的空间效率比数组高。如果单向链表的节点定义如下：

```c
struct ListNode
{
	int m_nValue;
	ListNode* m_pNext;
};
```
那么往该链表的末尾添加一个节点的C++代码如下：
```c
void AddToTail(ListNode**pHead, int value)
{
	ListNode* pNew = new ListNode();
	pNew->m_nValue = value;
	pNew->m_pNext = nullptr;
	if(*pHead == nullptr)
	{
		*pHead = pNew;	
	}
	else
	{
		ListNode* pNode = *pHead;
		while(pNode->m_pNext != nullptr)
			pNode = pNode->m_pNext;
		
		pNode->m_pNext = pNew;
	}
}
```

在上面的代码中，我们要特别注意函数的第一个参数pHead是一个指向指针的指针。当我们往一个空链表中插入一个节点时，新插入的节点就是链表的头指针。由于此时会改动头指针，因此必须把pHead参数设为指向指针的指针，否则出了这个函数pHead仍然是一个空指针。

由于链表中的内存不是一次性分配的，因而我们无法保证链表的内存和数组一样是连续的。因此，如果想在链表中找到它的第i个节点，那么我们只能从头节点开始，沿着指向下一个节点的指针遍历链表，它的时间效率为O(n)。而在数组中，我们可以根据下标在O(1)时间内找到第i个元素。下面是在链表中找到第一个含有某值的节点并删除该节点的代码：
```c
void RemoveNode(ListNode** pHead, int value)
{
	if(pHead == nullptr || *pHead == nullptr)
		return;
	ListNode* pToBeDeleted == nullptr;
	if((*pHead)->m_nValue == value)
	{
		pToBeDeleted = *pHead;
		*pHead = (*pHead)->m_pNext;
	}
	else
	{
		ListNode* pNode = *pHead;
		while(pNode->m_pNext != nullptr && pNode->m_pNext->m_nValue != value)
			pNode = pNode->m_pNext;

		if(pNode->m_pNext != nullptr && pNode->m_pNext->m_nValue == value)
		{
			pToBeDeleted = pNode->m_pNext;
			pNode->m_pNext = pNode->m_pNext->m_pNext;
		}
	}
	
	if(pToBeDeleted != nullptr)
	{
		delete pToBeDeleted;
		pToBeDeleted = nullptr;	
	}
}
```

> 剑指 Offer P56
