# 第二章 线性表（数据结构导论）

## 线性表的基本概念
---

线性表（Linear List）：是一种<span style="border-bottom:2px solid; black;">线性结构</span>，它是由n（n>=0）个数据元素组成的<span style="border-bottom:2px solid; black;">有穷序列</span>，数据元素又称结点。结点个数n称为表长。

基本特征：线性表中结点具有<span style="border-bottom:2px solid; black;">一对一</span>的关系，如果结点数不为零，则除起始结点没有直接前驱外，其他每个结点<span style="border-bottom:2px solid; black;">有且仅有一个直接前驱</span>；除终端结点没有直接后继外，其他每个结点<span style="border-bottom:2px solid; black;">有且仅有一个直接后继</span>。

线性表基本运算有：初始化、求表长、读表元素、定位、插入、删除。

## 顺序表
---

### 顺序表定义

线性表顺序存储的方法是：将表中的结点依次存放在计算机内存中一组连续的存储单元中，数据元素在线性表中的邻接关系决定它们在存储空间中的存储位置，即<span style="border-bottom:2px solid; black;">逻辑结构中相邻的结点其存储位置也相邻</span>。用顺序存储实现的线性表称为顺序表。一般使用数组来表示顺序表。

顺序表的结构定义如下：
```c
typedef struct 
{
	int num;
	char name[8];
	char sex[2];
	int age;
	int score;
} DataType;
const int Maxsize = 100;
typedef struct 
{
	DataType data[Maxsize];
	int length;
} SeqList;
SeqList L;
```

### 顺序表插入

首先将结点a(i)~a(n)依次向后移动一个元素的位置，这样空出第i个数据元素的位置；然后将x置入该空位，最后表长加1。
```c
void InsertSeqlist(SeqList L, DataType x, int i)
{
	if (L.length==Maxsize) exit("表已满");
	if (i<1||i>L.length+1) exit("位置错");
	for (int j = L.length; j >= i; j--)
		L.data[j] = L.data[j-1];
	L.data[i-1] = x;
	L.length++;
}
```

### 顺序表删除

如果i的值合法，当1<=i<=n-1时，将原表中第i+1，i+2，...，n个元素一次向左移动一个元素位置，以填补删除操作造成的空缺。当i=n时，直接将表长减1即可。
```c
void DeleteSeqlist(SeqList L, int i)
{
	if (i<1||i>L.length) exit("非法位置");
	for (int j = i; j < L.length; j++)
		L.data[j-1] = L.data[i];
	L.length--;
}
```

### 顺序表定位

i从0开始，作为扫描顺序表时的下标。如果表L中有一个结点的值等于x，或i等于L.length，则终止while循环。若while循环终止于i等于L.length，则未找到值为x的元素，返回0，否则返回值为x的元素的位置。
```c
int LocateSeqlist(SeqList L, DataType x)
{
	int i=0;
	while((i<L.length) && (L.data[i]!=x))
		i++;
	if (i<L.length) return i+1
	else return 0;
}
```

### 顺序表实现算法的分析

顺序表的插入、删除算法在时间性能方面是不理想的。

#### 插入

* 时间复杂度：O(n)
* 移动次数：n-i+1
* 平均移动次数：n/2

#### 删除

* 时间复杂度：O(n)
* 移动次数：n-i，最坏移动次数：n-1
* 平均移动次数：(n-1)/2

#### 定位

* 时间复杂度：O(n)

#### 读表长和读元素

* 时间复杂度：O(1)

## 线性表的链接存储
---

线性表的链接存储时指它的存储结构时链式的。线性表常见的链式存储结构有单链表、循环链表和双向循环链表，其中最简单的事单链表。

## 单链表
---

### 单链表定义
data部分称为数据域，用于存储线性表的一个数据元素，next部分称为指针域或链域，用于存放一个指针，该指针指向本结点所含数据元素的直接后继结点。

所有结点通过指针链接形成链表（Link List）。head称为头指针变量，该变量的值是指向单链表的第一个结点的指针。

