# 数组与指针

在C/C++中，数组和指针是既相互关联又有区别的两个概念。当我们声明一个数组时，其数组的名字也是一个指针，该指针指向数组的第一个元素。我们可以用一个指针来访问数组。但值得注意的是，C/C++没有记录数组的大小，因此在用指针访问数组中的元素时，程序员要确保没有超出数组的边界。下面通过一个例子来了解数组和指针的区别。运行下面的代码，请问输出是什么？

```c
int GetSize(int data[])
{
    return sizeof(data);
}

int main(int argc, const char * argv[]) {
    int data1[] = {1,2,3,4,5};
    int size1 = sizeof(data1);
    int* data2 = data1;
    int size2 = sizeof(data2);
    int size3 = GetSize(data1);
    printf("%d,%d,%d",size1,size2,size3);
    return 0;
}
```

答案是输出“20,4,4”。data1是一个数组，sizeof(data1)是求数组的大小。这个数组包含5个整数，每个整数占4字节，因此共占用20字节。data2声明为指针，尽管它指向了数组data1的第一个数字，但它的本质仍然是一个指针。在32位系统上，对任意指针求sizeof，得到的结果都是4。在C/C++中，当数组作为函数的参数进行传递时，数组就自动退化为同类型的指针。因此，尽管函数GetSize的参数data被声明为数组，但它会退化为指针，size3的结果仍然是4。

> 剑指 Offer P38