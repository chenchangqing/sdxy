# 控制语句

* 24.8.28 10:39 created

## if

* Comparison Operator: <, <=, > and so on
* Logical Operator: not, in, and, or
* Truthy and Falsy Values: [] and so on

```python
if True:
	print("This is so true!!")
else:
	print("This is false.")
```

```python
age = 15
if age < 8:
	print("Movie is free for you!!")
elif 8 <= age < 65:
	print("You need to pay $300!")
else
	print("You only need to pay $150!")
```

```python
if 5 > 3 and []:  # empty collection is falsy
	print("the condition is true")
else:
	print("the condition is false")
```

```python
k = True
# if k == True:
if k:
	print("Variable k is true")
else:
	print("Variable k is false")
```

example:
```python
# program asks user`s name
# cash
# Y/N
# program checks if the user as more than or equal to $30
name = input("Enter your name: ")  # excute `python ./try.py` in terminal
money = input("Enter your cash amount: ")
hungry = input("Are you hungry? Y/N")

if hungry == "Y":
    if int(money) >= 30:
        print(f"{name} should go eat breakfast.")
    else:
        print(f"{name} is hungry but might not have enough money to buy breakfast!")
elif hungry == "N":
    if int(money) >= 30:
        print(f"{name} has budget but doesn`t want to eat breakfast.")
    else:
        print(f"{name} has no money but is not hungry...")
else:
    print("Please make sure that you enter either Y or N.")
```

> 如果VSCode中的terminal还是2的版本，需要修改为3的版本：https://blog.csdn.net/weixin_43659913/article/details/103830210

## switch

python 3.10 news：https://docs.python.org/3.10/whatsnew/3.10.html

```python
match subject:
    case <pattern_1>:
        <action_1>
    case <pattern_2>:
        <action_2>
    case <pattern_3>:
        <action_3>
    case _:
        <action_wildcard>
```
example:
```python
lang = input("你希望学什么程式语言？")
match lang:
	case "JavaScript":
		print("你会成为网页前端开发人员")
	case "PHP":
		print("你会成为网页后端开发人员")
	case "Python":
		print("你会成为资料科学家")
	case "Kotlin":
		print("你会成为Android应用开发人员")
	case "Swift":
		print("你会成为iOS应用开发人员")
	case _:
		print("你会成为其他开发人员")
```
example2:
```python
day = input("今天星期几？")

match day:
	case "星期日" | "星期一":
		print("今日公休")
	case "星期六":
		print("今日营业半天")
	case _:
		print("今日正常营业")
```
example3:
```python
command = input("Where do your wanna go?")
print(command.split(" "))
match command.split(" "):
    case ["Go", "home"]:
        print("You wanna go home")
    case _:
        prnt("The system cannot determine where you wanna go.")
```
example4:
```python
name = input("Enter your name: ")  # excute `python ./try.py` in terminal
money = input("Enter your cash amount: ")
hungry = input("Are you hungry? Y/N")

match hungry:
    case "Y":
        if int(money) >= 30:
            print(f"{name} should go eat breakfast.")
        else:
            print(
                f"{name} is hungry but might not have enough money to buy breakfast!")
    case "N":
        if int(money) >= 30:
            print(f"{name} has budget but doesn`t want to eat breakfast.")
        else:
            print(f"{name} has no money but is not hungry...")
    case _:
        print("Please make sure that you enter either Y or N.")
```

## for and while loop

```python
for variable in iterable:
	do someting here
```

example:
```python
for letter in "Hello World":
    if (letter == letter.upper()):
        print(letter)
```
example2:
```python
myList = [1, 3, 5, 7, 9]
for num in myList:
	print(num)
```
example3:
```python
for a, b in [(1, 2), (3, 5), (5, 7)]:
	print(a + b)
```
example4:
```python
myDictionary = {"name": "Wilson", "age": 25}
for item in myDictionary:
	# name
	# age
	print(item)
```
example5:
```python
myDictionary = {"name": "Wilson", "age": 25}
for key, value in myDictionary.items():
	print(f"The key is {key}")
	print(f"The value is {value}")
