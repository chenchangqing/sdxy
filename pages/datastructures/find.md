# 第六章 查找

## 基本概念

查找表（Search Table）是由同一类型的数据元素构成的集合，它是一种以查找为“核心”，同时包括其他运算的非常灵活的数据结构。

关键字，简称键，是数据元素中某个数据项，可以用来标识数据元素，该数据项的值称为键值。

根据给定的某个值，在查找表中寻找一个其键值等于给定值的数据元素。若找到一个这样的数据元素，则称查找成功，此时的运算结果为该数据元素在查找表中的位置；否则，称查找不成功，此时的运算结果为一个特殊标志。

静态查找表是以具有相同特性的数据元素集合为逻辑结构，包括下列三种基本运算（但不包括插入和删除运算）：

- 建表Create（ST）：操作结果是生成一个由用户给定的若干数据元素组成的静态查找表ST；
- 查找Search（ST，key）：若ST中存在关键字值等于key的数据元素，操作结果为该数据元素的值，否则操作结果为空；
- 读表中元素Get（ST，pos）：操作结果是返回ST中pos位置上的元素。

## 静态查找表

### 顺序表上的查找

静态查找表最简单的实现方法是以顺序表为存储结构，静态查找表顺序存储结构的类型定义如下：
```c
const int Maxsize = 20;
typedef struct
{
	KeyType key;
	...
}TableElem;
typedef struct
{
	TableElem ele[Maxsize+1];
	int n;
}SqTable;
```
查找算法如下：
```c
int SearchSqTable(SqTable T, KeyType key)
{
	T.elem[0].key = key;
	i = T.n;
	while(T.elem[i].key! = key)
		i--;
	return i;
}
```
对于查找运算，其基本操作是“数据元素的键值与给定值的比较”，所以通常用“数据元素的键值与给定值的比较次数”作为衡量查找算法好坏的依据，称上述比较次数为查找长度。

### 有序表上的查找

如果顺序表中数据元素是按照键值大小的顺序排列的，则称为有序表。

二分查找的查找过程为每次用给定值与处在表中间位置的数据元素键值进行比较，确定给定值的所在区间，然后逐步缩小查找区间。重复以上过程直至找到或确认找不到该数据元素为止。
```c
int SearchBin(SqTable T, KeyType key)
{
	int low,high;
	low=1;high=T.n;
	while(low<=high)
	{
		mid=(low+high)/2;
		if (key==T.elem[mid].key) return mid;
		else if (key<T.elem[mid].key) high = mid-1;
		else low = mid+1;
	}
	return 0;
}
```

### 索引顺序表上的查找

1. 先确定待查数据元素所在的块；
2. 然后在块内顺序查找。

## 二叉排序树

实现动态查找的树表，这种树表的结构本身是在查找过程中动态生成的，即对于给定key，若表中存在与key相等的元素，则查找成功，不然插入关键字等于key的元素。

一颗二叉排序树（Binary Sort Tree）（又称二叉查找树）或者一颗空二叉树，或者是具有下列性质的二叉树：

1. 若它的左子树不空，则左子树上所有结点的键值均小于它的根结点键值；
2. 若它的右子树不空，则右子树上所有结点的键值大于它的根结点键值；
3. 根的左、右子树也分别为二叉排序树。

中序遍历一颗二叉排序树可得到一个键值的升序序列。

二叉排序树的二叉链表的类型定义如下：
```c
typedef struct btnode
{
	KeyType key;
	struct btnode *lchild, *rchild;
}BSTNode, *BinTree;
BinTree bst;
```

### 二叉排序树上的查找
```c
Bintree SearchBST(BinTree bst, KeyType key)
{
	if (bst==NULL) return NULL;
	else if (key==bst->key) return bst;
	else if (key<bst->key)
		return SearchBST(bst->lchild, key);
	else 
		return SearchBST(bst->rchild, key);
}
```
关键字比较的次数不超过二叉树的深度。

### 二叉排序树的插入

由于二叉排序树这种动树表是在查找过程中，不断地往树中插入不存在的键值而形成的，所有插入算法必须包含查找过程，并且是在查找不成功时进行插入新结点的操作。在二叉排序树上进行插入的原则是：必须要保证插入一个新结点后，仍为一颗二叉排序树。这个结点是查找不成功时查找路径上访问的最后一个结点的左孩子或右孩子。
```c
Bintree SearchBST(BinTree bst, KeyType key, BSTNode *f) 
{
	if (bst==NULL) return NULL;
	else if (key==bst->key) return bst;
	else if (key<bst->key) return SearchBST(bst->lchild, key, bst);
	else return SearchBST(bst->rchild, key, bst);
}

int InsertBST(BinTree bst, KeyType key)
{
	BSTNode *p, *t, *f;
	f = NULL;
	t = SearchBST(bst, key, f);
	if (t==NULL) 
	{
		p = malloc(sizeof(btnode));
		p->key = key;
		p->lchild = NULL;
		p->rchild = NULL;
		if (f==NULL) bst = p;
		else if (key<f->key) f->lchild = p;
		else f->rchild = p;
		return 1;
	} 
	else 
	{
		return 0;
	}
}
```

