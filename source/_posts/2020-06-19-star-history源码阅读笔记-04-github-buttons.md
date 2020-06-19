---
title: star-history源码阅读笔记(04)-github-buttons
date: 2020-06-19 17:34:12
tags:
- Github
categories:
- [star-history源码阅读笔记]
- [code snippet]
---

本文是[star-history项目](https://github.com/timqian/star-history)源码阅读的第四篇文章，会包含:

- github button介绍与使用

本次对代码的分析基于 [commit dca63d05369886573843839c08722d93a96cb047](https://github.com/timqian/star-history/commit/dca63d05369886573843839c08722d93a96cb047)

<!-- more -->
## github button

所谓的Github Button，可以认为是一种前端组件，效果如下，这个是`twbs/bootstrap`的star button

<iframe src="https://ghbtns.com/github-btn.html?user=twbs&repo=bootstrap&type=star&count=true&size=large" frameborder="0" scrolling="0" width="170" height="30" title="GitHub"></iframe>

Github Button主要有两个作用:

- 展示数据
  - 根据类型的不同，展示star数，fork数，watch数等等
- 点击后跳转到对应的Github仓库页面

## 如何使用

由于这样的Github Button使用非常广泛，所以已经有很多的开源库提供了这一组件功能

star-history仓库中使用的是[mdo/github-buttons](https://github.com/mdo/github-buttons)

使用方式也非常简单，只要在需要的界面插入一个HTML标签，在属性`src`中填上对应的参数就可以了

```HTML
<iframe src="https://ghbtns.com/github-btn.html?user=twbs&repo=bootstrap&type=star&count=true&size=large" frameborder="0" scrolling="0" width="170" height="30" title="GitHub"></iframe>
```

同时，还有许多开源项目提供了和Vue, Angular等前端框架相适用的组件，也可以试试
