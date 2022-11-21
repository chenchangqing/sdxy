# 赋值运算符函数

> 题目：如下为类型CMyString的声明，请为该类型添加赋值运算符函数。

```c
class CMyString
{
public:
    CMyString(char* pData = nullptr);
    CMyString(const CMyString& str);
    ~CMyString(void);

    CMyString& operator = (const CMyString& str);

    void Print();
      
private:
    char* m_pData;
};
```

当面试官要求应聘者定义一个赋值运算符函数时，他会在检查应聘者写出的代码时关注如下几点：

* 是否把返回值的类型声明为该类型的引用，并在函数结束前返回实例自身的引用(*this)。只有返回一个引用，才可以允许连续赋值。否则，如果函数的返回值是void,则应用该赋值运算符将不能进行连续赋值。假设有3个CMyString的对象：strl、str2和str3,在程序中语句str1=str2=str3将不能通过编译。

* 是否把传入的参数的类型声明为常量引用。如果传入的参数不是引用而是实例，那么从形参到实参会调用一次复制构造函数。把参数声明为引用可以避免这样的无谓消耗，能提高代码的效率。同时，我们在赋值运算符函数内不会改变传入的实例的状态，因此应该为传入的引用参数加上const关键字。

* 是否释放实例自身已有的内存。如果我们忘记在分配新内存之前释放自身已有的空间，则程序将出现内存泄漏。

* 判断传入的参数和当前的实例(\*this)是不是同一个实例。如果是同一个，则不进行赋值操作，直接返回。如果事先不判断就进行赋值，那么在释放实例自身内存的时候就会导致严重的问题：当\*this和传入的参数是同一个实例时，一旦释放了自身的内存，传入的参数的内存也同时被释放了，因此再也找不到需要赋值的内容了。

> 经典的解法，适用于初级程序员

当我们完整地考虑了上述4个方面之后，可以写出如下的代码：

```c
CMyString& CMyString::operator = (const CMyString& str)
{
    if(this == &str)
        return *this;

    delete []m_pData;
    m_pData = nullptr;

    m_pData = new char[strlen(str.m_pData) + 1];
    strcpy(m_pData, str.m_pData);

    return *this;
}
```

> 考虑异常安全性的解法，高级程序员必备

在前面的函数中，我们在分配内存之前先用delete释放了实例m_pData的内存。如果此时内存不足导致new char抛出异常，则m_pData将是一个空指针，这样非常容易导致程序崩溃。也就是说，一旦在赋值运算符函数内部抛出一个异常，CMyString的实例不再保持有效的状态，这就违背了异常安全性(Exception Safety)原则。

要想在赋值运算符函数中实现异常安全性，我们有两种方法。一种简单的办法是我们先用new分配新内容，再用delete释放已有的内容。这样只在分配内容成功之后再释放原来的内容，也就是当分配内存失败时我们能确保CMyString的实例不会被修改。我们还有一种更好的办法，即先创建一个临时实例，再交换临时实例和原来的实例。下面是这种思路的参考代码：
```c
CMyString& CMyString::operator = (const CMyString& str)
{
    if(this != &str) 
    {
    	CMyString strTemp(str);
		char*pTemp=strTemp.m_pData;
		strTemp.m_pData=m_pData;
		m_pData=pTemp;
    }
    return *this;
}
```

在这个函数中，我们先创建一个临时实例strTemp,接着把strTemp.m_pData和实例自身的m_pData进行交换。由于strTemp是一个局部变量，但程序运行到if的外面时也就出了该变量的作用域，就会自动调用strTemp的析构函数，把strTemp.m_pData所指向的内存释放掉。由于strTemp.m_pData指向的内存就是实例之前m_pData的内存，这就相当于自动调用析构函数释放实例的内存。

在新的代码中，我们在CMyString的构造函数里用new分配内存。如果由于内存不足抛出诸如bad alloc等异常，但我们还没有修改原来实例的状态，因此实例的状态还是有效的，这也就保证了异常安全性。

> 源代码：https://github.com/zhedahht/CodingInterviewChinese2/tree/master/01_AssignmentOperator