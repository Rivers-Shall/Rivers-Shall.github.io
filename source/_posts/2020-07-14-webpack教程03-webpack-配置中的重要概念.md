---
title: webpack教程03-webpack-配置中的重要概念
date: 2020-07-14 14:50:14
tags:
- webpack
categories:
- [webpack教程]
- [basic knowledge]
---

本文是webpack教程的第三篇文章，主要会介绍：

- 使用webpack配置文件中的重要概念
  - entry
  - output
  - module
  - plugins

<!-- more -->

## 使用webpack配置文件

在之前的系列中，我们都是使用webpack命令行参数进行webpack配置，这不利于我们集中管理配置选项

我们当然可以使用配置文件:

- webpack本身默认当前文件夹下的`webpack.config.js`是自己的配置文件
- 可以使用`--config`选项来指定配置文件

我们这里方便起见，一般就是用`webpack.config.js`

## webpack配置中的重要概念

首先，我们需要知道一个webpack配置事实上就是一个js对象，通过对这个对象的字段进行赋值，我们也就是配置了webpack

基本的webpack使用涉及到到的配置字段有四个

- entry
- output
- module / rules
- plugins

### entry

也就是前文所说的进入点，用于webpack计算依赖关系的起始文件

直接写上相对路径即可:

```js
entry: "./js/app.js",
```

### output

也就是前文所说的打包目标，用于webpack最终输出打包好的文件

这里的output是一个对象，通过不同的字段进行更加细致的配置:

```js
output: {
    path: path.resolve(__dirname, 'dist'),
    filename: "bundle.js",
    publicPath: "/dist"
},
```

- `path`字段指打包目标的文件夹，**必须是绝对路径**，使用了nodejs的path库进行操作
- `filename`字段指打包目标的文件名
- `publicPath`是webpack-dev-server启动后，打包文件的挂载路径，比如这里生成了`bundle.js`，挂载路径为`/dist`，那么就可以在`localhost:8081/dist/bundle.js`路径获取打包文件

### module

```js
module: {
    rules: [
        {
            test: /\.css/,
            use: ["style-loader", "css-loader"]
        }
    ]
},
```

这是module的基本用法——“引入loader”

> loader是在打包过程中对特定文件进行处理的插件

可以看到:

- module由rules组成
- 每个rule有两个部分
  - test，一个正则表达式，用于匹配文件名，确定本条规则是否适用于某个文件
  - use，一个loader数组
    - **从后往前进行处理**
    - 比如这里，先是"css-loader"进行处理，然后才是"style-loader"处理
      - css-loader处理依赖关系中import的css文件
      - style-loader将取出的css文件中的样式作用在引用entry的html文档上

### plugins

plugins类似于loaders，区别在于

> plugins是在打包文件生成了之后进行额外处理的插件

```js
plugins: [
    new uglifyJsPlugin(),
]
```

这就是一个用于minify生成文件的插件，不同的插件有不同的接入方式，可以去其官网文档查找
