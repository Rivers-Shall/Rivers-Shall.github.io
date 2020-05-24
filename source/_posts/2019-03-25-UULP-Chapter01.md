---
title: Chapter01 --- 编写自己的 `more` 程序(1)
tags:
  - Linux
categories:
  - Books
  - Understanding-Unix/Linux-Programming
date: 2019-03-25 19:45:34
---


## 简介

这次博文是我阅读 _Understanding Unix/Linux Programming_ 这本书的第一章做的相关笔记，第一章主要是介绍了操作系统概念和一个极不完善的`more`命令，这篇文章主要关注`more`命令的编写，当然，这次主要是书上源码和项目组织的一点感悟，下次会是完整的编写一个`more`命令。

<!-- more -->

## 初版

标准版源码[more01.c](https://github.com/Rivers-Shall/UULP-Code/blob/master/Chap01/src/std/more01.c)，虽然这个版本既不支持管道连接，普通的状态下也有`more?`字幕上滚的问题，但总算是有一点样子了。

## 心得

### `more`的模式

```C
/*
 * read PAGELEN lines, then call see_more() for further instructions
 */
void
do_more(FILE *fp) {
  char line[LINELEN];
  int num_of_lines = 0;
  int reply;
  while (fgets(line, LINELEN, fp)) {
    if (num_of_lines == PAGELEN) {
      reply = see_more();
      if (reply == 0) {
        break;
      }
      num_of_lines -= reply;
    }
    if (fputs(line, stdout) == EOF) {
      exit(1);
    }
    num_of_lines++;
  }
}
```

先看这一段代码，一开始的时候写炸了，后来才明白，对于`more`这种程序，明显是__不断读入，直到完结，中间段特判并操作__的模式，就应该使用

```C
while (readin) {
    if (counter_condition) {
        ...
    }
    ...
}
```

这种模式，之前写的时候居然在大循环里还有读入语句，一团乱麻，bug不断。

### Makefile

#### 自动检测源文件与编译

两个程序，一个标程，一个自己的程序，有任何删改都要手动键入`gcc`和一大堆编译选项多烦啊，于是写了一个`Makefile`

```makefile
SRC=$(shell find . -name "*.c")
BIN=$(SRC:.c=.out)

%.out: %.c
		gcc $< -o $@ -ggdb3 -Wall

.PHONY: all

all: $(BIN)
```

第一行用`shell`命令找到当前目录下的所有`.c`源文件，由于目前的都是单文件程序，所以第二行将目标二进制文件变成了和每个`.c`文件对应的`.out`文件(文本替换命令)，并且用`all`假目标来使得`make`生效编译。

中间的两行表明对所有的`.out`目标都需要一个对应的`.c`文件依赖，`$<`指代第一个依赖即`.c`源文件，`$@`指代目标即`.out`文件。

这样的一个文件就完成了自动寻找所有`.c`文件并编译出对应`.out`文件的工作。

#### 源文件与二进制文件分属不同文件夹

一个文件夹里，又有源文件，又有可执行文件，多乱啊，改进一下Makefile和文件组织结构

```
.--+-src---*.c
   +-bin---*.out
   +-Makefile
```

```makefile
SRC_DIR=./src
BIN_DIR=./bin
SRC=$(shell find $(SRC_DIR) -name "*.c")
BIN=$(SRC:$(SRC_DIR)/%.c=$(BIN_DIR)/%.out)

$(BIN_DIR)/%.out: $(SRC_DIR)/%.c
	mkdir -p $(dir $@)
	gcc $< -o $@ -ggdb3 -Wall

.PHONY: clean all
.DEFAULT_GOAL :=all

clean:
	rm -rf bin

all: $(BIN)
```

这也很简单

1. 多了两个变量`BIN_DIR`和`SRC_DIR`
2. 对于`BIN`的文本替换模式也做了一点调整
3. 加入为了避免没有文件夹而出现的`mkdir`语句
4. 通过`.DEFAULT_GOAL`设置默认目标

#### 节约内存空间

这是在文件夹`Chapter01`下的结构，那岂不是每个`Chapter`都要写一个一样的Makefile，再改变一下文件组织结构吧

```
.----+--Makefile.single
     |
     +--Chapter01-+-Makefile
     |            `-OTHER FILES
     +--Chapter02-+-Makefile
                  `-OTHER FILES
```

看起来还是每个文件夹一个Makefile啊，但是我把上一步的Makefile内容放置到最上层的Makefile.single里，而其余的下层Makefile只需要

```makefile
include ../Makefile.single
```

## 改进版

标准源码[more02.c](https://github.com/Rivers-Shall/UULP-Code/blob/master/Chap01/src/std/more02.c)，这个版本主要是修复了`stdin`输入时无法键盘交互的bug，解决的方法是，不再从`stdin`中读入指令，只从`stdin`中读入要显示的内容，而输入的指令是从文件`/dev/tty`中读入，`/dev/tty`是一个特殊的文件，其指代了当前进程的控制终端(如果存在的话)。

但这个版本仍然有许多问题:

1. 输入字符后需要回车才能读入
2. 输入回车后`more?`提示符上滚
3. 文件无法显示当前百分比
4. 多文件显示问题很大

这个会在下一次博文中进行解释和解决，当然，完整的源码就在[Github](https://github.com/Rivers-Shall/UULP-Code/blob/master/Chap01/src/more.c)上，已经可以~~阅读~~(找bug)啦！

