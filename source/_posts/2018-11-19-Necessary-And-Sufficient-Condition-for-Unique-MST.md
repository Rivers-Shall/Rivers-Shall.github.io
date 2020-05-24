---
title: Necessary-And-Sufficient-Condition-for-Unique-MST
date: 2018-11-19 10:43:50
mathjax: true
tags: 
- MST
- Problem Solving Class
category: 
- Graph Theory
comments: true
---

Let $G$ be a connected weighted graph and $T$ a minimum spanning tree of $G$. Show that $T$ is a unique minimum spanning tree if and only if the weight of each edge $e$ of $G$ that is not in $T$ exceeds the weight of every other edge on the cycle in $T+e$.
<!-- more -->
### Proof

## "$\Rightarrow$": 

Suppose that $T$ is a unique minimum spanning tree. Now we need to prove that the weight of each edge $e$ of $G$ that is not in $T$  exceeds the weight of every other edge on the cycle in $T+e$. We prove the contrapositive of this statement.

Suppose that there is an edge $e$ of $G$ that is not in $T$ and the weight of it is less than or equal that of some other edge $e_0$ on the cycle in $T+e$. Now we take the spanning tree $T+e-e_0$. Now 

$w(T+e-e_0)=w(T)+w(e) -w(e_0)\le w(T)+w(e_0)-w(e_0)=w(T)$. 

Since $T$ is a minimal spanning tree, we know $w(T)\le w(T+e-e_0)$. So we know $w(T)=w(T+e-e_0)$, indicating that $T+e-e_0$ is a minimal spanning tree different from $T$. So the contrapositive of "$\Rightarrow$" has been proved. So is "$\Rightarrow$".

## "$\Leftarrow$": 

To prove this statement, we first give a lemma.

**Lemma ** Suppose that $T$ and $T'$ are both the spanning tree of $G$ and that there exists an edge $e$ such that $e\in T$ and $e\notin T'$(i.e., $T$ and $T'$ are different). Then there exists an edge $e'$ such that $e'\in T'$ and  $e'\notin T$ and that $T-e+e'$ and $T'-e'+e$ are both spanning trees of $G$.

##### Proof of Lemma

Suppose that $e=\{u,v\}$. Then $T-e$ has two connected components, namely $T_1$ and $T_2$. Since $T'$ is also a spanning tree, it must also contain an edge connecting $T_1$ and $T_2$. Now we select this edge as $e'$. It is straightforward that $T-e+e'$ and $T'-e'+e$ are spanning trees because the $-$ disconnects $T_1$ and $T_2$ and $+$ fixes it.

Now we prove the original statement by contradiction. Suppose that $T$ is not unique, i.e., there is another minimal spanning tree $T'$ different from $T$. By the 
lemma, we know there are two edges, $e$ and $e'$ such that $e\in T, e\notin T'$, $e'\in T', e'\notin T$ and that  $T-e+e'$ and $T'-e'+e$ are both spanning trees. But we know that $T+e'$ have a cycle and that $e$ lies on that cycle because $T+e'-e$ is acyclic.  According to the condition of the problem, $w(e')>w(e)$. So we know $w(T'-e'+e)=w(T')-w(e')+w(e)<w(T')=w(T)$, which contradicts the fact that $T$ and $T'$ are both minimal spanning trees.

