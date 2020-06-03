---
title: goland中Run与Debug里working-directory的含义
date: 2020-06-03 20:15:43
tags:
- golang
- goland
- basic knowledge
---

本文记录了作者由于不了解goland中Run与Debug配置中working-directory含义而引起的bug，简单来说:

> working directory就是golang项目编译好后的二进制文件执行的文件夹路径

## 情景

项目框架中存在`conf`这样的专门放置配置文件的文件夹，当使用项目框架自带的`build.sh`构建脚本时，会将编译好的二进制文件和`conf`中的配置文件分别拷贝到`output/bin`和`output/conf`这两个文件夹下，将`output`试做发布文件夹

但是，在goland中如果想要配置Run或者Debug，是不能使用`build.sh`脚本的，只能配置原始的go编译命令

在配置的同时，我将working-directory很随意地设置为了`output`文件夹

## 出现问题

当我修改了配置文件并进行Run或者Debug时，发现修改没有生效

## 思考

没有生效是因为，working-directory被设置为`output`文件夹，那么goland在执行goland本身编译好的二进制文件时，会引用`output/conf`下的配置文件

但是，`conf`文件夹下的修改是不会自动同步到`output/conf`里的(对源代码的修改会同步到goland上，因为goland会重新编译)，必须执行`./build.sh`脚本才可以

## 解决

可以每次修改配置文件是都先执行`./build.sh`，然后再goland使用Run或Debug

也可以将working-directory设置为`./`而不是设置为`./output`，这样以后goland编译执行引用的就是`./conf`中的配置文件，修改也就能直接同步了
