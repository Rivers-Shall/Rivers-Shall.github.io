---
title: git-status中文乱码问题
date: 2020-05-29 18:21:28
tags:
- git
- 中文乱码
---

本文记录了作者解决`git status`命令中出现中文名乱码问题的方法，简单来说

> 配置 core.quotepath 为 false 即可

<!-- more -->

## 场景

当我们的修改文件中出现中文文件名时，`git status`就会出现乱码

```bash
➜  project git:(master) ✗ git status -s
?? "\344\270\255\346\226\207\346\226\207\344\273\266"
```

这是由于Git默认会对ASCII以外的编码进行转义，只要将这个转义关掉，就可以恢复正常了，关掉的方式就是

```bash
➜  project git:(master) ✗ git config core.quotepath false
➜  project git:(master) ✗ git status -s
?? 中文文件
```

当然，如果希望让这个设定在所有的Git本地仓库里都生效，可以加上`--global`选项

```bash
➜  project git:(master) ✗ git config --global core.quotepath false
```
