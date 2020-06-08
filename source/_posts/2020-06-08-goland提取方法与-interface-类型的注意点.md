---
title: 'goland提取方法与...interface{}类型的注意点'
date: 2020-06-08 17:15:04
tags:
- golang
- goland
categories:
- basic knowledge
---

本文记录了作者在使用goland提供的提取方法(Extract Method)功能时，由于`...interface{}`的类型问题而遭遇到的bug和一点感悟，简单来说:

- 可变长的参数会被goland的Extract Method转化为切片(slice)，比如`...interface{}`会被转化为`[]interface{}`
- 由于`interface{}`的特殊性，需要额外注意

<!-- more -->

## bug的产生

在代码中有如下片段

```go
func f(payload ...interface{}) {
    for _, p := range payload {
        // do something
    }
}
```

现在想要将循环提取出来，作为一个方法，在goland中可以直接选中文本然后Extract Method，但是结果是这样的

```go
func f(payload ...interface{}) {
    ExtractedMethod(payload)
}

func ExtractedMethod(payload []interface{}) {
    for _, p := range payload {
        // do something
    }
}
```

期望中的函数签名是`ExtractedMethod(payload ...interface{})`，不符合预期，所以要进行修改

```go
// WRONG!!!!!!!!

func f(payload ...interface{}) {
    ExtractedMethod(payload)
}

func ExtractedMethod(payload ...interface{}) {
    for _, p := range payload {
        // do something
    }
}
```

上述的代码不会有编译错误，但是是完全不符合预期的，为什么呢？

## bug的原因

```go
// WRONG!!!!!!!!

func f(payload ...interface{}) {
    // we need to unpack payload
    ExtractedMethod(payload)
}

func ExtractedMethod(payload ...interface{}) {
    for _, p := range payload {
        // do something
    }
}
```

如上述注释所说，我们需要对`f`中传递给`ExtractedMethod`的参数`payload`做一个解包工作，因为

- 我们`f`函数的本意是要用`ExtractedMehtod`对`payload`中的每一个元素做处理
- 现在不解包，`payload`原本一个`[]interface{}`又被**额外自动包装了一层**，成为了`interface{}`传递给了`ExtractedMethod`，只会对整个`payload`做一次处理

## bug的解决与思考

将代码修改为如下后正确

```go
func f(payload ...interface{}) {
    ExtractedMethod(payload...)
}

func ExtractedMethod(payload ...interface{}) {
    for _, p := range payload {
        // do something
    }
}
```

以后可以采取的方法是，先将传参的地方`payload`改为`payload...`，这样的话如果忘记修改参数`[]interface{}`为`...interface{}`，是会有编译器报错的

这个修改顺序可以让编译器为我们保驾
