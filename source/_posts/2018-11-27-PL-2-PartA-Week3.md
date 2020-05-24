---
title: PL(2) PartA-Week3
tags:
  - Programming Language
category:
  - Open Course
  - Programming Language By Dan Grossman
date: 2018-11-27 23:43:17
toc: true
---

<!-- toc -->
## Ideas of Week3

### Conceptual ways to build compound type

In week2, I have seen many ways to build compound types in SML---lists, options and tuples. And in other language I have learned, like C, there are structs, unions, etc. But in Week3, Dan extract the core ideas behind building compound types and categorize them into three different groups:

- "One of", the compound type descripts data that contains value which is *one of* the basic types that consist of this compound type. Typically, we use "or" in the description, like an `int option` contains an `int` **or** nothing.

- "Each of", the compound type descripts data which contains value of *each of* the basic types that consist of the compound type. Typically, we use "and" in the description, like, a `(int * bool)` tuple contains an `int` value **and** a `bool` value.

- "Self-Reference", the compound type refers to itself in the definition to define a recursive data, like an `int list` is empty list **or** an int **and** **another** `int list`(Note that list actually contains all the concepts mentions above---one-of, each-of and self-reference.)

Naturally, we can have any of them and nest them as deep as we want.

<!-- more -->
### Syntactic Sugar

Dan introduced the concept of syntactic sugar by defining tuples entirely in terms of records. And we can say that "tuples are just syntactic sugar of records with field names 1, 2, ..., n".

So syntactic sugar is just a special kind of language features which can be expressed entirely in terms of equivalent syntax of another language feature.

A simpler example will be `e1 andalso e2` is syntactic sugar of `if e1 then e2 else false`.

Syntactic sugar is introduced to both improve the readability and efficiency of the programming language. To put it another way, syntactic sugar can simplify both the process of understanding a programming language and the process of implementing one. 

Syntactic sugar improves the readability by making the program more concise and the keyword more self-contained. For example, `e1 andalso e2` is more concise than `if e1 then e2 else false`. And the keyword `andalso` is self-revealed about the meaning of this structure.

Syntactic sugar improves the efficiency of implementing the programming language by keeping the core of the language small. For example, once we implement `if e1 then e2 else e3`, we can use it to implement `e1 andalso e2` without much duplicate code. 

### By Position vs. By Name

Accessing by position or by name is a choice of the programming language designer. SML contains both of them---tuples use accessing by position and records use accessing by name, which Dan used to introduce these two concepts.

In SML and some other languages, like C/C++ or Java, the function caller uses accessing by position but the function callee uses accessing by name. And also there are languages, though it is not exactly "Programming Language", like Verilog HDL, provides both accessing by position and accessing by name to ~~function caller~~ module instantiation.

Generally speaking, with small number of fields, accessing by position is more convenient. But with large number of fields, accessing by name seems more reasonable because we can hardly remember which position is which.

### Tail Recursion

A tail recursion is a recursive call where the caller has no more work to do after making the call. Tail recursions can improve memory efficiency by removing unnecessary stack frame. Sometimes it may even be able to improve the time efficiency by using different sub-routines where you can not use with normal recursion.

We can, sometimes easily and even mechanically transform a non-tail recursion into a tail recursion by using an "accumulator". It contains three main steps:

- Use the result of the base case of the original function as the initial accumulator

- Return the accumulator in the base case of the tail-recursion function.

- Combine the work with the accumulator and pass it in the recursive call of the tail recursion.

For example,

```SML
(* original function *)
fun sum xs =
	case xs of
		[] => 0
	|   x::xs' => x + sum xs';
	
(* tail-recursion version *)
fun sum xs =
	let fun aux( xs, acc ) =
		case xs of
			[] => acc 
		|   x::xs' => aux( xs', x + acc )
	in 
		aux( xs, 0 )
	end;
```

The precise definition of **tail recursion** involves the recursive definition of **tail position**. And the definition of **tail recursion** is

*When a recursive call happens in a tail position, it is a tail recursion.*
## Language Features of Week3

Week3 is quite interesting because Dan makes the SML language shrink by introducing the concept of syntactic sugar and pattern-matching.

---
Build our own compound types.

- Build our own "one-of" type by `datatype`. Lists and options are `datatype`s.

- Build our own "each-of" type by records. Tuples are records.

- Build type alias by `type`.

- Build polymorphic type.
---
Use pattern-matching

- Apply `case` expression on both "one-of" and "each-of" type to use pattern-matching.

- Use pattern-matching in `val` binding.

- Every function in SML takes and returns only one argument. Multi-argument function is syntactic sugar for pattern-matching.

- Nested pattern-matching.
---
Also, Dan covered the exception feature in SML because the time is right---an `exception` is very similar to a `datatype` in SML.

- Build our own `exception`s

- `raise` and `handle` exceptions
