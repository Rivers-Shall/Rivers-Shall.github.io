---
title: PL(5) Part-B-Week1
date: 2019-03-19 18:36:04
tags:
  - Programming Language
category:
  - Open Course
  - Programming Language By Dan Grossman
toc: true
---

This post is notes from week1 of programming language part B on Coursera.  In this week, Dan introduces the basics of Racket, a programming language with parentheses.  Also, Dan discusses some new concepts---delayed evaluation, thunk, stream, macros.

<!-- more -->
## Scheme vs. Racket

Racket evolves from Scheme.  But Racket made some non-backward-compatable changes.

## Getting Started

DrRacket is splitted into "definition window" and "interaction window", just like editor buffer and REPL buffer for SML in Emacs.

### Comments

Line comments start with ';'.

### `#lang racket`

The first noncommon line of code in the racket file should be `#lang racket`, which informs DrRacket of the fact that it is racket code.(DrRacket can run other codes, thus this line is necessary)

### `(provide (all-defined-out))`

A line used to help test is `(provide (all-defined-out))`.  Racket has a built-in module system where every file is an independent module.  

And by default, everything in a module is private.  Since we will put test code in another file(module), we add this line to make everything public.

### Basic Definition

```Racket
(define s "hello")
```

## Racket Definitions, Functions, Conditionals

```racket
; Definitions
(define x 3) ; val x = 3
(define y (+ x 2)) ; + is a function

; Functions
(define cube1 
  (lambda (x)
    (* x (* x x))))
   
(define cube2
  (lambda (x)
    (* x x x)))
    
(define (cube3 x) ; syntactic sugar
  (* x x x))
 
; Conditions
(define (pow1 x y) ; x to the yth power, y is nonnegative
  (if (= y 0)
    1
    (* x (pow1 x (- y 1)))))
   
; currying
(define pow2
  (lambda (x)
    (lambda (y)
      (pow1 x y))))
      
; partially application
(define three-to-the
  (pow2 3))
  
; 16
(define sixteen ((pow2 4) 2))
```

## Racket Lists

Empty list: `null`
Cons constructor: `cons`, `(list e1 e2 ...)`
Access head of list: `car`
Access tail of list: `cdr`
Check for empty: `null?`

```racket
; sum all the numbers in a list
(define (sum xs)
  (if (null? xs)
    0
    (+ (car xs) (sum (cdr xs)))))

; append (note that hyphen is allowed in names)
(define (my-append xs ys)
  (if (null ? xs)
    ys
    (cons (car xs) (my-append (cdr xs) ys))))

; map
(define (my-map f xs)
  (if (null? xs)
    null
    (cons (f (car xs)) 
          (my-map f (cdr xs)))))
```

## Syntax and Parentheses

Racket Syntax
A term(anything in the language) is either:
1. An atom, e.g., #t, #f, 34, "hi", null, 4.0, x, ...
2. A _special form_, e.g., `define`, `lambda`, `if`
3. A _sequence_ of terms in parens: (t1 t2 ... tn)
   - if t1 a special form, semantics of sequence is special
   - else a function call

