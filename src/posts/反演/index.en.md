---
title: Incidence Algebra and Möbius Inversion
categories:
  - 数学
  - 代数
tags:
  - 数学
  - 反演
preview: 300
math: true
date: 2020-06-11 16:10:11
comments: true
lang: en
---
## Incidence Algebra

### Definition

A locally finite poset is a poset in which every closed interval $[a,b]$ is finite.

> Properties of a partial order:
>
> * Reflexivity: $\forall a\in S:a\le a$
> * Antisymmetry: $\forall a,b\in S: a\le b \wedge b\le a \rightarrow a=b$
> * Transitivity: $\forall a,b,c\in S: a\le b \wedge b\le c \rightarrow a\le c$
>
> Intervals on a poset:
>
> * $[a,b]=\{x|a\le x \wedge x\le b\}$
> * $[a,b)=\{x|a\le x\wedge x\le b\wedge b\neq x\}$
> * $(a,b]=\{x|x\neq a\wedge a\le x\wedge x\le b\}$
> * $(a,b)=\{x|x\neq a\wedge a\le x \wedge x\le b\wedge b\neq x\}$

An element $f$ of incidence algebra is a function mapping each non-empty interval $[a,b]$ of a locally finite poset $S$ to a scalar (a unital ring suffices) $f(a,b)$. Let $X$ be the set of such functions. The convolution operation is defined as:

$$
(f*g)(a,b)=\sum_{x\in [a,b]} f(a,x)g(x,b)
$$

We may also define addition: $(f+g)(a,b)=f(a,b)+g(a,b)$, which yields some interesting properties.

### Properties

#### Associativity

$$
\begin{aligned}
((f*g)*h)(a,b)&=\sum_{x\in[a,b]} (f*g)(a,x)h(x,b) & \text{def.}\\
&=\sum_{x\in [a,b]}\left(\sum_{y\in [a,x]} f(a,y)g(y,x)\right)h(x,b) & \text{def.}\\
&=\sum_{x\in [a,b]}\sum_{y\in[a,x]} f(a,y)g(y,x)h(x,b) & \text{distributivity}\\
&=\sum_{y\in [a,b]}\sum_{x\in[y,b]} f(a,y)g(y,x)h(x,b) & \text{swap sums}\\
&=\sum_{y\in[a,b]}f(a,y)\sum_{x\in[y,b]}g(y,x)h(x,b) & \text{distributivity}\\
&=\sum_{y\in[a,b]}f(a,y)(g*h)(y,b) & \text{def.}\\
&=(f*(g*h))(a,b) & \text{def.}
\end{aligned}
$$

#### Identity

Define $\delta$:

$$
\delta (a,b) =[a=b]= \begin{cases}
1 & a=b\\
0 & \text{otherwise}
\end{cases}
$$

For any $f\in X$:

$$
\begin{aligned}
(f*\delta)(a,b)&=\sum_{x\in [a,b]} f(a,x)\delta(x,b)\\
&=\sum_{x\in [a,b]} f(a,x)[x=b]\\
&=f(a,b) \\
(\delta*f)(a,b)&=\sum_{x\in[a,b]}\delta(a,x)f(x,b)\\
&=\sum_{x\in[a,b]}[a=x]f(x,b) \\
&=f(a,b)
\end{aligned}
$$

Hence $<X,*>$ forms a monoid, with $\delta$ as the identity. By monoid properties, the identity is unique.

#### Distributivity

$$
\begin{aligned}
(f*(g+h))(a,b)&=\sum_{x\in [a,b]} f(a,x)(g+h)(x,b) & \text{def.}\\
&=\sum_{x\in[a,b]}f(a,x)[g(x,b)+h(x,b)]\\
&=\sum_{x\in[a,b]}f(a,x)g(x,b)+f(a,x)h(x,b) \\
&=\sum_{x\in[a,b]}f(a,x)g(x,b)+\sum_{x\in [a,b]}f(a,x)h(x,b) \\
&=(f*g)(a,b)+(f*h)(a,b)\\
&=(f*g+f*h)(a,b)
\end{aligned}
$$

$(f+g)*h=f*h+g*h$ similarly.

#### Inverse

For $f\in X$ with $\forall a\in S:f(a,a)\neq 0$, we can construct:

