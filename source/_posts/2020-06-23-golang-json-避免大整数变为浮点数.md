---
title: golang json 避免大整数变为浮点数
date: 2020-06-23 18:17:49
tags:
- golang
- json
categories:
- [code snippet]
---

本文介绍了作者在使用golang中的json库时，为了避免大整数(`int64`)在经历`Marshal-Unmarshal`的过程后变成浮点数`float64`而做出的处理，简单来说:

- 使用`Decoder`而不是`Unmarshal`来获得更多定制化特性
- `Decoder.UseNumber()`可以避免大整数被处理为浮点数

可参考[stackoverflow相关问答](https://stackoverflow.com/questions/22343083/json-unmarshaling-with-long-numbers-gives-floating-point-number)

<!-- more -->

## 场景

存在一`map[string]interface{}`需要进行json的Marshal和Unmarshal，但是其中可能会出现大整数，比如`"big_number" : 13060000000000`，在直接使用json的Marshal和Unmarshal时，会出现整数被处理为了浮点数的情况

```go
package main

import (
    "encoding/json"
    "fmt"
)

func main() {
    m1 := map[string]interface{}{
        "big_number": 13060000000000,
    }
    b, _ := json.Marshal(m1)
    m2 := map[string]interface{}{}
    json.Unmarshal(b, &m2)
    // map[big_number:1.306e+13]
    // 大整数成为了浮点数
    fmt.Println(m2)
}
```

这个结果其实是可以预见的，毕竟Marshal了之后就变成了普通的字符串，重新Unmarshal时，由于没有办法指定`interface{}`为`int64`，就会出现将大整数默认转化为浮点数的行为

为了处理这种情况，我们不能使用默认的Marshal和Unmarshal，而应该使用更加定制化的动作，比如`Decoder`

```go
package main

import (
    "encoding/json"
    "fmt"
    "strings"
)

func main() {
    m1 := map[string]interface{}{
        "big_number": 13060000000000,
    }
    b, _ := json.Marshal(m1)
    m2 := map[string]interface{}{}

    d := json.NewDecoder(strings.NewReader(string(b)))
    d.UseNumber()
    d.Decode(&m2)
    // map[big_number:13060000000000]
    // 大整数仍然是大整数
    fmt.Println(m2)
}
```

使用`Decoder`，我们可以调用其方法进行更多定制化设置，比如这里就调用了`UseNumber`来避免大整数被转化为浮点数
