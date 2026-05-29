---
title: '[CW]Faberge Easter Eggs Crush Test — Solution (Math Part)'
categories:
  - Online Judge
  - CodeWars
  - 1Kyu
tags:
  - Combinatorics
  - Generating Functions
preview: 274
date: 2020-06-27 21:34:50
math: true
comments: true
lang: en
---

## Recurrence

Let $F(n,m)$ be the function we seek. Then:

$$
\begin{aligned}
  F(0,m)&=0\\
  F(n,0)&=0\\
  F(n,m)&=F(n,m-1)+F(n-1,m-1)+1
\end{aligned}
$$

## Generating Function

The generating function satisfies:

$$
  G(x,y)=yG(x,y)+xyG(x,y)+\frac{xy}{(1-x)(1-y)}
$$

Rearranging:

$$
\begin{aligned}
  (1-y-xy)G(x,y)&=\frac{xy}{(1-x)(1-y)} \\
  G(x,y)&=y(1-y)^{-1}x(1-x)^{-1}(1-y-xy)^{-1}\\
\end{aligned}
$$

## Solving the Generating Function

Let $p_1=(1-x)^{-1},\ p_2=(1-y-xy)^{-1}$.

Then $G(x,y)=y(1-y)^{-1}xp_1p_2$.

$$
\frac {\partial^n G(x,y)} {\partial x^n}
= y(1-y)^{-1}\frac { \partial^nxp_1p_2 } {\partial x^n}\\
\left. \frac{\partial^n G(x,y)}{\partial x^n} \right| _{x=0}
= y(1-y)^{-1}\left.\frac{ \partial^nxp_1p_2 }{\partial x^n}\right| _{x=0}
$$

### Leibniz Rule

Note the following isomorphism:

$$
\begin{aligned}
a^nb^m &\sim u^{(n)}v^{(m)} \\
a^nb^m(a+b)=a^{n+1}b^m+a^nb^{m+1} &
\sim u^{(n+1)}v^{(m)}+u^{(n)}v^{(m+1)}=(u^{(n)}v^{(m)})' \\
a^0b^0(a+b)^n=\sum_{i=0}^n \frac {n!} {i!(n-i)!} a^ib^{n-i}&
\sim (uv)^{(n)}=\sum_{i=0}^n \frac {n!} {i!(n-i)!} u^{(i)}v^{(n-i)} \\
\end{aligned}
$$

### Computing $p_1p_2$

$$
\begin {aligned}
\frac {\partial^np_1} {\partial x^n} &=n!(1-x)^{-n-1} \\
\frac {\partial^np_2} {\partial x^n}& =n!y^n(1-y-xy)^{-n-1}\\
\left. \frac {\partial^np_1}{\partial x^n} \right|_{x=0} &=  n! \\
\left. \frac {\partial^np_2}{\partial x^n} \right|_{x=0} &= n!y^n(1-y)^{-n-1}\\
\left .\frac {\partial^n p_1p_2} {\partial x^n} \right|_{x=0}&
=\sum_{i=0}^n \frac {n!}{i!(n-i)!}
\left.\frac{\partial^{n-i}p_1}{\partial x^{n-i}}
\frac {\partial^i p_2} {\partial x^i} \right|_{x=0}  \\
&= \sum_{i=0}^n \frac {n!} {i!(n-i)!} i!y^i(1-y)^{-i-1}  (n-i)! \\
&=n! \sum_{i=0}^{n} y^i(1-y)^{-i-1} \\
\end {aligned}
$$

### Computing $xp_1p_2$

$$
\begin{aligned}
\frac {\partial^n xp_1p_2} {\partial x^{n}}&
= \sum _{i=0}^n \frac {n!} {i!(n-i)!}\frac {d^ix}{\partial x^i}
\frac {d^{n-i}p_1p_2} {\partial x^{n-i}} \\
&=x \frac {\partial^n p_1p_2} {\partial x^{n}}
+n\frac {d^{n-1}p_1p_2} {\partial x^{n-1}} \\
\left. \frac {\partial^n xp_1p_2} {\partial x^{n}} \right| _{x=0}&
= n\left .\frac {d^{n-1}p_1p_2} {\partial x^{n-1}} \right| _{x=0}\\
&=n(n-1)! \sum _{i=0}^{n-1} y^i(1-y)^{-i-1} \\
&=n!\sum _{i=0}^{n-1} y^i(1-y)^{-i-1}
\end{aligned}
$$

### Solving $G(x,y)$

$$
\begin{aligned}
G(x,y)&=\sum_{n=0}^\infty
\frac{\left. \frac {\partial^n G(x,y)} {\partial x^n} \right|_{x=0}}
{n!}x^n & \text{Maclaurin series} \\
&=\sum _{n=0}^\infty \frac {n!\sum _{j=0}^{n-1}y^{j+1}(1-y)^{-j-2}} {n!} x^n & \text{substitute}\\
&=\sum_{n=0}^\infty x^n\sum _{j=0}^{n-1}  y^{j+1}(1-y)^{-j-2} \\
&=\sum_{n=0}^\infty x^n\sum _{j=0}^{n-1}  y^{j+1}
\sum_{i=0}^\infty \frac {(i+j+1)!}{i!(j+1)!} y^i & \text{expand }(1-y)^{-j-2}\\
&=\sum_{n=0}^\infty x^n\sum _{j=0}^{n-1}
\sum _{i=0}^\infty \frac {(i+j+1)!}{i!(j+1)!} y^{i+j+1} \\
&=\sum_{n=0}^\infty x^n\sum _{j=0}^{n-1}
\sum _{m=j+1}^\infty \frac {m!}{(j+1)!(m-j-1)!} y^m & m=i+j+1\\
&=\sum_{n=0}^\infty x^n\sum _{j=0}^{n-1}
\sum _{m=j+1}^\infty \frac {m!}{(j+1)!(m-j-1)!} y^m \\
&= \sum_{n=0}^\infty x^n \sum _{m=1}^\infty
\sum _{j=0}^{\min(m,n)-1}\frac {m!}{(j+1)!(m-j-1)!} y^m & \text{swap sums} \\
&= \sum_{n=0}^\infty x^n \sum _{m=1}^\infty y^m
\sum _{j=1}^{\min(n,m)}\frac {m!}{j!(m-j)!}  & j=j+1
\end{aligned}
$$

## Solution

$$
F(n,m)=\sum _{j=1}^{\min(n,m)} \frac {m!} {j!(m-j)!}
$$
