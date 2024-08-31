# io

* 24.8.29 11:05 created

## file.read()

再当前py文件目录下，准备`myfile.txt`：
```
hello, how are you today?
I'm fine, thank you
```

读文件内容：
```python
file = open("myFile.txt")
"""
hello, how are you today?
I'm fine, thank you
"""
print(file.read())
```

读文件前5个字符：
```python
file = open("myFile.txt")
print(file.read(5))  # hello
```

读文件前5个字符后，再读5个字符
```python
file = open("myFile.txt")
print(file.read(5))  # hello
print(file.read(5))  # , how
```

不能连续使用read()，第二次使用无法读取：
```python
file = open("myFile.txt")
print(file.read())

print(file.read())
```

重置read的位置：
```python
"""
hello, how are you today?
I'm fine, thank you

hello, how are you today?
I'm fine, thank you
"""
file = open("myFile.txt")
print(file.read())
file.seek(0)
print(file.read())
```

read返回的类型是string：
```python
file = open("myFile.txt")
# file.read() returns a string
print(type(file.read()))  # <class 'str'>
```

