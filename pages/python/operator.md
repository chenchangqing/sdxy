# 操作符

* 24.8.28 10:17 created

## and

```python
a = True
b = False
print(a and b)  # False
```

## or

```python
a = True
b = False
print(a or b)  # True
```

## not

```python
a = True
print(not a)  # False
```

## operator - &

```python
a = 60  # 0000 1100
b = 13  # 0000 1101
print(a & b) # 12 0000 1100
```

## operator - |

```python
a = 60  # 0000 1100
b = 13  # 0000 1101
print(a | b) # 61 0000 1101
```

## operator - ^
```python
a = 60  # 0000 1100
b = 13  # 0000 1101
print(a ^ b)  # 49 0011 0001
```

## operator - ~
```python
a = 60  # 0000 1100
print(~a)  # -61
```

## operator - <<
```python
a = 60  # 0000 1100
print(a << 2)  # 240 1111 0000
```

## operator - >>
```python
a = 60  # 0000 1100
print(a >> 2)  # 15 0000 1111
```

## Truthy and Falsy Values

以下Collections、Sequences是假的（Falsy）：
* Empty lists []
* Empty tuples []
* Empty dictionaries {}
* Empty sets set()
* Empty strings ""
* Empty ranges range(0)

以下numbers是假的：

* Integer: 0
* Float: 0.0
* Complex: 0j

以下constant是假的：

* None
* False

真的值：

* 不为空的Collections、Sequences
* 不为0的数字
* True

```python
# case 1
print(3 and 1)  # True
# case 2
if 3:
	print(True)
if []:
	print("empty list is true in boolean context")
else:
	print("empty list is false in boolean context")  # 走这里
print(bool(""))  # False
print(bool("Wilson"))  # True
```

## short circuit

* 例如：如果 `a and b`，a为`False`，那么不需要检查b，这个表达式就是`False`
* 例如：如果 `a or b`， a为`True`，那么也不需要检查b，这个表达式就是`True`

```python 
# case 1
print([] and [])  # []
# case 2
if 2 or (10 / 0):
	print("we got no error")
```
