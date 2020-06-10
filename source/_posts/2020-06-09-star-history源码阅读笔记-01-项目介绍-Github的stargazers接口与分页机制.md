---
title: 'star-history源码阅读笔记(01)-项目介绍,Github的stargazers接口与分页机制，获取star历史的思路'
date: 2020-06-09 16:20:00
tags:
- Github
categories:
- [star-history源码阅读笔记]
- [good practice]
- [basic knowledge]
---

本文是[star-history项目](https://github.com/timqian/star-history)源码阅读的第一篇文章，会包含:

- 作者对项目的介绍，这个系列博文的目的
- Github的stargazers接口
- Github接口的分页策略
- 获取star历史的思路

本次对代码的分析基于Commit - [first commit deecd92 timqian](https://github.com/timqian/star-history/tree/deecd92097809f39cd0ccd521b85ad54ac8fad24)

<!-- more -->

## 项目的介绍与系列博文的目的

### 项目介绍

首先说明，本文作者并非项目作者，各种介绍和分析，如有不当，还请谅解。

[star-history项目](https://github.com/timqian/star-history)([体验地址](https://star-history.t9t.io/))是一个用于统计github项目获得star历史的组件，包括web app网页版本和chrome extension版本

产生这个项目的原因，是Github官方并没有提供查看项目star历史的功能

### 博文目的

- 留作知识沉淀
  - 从体验界面来看，前端效果和功能都很不错，希望学习一下
- 将我三次元的时间，尽！情！挥！霍！

## Github的stargazers接口

Github官方提供了一系列REST API(现在有向graphql上迁移的趋势)，通过REST API，可以获得许多Github上的信息，以此为基础，我们可以构建各式各样的APP，star-history这个项目也是这样建立起来的

Github虽然没有提供直接查看项目star历史的功能，但是却提供了[stargazers接口](https://developer.github.com/v3/activity/starring/)，这个接口有两种形式

1. 查看star了一个项目的所有用户
2. 同上，并且加入该用户star该项目的时间

这二者共用同一个rest url，不同的是：

> 方法2需要在HTTP请求头中加入`Accept: application/vnd.github.v3.star+json`

其rest url和返回的json格式分别是

```json
GET /repos/:owner/:repo/stargazers
# 没有时间
[
  {
    "login": "octocat",
    "id": 1,
    "node_id": "MDQ6VXNlcjE=",
    "avatar_url": "https://github.com/images/error/octocat_happy.gif",
    "gravatar_id": "",
    "url": "https://api.github.com/users/octocat",
    "html_url": "https://github.com/octocat",
    "followers_url": "https://api.github.com/users/octocat/followers",
    "following_url": "https://api.github.com/users/octocat/following{/other_user}",
    "gists_url": "https://api.github.com/users/octocat/gists{/gist_id}",
    "starred_url": "https://api.github.com/users/octocat/starred{/owner}{/repo}",
    "subscriptions_url": "https://api.github.com/users/octocat/subscriptions",
    "organizations_url": "https://api.github.com/users/octocat/orgs",
    "repos_url": "https://api.github.com/users/octocat/repos",
    "events_url": "https://api.github.com/users/octocat/events{/privacy}",
    "received_events_url": "https://api.github.com/users/octocat/received_events",
    "type": "User",
    "site_admin": false
  }
]

GET /repos/:owner/:repo/stargazers
Header:
Accept: application/vnd.github.v3.star+json
# 有star时间
[
  {
    "starred_at": "2011-01-16T19:06:43Z",
    "user": {
      "login": "octocat",
      "id": 1,
      "node_id": "MDQ6VXNlcjE=",
      "avatar_url": "https://github.com/images/error/octocat_happy.gif",
      "gravatar_id": "",
      "url": "https://api.github.com/users/octocat",
      "html_url": "https://github.com/octocat",
      "followers_url": "https://api.github.com/users/octocat/followers",
      "following_url": "https://api.github.com/users/octocat/following{/other_user}",
      "gists_url": "https://api.github.com/users/octocat/gists{/gist_id}",
      "starred_url": "https://api.github.com/users/octocat/starred{/owner}{/repo}",
      "subscriptions_url": "https://api.github.com/users/octocat/subscriptions",
      "organizations_url": "https://api.github.com/users/octocat/orgs",
      "repos_url": "https://api.github.com/users/octocat/repos",
      "events_url": "https://api.github.com/users/octocat/events{/privacy}",
      "received_events_url": "https://api.github.com/users/octocat/received_events",
      "type": "User",
      "site_admin": false
    }
  }
]
```

## Github接口的分页策略

对于stargazers接口，一个仓库很可能有数万甚至数十万个用户star过，如果我们在一次请求
`GET /repos/:owner/:repo/stargazers`
中，就将所有的信息全部都拿出来，会导致:

- 网络IO和内存IO负荷过大
- 不灵活，也许有些接口调用方并不想要全部的数据，只想要部分的，这样的请求IO就全部浪费了

为此，Github的很多API都引入了分页机制

分页机制中，比较重要的有几点：

- 如何知道一个url的资源被分成了多少页？
- 如何知道目前是哪一页？
- 如何知道一个url的资源在一页上有多少个？
- 如何获取一个url任意一页的资源？

我们先来看看Github的REST API是如何接受和提供分页信息的

### 接受分页信息

对于每一个url，我们可以在后面加上`page`和`per_page`参数:

- `per_page`参数指定了一页上有多少个资源
  - 这个参数可以没有，不同的url接口会有不同的默认值，有的是30，有的是100，具体靠阅读文档
  - 并不是所有的url接口都接受这个参数，有些url接口不接受，具体靠阅读文档
- `page`参数指定了需要拿哪一页的资源

### 提供分页信息

在HTTP响应中，Github接口加入一个响应头`Link`，这个响应头的样式大概是

```text
# 注意这个请求没有加上page参数，也能获得Link响应头
GET https://api.github.com/search/code?q=addClass+user%3Amozilla

# HTTP响应的响应头
Link: <https://api.github.com/search/code?q=addClass+user%3Amozilla&page=15>; rel="next",
  <https://api.github.com/search/code?q=addClass+user%3Amozilla&page=34>; rel="last",
  <https://api.github.com/search/code?q=addClass+user%3Amozilla&page=1>; rel="first",
  <https://api.github.com/search/code?q=addClass+user%3Amozilla&page=13>; rel="prev"
```

其中`rel`表示的是url和当前url的关系:

- `prev`，前一页的url
- `next`，下一页的url
- `last`，最后一页的url，也就是总页数
- `first`，第一页的url

### 疑问的解答

所以我们之前的数个疑问就可以得到解答

- 如何知道一个url的资源被分成了多少页？
  - 首先不带`page`参数进行请求，而后通过响应头，提取出`last`对应的url中的`page`参数即可
- 如何知道目前是哪一页？
  - 当前url的`page`参数就是当前页数
  - 响应头中的`next`对应的url中的`page`参数是下一页
- 如何知道一个url的资源在一页上有多少个？
  - 查看文档，会有默认值
  - 查看文档，如果url接口接受`per_page`参数，就可以自行设置(注意可能会有最大值限制)
- 如何获取一个url任意一页的资源？
  - 加入`page`参数

## 获取star历史的思路

了解了Github的stargazers接口及分页策略，我们就可以来分析一下获取star历史的方法:

1. 调用stargazers接口，要带star日期的
2. 根据star日期进行排序
3. 统计出star发生改变的时间(也就是某个用户star了仓库的时间)和当时的star数目(就是排序后的索引值)
4. 以改变的时间作为横轴，改变当时的star数目作为纵轴，绘制图像

这样来看，基本上是没错的，但是还要考虑一点

> 如果一个仓库有数千数万数十万star，我们就要绘制数千数万数十万的点吗？

可以当然是可以的，但是这么做，对于高star的项目，内存和网络消耗过大，处理时间过长，项目初期，不利于我们开发和调试

所以我们可以利用分页机制进行**取样**

比如，我们选定取样点数为20，那么，

- 对于star数目不足20的项目，
  - 我们获取所有的信息，并绘制出所有的点
- 对于star数目高于20的项目(假设star数为N)，
  - 我们获取0, N/20, 2N/20, 3N/20, ..., N时的时间
  - 然后以这二十个时间点和star数，绘制20个点即可

上面描述的是如何取样，那么**取样**与**分页**有什么关系呢？

那就是——我们不需要获取*总star数目*，我们只需要获取*总页数*

- 对于一个stargazers接口页数为N的项目
  - 我们获取0, N/20, 2N/20, 3N/20, ..., N页上最早的时间
  - 然后以这二十个时间点和star数(页编号 * 每页资源数目)，绘制20个点即可

## 代码分析

事实上，项目代码中也是这么操作的(事实上刚才的思路是我从代码中倒推出来的，尬笑)

`generateUrls.js`中

```js
const getConfig = {
  headers: {
    Accept: 'application/vnd.github.v3.star+json',
  },
};

export default async function(repo) {
  const initUrl = `https://api.github.com/repos/${repo}/stargazers`;
  const res = await axios.get(initUrl, getConfig).catch(e => {
      //...
  })
  //
}
```

这表明我们使用的是stargazers的带时间的接口

```js
  const link = res.headers.link;
  if (!link) {
      //...
  } else {
    const pageNumArray = /next.*?page=(\d*).*?last/.exec(link);
    const pageNum = pageNumArray[1];
    let samplePageUrls = [];
    let pageIndexes = [];
    if (pageNum <= sampleNum) {
      for (let i = 2; i <= pageNum; i++) {
        pageIndexes.push(i);
        samplePageUrls.push(initUrl + '?page=' + i);
      }
    } else {
      for (let i = 1; i < sampleNum; i++) {
        let pageIndex = Math.round(i / sampleNum * pageNum);
        pageIndexes.push(pageIndex);
        samplePageUrls.push(initUrl + '?page=' + pageIndex);
      }
    }
    //...
    return {
      samplePageUrls, pageIndexes,
    };
  }
```

显然这一段代码是通过响应头`Link`，使用正则表达式提取出总页数，然后取样`sampleNum`个点

`getStarHistory.js`中

```js
export default async function(repo) {
  const {
    samplePageUrls, pageIndexes
  } = await generateUrls(repo).catch(e => {
    console.log(e); // throw don't work
  });

  const getArray = samplePageUrls.map(url => axios.get(url, getConfig));

  const resArray = await Promise.all(getArray).catch(e => {
    console.log(e); // throw don't work
  });

  const starHistory = pageIndexes.map((p, i) => {
    return {
      date: resArray[i].data[0].starred_at.slice(0, 10),
      starNum: 30 * (p - 1),
    };
  });
  console.log(starHistory);

  return starHistory;
}
```

这一段代码，

1. 通过`generateUrls.js`的接口获取所有采样的url接口，而后进行请求
2. 请求后获得每一页最小的时间，并把最小的时间和当页代表的star数组合起来返回

这样，就得到了一个项目的star历史
