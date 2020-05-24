---
title: PL(3) Part-A-Week4
tags:
  - Programming Language
category:
  - Open Course
  - Programming Language By Dan Grossman
toc: true
date: 2018-12-13 10:21:38
---


<!-- toc -->

# Ideas of Week4

## Unnecessary Function Wrapping
Unnecessary function wrapping is a low-level mistake. In some languages like C/C++, Java, this is easy to find. But in SML, this becomes a little harder due to the existence of anonymous functions:
```SML
fn x => tl x
```
The code above is a typical unnecessary function wrapping. It is hard to find out because SML makes the **calling** process less observable. And unnecessary function wrapping is easy to confuse with function reusing( though I make up this term, its meaning is straightforward ).
```C
int abs( int a ) {
  diff( a, 0 );
}
```
The code above is function reusing instead of unnecessary function wrapping. One way to distinguish between them, I believe, is to check the parameter list. Function reusing typically uses a different parameter list( like `( a, 0 )` and `( int a )` in the above code ).

## Functional Programming

The term **functional programming** may refer to distinct concepts according to the context. But two most common and important are:

1. immutable data
2. treat functions like values

And there are some more terms that relate to the second point--first-class functions, higher-order functions and function closures. These terms are often used unprecisely or interchangably, but in this course they have the following meaning respectively:

- First-class functions: Those functions which can be passed into or returned from other functions, computed, stored, etc. like values. 
- Higher-order functions: From the name we can tell that it is sort of opposite to *first-class functions*. This term refers to those functions that take or return other functions
- Function closures: This term refers to those functions that use variables defined **outside** them. Another two closely-related terms are *Lexical Scope* and *Dynamic Scope*.

### Lexical Scope vs. Dynamic Scope

Before we tell the difference between these two scopes, we need to clarify some points about functions.  A function actually contains two parts--the code and the environment.  The code part is easy to understand.  But where does the *environment* part come from?  

Consider the code part of functions.  They are nothing more than just a bunch of symbols.  And among the symbols there are arguments, local variables( defined by `let in end` in SML ) and variables defined outside the function body.  The arguments, which are passed to the functions when calling them, have clear meaning--just look them up when calling them.  The local variables, defined inside the function body, also have clear meaning because when we define it in the function body we must be clear enough to pass the compiler.  So the code will reveal the meaning of any local variables.

But here comes the problem--the last one, variables defined outside the function body.  Looking at the code tells us nothing about this kind of variables.  No definition in the body.  No trace of them when calling the function. For example:

```SML
fun f( a, b, c ) =
	let
		q = a + b
	in
		c > q andalso a > d andalso b > e
	end
	
val x = f( 1, 2, 3 )
```
Now the meaning of `a, b, c` are clear--they are arguments, by looking them up in the call-site we know `a = 1, b = 2, c = 3`.  The meaning of `q` is also clear--it is a local variable, by looking it up in the code we know `q = a + b`.  Combined with the infomation of arguments we know `q = 3`.  But what are `d` and `e`?  The code makes no contribution here.  And that's where the **environment** part takes control.  The environment contains **all** the definitions of variables defined outside the functions.

Now here comes the combat of *lexical scope* and *dynamic scope*.  Lexical scope insists that the environment of a function should be the environment where the function get *defined* while the dynamic scope argues the environment of a function should be that where the function get *called*.  For example:
```SML
fun f g =
	let
		val x = 3
	in
		g 2
	end

val x = 2
fun h y = x + y
val z = f h
```
In the code above, if we take the lexical scope, function`h` always increment its argument by 2.  And `z=4`.  If we take the dynamic scope, function `h` increments its argument by 3 when called inside `f` because in `f`, `x` has a new definition `3`.  And `z=5`.

After decades of trials and errors, lexical scope stands out and dynamic scope are now considered inferior style.  The reason, I believe, is that lexical scope **locks** the variables in the function definition and **protects** them from the changing current environment.  So in lexical scope, once a function is defined, the function of it is settled down.  In the subsequent calling we know its effect by just seeing its name.  No need to combine the current environment to get the effect clear.

Lexical scope is widely used and many programming idioms are bound with it.  Dan presents us some in Week4.

<!-- more -->
## Programming Idioms

As mentioned before, to be precise, in PL-PartA Week1, idioms are a part of a programming language. However, some of the idioms are common in many programming languages. In this week, Dan presents us some idioms in functional programming language with lexical scope( though they may also be common in some other programming paradigms ). There are `map`, `filter`, `fold` and **currying**.

In the idioms mentioned above, `map` and `filter` are similar.  They both work on a list and produce another according to some rules.  Part of the rules come with `map` and `filter` and part of the rules is *configurable*.  And the rules are configured by passing a first-class function into them.
### Map

`map` is actually the *functions* in the sense of maths. It takes a list in domain( an `'a list` in SML ) and a relation( a first-class function with type `'a->'b` in SML ) and returns the coresponding list( a `'b list` in SML ) in codomain. A typical implementation of `map` in SML is:
```SML
fun map( f, xs ) =
	case xs of
	  [] => []
	| x::xs' => ( f(x) )::( map(f, xs') )
```

### Filter

`filter` takes in a list of candidates( an `'a list` in SML ) and an evaluation process( an `'a -> bool` function in SML ) and returns a list of the selected( an `'a list` in SML ).  Being selected means making the evaluation process return `true`. A typical implementation in SML is:
```SML
fun filter( f, xs ) =
	  [] => []
	| x::xs' => if ( f(x) ) then x::( filter(f, xs') )
	            else filter( f, xs' )
```

### Fold

The name `fold` of this idiom is more metaphorical than the previous two.  It takes one container( an `'a` variable or accumulator in SML ), a folding function( an `'a * 'b -> 'a` function in SML ) and a list of raw material( a `'b list` in SML ) and returns a container full of material, folded.  The folding process is repeatedly applying the folding function to the accumulator and head element of the material list and storing the result in the accumulator for the next folding until no more element remains in the material list.  A typical implementation of `fold` in SML is:
```SML
fun fold( f, acc, xs ) =
	case xs of
	  [] => acc
	| x::xs' => fold( f, f(acc, x), xs' )
```

### Currying

Currying is a technique commonly used in maths and functional programming.  Some functional programming language even use it to implemente multi-argument functions.  Currying is just a trick that transforms a multi-argument function into a sequence of functions. For example,
```SML
fun sort( a, b, c ) = a < b andalso b < c

fun sort_curry( a )= fn b => fn c => a < b andalso b < c
```
Consider the code above. Calling `sort( a, b, c )` is equivalent to calling `(((sort a)b)c)`.  The key of this trick is--instead of *taking more than one argument*, the function *takes one argument and returns another function that waits for the next argument*.

More infomation about currying can be seen [here](https://en.wikipedia.org/wiki/Currying).