```
while loop example:
```python
x = 0
while x < 5:
	print(x)
	x += 1
```
nested loop example:
```python
counter = 0
for i in "1234":
	for j in "abcdefg":
		print(i, j)
		counter += 1
print(f"counter is {counter}")
```
pass example:
```python
for i in "How are you":
	# 解决语法上的问题
	pass
```
> `if`、`function`都可以使用`pass`

break example:
```python
print("Before the for loop")
for i in "123456789":
	if i == "5":
		break
	else:
		print(i)
print("After the for loop")
```
break in nested loop example:
```python
for i in "123456789":
	for j in "abcdefg":
		if j == "c":
			break
		print(i, j)
```
> If the break statement is present in the nested loop, it terminates only those loops containing the break statement.

continue example:
```python
for i in "abcd":
	if i == "a":
		continue
	print(i)
```

## range function:
```python
range(start, stop, step)
```
* start，可选，默认0
* stop，必须，不包含stop位置的值
* step，可选，默认1

example:
```python
for i in range(5):
	# 0 1 2 3 4
	print(i)
```

example2:
```python
for i in range(10, 15):
	# 10 11 12 13 14
	print(i)
```

example3:
```python
for i in range(0, 100, 10):
	# 0 10 20 30 40 50 60 70 80 90
	print(i)
```

example4:
```python
for i in range(20, 15, -1):
	# 20 19 18 17 16
	print(i)
```

typecasting to list:
```python
# 不建议这么使用，range是为了节省空间，放进list就会马上占用空间
myList = list(range(0, 15, 2))
print(myList)
```

## enumerate

enumerate example:
```python
for counter, char in enumerate("How are you today?"):
	if counter < 10:
		print(char)
```

## zip

```python
x = [1, 2, 3]
y = ['A', 'B', 'C']
z = ['a', 'b', 'c', 'c']
for tuple in zip(x, y, z):
	# (1, 'A', 'a')
	# (2, 'B', 'b')
	# (3, 'C', 'c')
	print(tuple)
```

## comprehensions

no use comprehensions:
```python
x = [1, 2, 3, 4]
squared_x = []
for item in x:
	squared_x.append(item ** 2)
# [1, 4, 9, 16]
print(squared_x)
```

### list comprehensions

```python
new_list = [operation for variable in original_list if condition]
```
example:
```python
x = [1, 2, 3, 4]
squared_x = [item ** 2 for item in x if item > 2]
print(squared_x)
```

### dictionary comprehensions

```python
new_dict = {key: value(operatin) for variable in original_dict if condition}
```
example:
```python
x = [1, 2, 3, 4]
x_squared_dict = {item: item ** 2 for item in x if item > 2}
# {3: 9, 4: 16}
print(x_squared_dict)
```

### set comprehensions

```python
{operation for variable in original_set if condition}
```
example:
```python
x = [1, 2, 3, 4]
x_squared_set = {item ** 2 for item in x if item > 2}
print(x_squared_set)
```

### generator

```python
x = [1, 2, 3, 4]
x_squared_generator = (item ** 2 for item in x)
for i in x_squared_generator:
	print(i)
```

## word count

准备一个`myfile.txt`，根py文件同一个目录：
```
roses are red
sky is blue
syntax error in line 32
```

实现`wc myfile.txt `功能：
```
2      11      49 myfile.txt
```

准备`try.py`文件：
```python
from sys import argv

if len(argv) < 2:
	print("Please provide a filename")
else:
	file = open(argv[1])  # argv[0] is try.py
	lines = file.read()

	lines = lines.split("\n")
	word_count = 0
	letter_count = 0

	for line in lines:
		words = line.split(" ")
		word_count += len(words)
		letter_count += len(line)

	# ['roses are red', 'sky is blue', 'syntax error in line 32']
	print(lines)
	line_count = len(lines)
	# The line count is 2
	print(f"The line count is {line_count}")
	# The word count is 11
	print(f"The word count is {word_count}")
	# The letter count is 47
	print(f"The letter count is {letter_count}")
```

执行`try.py`:
```python
python try.py myfile.txt
```
* 24.8.28 16:21 updated