链表中第一个数据元素结点称为链表的首结点。尾结点指针域的值NULL称为空指针，它不止向任何结点，表示链表结束。

如果head等于NULL，则表示该链表无任何结点，是空单链表。

单链表的类型定义：
```c
typedef struct node
{
	DataType data;
	struct node *next;
} Node, *LinkList;
LinkList head;
```
struct node表示链表的结点，结点包含两个域：数据域（data）和指针域（next）。数据域的类型为DataType，指针域存放该结点的直接后继结点的地址，类型为指向struct node的指针。

定义中通过typedef语句把struct node类型定义为Node，把struct node指针类型定义为LinkList，LinkList的实质是该链表的头指针类型。

### 单链表初始化

空表由一个头指针和一个头结点组成。初始化一个单链表首先需要创建一个头结点并将其指针域设为NULL，然后用一个LinkList类型的变量指向新创建的结点。
```c
LinkList InitateLinkList() 
{
	LinkList head;
	head=malloc(sizeof(Node));
	head->next=NULL;
	return head;
}
```

### 单链表求表长

在单链表存储结构中，线性表的表长等于单链表中数据原属的结点个数，即除了头结点以外的结点的个数。

通过结点的指针域来从头到为访问每一个结点，让工作指针p通过指针域逐个结点向尾结点移动，工作指针没向尾部移动一个结点，让计数器加1，直到工作指针p->next为NULL时，说明已经走到了表的尾部。计数器cnt的值即是表的长度。
```c
int LengthLinkList(LinkList head)
{
	Node *p=head;
	int cnt=0;
	while(p->next!=NULL)
	{
		p=p->next;
		cnt++;
	}
	return cnt;
}
```

### 单链表读表元素

通常给定一个序号i，查找线性表的第i个元素。从头指针出发，一直往后移动，直到第i个结点。
```c
Node * GetLinkList(LinkList head, int i)
{
	Node *p;
	p=head->next;
	int c=1;
	while((c<i) && (p!=NULL))
		p=p->next;c++;
	if (i==c) reutrn p; 
	else reuturn NULL:
}
```

### 单链表定位

线性表的定位运算，就是对给定表元素的值，找出这个元素的位置。从头到尾访问链表，直到找到需要的结点，返回其序号。若未找到，返回0。
```c
int LocateLinkList(LinkList head, DataType x)
{
	Node *p=head;
	p=p->next;
	int i=0;
	while(p!=NULL && p->data!=x) 
	{
		i++;
		p=p->next;
	}
	if (p!=NULL) return i+1;
	else return 0;
}
```

### 单链表插入

单链表的插入运算是将给定值为x的元素插入到链表head的第i个结点之前。

先找到链表的第i-1个结点q，然后，生成一个值为x的新结点p，p的指针域指向q的值接后继结点，q的指针域指向p。
```c
void InsertLinkList(LinkList head, DataType x, int i)
{
	Node *p, *q;
	if (i==1) q=head;
	else q=GetLinkList(head, i-1);
	if (q==NULL) exit("找不到插入的位置");
	else 
	{
		p=malloc(sizeof(Node));
		p->data=x;
		p->next=q->next;
		q->next=p;
	}
}
```

### 单链表删除

删除运算是给定一个值i，将链表中第i个结点从链表中移除。

将a（i）结点移出后，需要修改改结点的直接前驱结点a（i-1）的指针域，使其指向移出结点a（i）的直接后继结点。
```c
void DeleteLinkList(LinkList head, int i)
{
	Node *q;
	if (i==1) q=head;
	else q=GetLinkList(head, i-1);
	if (q!=NULL && q->next!=NUll)
	{
		p=q->next;
		q->next=p->next;
		free(p);
	}
	else ext("找不到要删除的结点");
}
```

## 参考
---

- [手把手教你数据结构c语言实现](https://www.kancloud.cn/digest/datastructbyc/143032)
- [数据结构](http://c.biancheng.net/view/3338.html)
- [C语言数据结构-顺序栈](https://blog.csdn.net/ahafg/article/details/49030093)