---
title: star-history源码阅读笔记(03)-include bundle.js
date: 2020-06-18 16:19:21
tags:
- git
categories:
- [star-history源码阅读笔记]
- [good practice]
---

本文是[star-history项目](https://github.com/timqian/star-history)源码阅读的第二篇文章，会包含:

- 项目仓库中是否需要保存被构建文件的讨论

简单来说:

- 为了项目仓库的整洁，一般不保存被构建文件
- 如果有项目本身不是非常复杂，有展示需求且构建文件为跨平台文件，可以考虑直接保存在项目仓库中

本次对代码的分析基于 [commit cb4d5828d5147df1d3db79ce728e6fb1f088e38b](https://github.com/timqian/star-history/commit/cb4d5828d5147df1d3db79ce728e6fb1f088e38b)

<!-- more -->

## gitignore的改变

在[这个commit](https://github.com/timqian/star-history/commit/cb4d5828d5147df1d3db79ce728e6fb1f088e38b)中，做出的唯一改变就是将`bundle.js`从`.gitignore`中删除了

```text
git commit remove
- # Built by webpack
- bundle.js
```

这就意味着，以后的仓库中可以存储webpack构建的`bundle.js`

### 构建文件一般不会放置在代码仓库中

但是我们知道，对于这一类的构建文件，一般是不会直接存放在代码仓库中的

就好像用C/C++编写的项目，却把可执行文件放到了仓库里，或者Java编写的项目，却把Jar文件放到了仓库里

这违背了**代码**仓库的原则

### 正常的做法

正常情况下，被构建文件当然可以公开，但是一般是以

- 发布(Release)

的方式进行公开，Github本身也提供了[产品发布](https://help.github.com/en/enterprise/2.13/user/articles/creating-releases)的
功能

比如C/C++编写，那么就将不同平台下编译好的可执行文件分别发布，Java编写的项目就考虑将Jar/War文件发布

### 这里操作的合理性

但是star-history选择了直接将构建文件放置在代码仓库里，我觉得是出于以下考虑:

- 项目本身较小，处于起步阶段，还没有达到版本发布的级别
- 但是希望感兴趣的用户在下载了源代码后无需额外操作(安装webpack并构建)，立刻能够使用web app
- Javascript代码仅依赖于浏览器，直接发布，不会有平台问题

以上，有时我会觉得我[迪化](https://zh.moegirl.org/zh-hans/%E5%A4%A7%E5%B8%88%E6%95%88%E5%BA%94)了
