---
title: PL-Part-B-Extra-Practice-Week1
tags:
  - Programming Language
category:
  - Open Course
  - Programming Language By Dan Grossman
toc: true
date: 2019-03-20 15:44:14
---


This is a post about the extra practice of an open course on Coursera, Programming Language Part B Week1.  This post will present code snippets and corresponding explanations of practice 7 and 8.  The whole code is available on [Github](https://github.com/Rivers-Shall/PL-Extra-Practice).

This is also my first post about extra practice of PL.  Dan tells us not to present code of homework online, so I won't.  But it feels like presenting code of extra practice is OK.

<!-- more -->

## Practice 7

```racket
; 7.
(define (interleave strms)
  (define (f old-strms new-strms)
    (cond [(null? old-strms) (define real-new-strms (reverse new-strms null))
                             (define pr ((car real-new-strms)))
                             (lambda ()
                               (cons (car pr) (f (cdr real-new-strms) (list (cdr pr)))))]
          [#t                (define pr ((car old-strms)))
                             (lambda ()
                               (cons (car pr) (f (cdr old-strms) (cons (cdr pr) new-strms))))]))
                              
  (f strms null))
```

The requirement of this practice is:

1. Write a function `interleave` that takes a list of streams and produces a new stream that takes one element from each stream in sequence. So it will first produce the first value of the first stream, then the first value of the second stream and so on, and it will go back to the first stream when it reaches the end of the list. 

2. Try to do this without ever adding an element to the end of a list.

Since we need a new stream to _loop around_ the given list of streams, a basic idea is that we get the element of the first stream by `(car ((car strms)))` and add the new stream of the first stream `(cdr ((car strms))` (of course we can precompute `((car strms))`) to the end of the list.  But this is inproper in this case because:

- The second requirement is not ever adding an element to the end of a list
- Adding an element to the end of a list may cost more than to the head of a list

Thus I use two lists, one to produce elements and the other to store the streams for the next round.  The code is a little ugly since we need a special case for `(null? old-strms)`.

## Practice 8

```racket
; 8.
; @first-n-ele-and-last-strm given n and s, return a pair where
;   the car part is a list of first n elements of s and
;   the cdr part is the stream starting from the (n+1)th element
(define (pack n s)
  (define (first-n-ele-and-last-strm n s)
    (cond [(= n 0) (cons null s)]
          [#t (define spr (s))
              (define restpr (first-n-ele-and-last-strm (- n 1) (cdr spr)))
              (cons (cons (car spr)
                          (car restpr))
                    (cdr restpr))]))
  (lambda ()
    (define restpr (first-n-ele-and-last-strm n s))
    (cons (car restpr) (pack n (cdr restpr)))))
```
