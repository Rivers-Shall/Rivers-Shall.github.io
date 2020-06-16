---
title: webpack教程02-webpack-dev-server是什么与webpack-dev-server命令行使用
date: 2020-06-16 15:37:30
tags:
- webpack
- webpack-dev-server
categories:
- [webpack教程]
- [basic knowledge]
---

本文是webpack教程的第二篇文章，会介绍:

- webpack-dev-server的概念和作用
- webpack-dev-server的基本命令行使用和一个坑点

本次相关代码在[Github仓库 commit bbaea1bc](https://github.com/Rivers-Shall/webpack-demo/commit/bbaea1bca75a4e6870b42d993e490415f8f4f253)

<!-- more -->

## webpack-dev-server的概念与作用

### 概念

webpack-dev-server，顾名思义，这是一个**server**，也就是说，`webpack-dev-server`命令能够用来启动一个本地服务器，接受HTTP请求

### 作用

#### 不使用webpack-dev-server的场景

在上一次的教程中，我们是采用直接打开`index.html`文件的方式来查看我们web app的实现效果

但是，这样的话我们的浏览器地址栏中会是`file://path/to/index.html`

也就是说，使用的协议是*文件协议*，并不会发起HTTP请求，只会从本地文件系统将文件加载到浏览器里

这样的话，我们就无法使用很多HTTP协议特性，无法使用也就无法测试，调试，对开发工作有很大的阻碍

#### 使用webpack-dev-server

通过webpack-dev-server，我们能够直接启动一个简易的服务器，通过这个服务器，可以使用HTTP协议进行web app的效果测试

除此之外，还能够实现许多额外的功能，比如热加载(一旦修改项目文件，就自动重新加载服务器)

## webpack-dev-server的基本命令行使用和一个坑点

### 基本命令行使用

想要从webpack转向webpack-dev-server是比较简单的，因为webpack-dev-server兼容了webpack所有的命令行选项

这也是很合理的，因为webpack-dev-server基本上就是"webpack打包 + 启动简易服务器"

所以我尝试直接将npm配置中的`webpack`命令修改为`webpack-dev-server`命令

```json
    "build": "webpack-dev-server ./js/app.js -o bundle.js --mode development"
```

而后`npm run build`

```bash
> npm run build
 ｢wds｣: Project is running at http://localhost:8081/
 ｢wds｣: webpack output is served from /
 ｢wds｣: Content not from webpack is served from /path/to/working-dir
```

打开`localhost:8081`，发现代码运行正常，且浏览器使用的是HTTP协议

### 一个坑点

#### 坑点总结

1. `webpack-dev-server`不会在文件系统中生成打包后的文件，而是直接将文件加载到内存里
2. 对于打包后的文件，默认会放置在host的`/`路径下，需要配置`publicPath`来自定义host路径

#### 过程

但是，当我希望将生成的`bundle.js`放入固定文件夹`dist`时，问题出现了

npm配置

```json
    "build": "webpack-dev-server ./js/app.js -o ./dist/bundle.js --mode development"
```

HTML文件

```html
<body>
<!-- .... -->
<script src="dist/bundle.js"></script>
</body>
```

但是在打开`localhost:8081`之后，代码运行异常(按钮不起作用)，console报错

```text
GET http://localhost:8081/dist/bundle.js net::ERR_ABORTED 404 (Not Found)
```

这说明`dist/bundle.js`没有能被加载，且磁盘上没有`dist/bundle.js`文件生成

查看`npm run build`的日志输出

```bash
> npm run build
ℹ ｢wds｣: Project is running at http://localhost:8081/
ℹ ｢wds｣: webpack output is served from /
ℹ ｢wds｣: Content not from webpack is served from
```

其中

```bash
ℹ ｢wds｣: webpack output is served from /
```

这一行比较引人注意，因为`dist/bundle.js`正是`webpack output`

于是我访问了`localhost:8081/bundle.js`，发现可以正常访问

于是去webpack的官网文档中寻找解决方案，在[这个文档](https://webpack.js.org/guides/development/#using-webpack-dev-server)上找到了这么一个提示

> webpack-dev-server doesn't write any output files after compiling. Instead, it keeps bundle files in memory and serves them as if they were real files mounted at the server's root path. If your page expects to find the bundle files on a different path, you can change this with the publicPath option in the dev server's configuration.

对于配置文件，我们需要指定`publicPath`

对于webpack-dev-server CLI，我们需要指定`output-public-path`，所以将npm配置修改为

```json
    "build": "webpack-dev-server ./js/app.js -o ./dist/bundle.js --output-public-path /dist/  --mode development"
```

代码运行就可以恢复正常，`localhost:8081/dist/bundle.js`也可以正常访问
