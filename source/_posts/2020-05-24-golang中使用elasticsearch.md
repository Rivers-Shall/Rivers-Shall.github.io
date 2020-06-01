---
title: golang中使用elasticsearch
date: 2020-05-24 21:47:20
tags:
- golang
- elasticsearch
categories:
- code snippet
---

这是一篇介绍如何利用golang第三方库[https://github.com/olivere/elastic](https://github.com/olivere/elastic)进行elasticsearch的操作的文章。
文章中并不会介绍非常详细的API，更侧重于作者在工作中的使用经验和查文档经验。文章中主要包括以下内容：

1. 作者认为比较重要的API设计理念以及文档查阅方式
2. 作者在工作中使用到的elasticsearch的实例，包括从接到需求，查阅文档，并实现的过程

<!-- more -->
## API设计理念思考

### API的分类

在使用elasticsearch的golang Client过程中，我觉得可以将olivere/elastic的常用API分作三类：

1. 面向elasticsearch的metadata的Service
2. 面向elasticsearch的data的Service
3. 面向Query

而这三类分别对应了对elasticsearch的不同类别的操作：

1. 面向elasticsearch的metadata的Service，主要是对elasticsearch的metadata进行查询和操作，比如
   - 配置elasticsearch
   - 查询elasticsearch的状态，比如集群状态，节点数目等
2. 面向elasticsearch的data的Service，住哟是对elasticsearch内的数据和数据格式进行操作
   1. elasticsearch中的index的metadata进行操作，比如
      1. 查询是否存在某个index
      2. 创建并配置index
   2. elasticsearch中的index下的document的增删改操作
3. 面向Query，主要是对index下的document的查询操作

### 分类在代码中的体现

首先需要说明，在olivere/elastic的所有操作都是依靠生成一个`XXXService`对象然后`XXXService.Do(ctx)`来实现的，这里将他们分成面向Service和面向Query只是表示后者我们的主要精力都会集中在构造Query上

#### 面向elasticsearch的metadata的Service

面向elasticsearch的metadata的Service，一般是通过建立连接的ESClient，新建出查询或者操作所需的Service，而后进行操作的模式

比如如下，查询集群内es节点数

```go
// 建立连接的Client
esClient, _ := elastic.NewClient()
// 新建出用于操作的Service
clusterHealthClient := elastic.NewClusterHealthService(esClient)
// 查询，拿到结果
result, _:= clusterHealthClient.Do(context.Background())
fmt.Println(result.NumberOfNodes)
```

#### 面向elasticsearch的data的Service

面向elasticsearch的data的Service，一般是通过建立连接的ESClient的成员函数直接取得Service，而后进行操作

比如如下，新建索引

```go
// Create a new index.
mapping := `{
    "settings":{
        "number_of_shards":1,
        "number_of_replicas":0
    },
    "mappings":{
        "properties":{
            "tags":{
                "type":"keyword"
            },
            "location":{
                "type":"geo_point"
            },
            "suggest_field":{
                "type":"completion"
            }
        }
    }
}`
ctx := context.Background()
createIndex, _ := esClient.CreateIndex("twitter").BodyString(mapping).Do(ctx)
fmt.Println(createIndex.Index)
```

#### 面向Query

面向Query，一般是先新建出Query，而后通过`client.Search().Index(index).Query(query).Do(ctx)`的方式执行查询操作

比如如下，查询上一个构造的索引中，`tags`字段含有`test`的document

```go
query := elastic.NewBoolQuery()
query = query.Must(elastic.NewTermQuery("tags", "test"))
result, _ := esClient.Search().Index("twitter").Query(query).Do(context.Background())
```

## API文档的查询方法

查询olivere/elastic的文档，主要有三个来源：

1. 项目Wiki [https://github.com/olivere/elastic/wiki](https://github.com/olivere/elastic/wiki)
2. 源代码 [https://github.com/olivere/elastic](https://github.com/olivere/elastic)
3. elasticsearch官方文档 [https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html](https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html)

这三者各有特点：

1. 项目Wiki
   - 优点：简单直接，并且会给出相应的操作的示例代码，上手很快
   - 缺点：示例较简单，且不全面，面对复杂逻辑/特定逻辑很可能缺乏指导性，或者找不到相关文档
2. 源代码
   - 优点：全面而且本质的东西，掌握了源代码就掌握了一切
   - 缺点：复杂，费力，考虑投入产出比，几乎绝无必要源码级掌握(除非想成为库的开发者)
3. elasticsearch官方文档
   - 优点：比较齐全的同时仍然是可读性较高的文档，难度在项目Wiki和源代码之间
   - 缺点：没有直接对应到olivere/elastic的API上，找到elasticsearch的API之后，要回头再找olivere/elastic的API

一般的查询方式如下：

1. 首先明确需求，即到底需要获得elasticsearch的什么信息或者对其进行什么操作
2. 明确需求后先查阅Wiki，如果有相应的条目，可用的就可以直接用了
3. Wiki中找不到，那就按照[api设计理念思考](#api设计理念思考)中描述的进行分类
4. 分类后有两条路径
   1. 源代码中寻找对应的Service或者Query接口，找到后去elasticsearch文档验证
   2. elasticsearch文档中寻找对应的查询接口，找到后去olivere/elastic中找对应的接口

当然，合理利用其他资源作为文档入口也是有必要的(或许这才是很多人的首选)：

1. Stack Overflow，启动！
2. 输入关键字查询，能找到合适的问答，就直接采用，不能就返回上述的一般查询方式

## 使用实例与解决过程

### 查询集群的健康状态

过程：

1. 查阅Wiki，没有
2. 查阅源代码，cluster为关键字查找，找到cluster_health.go，前往注释中指定的elasticsearch文档[http://www.elastic.co/guide/en/elasticsearch/reference/7.0/cluster-health.html](http://www.elastic.co/guide/en/elasticsearch/reference/7.0/cluster-health.html)验证想法
3. 想法验证成功，编程

### 实现text类型的字段的模糊查找

过程：

1. 查找Wiki，没有
2. 源代码，elasticsearch文档没有“模糊查找”相关的部分
3. stack overflow 搜索 match part of text，找到使用正则表达式查询RegexQuery的方法
4. 返回elasticsearch文档验证，验证成功
