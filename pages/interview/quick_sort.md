## 快速排序
24.7.2 update

实现步骤：

0  1 2	3  4  5  6  7  8  9  
72 6 57 88 60 42 83 73 48 85  
i                         j  
48 6 57 88 60 42 83 73 坑 85 a[0] = a[8];i++;  
   i                   j
48 6 57 坑 60 42 83 73 88 85 a[8] = a[3];j--;  
        i           j  
48 6 57 42 60 坑  83 73 88 85 a[3] = a[5]; i++;  
           i  j  
48 6 57 42 60 72 83 73 88 85 i==j;a[5] = 73;  
              ij  
x 6 57 42 60 x=48  x 73 88 85 x=83  
i          j       i        j   
42 6 57 x 60       73 x 88 85  
   i    j             ij  
42 6 x 57 60       73 83 88 85  
     ij            73 83 85 88  
42 6 48 57 60       
6 42 48 57 60  

6 42 48 57 60 72 73 83 85 88  

实现代码：
```c
//快速排序
void quick_sort(int s[], int l, int r)
{
    if (l < r)
    {
        //Swap(s[l], s[(l + r) / 2]); //将中间的这个数和第一个数交换 参见注1
        int i = l, j = r, x = s[l];
        while (i < j)
        {
            while(i < j && s[j] >= x) // 从右向左找第一个小于x的数
                j--;  
            if(i < j) 
                s[i++] = s[j];
            
            while(i < j && s[i] < x) // 从左向右找第一个大于等于x的数
                i++;  
            if(i < j) 
                s[j--] = s[i];
        }
        s[i] = x;
        quick_sort(s, l, i - 1); // 递归调用 
        quick_sort(s, i + 1, r);
    }
}
```

参考链接：https://www.runoob.com/w3cnote/quick-sort.html
