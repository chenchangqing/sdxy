 

# 第一章 概论（数据结构导论）

## 引言

数据结构（Data Structure）：是计算机<span style="border-bottom:2px solid; black;">组织</span>数据和<span style="border-bottom:2px solid; black;">存储</span>数据的方式。 

计算机解决问题的步骤：

- 建立数学模型
- 设计算法
- 编程实现算法

## 基本概念和术语

### 数据、数据元素和数据项

数据：所有被计算机<span style="border-bottom:2px solid; black;">存储</span>、<span style="border-bottom:2px solid; black;">处理</span>的对象。  
数据元素：<span style="border-bottom:2px solid; black;">数据的基本单位</span>，在程序中作为一个整体而加以考虑和处理。  
数据项：数据元素由数据项组成。在数据库中数据项又称为<span style="border-bottom:2px solid; black;">字段或域</span>。它是数据的不可分割的<span style="border-bottom:2px solid; black;">最小标识单位</span>。   
原始数据：实际问题中的数据。  

### 数据的逻辑结构

逻辑结构：数据元素之间的逻辑关系。  
逻辑结构的类型：<span style="border-bottom:2px solid; black;">集合</span>、<span style="border-bottom:2px solid; black;">线性结构</span>、<span style="border-bottom:2px solid; black;">树形结构</span>、<span style="border-bottom:2px solid; black;">图形结构</span>。  
线性结构：除了第一个和最后一个数据元素外，每个结点有<span style="border-bottom:2px solid; black;">一个前驱和一个后继</span>。  
树形结构：除根结点外，<span style="border-bottom:2px solid; black;">最多一个前驱，可以有多个后继</span>。  
- 逻辑结构与数据元素本身<span style="border-bottom:2px solid; black;">形式</span>、<span style="border-bottom:2px solid; black;">内容</span>无关。  
- 逻辑结构与数据元素的<span style="border-bottom:2px solid; black;">相对位置</span>无关。  
- 逻辑结构与所含<span style="border-bottom:2px solid; black;">结点个数</span>无关。  

### 数据的存储结构

存储结构：数据的逻辑结构在计算机中的实现。存储结构包含两部分：

- <span style="border-bottom:2px solid; black;">存储数据元素</span>。
- <span style="border-bottom:2px solid; black;">数据元素之间的关联方式</span>。

数据元素之间的关联方式：

- 顺序存储方式
- 链式存储方式
- 索引存储方式
- 散列存储方式

顺序存储方式：指所有存储结点存放在一个连续的存储区里。利用结点在存储器中的<span style="border-bottom:2px solid; black;">相对位置</span>来表示数据元素之间的逻辑关系。  
链式存储方式：指每个存储结点除了含有一个数据元素外，还包含指针，每个指针指向一个与本结点有逻辑关系的结点，<span style="border-bottom:2px solid; black;">用指针</span>表示数据元素之间的逻辑关系。

### 运算

- 建立
- 查找
- 读取
- 插入
- 删除

## 算法及描述

算法：规定了求解给定问题所需的<span style="border-bottom:2px solid; black;">处理步骤</span>及其<span style="border-bottom:2px solid; black;">执行顺序</span>，使得给定问题能在<span style="border-bottom:2px solid; black;">有限时间</span>内被求解。

## 算法分析

评价算法好坏的因素：

- 正确性：能正确地实现预定的功能，满足具体问题的需要。
- 易读性：易于阅读、理解和交流，便于调试、修改和扩充。
- 健壮性：即使输入非法数据，算法也能适当地做出反应或进行处理，不会产生预料不到的运行结果。
- 时空性：指该算法的时间性能和空间性能。

### 时间复杂度

算法运算时需要的总步数，通常是问题规模的函数。

如何确定算法的计算量？

- 可在算法中合理地选择一种或几种操作作为“基本操作”。
- 对给定的输入，确定算法<span style="border-bottom:2px solid; black;">共执行了多少次基本操作</span>，可将基本操作次数作为该算法的时间度量。

最坏时间复杂度：对相同输入数据量的不同输入数据，算法时间用量的最大值。  
平均时间复杂度：对所有相同输入数据量的各种不同输入数据，算法时间用量的平均值。

时间复杂度的计算先定义标准操作，在计算标准操作的<span style="border-bottom:2px solid; black;">次数</span>，得到一个标准操作的次数和问题规模的函数。然后取出函数的主项，就是它的时间复杂度的大O表示。

常数阶O(1)，对数阶O(log2^n)，线性阶O(n)，平方阶O(n^2)，立方阶O(n^3)

### 空间复杂度

算法执行时所占用的存储空间，通常是问题规模的函数。

空间复杂度：对一个算法在运行过程中<span style="border-bottom:2px solid; black;">临时占用存储空间大小的量度</span>。一个算法在执行期间所需要的存储空间量应包括以下三个部分：

- 程序代码所占用的空间；
- 输入数据所占用的空间；
- 辅助变量所占用的空间；

算法的空间复杂度指的是：算法中除输入数据占用的存储空间之外所需的附加存储空间的大小。
