# Functions and Methods

* functions：跟对象不关联
* methods：跟对象关联

> Python function default return value is None.

## help

* 使用`help`查看functions的参数
* 查阅文档：https://docs.python.org/3.12/tutorial/datastructures.html

```python
myList = [1, 2, 3, 4]
myList.insert(2, 10)
print(myList)  # [1, 2, 10, 3, 4]
"""
Help on built-in function insert:

insert(index, object, /) method of builtins.list instance
    Insert object before index.
"""
help(myList.insert)
```

## def

定义function格式：

```python
def functionName(input1, input2, ...):
	function code here
```

example:

```python
def sayHi():
	print("Hello, how are you")

# function execution, invokation
print(sayHi)
sayHi()
```

example2:

```python
def addition(x, y):
	print(x + y)
addition(15, 35)
```

## gloabl variables, local variable

```python
a = 5 # global variable

def f1():
	x = 2  # f1 function`s local variable
	y = 3  # f1 function`s local variable
	print(x, y, a)

def f2():
	x = 10  # f2 function`s local variable
	y = 17  # f2 function`s local variable
	print(x, y, a)

f2()
print(a)
```

## copy by value

```python
a = 10

# parameters (inputs) are local variables in the funtion

def change(num):
	# num = a (copy by value) => num = 10
	num = 25

change(a)
print(a)  # 10
```

can we ever change any copy by value global variables?

```python
a = 100

def change(num):
	global a
	a = 25

change(a)
print(a) # 25
```

## copy by reference


```python

a = [1, 2, 3, 4]

# parameters (inputs) are local variables in the funtion

def change(lst):
	# lst = a (copy by reference)
	lst[0] = 100

change(a)
print(a)  # [100, 2, 3, 4]
```

## comment function

```python
def myAddition(a, b):
	"""This function does addtion for inputs a and b"""
	print(a + b)

help(myAddition)
```

## return

```python
def myAddition(a, b):
	return a + b

print(myAddition(10, 18) + myAddition(26, 19) + myAddition(15, 17))  # 105
```

## python playground

```python
# Use exit() or Ctrl-D (i.e. EOF) to exit
(base) chenchangqingdeMacBook-Pro-2:python_practice chenchangqing$ python
Python 3.12.4 | packaged by Anaconda, Inc. | (main, Jun 18 2024, 10:14:12) [Clang 14.0.6 ] on darwin
Type "help", "copyright", "credits" or "license" for more information.
>>> 26 * 3
78
```

## import functions

之前使用过的`import`:

* `import math`
* `from sys import argv`

Some other common modules include:

* request - 网络请求, bs4(for web scraping) - 网络爬虫
* numpy - 图表, pandas, matplotlib, seaborn(data visualization)
* random, sklearn, tensorflow(machine learning, deep learning) - 人工智能


Why is Python designed in this way?

* 更少编译时间，因为按需使用
* 使用命名空间，解决同名函数编译问题

## keyword arguments

positional arguments:
```python
def exponent(a, b)
	return a ** b

# positional arguments
print(exponent(2, 3))
print(exponent(3, 2))
```

keyword arguments:
```python
def exponent(a, b):
	return a ** b

# keyword arguments
print(exponent(b = 2, a = 10))

myList = [4, 6, 3, 2, 1]

# myList is positional argument
# reverse is keyword arguments
print(sorted(myList, reverse = False)) # [1, 2, 3, 4, 6]
```

## default arguments

when we define default arguments, we have to put all of them at the end; oterwise, we will see: `SyntaxError:non-default argument follows default argument`.

error:
```python
def sum(n1=10, n2):
	return n1 + n2
print(sum(12))  # SyntaxError: parameter without a default follows parameter with a default
```

correct:
```python
# default argument
def sum(n1, n2 = 0):
	return n1 + n2

print(sum(12))  # 12
print(sum(12, 25))  # 37

```

## arbitrary（任意）number of arguments

*args:

```python
def sum(*args):
	print(args)  # (1, 2, 3, 4, 5)
	print(type(args))  # <class 'tuple'>

sum(1, 2, 3, 4, 5)
```

```python
def sum(*args):
	result = 0 
	for number in range(0, len(args)):
		result += args[number]
		print(f"Now, the result is {result}")
	return result

print(sum(1, 2, 3, 4, 5))  # 15
```

**kwargs:

```python
def myfunc(**kwargs):
	print("{} is now {} years old.".format(kwargs["name"], kwargs["age"]))

myfunc(name="Wilson", age=25, address="Hawaii")
```

they can be used in one function at the same time as well.

```python
def myfunc(*args, **kwargs):
	print("I would like to eat {} {}".format(args[1], kwargs["food"]))

myfunc(14, 17, 13, "Hello", name="Wilson", food="eggs")
```

> `*args`可以写成`*whatever`，args可以是任意的，只不过是规范。

参数类型优先级：

```python
def func(p1, p2, p3="three", *args, **kwargs):
	print("---------------------")
	print(p1, p2, p3, args, kwargs)
