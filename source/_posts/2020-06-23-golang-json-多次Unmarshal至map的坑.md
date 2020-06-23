---
title: golang json 多次Unmarshal至map/struct的坑
date: 2020-06-23 17:13:29
tags:
- golang
categories:
- [basic knowledge]
---

本文介绍的是作者在使用golang的json库时发现的一个坑点，简单来说:

- 当json库Unmarshal到map或者struct中时，并不会默认将`[]byte`中没有提供的字段置为零值

<!-- more -->

## 场景

在服务中有配置以json形式存在于远程配置中心，需要不断拉取配置并Unmarshal到本地配置结构体中

但是在修改配置，进行功能验证的时候，发现部分配置的删除没有生效

最终排查发现是被删除的配置项是一个`map[string]string`，在多次Unmarshal时，map不会被清除，只会加入，导致了问题

## 简单复现

经过试验，发现除了map，对于struct也有同样的问题，且无论是官方json库还是第三方库，都有存在这样的问题

实验代码

```go
package main

import (
    "fmt"

    jsoniter "github.com/json-iterator/go"
)

type test struct {
    Str  string `json:"str"`
    Str2 string `json:"str2"`
}

func main() {
    var m map[string]string

    b1 := `{ "key1" : "value1", "key2" : "value2" }`
    jsoniter.Unmarshal([]byte(b1), &m)
    fmt.Println(m)
    // 仅仅添加了<key3, value3>，没有清除前面的两个kv对
    b2 := `{ "key3" : "value3"}`
    jsoniter.Unmarshal([]byte(b2), &m)
    fmt.Println(m)

    t := test{}
    s1 := `{"str" :"s"}`
    jsoniter.Unmarshal([]byte(s1), &t)
    fmt.Printf("%+v\n", t)
    // 仅仅将Str2字段置为s2，没有将Str字段置为空字符串
    s2 := `{"str2" : "s2"}`
    jsoniter.Unmarshal([]byte(s2), &t)
    fmt.Printf("%+v\n", t)
}
```

其打印结果为

```text
map[key1:value1 key2:value2]
map[key1:value1 key2:value2 key3:value3]
{Str:s Str2:}
{Str:s Str2:s2}
```

## 解决方案

对于map或者struct，如果存在多次Unmarshal的情况，需要在Unmarshal之前手动清空
