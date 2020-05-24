---
title: Extended Euclid Bug
tags:
  - Algorithm
categories:
  - Bug
  - Algo Implem
date: 2019-04-10 17:51:18
---


# 简介
辗转相除法是经典的求最大公约数的算法，也是已知的最古老的算法，最近学到了扩展的辗转相除法，也就是对于$a$和$b$不仅返回$\gcd(a,b)$,而且返回$x$和$y$使得$xa + yb=\gcd(a,b)$.

在实现的过程中遇到了我觉得还算有意思的一点bug，就记录了下来. 用的Python.

<!-- more -->
## 算法

先来看一下算法，我们`gcd(a, b)`函数需要返回三个值`g, x, y`，`g`是`a`和`b`的最大公约数，而`x`和`y`满足`xa+yb=g`，依旧使用经典的递归实现。

![递归公式](gcd.jpg)
## Bug

先看两个有Bug的代码
```Python
import numpy as np
def gcd_pos(a, b):
    if b == 0:
        return a, 1, 0
    g, x, y = gcd(b, a % b)
    return g, y, x + y * (- a // b)

def gcd(a, b):
    g, x, y = gcd_pos(abs(a), abs(b))
    return g, x * np.sign(a), y * np.sign(b)
```

当时发现这个程序有Bug的时候，我一时没有回过神来，不过这其实是一个Python语法相关的Bug，因为`gcd_pos`保证了参数是正数，那么`(- a // b)`就是一个负数对一个正数求整数除法商，而Python中的整数除法是通过**去掉小数部分**完成的，并不是**向下取整**完成的。

所以这个看起来和递归公式无比契合的代码其实是错的.它表达的意思是$x + \lceil -a/b\rceil$.

```Python
import numpy as np
def gcd_pos(a, b):
    if b == 0:
        return a, 1, 0
    g, x, y = gcd(b, a % b)
    return g, y, x - y * a // b

def gcd(a, b):
    g, x, y = gcd_pos(abs(a), abs(b))
    return g, x * np.sign(a), y * np.sign(b)
```
这个Bug则更加难于发现，Python的表达式乘除计算是从左到右的，所以`y * a // b`实际上是`(y * a) // b`。

那么这个代码表达的是$x-\lfloor (ya)/b\rfloor$.根据数论知识，我明白了这是与递归公式不同的。

## 正确实现
```Python
import numpy as np
def gcd_pos(a, b):
    if b == 0:
        return a, 1, 0
    g, x, y = gcd(b, a % b)
    return g, y, x - y * (a // b)
def gcd(a, b):
    g, x, y = gcd_pos(abs(a), abs(b))
    return g, x * np.sign(a), y * np.sign(b)
```

## 总结
代码与数学公式之间的对应关系是很微妙的，以后编程时要注意这一点。
