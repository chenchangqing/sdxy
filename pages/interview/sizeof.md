# sizeof

**面试官：**定义一个空的类型，里面没有任何成员变量和成员函数。对
该类型求sizeof，得到的结果是多少？  
**应聘者：**答案是1。

**面试官：**为什么不是0？  
**应聘者：**空类型的实例中不包含任何信息，本来求sizeof应该是0，但是当我们声明该类型的实例的时候，它必须在内存中占有一定的空间，否则无法使用这些实例。至于占用多少内存，由编译器决定。在Visual Studio中，每个空类型的实例占用1字节的空间。

**面试官：**如果在该类型中添加一个构造函数和析构函数，再对该类型求sizeof,得到的结果又是多少？  
**应聘者：**和前面一样，还是1。调用构造函数和析构函数只需要知道函数的地址即可，而这些函数的地址只与类型相关，而与类型的实例无关，编译器也不会因为这两个函数而在实例内添加任何额外的信息。

**面试官：**那如果把析构函数标记为虚函数呢？  
**应聘者：**C+的编译器一旦发现一个类型中有虚函数，就会为该类型生成虚函数表，并在该类型的每一个实例中添加一个指向虚函数表的指针。在32位的机器上，一个指针占4字节的空间，因此求sizeof得到4；如果是64位的机器，则一个指针占8字节的空间，因此求sizeof得到8。

测试代码：

```c
#include <iostream>
 
using namespace std;
 
class X {
    
};
 
class Y: public virtual X {
    
};
 
class Z: public virtual X {
 
};
 
class A: public Y, public Z {
 
};
 
int main() {
    int x = 0;
    x = sizeof(X);
    cout <<"x："<<x <<endl;
 
    int y = 0;
    y = sizeof(Y);
    cout << "y：" << y << endl;
 
    int z = 0;
    z = sizeof(Z);
    cout << "z：" << z << endl;
 
    int a = 0;
    a = sizeof(A);
    cout << "a：" << a << endl;
    return 0;
}
```

在Xcode上的执行结果：

```
x：1
y：8
z：8
a：16
```

>参考链接：https://blog.csdn.net/zhuiqiuzhuoyue583/article/details/92846054