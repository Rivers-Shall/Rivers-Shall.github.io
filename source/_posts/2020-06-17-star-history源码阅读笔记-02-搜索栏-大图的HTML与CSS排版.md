---
title: star-history源码阅读笔记(02)-搜索栏+大图的HTML与CSS排版
date: 2020-06-17 19:44:13
tags:
- HTML
- CSS
categories:
- [star-history源码阅读笔记]
- [code snippet]
- [basic knowledge]
---

本文是[star-history项目](https://github.com/timqian/star-history)源码阅读的第一篇文章，会包含:

- 搜索栏+大图的HTML与CSS排版

本次对代码的分析基于Commit - [first commit deecd92 timqian](https://github.com/timqian/star-history/tree/deecd92097809f39cd0ccd521b85ad54ac8fad24)

## 项目页面排版

在[这个commit](https://github.com/timqian/star-history/tree/deecd92097809f39cd0ccd521b85ad54ac8fad24)上，项目的外观还不是很美观，但是已经具备了一种模式，那就是"搜索栏+大图"的模式

```text
+----------------------------------------------------------------+
|                   |search input|||search button|               |
+----------------------------------------------------------------+
|                                                                |
|                                                                |
|                                                                |
|                                                                |
|                           svg picture                          |
|                                                                |
|                                                                |
|                                                                |
|                                                                |
|                                                                |
|                                                                |
+----------------------------------------------------------------+
```

## 排版的HTML与CSS实现

首先，我们可以看到整个页面被分做了两块，一块是搜索栏，另一块是svg图片(用于展示star历史)，也就是

- 搜索栏
  - 搜索输入栏
  - 搜索点击按钮
- svg图片

项目使用的HTML结构则是

```html
<h1>
    <input/>
    <button></button>
</h1>
<svg></svg>
```

为了界面的美观，当然还会使用CSS，这里选取一些比较重要的属性设置进行注解

```css
h1 {
    # text-align使得input和button居中显示
    text-align: center,
    # 设置背景色
    background-color: rgba(46, 137, 216, 0.88),
}

input {
    # 形状
    width: 350px;
    height: 23px;
    # 字体大小
    font-size: 15pt;
}

button {
    # 原生文字格式
    text-decoration: none;
    # 文字居中
    text-align: center;
    # 文字大小
    font-size: 16pt;
    # 背景色
    background-color: #01A94C;
    # 字体色
    color: white;
}
```
