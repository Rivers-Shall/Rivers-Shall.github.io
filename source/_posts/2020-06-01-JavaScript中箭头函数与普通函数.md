---
title: JavaScript中箭头函数与普通函数
date: 2020-06-01 20:26:38
tags:
- JavaScript
categories:
- basic knowledge
---

本文记录了作者在使用mongoose的过程中，因为箭头函数与普通函数的区别而引起的一个bug，以及因此而学会的有关箭头函数与普通函数的区别，简单来说：

1. 箭头函数不能使用`arguments`参数，普通函数可以
2. 箭头函数的`this`关键字是lexically bound，也就是`this`是和**最近的外层普通函数**所具有的`this`一致(如果没有这样的函数，就和文件本身代表的对象绑定)；普通函数的`this`是dynamically bound，视运行时环境而确定

其实还有什么`new`之类的，作者觉得不大重要，就算了

<!-- more -->

## 场景

在使用mongoose的过程中，需要对schema构造一个“虚字段”，参考实现中使用如下代码:

```javascript
itemSchema.virtual("id").get(function() {
    return this._id.toHexString();
});
```

我寻思着可以少写点东西，更精简一些，于是在我的实现里使用了:

```javascript
itemSchema.virtual("id").get(() => {
    return this._id.toHexString();
});
```

运行时报错:

```bash
undefined 没有 toHexString 成员函数
```

这才意识到，原来使用箭头函数的时候，`this`的绑定规则和普通函数不一致

## 箭头函数和普通函数的区别

### arguments

```js
function f1() {
    console.log(arguments)
}

let f2 = () => {
    console.log(arguments)
}

f1(1, 2)
f2(1, 2)
```

这段代码**在浏览器中**，`f1`可以正常打印，`f2`会报`undefined`，当然，在node.js环境下，还会有些不同，可以自己试试

### this

```js
exports.mod = "mod"

let user = {
    f1() {
        console.log(this)
    }
}

let user2 = {
    f1 : () => {
        console.log(this)
    }
}

user.f1()
user2.f1()
```

这段代码在node.js下，打印出如下结果

```bash
> node test2.js
{ f1: [Function: f1] }
{ mod: 'mod' }
```

可见，普通函数绑定的是运行时的对象，箭头函数绑定的是静态的编译时的对象