$$
g(a,b)= \begin{cases}
\frac 1 {f(a,b)} & a=b\\
\frac {-\sum_{x\in (a,b]} f(a,x)g(x,b)} {f(a,a)} & a \neq b\\
\end{cases}
$$

Since $(a,b]=[a,b]-\{a\}$ and $[a,b]$ is finite, this definition is well-formed.

Then:

$$
\begin{aligned}
(f*g)(a,b)=\sum_{x\in[a,b]}f(a,x)g(x,b)&=\begin{cases}
f(a,b)g(a,b)=f(a,b)\frac 1 {f(a,b)}=1 & a=b\\
f(a,a)g(a,b)+\sum_{x\in(a,b]} f(a,x)g(x,b)=0 & a\neq b
\end{cases} \\
&=\delta(a,b)
\end{aligned}
$$

Additionally, $g(a,a)=\frac 1 {f(a,a)}\neq 0$, so $g$ also satisfies the condition.

Symmetrically, we can construct a left inverse:

$$
g'(a,b)= \begin{cases}
\frac 1 {f(a,b)} & a=b\\
\frac {-\sum_{x\in [a,b)} g'(a,x)f(x,b)} {f(b,b)} & a \neq b\\
\end{cases}
$$

satisfying $(g'*f)=\delta$.

Hence $\forall a\in S:f(a,a)\neq 0$ is sufficient for $f$ to be invertible.

Since $1=\delta(a,a)=f(a,a)f^{-1}(a,a)$, it is also necessary ($\forall x\in\mathbb R:0\times x=0$).

Therefore $f$ is invertible iff $\forall a\in S:f(a,a)\neq 0$.

> Consider the subset of incidence algebra:
> $\hat X=\left\{f|f\in X\wedge \forall a\in S:f(a,a)\neq 0\right\}$.
> The structure $<\hat X,*>$ satisfies:
>
> * Closure (product of two non-zero numbers is non-zero):
>
> $$
>   (f*g)(a,a)=f(a,a)g(a,a)\neq0
> $$
>
> * Associativity (same as $<X,*>$)
> * Identity $\delta\in\hat X$
> * Inverses (proved above)
>
> Hence $<\hat X,*>$ forms a group.
>
> (Left and right inverses coincide, as shown below:)
>
> $$
> g=\delta*g=(g'*f)*g=g'*f*g=g'*(f*g)=g'*\delta=g'
> $$

### Relationship with Ordinary Functions

Define $F,G:S\to \mathbb R$, $f\in \hat X$, $a,b\in S$, with the relation:

$$
F(x)=\sum_{k\in [a,x]} G(k)f(k,x)
$$

Then:

$$
\begin{aligned}
\sum_{k\in [a,x]} F(k)f^{-1}(k,x) &=
\sum_{k\in[a,x]} \left[\sum_{t\in [a,k]} G(t)f(t,k)\right] f^{-1}(k,x) & \text{def.}\\
&=\sum_{k\in [a,x]}\sum_{t\in [a,k]} G(t)f(t,k)f^{-1}(k,x) & \text{distributivity}\\
&=\sum_{t\in [a,x]} \sum_{k\in [t,x]} G(t)f(t,k)f^{-1}(k,x) & \text{swap sums}\\
&=\sum_{t\in [a,x]} G(t) \sum_{k\in [t,x]} f(t,k)f^{-1}(k,x) & \text{distributivity}\\
&=\sum_{t\in [a,x]} G(t) \delta(t,x) & \text{def.}\\
&=\sum_{t\in [a,x]} G(t) [t=x] = G(x)
\end{aligned}
$$

> Essentially, this is equivalent to $F(x)=F'(a,x)$.

Symmetrically:

$$
F(x)=\sum_{k\in[x,b]} f(x,k)G(k)\\
G(x)=\sum_{k\in[x,b]}f^{-1}(x,k)F(k)
$$

Thus we can construct a group action on this structure.

## The Poset and the $\zeta$ Function

### Definition

Define $\zeta\in X$ as:

$$
\zeta(a,b)=[a\le b]=\begin{cases}
1 & a\le b \\
0 & \text{otherwise}
\end{cases}
$$

Since the definition of $X$ requires $[a,b]$ to be a non-empty interval, $\exists x\in S:a\le x \wedge x\le b \Leftrightarrow a\le b$. So we can also view $\zeta(a,b)=1$ as shorthand.

Since $\forall a\in S:\zeta(a,a)=1$, we have $\zeta\in \hat X$.

Let $\mu=\zeta^{-1}$. Then:

$$
\mu (a,b)=\begin{cases}
1 & a=b\\
-\sum_{x\in(a,b]} \mu(x,b) = -\sum_{x\in [a,b)} \mu(a,x) & a\lt b\\
0 & \text{otherwise}
\end{cases}
$$

Let $S_1,S_2$ be two posets. Define a partial order on $S_1\times S_2$:

$$
\langle a_1,b_1\rangle \le \langle a_2,b_2\rangle \Leftrightarrow a_1\le a_2 \wedge b_1\le b_2
$$

Thus $S_1\times S_2$ is also a poset. The direct product of finitely many posets is a poset.

### Properties

The number of elements in $[a,b]$ can be expressed as:

$$
\zeta^2(a,b)=\sum_{x\in[a,b]}\zeta(a,x)\zeta(x,b)=\sum_{x\in[a,b]}1=\operatorname{Card}([a,b])
$$

Let $S_1,S_2$ be locally finite posets, $S=S_1\times S_2$. Let $\zeta_1,\zeta_2,\zeta$ be their $\zeta$ functions, $\mu_1,\mu_2,\mu$ their $\mu$ functions, and $\delta_1,\delta_2,\delta$ their $\delta$ functions.

$\forall a,b\in S$ with $a\le b$, let $a=\langle a_1,a_2\rangle,b=\langle b_1,b_2\rangle$. Then:

$$
\begin{aligned}
\delta(a,b)&=[a=b] \\
&=[a_1=b_1\wedge a_2=b_2]\\
&=[a_1=b_1][a_2=b_2]\\
&=\delta_1(a_1,b_1)\delta_2(a_2,b_2)\\
\\
\zeta(a,b)&=[a\le b] \\
&=[a_1\le b_1 \wedge a_2\le b_2] \\
&=[a_1\le b_1][a_2\le b_2]\\
&=\zeta_1(a_1,b_1)\zeta_2(a_2,b_2)\\
\end{aligned}
$$

Construct $\mu'(a,b)=\mu_1(a_1,b_1)\mu_2(a_2,b_2)$. Then:

$$
\begin{aligned}
(\mu'*\zeta)(a,b) &= \sum_{x\in [a,b]} \mu'(a,x)\zeta(x,b) & \text{def.}\\
&=\sum_{x_1\in [a_1,b_1] \wedge x_2\in [a_2,b_2]}
\mu_1(a_1,x_1)\mu_2(a_2,x_2)\zeta_1(x_1,b_1)\zeta_2(x_2,b_2)& \text{expand} \\
&=\sum_{x_1\in [a_1,b_1]}\sum_{x_2\in [a_2,b_2]}
\mu_1(a_1,x_1)\zeta_1(x_1,b_1) \mu_2(a_2,x_2)\zeta_2(x_2,b_2) & \text{split sums}\\
&=\sum_{x_1\in [a_1,b_1]}\mu_1(a_1,x_1)\zeta_1(x_1,b_1)
\sum_{x_2\in [a_2,b_2]} \mu_2(a_2,x_2)\zeta_2(x_2,b_2) & \text{distributivity}\\
&= (\mu_1*\zeta_1)(a_1,b_1) (\mu_2*\zeta_2)(a_2,b_2) \\
&= \delta_1(a_1,b_1)\delta_2(a_2,b_2)\\
&=\delta(a,b)
\end{aligned}
$$

Hence $\mu'=\zeta^{-1}=\mu$, i.e., $\mu(a,b)=\mu_1(a_1,b_1)\mu_2(a_2,b_2)$.

## Inversion

### Binomial Inversion

Let $p_n(x)=x^n$ and $q_n(x)=(x-1)^n$ be polynomials of degree $n$. Then:

$$
\begin{aligned}
q_n(x)&=\sum_{k=0}^n \binom n k (-1)^{n-k} x^k \\
&= \sum_{k=0}^n \binom n k (-1)^{n-k} q_k(x) \\
\\
p_n(x) &= ((x-1)+1)^n\\
&= \sum_{k=0}^n \binom n k (x-1)^k \\
&= \sum_{k=0}^n \binom n k q_k(x)
\end{aligned}
$$

Define $(n+1)\times (n+1)$ matrices $A,B$ (0-indexed):

$$
\begin{aligned}
A_{i,j}&= \binom j i (-1)^{j-i} \\
B_{i,j}&= \binom j i \\
\end{aligned}
$$

Note:

* $A,B$ are both unit upper triangular matrices.
* From the construction of coefficient vectors for $p,q$: $AB=BA=I$, so $A,B$ are inverses.

Let $f(a,b)=A_{a,b}, g(a,b)=B_{a,b}$. Since $A,B$ are unit upper triangular, $f,g$ can be viewed as elements of the incidence algebra on the integer interval $[0,n]$ with the usual order $\le$. This is isomorphic to multiplication of $(n+1)\times (n+1)$ matrices.

$$
\begin{aligned}
(f*g)(a,b)&=\sum_{x\in [a,b]} f(a,x)g(x,b) \\
&=\underbrace{\sum_{x\in [0,a)} f(a,x)g(x,b)}_{f(a,x)=0}
+\sum_{x\in [a,b]} f(a,x)g(x,b)
+\underbrace{\sum_{x\in (b,n]} f(a,x)g(x,b)}_{g(x,b)=0}\\
&=\sum_{x\in [0,n]} f(a,x)g(x,b) \\
&=(AB)_{a,b}=I_{a,b}\\
&=[a=b]=\delta(a,b)
\end{aligned}
$$

Thus $f$ and $g$ are inverses.

According to the relationship between incidence algebra and ordinary functions, for an integer $a$ in $[0,n]$, the following pair of equations are equivalent:

$$
\begin{aligned}
F(x)&=\sum_{k\in [a,x]}G(k)g(k,x)=\sum_{k\in[a,x]} \binom x k G(k) \\
G(x)&=\sum_{k\in[a,x]} F(k)f(k,x)=\sum_{k\in[a,x]}(-1)^{x-k} \binom x k F(k) \\
\end{aligned}
$$

In particular, for $a=0$:

$$
\begin{aligned}
F(x)&=\sum_{k\in [0,x]}G(k)g(k,x)=\sum_{k\in[0,x]} \binom x k G(k) \\
G(x)&=\sum_{k\in[0,x]} F(k)f(k,x)=\sum_{k\in[0,x]}(-1)^{x-k} \binom x k F(k) \\
\end{aligned}
$$

This is known as the binomial inversion formula.

### Möbius Inversion

Take the positive integers $\mathbb N^+$ with divisibility as the partial order. This yields another instance of incidence algebra.

Here:

$$
\begin{aligned}
\zeta(a,b)&=\begin{cases}
1 & a \mid b \\
0 & \text{otherwise}\\
\end{cases} \\
\\
\mu(a,b)&=\begin{cases}
1 & a=b \\
-\sum_{a\mid x \wedge a\neq x \wedge x\mid b} \mu(x,b) & a\mid b \wedge a\neq b \\
0 & \text{otherwise}
\end{cases}
\end{aligned}
$$

By induction:

$$
\begin{aligned}
\mu(ka,kb) &= \begin{cases}
1 & ka = kb &\Leftrightarrow a=b \\
-\sum_{ka\mid kx \wedge ka\neq kx \wedge kx\mid kb} \mu(kx,kb)
& ka \mid kb \wedge ka\neq kb & \Leftrightarrow a \mid b\wedge a\neq b \\
0 & \text{otherwise}
\end{cases} \\
&= \mu(a,b)
\end{aligned}
$$

Furthermore, $\mu(a,b)$ is meaningful (or possibly non-zero) only when $a\mid b$. Hence we can define $\mu'(\frac b a) = \mu(1,\frac b a)=\mu(a,b)$, which simplifies computation.

Then:

$$
\mu'(p)=\begin{cases}
1 & p=1 \\
-\sum_{x\neq 1 \wedge x\mid p} \mu'(\frac p x) & \text{otherwise}
\end{cases}
$$

This function is known as the classical Möbius function.

By the relationship between incidence algebra and ordinary functions, taking the lower bound $a=1$ (so every integer is divisible by $a$), we have the following equivalent pair:

$$
\begin{aligned}
F(x)&=\sum_{k\mid x} G(k) \zeta(k,x)=\sum_{k\mid x} G(k) \\
G(x)&=\sum_{k\mid x} F(k) \mu(k,x)=\sum_{k\mid x} \mu\left(\frac x k\right) F(k) \\
\end{aligned}
$$

Which is the classical Möbius inversion formula.
