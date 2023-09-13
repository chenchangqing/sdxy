# 第三章 栈、队列和数组

## 栈
---

### 栈的基本概念

栈是运算受限的线性表，这种线性表上的插入和删除运算限定在表的某一端进行。允许进行插入和删除的一端称为栈顶，另一端称为栈底。不含任何数据元素的栈称为空栈。处于栈顶位置的数据元素称为栈顶元素。

栈的修改原则是后进先出，栈又称为后进先出线性表，简称后进先出表。

栈的基本运算：

- 初始化 InitStack(S)：构建一个空栈S；
- 判栈空 EmptyStack(S)：若栈S为空栈，则结果为1，否则结果为0；
- 进栈 Push(S, x)：将元素x插入栈S中，使x称为栈S的栈顶元素；
- 出栈Pop(S)：删除栈顶元素；
- 取栈顶 GetTop(S)：返回栈顶元素。

### 栈的顺序实现

栈的顺序存储结构式用一组连续的存储但愿依次存放栈中的每个元素，并用始端作为栈底。栈的顺序实现称为顺序栈。通常用一个一维数组和一个记录栈顶位置的变量来实现栈的顺序存储。

顺序栈用类C语言定义：
```c
const int maxsize=6;
typedef struct seqstack
{
	DataType data[maxsize];
	int top;
} SeqStk;
```
maxsize为顺序栈的容量。  
data[maxsize]为存储栈中数据元素的数组。  
top为标志栈顶位置的变量，常用整型表示，范围0～(maxsize-1)。

#### 初始化
```c
int InitStack(SeqStk *stk) 
{
	stk->top=0;
	return 1;
}
```

#### 判栈空
```c
int EmptyStack(SeqStk *stk)
{
	if (stk->top==0) return 1;
	else return 0;
}
```

#### 进栈
```c
int Push(SeqStk *stk, DataType x)
{
	if (stk->top==maxsize-1)
	{
		error("栈已满");return 0;
	} 
	else 
	{
		stk->top++;
		stk->data[stk->top]=x;
		return 1;
	}
}
```

#### 出栈
```c
int Pop(SeqStk *stk)
{
	if (EmptyStack(stk))
	{
		error("下溢");return 0;
	} 
	else 
	{
		stk->top--;
		return 1;
	}
}
```

#### 取栈顶元素
```c
DataType GetTop(SeqStk *stk)
{
	if (EmptyStack(stk))
	{
		return NULL;
	}
	else 
	{
		return stk->data[stk->top];
	}
}
```

### 栈的链接实现

栈的链接实现称为链栈，链栈可以用带头结点的单链表来实现。各个结点通过链域的链接组成栈，由于每个结点空间都是动态分配产生，链栈不用预先考虑容量的大小。

链栈用类C语言定义：
```c
typedef struct node 
{
	DataType data;
	struct node *next;
}LkStk;
```

#### 初始化
```c
void InitStack(LkStk *LS)
{
	LS = (LkStk *)malloc(sizeof(LkStk));
	LS->next=NULL;
}
```
生成一个结点，该结点的next域设置为NULL。

#### 判栈空
```c
int EmptyStack(LkStk *LS)
{
	if (LS->next==NULL)
	{
		return 1;
	}
	else 
	{
		return 0;
	}
}
```

#### 进栈
```c
void Push(LkStk *LS, DataType x)
{
	LkStk *temp;
	temp=(LkStk *)malloc(sizeof(LkStk));
	temp->data=x;
	temp->next=LS->next;
	LS->next=temp;
}
```

#### 出栈
```c
int Pop(LkStk *LS) 
{
	LkStk *temp;
	if (!EmptyStack(LS))
	{
		temp=LS->next;
		LS->next=temp->next;
		free(temp);
		return 1;
	}
	else
	{
		return 0;
	}
}
``` 

### 栈的简单应用和递归

递归是一个重要的概念，同时也是一种重要的程序设计方法。简单地说，如果在一个函数或数据结构的定义中又应用了它自身，那么这个函数或数据结构称为递归定义的，简称递归的。

递归定义不能是“循环定义”。为此要求任何递归定义必须同时满足如下两个条件：

- 被定义项在定义中的应用（即作为定义项的出现）具有更小的“规模”；
- 被定义项在最小“规模”上的定义是非递归的，这是递归的结束条件；

理解：
- 递归前进段
- 递归边界段
- 递归回归段

阶乘函数的递归算法：
```c
long f(int n) 
{
	if(n==0)return 1;
	else return n*f(n-1);
}
```

递归函数的运行引起递归调用。为了保证在不同层次的递归调用能正确的返回，必须将每一次递归调用的参数和返回地址保存起来。由于函数的递归是后进先出的，所以要用栈来保存这些值。

## 队列
---

### 队列的基本概念

队列是有限个同类型数据元素的线性序列，是一种先进先出的线性表，新加入的数据元素插在队列尾端，出队列的数据元素首部被删除。

列表的基本运算：

- 队列初始化 InitQueue(Q)：设置一个空队列Q；
- 判队列空 EmptyQueue(Q)：若队列Q为空，则返回值为1，否则返回值为0；
- 入队列 EnQueue(Q, x)：将数据元素x从对尾一端插入队列，使其成为队列的新尾元素；
- 出队列：OutQueue(Q)：删除队列首元素；
- 取队列首元素 GetHead(Q)：返回队列首元素的值。

### 队列的顺序实现

顺序存储实现的队列称为顺序队列，它由一个一维数组（用于存储队列中元素）及两个分贝指示队列首和队列尾元素的变量组成，这两个变量分别称为“队列首指针”和“队列尾指针”。

用类C语言定义顺序队列类型如下：
```c
const int maxsize=20;
typedef struct sequeue
{
	DataType data[maxsize];
	int front, rear;
}SeqQue;
SeqQue SQ;
```
顺序队列结构类型中有三个域：data、front和rear。其中data为一维数组，存储队列中数据元素。front和rear定义为整型变量，实际取值范围是0~(maxsize-1)。为了方便操作，规定front指向队列首元素的前一个单元，rear指向实际的队列元素单元。

假溢出：数组的实际空间并没有沾满，新元素无法进入队列。通过SQ.rear=0，把SQ.data[0]作为新的队列尾，可以解决“假溢出”问题。

用类C语言定义循环队列：
```c
typedef struct cycqueue
{
	DataType data[maxsize];
	int front, rear;
}CycQue;
```

#### 队列的初始化
```c
void InitQueue(CycQue CQ)
{
	CQ.front=0;
	CQ.rear=0;
}
```

#### 判队列空
```c
int EmptyQueue(CycQue CQ)
{
	if(CQ.rear==CQ.front) return 1;
	else return 0;
}
```

#### 入队列
```c
int EnQueue(CycQue CQ, DataType x)
{
	if ((CQ.rear+1)%maxsize==CQ.front)
	{
		error("队列满");return 0;
	}
	else 
	{
		CQ.rear=(CQ.rear+1)%maxsize;
		CQ.data[CQ.rear]=x;
		return 1;
	}
}
```

#### 出队列
```c
int OutQueue(CycQue CQ)
{
	if (EmptyQueue(CQ))
	{
		error("队列空");return 0;
	}
	else 
	{
		CQ.front=(CQ.front+1)%maxsize;
		return 1;
	}
}
```

#### 取队列首元素
```c
DataType GetHead(Cycle CQ)
{
	if (EmptyQueue(CQ))	
	{
		return NULL;
	} 
	else {
		return CQ.data[(CQ.front+1)%maxsize];
	}
}
```
