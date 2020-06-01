---
title: 一个golang的RPC框架设计中的坑点
date: 2020-05-27 21:13:42
tags:
- golang
- RPC
categories:
- good practice
---

本文记录了作者在使用公司的RPC框架时，由于RPC框架本身的设计以及程序员的投机取巧而遇到的一个坑点。

简单来说，RPC框架没有能够做足够好的封装，程序员（不是作者，是前人）也没有按照RPC框架约定的方式进行API调用。

<!-- more -->

## 背景提要

我们知道，RPC调用是不同主机间的进程通信的方式，如果想要额外传递消息，我们往往需要修改RPC调用的接口，通过新增参数的方式来新增传递信息。

但是这样修改参数，修改接口的方式侵入性太强，需要进行上下游调用接口的适配，很麻烦。

当我们面对一些遍布在各个RPC服务的需求（也就是很多人喜欢提及的编程"切面"Aspect），比如这回我接到的日志系统的需求，将所有的接口都修改一遍，显然是不现实的。

在这里，golang的RPC框架可以通过传递`context.Context`来实现，也就是说，这些额外的，遍布各个RPC服务的消息，通过`context.Context`来传递。

```go
// rpc 上游调用时，传递一个`context.Context`和本来必要的下游rpc接口参数
rpcClient.remoteMethod(ctx, request)

// rpc 下游接受请求时，接受一个`context.Context`和本来必要的接口参数
func methodHandler(ctx context.Context, request MethodRequest)
```

### 类比HTTP解释

上面提及的RPC调用传递`context.Context`和本来的接口参数，其实可以类比HTTP协议：

- `context.Context` -> HTTP Request Headers
- 接口参数 -> HTTP Request Body

二者都是传递信息的手段，但是接口参数和Request Body往往是明面上的写出来的主要业务逻辑需要的消息，`context.Context`和Request Headers往往是一些元数据(metadata)。

## 需求场景

这次的日志系统，需要我记录RPC运行时的动态调用链，也就是说，如果有一条RPC调用链路是

> RPC1 -> RPC2 -> RPC3

那么实时的日志里，会有如下条目：

```text
RPC1:
stack : []

RPC2:
stack : [RPC1]

RPC3:
stack : [RPC1, RPC2]
```

## 解决过程中遇到的问题

对于这个功能，我们发现RPC框架提供了三个接口：

```go
// 向一个context.Context加入key-val键值对
func AddInfo(ctx context.Context, key string, val string) context.Context

// 获取上游通过AddInfo传来的key对应的val
func GetUpstreamInfo(ctx context.Context, key string) string

// 获取所有上游通过AddInfo传来的键值对，组织成一个map[string][string]
func GetAllUpstreamInfo(ctx context.Context) map[string]string
```

为此，我们的解决方案是，将`stack`做成`[]RPC`，其中`struct RPC`记录RPC的信息，通过JSON将`[]RPC`转化成`string`，而后用`context.Context`里的`"stack" - JSON([]RPC)`的键值对进行传递。

在我之前编码的程序员，没有遵守API调用规则，不使用`AddInfo`，而是使用的是如下方式进行`stack`的传递的

```go
// 获取所有的键值对
m := util.GetAllUpstreamInfo(ctx)
// 取出stack并使用JSON解析
stack, err := json.Unmarshal(m["stack"])
if err != nil {
    logError(...)
    return
}

// 添加现有RPC调用
stack = append(stack, currentRPC)
// JOSN编码，更新ctx内的map
m["stack"], err = json.Marshal(stack)
if err != nil {
    logError(...)
    return
}
```

由于golang中的map是引用传值，所以看上去这个代码已经成功更新了ctx内部的map，使用Goland-Debug查看ctx也会发现map已经修改了

但事实上程序并没有按照预期的方式进行工作

### 排查原因

仔细观察`AddInfo`函数的签名

```go
func AddInfo(ctx context.Context, key string, val string) context.Context
```

该函数返回了一个全新的Context，事实上`AddInfo`的逻辑是这样的：

```go
newCtx := AddInfo(ctx, "key", "val")

+------------------------------+
|          newCtx              |
|   +------------------------+ |
|   |                        | |
|   |                        | |
|   |        ctx             | |
|   |                        | |
|   |                        | |
|   +------------------------+ |
|    K_KV ->                   |
| struct{key:"key",val:"val"}  |
+------------------------------+
```

也就是说，新的Context在原来的Context上多加了一层，这一层的结构是

`K_KV(RPC框架定义的一个字符串) -> struct{key: "key", val: "val"}`

我们通过`newCtx.Value("key")`是拿不到任何东西的，只能通过`newCtx.Value(K_KV)`才能拿到完整的键值对

#### 这时，RPC框架有了一个骚操作

```text
RPC1 ctx -------中间对ctx做了转化----------> RPC2
```

假设我们上游RPC1使用了如下`AddInfo`

```go
newCtx := AddInfo(ctx, "key", "val")
newCtx2 := AddInfo(newCtx, "key2", "val2")

+------------------------------+
|          newCtx2             |
|   +------------------------+ |
|   |      newCtx            | |
|   |   +-------------+      | |
|   |   |    ctx      |      | |
|   |   +-------------+      | |
|   | K_KV -> struct{        | |
|   |          key:"key"     | |
|   |          val:"val"}    | |
|   +------------------------+ |
|  K_KV -> struct{key:"key2",  |
|                 val:"val2"}  |
+------------------------------+
```

那么`newCtx2`就该如图示的那样，但是下游RPC2拿到的是

```go
+------------------------------+
|          newCtx              |
|   +------------------------+ |
|   |                        | |
|   |        ctx             | |
|   |                        | |
|   +------------------------+ |
|    K_UPSTREAM ->             |
|     map[string]string{       |
|           "key" : "val",     |
|           "key2" : "val2"    |
|     }                        |
+------------------------------+
```

所以，用于从Context取出键值对的索引从`K_KV`变为了`K_UPSTREAM`!!!

这意味着上游传来的消息最多只能保留一个RPC路径，所以我们必须使用`AddInfo`而不是直接写入map的方式来更新数据：

```go
// 获取所有的键值对
m := util.GetAllUpstreamInfo(ctx)
// 取出stack并使用JSON解析
stack, err := json.Unmarshal(m["stack"])
if err != nil {
    logError(...)
    return
}

// 添加现有RPC调用
stack = append(stack, currentRPC)
// JOSN编码，更新ctx内的map
jsonStack, err := json.Marshal(stack)
if err != nil {
    logError(...)
    return
}
ctx = util.AddInfo(ctx, "stack", jsonStack)
```

## 总结

框架底层的逻辑并不是很易懂，解释比较麻烦，一篇博文难以说明清楚，但是需要记住的是：

1. 使用框架，尽量使用框架的标准接口
2. 框架封装的时候，如果有map这类可能会让人有hack欲望的，写明文档
