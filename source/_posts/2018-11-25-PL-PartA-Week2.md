---
title: PL(1) PartA-Week2
tags:
  - Programming Language
category:
  - Open Course
  - Programming Language By Dan Grossman
date: 2018-11-25 20:40:21
toc: true
---

<!-- toc -->

## History Between PL and Me

PL will stand for the open course Programming Language produced by Dan Grossman on Coursera platform in my posts.

Actually, the first time I met this course was the winter vacation of 2017. I heard about this course on Zhihu and got interested because the people there described how amazing and magic this course can be. But the reason I did not formally take the course until now is that I have tons of bad habits, delaying anything that involves thinking included.

The first time I (informally) took this course was the summer vacation of 2018. I had an impression that this course is a little bit hard-core due to the amount and level of the material. But this impression cannot overshadow the value of the course. So now I am back to take the course formally.

## Structrue of My Notes on PL

The course, as Dan stated, aims at teaching core ideas and concepts behind all the programming languages with several specific programming languages being the vehicle. So contents of every week can be divided into two parts---the contents specific to one selected language and the general idea behind all of them. So will my notes. But typically, I will leave out the language-features part and only present the ideas, concepts or philosophy part.

<!-- more -->
## Ideas of Week2

### How should we learn a language feature?

Every time we encounter a new language feature, understanding it will always be a first task for serious study. But how can we make sure that we understand it? Dan gives us suggestions. We could do in on two aspects:

- Syntax. How should we write down this language feature?

- Semantics. What does the statements or sentences written according to the syntax mean? Normally, we may consider the type-checking rule and the evaluation rule.

### What consists of a programming language?

To learn a programming language, we first need to know what consists of it. As Dan stated, there are five parts for a typical programming language(and I subscribe to his opinion):

- Syntax. How should we write various parts of this language?

- Semantics. What do language features mean?

- Idioms. What are the common approaches to using language features to express computation?

- Libraries. What has been written for you? (Do not reinvent the wheel)

- Tools. What is available to manipulate the language? (debugger, IDE, etc.)

### Lack of Mutation and Benefits of it

The Standard ML does not have approach to assigning value to a variable or mutating the value of a variable. Program written in SML is composed of only "bindings" which is similar to pointer to constants in C.

The significant difference made by this feature is that in the program, there is no difference between alias and copy, which contributes to both the efficiency of SML and security of the program(I believe that this feature sometimes makes the computation harder to express, though).

### Use local variables

Using local variables can improve both readability and efficiency of the program.

Local variables improve the readability by giving a meaningful name to a piece of data or an intermidiate result.

Local variables improve the efficiency by storing the result of computation and avoiding repeated computation.