### 二叉排序树的查找分析

二叉排序树的平均查找长度是介于O（n）和 O（log2^n）之间的，其查找效率与树的形态有关。

## 散列表

为了使数据元素的存储位置和键值之间建立某种联系，以减少比较次数，本节介绍用散列技术实现动态查找表。

数据元素的键值和存储位置之间建立对应关系H称为散列函数，用键值通过散列函数获取存储位置的这种存储方式构造的存储结构称为散列表（Hash Table），这一映射过程称为散列。如果选定了某个散列函数H及相应的散列表L，则对每个数据元素X，函数值H（X.key）就是X在散列表L中的存储位置，这个存储位置也称为散列地址。

设有散列函数H和键值k1、k2，若k1!=k2，但是H（k1）= H（k2），则称这种现象为冲突，且称k1、k2室相对于H的同义词。

采用散列技术时需要考虑两个问题：
1. 如何构造（选择）“均匀的”散列函数
2. 用什么方法右效地解决冲突

### 常用散列法

#### 数字分析法

数字分析法又称数字选择法，其方法是收集所有可能出现的键值，排列在一起，对键值的每一位进行分析，选择分布较均匀的若干位组成散列地址。

#### 除留余数法

除留余数法是一种简单有效且最常用的构造方法，其方法是选择一个不大于散列表长n的正整数p，以键值除以p所得的余数作为散列地址。

#### 平方取中法

平方取中法以键值平方的中间几位作为散列地址。

#### 技术转换法

将键值看成另一种进制的数再转换成原来的进制的数，然后选其中几位作为散列地址。

### 散列表的实现

通常用来解决冲突的方法有以下几种：

1. 线性探测法
2. 二次探测法
3. 链地址法
4. 多重散列法
5. 公共溢出区法

### 散列表的基本操作算法

#### 链地址法散列表

```c
const int n=20;
typedef struct TagNode
{
	KeyType key;
	struct TagNode *next;
	...
}*Pointer, Node;
typedef Pointer LinkHash[n];
```
这种散列表查找的过程是首先计算给定值key的散列地址i，由它到指针向量中找到指向key的同义词子表的表头指针。然后，在该同义词子表中顺序查找键值为key的结点。
```c
Pointer SearchLinkHash(KeyType key, LinkHash HP)
{
	i = H(key);
	p = HP[i];
	if (p==NULL) return NULL;
	while((p!=NULL) && (p->key != key))
		p=p->next;
	return p;
}
```
散列表上的插入算法：
```c
void InsertLinkHash(KeyType key, LinkHash HP)
{
	if((SearchLinkHash(key, HP)) == NULL)
	{
		i=H(key);
		q=Pointer malloc(size(Node));
		q->key = key;
		q->next = HP[i];
		HP[i]=q;
	}
}
```
散列表删除算法：
```c
void DeleteLinkHash(KeyType key, LinkHash HP)
{
	i=H(key);
	if (HP[i]==NULL) return;
	else 
	{
		p=HP[i];
		if (p->key==key)
		{
			HP[i]=p->next;
			free(p);
			return;
		} else {
			while (p->next!=NULL)
			{
				q=p;
				p=p->next;
				if(p->key==key)
				{
					q->next=p->next;
					free(p);
					return;
				}
			}
		}
	}
}
```

#### 线性探测法散列表

散列表数据元素的类型定义如下：
```c
const int MaxSize = 20;
typedef struct
{
	KeyType key;
	...
}Element;
typedef Element OpenHash[MaxSize];
```
用线性探测法解决冲突的散列表查找运算的实现算法描述如下：
```c
int SearchOpenHash(KeyType key, OpenHash HL)
{
	/* 在散列表HL中查找键值为key的结点，成功时返回该位置；不成功时返回标志0，嘉定以线性探测法解决冲突 */
	d=H(key);
	i=d;
	while((HL[i].key!=NULL) && (HL[i].key!=key))
		i=(i+1)%m;
	if(HL[i].key==key)return i;
	else return 0;
}
```