Example: (+ 3 (car xs))
Example: (lambda (x) (if x "hi" #t))

Minor note:
Can use `[` anywhere you use `(` but must match with `]`
- will see some places where `[]` is common

### Why this is good?

Converting the program text into a tree representing the program(Parsing) is trival and unambiguous
- Atoms are leaves
- Sequences are nodes with elements as children
- No other rules

No need to discuss "operator precedence" (e.g. `x + y * z`)

## Parentheses Matter!

Parentheses are not optional or meaningless!
- `(e)` means call `e` with zero argument
- `((e))` means call `e` with zero argument and call the result with zero argument

## Dynamic Typing

For now:
1. Frustrating not to catch "little errors" like `(n * x)` until you test your function
2. But can use very flexible data structures and code without convincing a type checker that it makes sense

```racket
(define xs (list 4 5 6))
(define ys (list (list 4 5) 6 7 (list 8) 9 2 3 (list 0 1)))

; sum no matter how deep the list nests
(define (sum1 xs)
  (if (null? xs)
    0
    (if (number? (car xs))
      (+ (car xs) (sum1 (cdr xs)))
      (+ (sum1 (car xs)) (sum1 (cdr xs))))))

(define (sum2 xs)
  (if (null? xs)
    0
    (if (number? (car xs))
      (+ (car xs) (sum2 (cdr xs)))
      (if (list? (car xs))
        (+ (sum2 (car xs)) (sum2 (cdr xs)))
        0))))
```

## `cond` Expression

Alternative for nested `if`-expressions(often a better choice)

```racket
(cond [e1a e1b]
      [e2a e2b]
      ...
      [eNa eNb])
```

:loudspeaker: Good style: `eNa` should be `#t`

`eia` is the condition and `eib` is the result of this branch.  `cond` will select the first true branch to execute.  If there is no true branch, it will return some strange, void value, for which the __Good style__ exists.

```racket
(define (sum3 xs)
  (cond [(null? xs) 0]
        [(number? (car xs)) (+ (car xs) (sum3 (cdr xs)))]
        [#t (+ (sum3 (car xs)) (sum3 (cdr xs)))]))
        
(define (sum4 xs)
  (cond [(null? xs) 0]
        [(number? (car xs)) (+ (car xs) (sum4 (cdr xs)))]
        [(list? (car xs)) (+ (sum (car xs)) (sum (cdr xs)))]
        [#t 0]))
```

For both `if` and `cond`, test expression can evaluate to anything:
- Treat anything other than `#f` as true

This feature makes no sense in a statically typed language since a test expression must have type `bool` or `boolean` or something like that.

```racket
> (if 34 14 15)
14
> (if null 14 15)
14
-----------------

(define (counts-false xs)
  (cond [(null? xs) 0]
        [(list? (car xs)) (+ (counts-false (car xs)) (counts-false (cdr xs)))]
        [(car xs) (counts-false (cdr xs))]
        [#t (+ 1 (counts-false (cdr xs)))]))
```

## Local Binding

```racket
(define (max-of-list xs)
  (cond [(null? xs) (error "max-of-list given empty list")]
        [(null? (cdr xs)) (car xs)]
        [#t (let ([tlans (max-of-list (cdr xs))])
              (if (> tlans (car xs))
                tlans
                (car xs)))]))
                
```

racket has four types of syntax for local bindings:
- `let`
- `let*`
- `letrec`
- `define`

### `let`

Any number of local variables, all evaluated in the environment **before the `let` expression**
- Not like SML
- Convenient for things like `(let ([x y][y x]))`

```racket
(define (silly-double x)
  (let ([x (+ x 3)]
        [y (+ x 2)])
     (+ x y -5)))
```

### `let*`

SML-style `let`, any number of variables, all evaluated in the environment produced from the **previous bindings**

```racket
(define (silly-double x)
  (let* ([x (+ x 3)]
        [y (+ x 2)])
     (+ x y -8)))
```

### `letrec`

Any number of varibles, evaluated in the environment that includes **all the bindings**

```racket
(define (silly-triple x)
  (letrec ([y (+ x 3)]
           [f (lambda (z) (+ z w y x))]
           [w (+ x 6)])
    (f -9)))
```

- Needed for mutually recursive functions (and suggestions say that only use them for mutually recursive functions)
- Variables are stilly evaluated in order, so any forward-reference will cause an error

### Local `define`

same as `letrec`, but prefered over `let, let*, letrec` by designer

```racket
(define (silly-mod2 x)
  (define (even? x) (if (= x 0) #t (odd? (- x 1))))
  (define (odd? x) (if (= x 0) #f (even? (- x 1))))
  (if (even? x) 0 1))
```

## Toplevel Bindings

### Files
Toplevel bindings are like `letrec`.  We can refer to later bindings in a function.  But we need to make sure that the function is called after that binding.  Any other forward-ref will produce error.

No shadowing is possible.

### REPL

Unlike `let*` or `letrec`, hard to say.  But there are still suggestions:

- Avoid recursive function definitions and forward ref
- Avoid shadowing

### Optional(Module System)

- Each file is implicitly a module
- A module can shadow bindings from other modules it uses
  - including standard library(like `+`)
  
## Mutation With `set!`

```racket
(set! x e)
```

For the `x` in the current environment (must be defined before), subsequent look-ups for `x` get the result of evaluating expression `e`.

It is like assignment statement in C, Java, Python, etc.

Once we have side-effects, sequences are useful.
```racket
; final value is en
(begin e1 e2 e3 ... en)
```

### Example
```racket
(define b 3)
(define f (lambda (x) (* 1 (+ x b))))
(define c (+ b 4)) ; 7
(set! b 4)
(define z (f 4)) ; 9
(define w c) ; 7
```
- The closure created by function definition is not evaluated untile called
- Once an expression is evaluated, it is irrelevent

### Defend Against Mutation

A general principle: make a local copy before anything change
```racket
(define b 3)
(define f
  (let ([b b])
    (lambda (x) (* 1 (+ x b)))))
```

The `b` in `f` is the `b` when it is defined instead the `b` when `f` is called.

We could use another name.

#### More Concerns

What if we mutate the `+` and `*` functions? Everything will fall out!

##### Defense From Language Designer

In every module, if this module does not mutate the toplevel variable, no other modules can.  And `+` and `*` are defined in a module where it is not mutated.  Thus `+`, `*` and all these primitives cannot be mutated.

## The Truth About Cons

`cons` is used to make _pairs_.  And a list in racket, like in many other dynamic languages, is a deeply nested pair ending with the empty list.

```racket
(define pr (cons 1 (cons #t "hi"))) ; (1 #t . "hi")
(define lst (cons 1 (cons #t (cons "hi" null)))) ; (1 #t "hi")
(and (list? lst) (pair? pr)) ; true
```

- `car` is `#1` in SML.  `cdr` is `#2` in SML.
- Sometimes we call a list `<proper list>` and a nested pair not ending with `null` an `<inproper list>`.
- Use proper lists for unknown size
- `list?` returns true for all proper lists
- `pair?` returns true for things made by `cons`
  - All improper and proper lists except `null`
  
### Why Allow Improper List?

Without static type, no need to distinguish between `(e1, e2)` and `e1::e2`.

## `mcons` For Mutable Pairs

No way to mutate pairs created by `cons` and this is good:
1. List-Aliasing irrelevent
2. Implementation can make `list?` fast since listness is determined when `cons` cell is created

```racket
> (define mpr (mcons 1 (mcons 43 "hi")))
> mpr
(mcons 1 (mcons 43 "hi"))
> (set-mcar! mpr 13)
> mpr
(mcons 13 (mcons 43 "hi"))
> (set-mcar! (mcdr mpr) 12)
> mpr
(mcons 13 (mcons 12 "hi"))
```

These are the built-in functions for `mcons`:
- `mcons`
- `mcar`
- `mcdr`
- `mpair?`
- `set-mcar!`
- `set-mcdr!`

Runtime-error to use `mcar` on a cons cell or `car` on an mcons cell.

## Delayed Evaluation and Thunks

### Delayed Evaluation

For each language construct, the semantics specifies when subexpressions get evaluated.  In SML, Racket, Java, C:
- Fucntion arguments are eager.
  - Evaluated once before calling the function
- Conditinal branches are not eager.

```racket
; eager subexpression evaluation
(define (my-if-bad x y z)
  (if x y z))
  
; never terminate
(define (factorial-bad n)
  (my-if-bad (= n 0)
    1
    (* n (factorial-bad (- n 1)))))
```

#### Thunks Delay

But we can use function to **delay** the evaluation.  A zero-argument function used to delay evaluation is called a _thunk_.
```racket
(define (my-if-strange-but-works e1 e2 e3)
  (if e1 (e2) (e3)))
  
(define (factorial-okay n)
  (my-if-strange-but-works (= n 0)
    (lambda () 1)
    (lambda () (* n (factorial-okay (- n 1))))))
```

### The Key Point

- Evaluate an expression `e` to get a result:
  - `e`
- A function that _when called_, evaluates `e` and returns result
  - `(lambda () e)`
- Evaluate `e` to some thunk and then call the thunk
  - `(e)`
  
## Avoid Unnecessary Computations

### Avoiding Expensive Computations

Thunks let you skip expensive computations if they are not needed

Great if you take the true-branch:
```racket
(define (f th)
  (if (...) 0 (... (th) ...)))
```

But worse if you end up using the thunk more than once:
```racket
(define (f th)
  (... (if (...) 0 (... (th) ...))
       (if (...) 0 (... (th) ...))
       (if (...) 0 (... (th) ...))
       (if (...) 0 (... (th) ...))))
```

```racket
(define (my-mult x y-thunk)
  (cond [(= x 0) 0]
        [(= x 1) (y-thunk)]
        [#t (+ (y-thunk) (my-mult (- x 1) y-thunk))]))
```

### Best of Both Worlds

Ideal condition:
- Not compute it _until needed_
- _Remember_ the answer so future uses complete immediately
Called _lazy_ evaluation

Languages where most constructs, including function arguments, work this way are _lazy languages_, like Haskell.

## Delay and Force

```racket
(define (my-delay th)
  (mcons #f th))
  
(define (my-force p)
  (if (mcar p)
      (mcdr p)
      (begin (set-mcar! p #t)
             (set-mcdr! p ((mcdr p)))
             (mcdr p))))
```

ADT represented by a mutable pair:
- #f in `car` means `cdr` is unevaluated thunk
- #t in `car` means `cdr` is the result of calling thunk
- one-of type

```racket
(define (f p)
  (... (if (...) 0 (... (my-force p) ...))
       (if (...) 0 (... (my-force p) ...))
       (if (...) 0 (... (my-force p) ...))
       (if (...) 0 (... (my-force p) ...))))
```

Back to the `my-mult` in the previous section:
```racket
(my-mult 100 (let ([p (my-delay (lambda () (slow-add 3 4)))])
                (lambda () (my-force p))))
```

### Lessons From Example

- With thunking second argument:
  - _Great_ if first argument 0
  - _Okay_ if first argument 1
  - _Worse_ otherwise
- With precomputing second argument:
  - _Okay_ in all cases
- With thunk that uses a promise for second argument
  - _Great_ if first argument 0
  - _Okay_ otherwise
  
  
## Using Stream

A stream is an _infinite sequence_ of values
- So cannot make a stream by making all the values
- Key idea: Use a thunk to delay creating most of the sequence
- A programming idiom

A powerful concept for division of labor:
- Stream producer knows how to create any number of values
- Stream consumer decides how many values to ask for

Some examples of streams you might (not) be familiar with:
- User actions (mouse clicks, etc.)
- UNIX pipes: `cmd1 | cmd2`
- Output values from a sequential feedback circuit

### Represent Streams Using Pairs and Thunks

Let a stream be a thunk _when called_ returns a pair: `(next-answer, next-thunk)`

So given a stream, the client can get any number of elements
- Frist: `(car (s))`
- Second: `(car ((cdr (s))))`
- Third: `(car ((cdr ((cdr (s))))))`

```racket
(define (number-until stream tester)
  (let ([f (lambda (stream ans)
              (define pr (stream))
              (if (tester (car pr))
                ans
                (f (cdr pr) (+ ans 1))))])
     (f stream 1)))
```
     
## Defining Stream

```racket
; 1 1 1 1 ...
(define ones (lambda ()
                (cons 1 ones)))
; 1 2 3 4 ...
(define (f x) (cons x (lambda () (f (+ x 1)))))
(define nats (lambda () (f 1)))

; 2 4 8 ...
(define (f x) (cons x (lambda () (f (* x 2)))))
(define nats (lambda () (f 2)))

;;;;;;;;;;;;;;;Something Wrong;;;;;;;;;;;;;
(define ones-really-bad (cons 1 ones-really-bad))
(define ones-bad (lambda () (cons 1 (ones-bad))))
```

## Memoization

If a function has no side effects and does not read mutable memeory, no point in computing it twice for the same arguments
- Can keep a _cache_ of previous results
- Net win if (1) maintaining cache is cheaper than recomputing and (2) cache results are reused

For recursive functions, this _memoization_ can lead to _exponentially_ faster programs.
- Related to algorithmic technique of _dynamic programming_

```racket
; exponential time complexity
(define (fibonacci1 x)
  (if (or (= x 1) (= x 2))
      1
      (+ (fibonacci1 (- x 1)) (fibonacci1 (- x 2)))))
      
; linear time complexity
(define fibonacci2
  (letrec ([memo null] ; list of pairs (arg . result)
           [f (lambda (x)
                (let ([ans (assoc x memo)])
                  (if ans
                      (cdr ans)
                      (let ([new-ans (if (or (= x 1) (= x 2))
                                        1
                                        (+ (f (- x 1)) (f (- x 2))))])
                        (begin (set! memo (cons (cons x new-ans) memo))
                               new-ans)))))])
    f))
```

## Macros: The Key Points

High-level idea of macros

### What is a macro

A _macro definition_ describes how to transform some new syntax into different syntax in the source languange.

A macro is one way to implement syntactic sugar.

A _macro system_ is a language (or part of a larger language) for defining macros.

_Macro expansion_ is the process of rewriting the syntax for each _macro use_. (Before a program is run or compiled)

### Using Racket Macros

If you define a macro `m` in Racket, then `m` becomes a new special form.  Use `(m ...)` gets expanded according to definition.

Example:
- Expand `(my-if e1 then e2 else e3)` to `(if e1 e2 e3)`
- Expand `(comment-out e1 e2)` to `e2`
- Expand `(my-delay a)` to `(mcons #f (lambda () e))`

```racket
> (define seven (my-if #t then 7 else 14))
> seven
7
> (define no-problem (comment-out (car null) #f))
> no-problem
#f
> (define p (my-delay (begin (print "hi") (* 3 4))))
> (my-force p)
hi12
> (my-force p)
12
```