"""
---------------------
1 2 3 (4, 5) {'x': 1, 'y': 3}
---------------------
1 2 3 (4,) {'x': 4}
---------------------
1 2 3 (4,) {}
---------------------
1 2 3 () {}
---------------------
1 2 three () {}
"""
func(1, 2, 3, 4, 5, x=1, y=3)
func(1, 2, 3, 4, x=4)
func(1, 2, 3, 4)
func(1, 2, 3)
func(1, 2)
```

## Higher-Order Function

```python
def higherOrder(fn):
	fn()

def smallfunc():
	print("Hello from small function.")

higherOrder(smallfunc)
```

map:

```python
def square(num):
	return num ** 2

myList = [-10, 3, 9, 8, 10]

for item in map(square, myList):
	print(item)
```

filter:

```python
def even(num):
	return num % 2 == 0

myList = [33213, 3243244, 32424, 423425]

for item in filter(even, myList):
	print(item)
```

## lambda expression

匿名方法

* 不给function名字
* 作为higher-order函数参数是，可以使用
* 自动return

```python
result = (lambda x: x**2)(5)
print(result)  # 25
```

```python
myTuple = (lambda x, y: (x + y, x - y))(15, 30)
print(myTuple[0])
print(myTuple[1])
```

lambda在higer-order function中使用：

```python
for item in map(lambda x: x**2, [15, 10, 5, 0]):
	print(item)

for item in map(lambda x: x % 2 == 0, [15, 10, 5, 0]):
	print(item)
```

## scope

```python
name = "Wilson"

def greet():
	name = "Grace"

	def hello():
		print("Hello, my name is " + name)

	def hello2():
		print("greeting from hello2")
		hello()

	hello()

greet()
```

> LEGB rule：先找local，再由内往外找，再找global，再找built-in(内建)

## UnboundLocalError

```python
a = "hello"

def change(x):
	if x:
		a = "We just changed a"  # a variable assignment
	print(a)  # Python created "a" local variable

change(True)

# UnboundLocalError: cannot access local variable 'a' where it is not associated with a value
# 因为`print(a)`后，a就是一个local variable，但是没有对a进行赋值，就会出现这样的错误
# 同样change中的a是一个local variable，而不是global variable。
# change(False) 
```

## functions are objects

functions are objects as well! Therefore, we can assignment functions to another function.

```python
def addition(a, b):
	return a + b

def subtraction(a, b):
	return a - b

addition = subtraction

print(addition(10, 5))
```

By knowing this, we should prevent variable assignment to the reserved words in Python.(Python won`t complain about this, but we will see bugs in our code.)

```python
str = "This is my string"
x = 25

# TypeError: 'str' object is not callable
print("hello", + str(x))
```

## naming restriction

* 以字母或_开头
* 区分大小写
* 不能是关键字，list 应该使用 lst
* 不可以用特殊符号，/?\()!@~+#

## naming convention(习惯)

Module name、Function name、Variable name: all lowercase, use _ if necessary
```python
formal_name = "Wilson Ren" # 更倾向
formalName = "Wilson Ren"  # (camelcase - 驼峰)
```
* Class name: Capitalized, Camelcase - 首字母大写，驼峰
* Constants: ALL CAPITALIZED, use _ if necessary

Comparision: No need for ==, just do if my_var:, if not my_var: - 尽量不用 ==

```python
haveBudget = True

if haveBudget:
	print("Buy house")
else:
	print("Don`t buy houses")
```
偏向用这种：
```python
not_have_budget = False

if not not_have_budget:
	print("Buy a house")
else:
	print("Don`t buy houses")
```

## Pythonic

* readable, clean, easy, clear

交换：
```python
a = 10
b = 5

a, b = b, a
```

自动解包：
```python
# get_user_id(id) returns a tuple (name, age)
name, age = get_user_id(id)
print("The user name is " + name)
print("The user age is " + age)
```

特有的比较：
```python
b = 50
if 10 < b < 100:
	print("b is in the range of 10 and 100")
```

use in:
```python
cmd = input("Give a command: ")
if cmd in ('dir', 'cd', 'echo'):
	print("valid command")
else:
	print("invalid command")
```

## zen of python

```python
(base) chenchangqingdeMacBook-Pro-2:python_practice chenchangqing$ python
Python 3.12.4 | packaged by Anaconda, Inc. | (main, Jun 18 2024, 10:14:12) [Clang 14.0.6 ] on darwin
Type "help", "copyright", "credits" or "license" for more information.
>>> import this
The Zen of Python, by Tim Peters

Beautiful is better than ugly.
Explicit is better than implicit.
Simple is better than complex.
Complex is better than complicated.
Flat is better than nested.
Sparse is better than dense.
Readability counts.
Special cases aren't special enough to break the rules.
Although practicality beats purity.
Errors should never pass silently.
Unless explicitly silenced.
In the face of ambiguity, refuse the temptation to guess.
There should be one-- and preferably only one --obvious way to do it.
Although that way may not be obvious at first unless you're Dutch.
Now is better than never.
Although never is often better than *right* now.
If the implementation is hard to explain, it's a bad idea.
If the implementation is easy to explain, it may be a good idea.
Namespaces are one honking great idea -- let's do more of those!
>>> 
```

https://zh.wikipedia.org/wiki/Python之禅

* 24.8.29 2.29 updated
