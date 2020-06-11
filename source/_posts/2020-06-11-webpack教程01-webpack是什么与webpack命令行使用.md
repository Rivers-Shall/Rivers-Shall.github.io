---
title: webpack教程01-webpack是什么与webpack命令行使用
date: 2020-06-11 15:20:01
tags:
- webpack
categories:
- [webpack教程]
- [basic knowledge]
---

本文是webpack教程的第一篇文章，会介绍

- 创作这个系列教程的原因
- webpack是什么
  - 构建工具
- webpack CLI(命令行交互)的基本使用
  - `webpack <入口文件> -o <目标文件> --mode <模式>`
  - `webpack --config <配置文件>`
- webpack CLI与npm结合使用
  - `scripts`添加与`npm run build`

涉及到的代码有[不使用webpack版本](https://github.com/Rivers-Shall/webpack-demo/tree/45285d4873a2b62c4e5808d158aa6dfe9b71bf14)，[使用webpack和npm版本](https://github.com/Rivers-Shall/webpack-demo/tree/44a3c5436a1b85916a23a37d6903865df2437026)
<!-- more -->

## 创作这个系列教程的原因

- webpack是一个应用广泛的构建系统
  - 尽管现在各个框架，各个公司都有发展使用自己的构建系统(脚手架)的趋势，比如vue-cli
  - 但是webpack仍然具有着很高的适用性和可扩展性
  - 其接口和使用方式的设计也很值得学习
- 把三次元的时间尽！数！挥！霍！

## webpack是什么

前面提到，webpack是一个构建系统，这究竟意味着什么呢？我们先来看webpack官网上的图

![webpack](webpack.png)

我们可以看到:

- 左边是**杂乱的，拥有复杂依赖的**项目文件
- 右边是**整齐的，无依赖的，生成的**独立文件

所以webpack是构建系统的含义:

> 根据项目文件中提供的依赖关系，自动构建整齐的独立文件

## webpack CLI(命令行交互)的基本使用

先贴一下[webpack CLI的官网文档](https://webpack.js.org/api/cli/)

### 一个不使用webpack的项目版本

为了体现使用webpack的优势，我们先准备一个不使用webpack的项目版本 [webpack-demo init commit](https://github.com/Rivers-Shall/webpack-demo/tree/45285d4873a2b62c4e5808d158aa6dfe9b71bf14)

这个项目实现的功能是: 点击按钮，下方的文字会出现或者消失

我们可以看到，`index.html`中引用了两个js文件:

```html
    <script src="js/dom-loader.js"></script>
    <script src="js/app.js"></script>
```

这两个引用的顺序是不可改变的，如果改变，那么按钮就会失效

#### 缺点

- 这样搭建的web项目，需要我们手动去关注引用的代码顺序，
  - demo项目中只有两个js文件，但是如果真实的项目中，或许会有数十个js文件，那时还要不断处理引用顺序，就会很头疼
- js代码的修改，可能需要额外修改html代码
  - 如果引用顺序改变，就必须修改引用js代码的html代码，修改的地方变多

缺点其实还有很多，比如后期引入Sass这种扩展CSS，或者Babel这种JS转译器，都需要手动引入和管理，非常麻烦，webpack会帮我们完成这些管理，当然，这些内容稍后再介绍，先看最基础的使用

### 使用webpack CLI构建文件

我们首先使用如下命令安装webpack和webpack-cli(当然，项目需要使用`npm init`初始化，需要安装`node.js`和`npm`):

```bash
npm install webpack webpack-cli --save-dev
```

在使用webpack之前，我们需要明白，webpack是**根据源代码中的依赖关系**进行构建的

那么，我们就必须在源代码中对依赖关系进行声明

声明的方式是ES6的`import, export`语法

> 注意: 这里使用ES6的`import, export`语法只是因为webpack可以识别它们，在项目中使用其他的ES6语法仍然会导致兼容性问题，关于如何将ES6或更新的语法转化为ES5语法，后续教程会涉及

所以我们对源代码作出修改

```js
// dom-loader.js
export var button = document.querySelector("#toggle-button")
export var graph = document.querySelector("#toggled-graph")
```

```js
// app.js
import {button, graph} from "./dom-loader"

//...
```

声明了依赖关系之后，就需要使用webpack构建文件了，为了构建，我们需要指定两类文件以及模式

1. 入口文件
   1. webpack会从这个文件开始分析依赖关系，将所有涉及的文件进行打包
2. 目标文件
   1. webpack会将构建出的文件保存到目标文件上
3. 构建模式
   1. 不提供的话默认是`production`，但是会报Warning
   2. 开发阶段使用`development`就好
   3. 二者的一个主要区别是`production`会*最小化*文件，导致整个文件没有多余的空白符，可读性为0

而后使用webpack CLI

```bash
> webpack <入口文件> -o <目标文件> --mode <模式>
```

在这里，就是

```bash
webpack ./js/app.js -o bundle.js --mode development
```

webpack就会直接生成`bundle.js`

而在`index.html`中，我们只需要引入这一个`bundle.js`就可以了

```html
<!-- index.html -->

<!--    <script src="js/dom-loader.js"></script>-->
<!--    <script src="js/app.js"></script>-->
    <script src="bundle.js"></script>
```

### webpack与配置文件

webpack CLI可以使用命令行参数的方式运作，也可以使用配置文件的方式运作

不过配置文件的书写方式涉及到webpack许多核心概念，下次再说，这里先放上指定配置文件的命令

```bash
> webpack --config <配置文件>
```

## webpack CLI与npm结合使用

使用webpack原生命令比较繁琐，也没有办法记录在项目文件中，可以使用npm的scripts列表进行管理

在`package.json`中添加scripts

```json
{
  "name": "webpack-demo",
  "version": "1.0.0",
  "description": "demo for webpack",
  "main": "app.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1",
    # 添加 script
    "build": "webpack ./js/app.js -o bundle.js --mode development"
  },
  "author": "rivers-shall",
  "license": "ISC",
  "devDependencies": {
    "webpack": "^4.43.0",
    "webpack-cli": "^3.3.11"
  }
}

```

而后我们只需要:

```bash
> npm run build
```

就可以便捷使用webpack构建文件了
