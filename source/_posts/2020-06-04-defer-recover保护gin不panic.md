---
title: defer+recover保护gin不panic
date: 2020-06-04 18:33:59
tags:
- golang
- gin
categories:
- code snippet
---

本文记录了作者保护gin构建的web app不panic的方式，简单来说：

1. 主程中的panic本身是会被gin拦截的
2. 协程中的panic需要使用`defer`和`recover`进行保护

<!-- more -->

## 情景

在我们用gin构建，运行web app并上线了之后，或许有一些请求会经过业务，在特定的情况下出发会触发golang中的`panic`

按照golang的设定，一旦`panic`，如果不在函数调用栈中存在`recover`，那么是一定会使得整个程序终止的

但是线上的服务是不能够因为一个两个的请求就直接终止了的，这样非常危险，所以我们需要手段来阻止web app在`panic`的情况下直接终止

## 解决方案

### 主程序中的`panic`

对于gin这个web框架来说，主程序中的`panic`是会被自动`recover`的，还会打印出非常详细的日志信息，比如

```go
package main

import (
    "github.com/gin-gonic/gin"
)

func main() {
    r := gin.Default()
    r.GET("/panic", func(ctx *gin.Context) {
        panic("panic")
    })
    r.Run()
}
```

运行之后我们作如下HTTP请求

```bash
> curl localhost:8080/panic
```

会发现在gin的运行窗口出现如下信息

```bash
2020/06/04 18:42:12 [Recovery] 2020/06/04 - 18:42:12 panic recovered:
GET /panic HTTP/1.1
Host: localhost:8080
Accept: */*
User-Agent: curl/7.64.1


panic
/Users/admin/go/src/gin-test/main.go:10 (0x1581418)
        main.func1: panic("panic")
/Users/admin/go/src/github.com/gin-gonic/gin/context.go:165 (0x156baca)
        (*Context).Next: c.handlers[c.index](c)
/Users/admin/go/src/github.com/gin-gonic/gin/recovery.go:83 (0x157fb13)
        RecoveryWithWriter.func1: c.Next()
/Users/admin/go/src/github.com/gin-gonic/gin/context.go:165 (0x156baca)
        (*Context).Next: c.handlers[c.index](c)
/Users/admin/go/src/github.com/gin-gonic/gin/logger.go:241 (0x157ec40)
        LoggerWithConfig.func1: c.Next()
/Users/admin/go/src/github.com/gin-gonic/gin/context.go:165 (0x156baca)
        (*Context).Next: c.handlers[c.index](c)
/Users/admin/go/src/github.com/gin-gonic/gin/gin.go:420 (0x1575d20)
        (*Engine).handleHTTPRequest: c.Next()
/Users/admin/go/src/github.com/gin-gonic/gin/gin.go:376 (0x157548c)
        (*Engine).ServeHTTP: engine.handleHTTPRequest(c)
/usr/local/Cellar/go/1.13.8/libexec/src/net/http/server.go:2802 (0x12cb6d3)
        serverHandler.ServeHTTP: handler.ServeHTTP(rw, req)
/usr/local/Cellar/go/1.13.8/libexec/src/net/http/server.go:1890 (0x12c6f74)
        (*conn).serve: serverHandler{c.server}.ServeHTTP(w, w.req)
/usr/local/Cellar/go/1.13.8/libexec/src/runtime/asm_amd64.s:1357 (0x105c030)
        goexit: BYTE    $0x90   // NOP

[GIN] 2020/06/04 - 18:42:12 | 500 |    1.238546ms |             ::1 | GET      "/panic"
```

并且整个app还在正常运行，没有终止，这非常好

### 协程中的`panic`

不过非常可惜的是，对于协程中的`panic`，gin并不能做到自动`recover`并打印日志信息，比如

```go
package main

import (
    "github.com/gin-gonic/gin"
)

func main() {
    r := gin.Default()
    r.GET("/go-panic", func(ctx *gin.Context) {
        go func() {
            panic("panic")
        }()
    })
    r.Run()
}
```

运行该app之后，我们作如下的HTTP请求

```bash
> curl localhost:8080/go-panic
```

会发现gin app退出了

```bash
panic: panic

goroutine 24 [running]:
main.main.func1.1()
        /Users/admin/go/src/gin-test/main.go:11 +0x39
created by main.main.func1
        /Users/admin/go/src/gin-test/main.go:10 +0x35
exit status 2
```

#### 协程解决方案

所以，对于协程，我们要手动进行`defer`和`recover`，来避免app的退出和打印日志信息，比如上面的代码应该修改为

```go
package main

import (
    "fmt"

    "github.com/gin-gonic/gin"
)

func main() {
    r := gin.Default()
    r.GET("/go-panic", func(ctx *gin.Context) {
        go func() {
            defer func() {
                if err := recover(); err != nil {
                    fmt.Printf("error: %v\n", err)
                }
            }()
            panic("panic")
        }()
    })
    r.Run()
}
```

而后我们像刚才一样进行HTTP请求

```bash
> curl localhost:8080/go-panic
```

会得到如下打印

```bash
error: panic
[GIN] 2020/06/04 - 18:50:20 | 200 |       2.951µs |             ::1 | GET      "/go-panic"
```

可以看到app正常响应了请求，并且没有退出并打印了日志，想要更多定制操作可以修改`defer`的函数
