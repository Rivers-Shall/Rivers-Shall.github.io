---
title: PL-Part-A-Section-1-Extra-Practice
tags:
  - Programming Language
category:
  - Open Course
  - Programming Language By Dan Grossman
date: 2019-10-15 11:40:51
---

## 函数式编程实现各类排序算法

[Github仓库链接(长期更新)](https://github.com/Rivers-Shall/PL-Extra-Practice)

### 介绍

在Coursera网站上的Programming Languages, Part A课程的第一节的额外练习中，有引导同学实现快速排序和归并排序的过程(事实上在正式作业的challenge部分也用到了排序进行去重，当然可以使用简单的$O(n^2)$算法进行去重，不过排序后去重能提升到$O(n\log n)$而已)，就我个人来看，这也是很有意思的一件事，所以写了博文记录下来。

### 使用到的函数式编程介绍

这次使用的语言是Programming Languages, Part A课程的Standard ML语言。

其实在传统的命令式编程中，我们应该已经比较熟悉各类排序算法的实现了，那么函数式编程有什么区别呢？

在这篇博文中中，我们暂时不使用函数式编程中比较高人气的`map`, `reduce`, `filter`等(第一节的课程也没有涉及，当然，日后可能回来更新也说不定)

我们主要使用的函数式编程功能如下：

- 不可更改的列表(存储同一类型的数据)
- 对列表的操作 `hd`, `tl`(`hd`返回列表第一个元素，`tl`返回删除了列表第一个元素的新列表)
- 元组，可以使用 `#<number>`的方式进行索引的不可变数据(可存储不同类型的数据)
- 递归
- 少量pattern-matching(在`val binding`里)，类似于python中的`x, y = y, x`

<!-- more -->

### 几类排序算法

#### 快速排序

说到排序算法，估计没有人不知道声名在外的快速排序，快速排序可以分为两个阶段:

1. 选定主元并根据主元进行分割
2. 对分割后的子列表进行递归排序

我们先不考虑随机选择主元的问题，直接将列表第一个元素作为主元，如此，我们得到以下代码

```SML
fun sort(numbers : int list) =
    if null numbers
    then []
    else
        let
            fun partition(numbers : int list, pivot : int) =
                if null numbers
                then ([], [])
                else
                    let
                        val current_number = hd numbers
                        val rest_of_numbers = tl numbers
                        val (less_than_or_equal_to_pivot, larger_than_pivot) = partition(rest_of_numbers, pivot)
                    in
                        if current_number > pivot
                        then (less_than_or_equal_to_pivot, current_number :: larger_than_pivot)
                        else (current_number :: less_than_or_equal_to_pivot, larger_than_pivot)
                    end
            val pivot = hd numbers
            val to_partition = tl numbers
            val (less_than_or_equal_to_pivot, larger_than_pivot) = partition(to_partition, pivot)
        in
            sort(less_than_or_equal_to_pivot) @ (pivot :: sort(larger_than_pivot))
        end
```

其中函数`partition`是用来分割列表的，我们在调用的时候直接使用`hd numbers`，也就是列表的第一个元素作为主元。

##### 和命令式编程快排的区别

可以看到基本的逻辑非常清晰，只不过我们多了一个使用`@`操作符进行拼接的过程(由于函数式编程中的列表不能直接修改，我们必须重新构造两个子列表，排序后拼接)。

但是这仍然对我们的快排造成了影响:

1. 快排不再是in-place的了，也就是说排序过程中需要额外的存储空间
2. 快排的渐进时间复杂度虽然没有受到影响($O(n\log n)$)，但是有常数级的减慢

对于时间复杂度，我们可以对拼接操作做这样的分析，一般拼接我们可以认为是这样实现的

```SML
fun concat(alist : int list, blist : int list) =
    if null alist
    then blist
    else (hd alist) :: concat(tl alist, blist)
```

所以其时间复杂度为$O(L_a)$，也就是第一个列表的长度。

在我们的快速排序中也就是$O(n)$，其中$n$为`numbers`的长度，故快排的渐进时间复杂度虽然没有受到影响($O(n\log n)$)，但是有常数级的减慢。

##### 随机选择主元的实现

我们知道，我们一直说的快排$O(n\log n)$时间复杂度其实是平均时间复杂度，想要达到这个目标，随机化必不可少，但我们上面实现的快排直接将第一个元素作为主元进行分割是不合适的，最简单的，面对一个已经排好序的列表，我们的快排将会达到$O(n^2)$的时间复杂度！

所以，我们有必要考虑一下随机选择主元应该怎么实现，一种比较直接的想法是，先随机产生一个下标，然后找到下标中的元素，并将其从原列表中剔除，然后将剩下的列表进行分割。

这样的话，我们需要三个函数，(寻找，剔除，分割(`partition`已实现))，这样当然是很好的，多个函数的合作也符合函数式编程的原则，但是事实上我们可以在一个函数中实现这个功能，这样可以减少遍历数组的次数，减少时间消耗。

```SML
fun extract_and_partition(nth : int, numbers : int list) =
    let
        val current_number = hd numbers
        val rest_numbers = tl numbers
    in
        if nth = 1
        then
            let
                val (less_than_or_equal_to_pivot, larger_than_pivot) = partition(rest_numbers, current_number)
            in
                (current_number, less_than_or_equal_to_pivot, larger_than_pivot)
            end
        else
            let
                val (pivot, less_than_or_equal_to_pivot, larger_than_pivot) = extract_and_partition(nth - 1, rest_numbers)
            in
                if current_number <= pivot
                then (pivot, (current_number :: less_than_or_equal_to_pivot), larger_than_pivot)
                else (pivot, less_than_or_equal_to_pivot, (current_number :: larger_than_pivot))
            end
    end
```

函数`extract_and_partition(nth, numbers)`将numbers中的第`nth`个元素提取出来作为主元并对剩下的所有元素进行分割，带着这个函数意义去阅读代码，逻辑其实比较明确，当然，该函数要求传入的`nth`必须是$[1, length]$中的索引。

所以我们的快排可以改为

```SML
val rand_seed = Random.rand(1, 100)

fun qsort(numbers : int list) =
    if null numbers
    then []
    else
        let
            val rand_index = Random.randInt(rand_seed) mod (List.length numbers) + 1
            val (pivot, less_than_or_equal_to_pivot , greater_than_pivot) = extract_and_partition(rand_index, numbers)
        in
            qsort(less_than_or_equal_to_pivot) @ (pivot :: qsort(greater_than_pivot))
        end
```

这样，就实现了随机选取主元的快排了。但是我们在选取随机索引时使用了`List.length`函数，如果该函数需要遍历整个列表的话，我们的速度又在常数级上减缓了。

#### 归并排序

归并排序与快排类似，也拥有递归的算法形式，主要是先排序子列表，然后合并，但是我们在函数式编程中不能直接在列表上操作，所以我们需要额外的子程序来将原列表分成两半。

一开始，我觉得需要先算出列表的长度，然后除以二后通过选取前`n`个的元素的方式将原列表分为前后两半，但是后来在完成练习的过程中，我发现了更好的办法。

受限于传统的命令式编程中的思维定势，想要将原列表分成**前后两半**是很正常的，但是这需要额外的数组遍历，消耗时间，我们事实上只需要将列表分成两部分就可以了，于是可以使用接下来的这个函数

```SML
(*
20. Write a function divide : int list -> int list * int list that takes a list of integers and produces two 
lists by alternating elements between the two lists. For example: divide ([1,2,3,4,5,6,7]) = ([1,3,5,7], [2,4,6])
*)
fun divide(numbers : int list) =
    let
        fun divide_first_put_to(numbers : int list, put_to_first : bool) =
            if null numbers
            then ([], [])
            else
                let
                    val rest_divided_pairs = divide_first_put_to(tl numbers, not put_to_first)
                in
                    if put_to_first
                    then ((hd numbers) :: (#1 rest_divided_pairs), #2 rest_divided_pairs)
                    else (#1 rest_divided_pairs, (hd numbers) :: (#2 rest_divided_pairs))
                end
    in
        divide_first_put_to(numbers, true)
    end
```

而归并的子程序其实和命令式编程中差不多

```SML
(*
18. Write a function sortedMerge : int list * int list -> int list that takes two lists of integers that 
are each sorted from smallest to largest, and merges them into one sorted list. For example: 
sortedMerge ([1,4,7], [5,8,9]) = [1,4,5,7,8,9]
*)
fun sortedMerge(first_numbers : int list, second_numbers : int list) =
    if null first_numbers andalso null second_numbers
    then []
    else
        if null first_numbers
        then (hd second_numbers) :: sortedMerge(first_numbers, tl second_numbers)
        else
            if null second_numbers
            then (hd first_numbers) :: sortedMerge(tl first_numbers, second_numbers)
            else
                if (hd first_numbers) > (hd second_numbers)
                then (hd second_numbers) :: sortedMerge(first_numbers, tl second_numbers)
                else (hd first_numbers) :: sortedMerge(tl first_numbers, second_numbers)
```

所以我们的归并排序可以写作

```SML
fun merge_sort(numbers : int list) =
    if null numbers orelse null (tl numbers)
    then numbers
    else
        let
            val divided_pairs = divide numbers
        in
            sortedMerge(merge_sort(#1 divided_pairs), merge_sort(#2 divided_pairs))
        end
```

### 总结

这篇博文就到这里，可以看出，由于这些经典的排序算法都具有明显的递归特征，所以函数式编程实现和命令式实现思路非常相似，但是由于函数式编程也有自己的特点，比如不可变数据，列表操作(`hd`, `tl`)等等，我们的实现细节事实上和命令式编程还是有很大的区别。

这次的代码对于递归式的，函数式的思考是一次不错的锻炼，非常有价值。
