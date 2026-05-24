---
title: Incident Algebra与反演
categories:
  - 数学
  - 代数
tags:
  - 数学
  - 反演
preview: 300
mathjax: true
date: 2020-06-11 16:10:11
comments: true
---
## Incidence algebra

### 定义

局部有限偏序集(locally finite poset)是一种特殊的偏序集，其满足对于所有的闭区间$[a,b]$是有限的。

> 偏序关系的性质:
>
> * 自反性：$\forall a\in S:a\le a$
> * 反对称性：$\forall a,b\in S: a\le b \wedge b\le a \rightarrow a=b$
> * 传递性:$\forall a,b,c\in S: a\le b \wedge b\le c \rightarrow a\le c$
>
> 偏序集上的区间：
>
> * $[a,b]=\{x|a\le x \wedge x\le b\}$
> * $[a,b)=\{x|a\le x\wedge x\le b\wedge b\neq x\}$
> * $(a,b]=\{x|x\neq a\wedge a\le x\wedge x\le b\}$
> * $(a,b)=\{x|x\neq a\wedge a\le x \wedge x\le b\wedge b\neq x\}$

Incident algebra中的元素$f$是一个局部有限偏序集$S$上的的非空区间$[a,b]$到一个标量(实际上幺环就足够了)$f(a,b)$的函数。定义其构成的集合为$X$，其上的运算定义如下：

$$
(f*g)(a,b)=\sum_{x\in [a,b]} f(a,x)g(x,b)
$$

有时我们也会在上面额外定义一个加法运算$(f+g)(a,b)=f(a,b)+g(a,b)$，这将使得其满足一些有趣的性质。

### 性质

#### 结合律

$$
\begin{aligned}
((f*g)*h)(a,b)&=\sum_{x\in[a,b]} (f*g)(a,x)h(x,b) & 定义\\
&=\sum_{x\in [a,b]}\left(\sum_{y\in [a,x]} f(a,y)g(y,x)\right)h(x,b) & 定义 \\
&=\sum_{x\in [a,b]}\sum_{y\in[a,x]} f(a,y)g(y,x)h(x,b) & 分配律\\
&=\sum_{y\in [a,b]}\sum_{x\in[y,b]} f(a,y)g(y,x)h(x,b) & 交换求和序\\
&=\sum_{y\in[a,b]}f(a,y)\sum_{x\in[y,b]}g(y,x)h(x,b) & 分配律\\
&=\sum_{y\in[a,b]}f(a,y)(g*h)(y,b) & 定义\\
&=(f*(g*h))(a,b) & 定义
\end{aligned}
$$

#### 单位元

定义函数$\delta$

$$
\delta (a,b) =[a=b]= \begin{cases}
1 & a=b\\
0 & otherwise
\end{cases}
$$

任意$f\in X$，有：

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

故$<X,*>$构成幺半群(Monoid)， $\delta$ 是其单位元，根据幺半群的性质可知它是唯一的单位元。

#### 分配律

$$
\begin{aligned}
(f*(g+h))(a,b)&=\sum_{x\in [a,b]} f(a,x)(g+h)(x,b) & 定义\\
&=\sum_{x\in[a,b]}f(a,x)[g(x,b)+h(x,b)]\\
&=\sum_{x\in[a,b]}f(a,x)g(x,b)+f(a,x)h(x,b) \\
&=\sum_{x\in[a,b]}f(a,x)g(x,b)+\sum_{x\in [a,b]}f(a,x)h(x,b) \\
&=(f*g)(a,b)+(f*h)(a,b)\\
&=(f*g+f*h)(a,b)
\end{aligned}
$$

$(f+g)*h=f*h+g*h$类似

#### 逆

对于$f\in X \wedge \forall a\in S:f(a,a)\neq 0$，我们可以构造：

$$
g(a,b)= \begin{cases}
\frac 1 {f(a,b)} & a=b\\
\frac {-\sum_{x\in (a,b]} f(a,x)g(x,b)} {f(a,a)} & a \neq b\\
\end{cases}
$$

因为$(a,b]=[a,b]-\{a\}$，且$[a,b]$是有限的，故上述定义是良构的。

那么我们有：

$$
\begin{aligned}
(f*g)(a,b)=\sum_{x\in[a,b]}f(a,x)g(x,b)&=\begin{cases}
f(a,b)g(a,b)=f(a,b)\frac 1 {f(a,b)}=1 & a=b\\
f(a,a)g(a,b)+\sum_{x\in(a,b]} f(a,x)g(x,b)=0 & a\neq b
\end{cases} \\
&=\delta(a,b)
\end{aligned}
$$

另外，$g(a,a)=\frac 1 {f(a,a)}\neq 0$，也满足上述条件

对称地，我们可以构造其另一个方向的逆：

$$
g'(a,b)= \begin{cases}
\frac 1 {f(a,b)} & a=b\\
\frac {-\sum_{x\in [a,b)} g'(a,x)f(x,b)} {f(b,b)} & a \neq b\\
\end{cases}
$$

满足$(g'*f)=\delta$

故可知$\forall a\in S:f(a,a)\neq 0$是$f$可逆的充分条件。

因为$1=\delta(a,a)=f(a,a)f^{-1}(a,a)$，故其亦是可逆的必要条件（$\forall x\in\mathbb R:0\times x=0$，以此反证)

因此，$f$可逆的充要条件是$\forall a\in S:f(a,a)\neq 0$

> 我们可以构造Incident algebra元素的一个子集
> $\hat X=\left\{f|f\in X\wedge \forall a\in S:f(a,a)\neq 0\right\}$，
> 那么对于代数结构$<\hat X,*>$，有：
>
> * 封闭性(两非$0$数积非$0$)
>
> $$
>   (f*g)(a,a)=f(a,a)g(a,a)\neq0
> $$
>
>* 结合律（同$<X,*>$)
> * 有单位元$\delta\in\hat X$
> * 有逆(上述已证)
>
>故可知$<\hat X,*>$构成群
>
>亦可知 (左右逆元一致，简证如下)
>
>$$
>g=\delta*g=(g'*f)*g=g'*f*g=g'*(f*g)=g'*\delta=g'
>$$
>

### 与一般函数之间的关系

若定义$F,G:S\to \mathbb R,f\in \hat X,a,b\in S$，且二者满足下列关系:

$$
F(x)=\sum_{k\in [a,x]} G(k)f(k,x)
$$

则有：

$$
\begin{aligned}
\sum_{k\in [a,x]} F(k)f^{-1}(k,x) &=
\sum_{k\in[a,x]} \left[\sum_{t\in [a,k]} G(t)f(t,k)\right] f^{-1}(k,x) & 定义\\
&=\sum_{k\in [a,x]}\sum_{t\in [a,k]} G(t)f(t,k)f^{-1}(k,x) & 分配律\\
&=\sum_{t\in [a,x]} \sum_{k\in [t,x]} G(t)f(t,k)f^{-1}(k,x) & 交换求和序\\
&=\sum_{t\in [a,x]} G(t) \sum_{k\in [t,x]} f(t,k)f^{-1}(k,x) & 分配律\\
&=\sum_{t\in [a,x]} G(t) \delta(t,x) & 定义\\
&=\sum_{t\in [a,x]} G(t) [t=x] = G(x)
\end{aligned}
$$

> 本质上，它是$F(x)=F'(a,x)$的一种等价。

对称地，也可以构造：

$$
F(x)=\sum_{k\in[x,b]} f(x,k)G(k)\\
G(x)=\sum_{k\in[x,b]}f^{-1}(x,k)F(k)
$$

故我们可以在其上构造一个群作用。

## 偏序集与$\zeta$函数

### 定义

定义$\zeta\in X$为：

$$
\zeta(a,b)=[a\le b]=\begin{cases}
1 & a\le b \\
0 & otherwise
\end{cases}
$$

因为在$X$定义时便要求$[a,b]$构成非空区间，
而$\exists x\in S:a\le x \wedge x\le b \Leftrightarrow a\le b$。
因此其也可以看作$\zeta(a,b)=1$

因为$\forall a\in S:\zeta(a,a)=1$，所以$\zeta\in \hat X$

故可令$\mu=\zeta^{-1}$，则有：

$$
\mu (a,b)=\begin{cases}
1 & a=b\\
-\sum_{x\in(a,b]} \mu(x,b) = -\sum_{x\in [a,b)} \mu(a,x) & a\lt b\\
0 & otherwise
\end{cases}
$$

令$S_1,S_2$为两偏序集，定义$S_1\times S_2$上的偏序关系：

$$
<a_1,b_1>\le <a_2,b_2>\Leftrightarrow a_1\le a_2 \wedge b_1\le b_2
$$

因此，我们可以定义$S_1\times S_2$也是一个偏序集，进一步，有限个偏序集的直积也是一个偏序集。

### 性质

区间$[a,b]$中元素的个数可以表示为：

$$
\zeta^2(a,b)=\sum_{x\in[a,b]}\zeta(a,x)\zeta(x,b)=\sum_{x\in[a,b]}1=Card([a,b])
$$

设局部有限偏序集$S_1,S_2$，有$S=S_1\times S_2$。若$\zeta_1,\zeta_2,\zeta$分别为$S_1,S_2,S$上的$\zeta$函数，$\mu_1,\mu_2,\mu$分别为$S_1,S_2,S$上的$\mu$函数，$\delta_1,\delta_2,\delta$分别为$S_1,S_2,S$上的$\delta$函数。

$\forall a,b\in S\wedge a\le b$，令$a=<a_1,a_2>,b=<b_1,b_2>$，易得：

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

进一步地，构造$\mu'(a,b)=\mu_1(a_1,b_1)\mu_2(a_2,b_2)$，则有:

$$
\begin{aligned}
(\mu'*\zeta)(a,b) &= \sum_{x\in [a,b]} \mu'(a,x)\zeta(x,b) & 定义\\
&=\sum_{x_1\in [a_1,b_1] \wedge x_2\in [a_2,b_2]}
\mu_1(a_1,x_1)\mu_2(a_2,x_2)\zeta_1(x_1,b_1)\zeta_2(x_2,b_2)& 展开 \\
&=\sum_{x_1\in [a_1,b_1]}\sum_{x_2\in [a_2,b_2]}
\mu_1(a_1,x_1)\zeta_1(x_1,b_1) \mu_2(a_2,x_2)\zeta_2(x_2,b_2) & 拆开x_1,x_2的求和\\
&=\sum_{x_1\in [a_1,b_1]}\mu_1(a_1,x_1)\zeta_1(x_1,b_1)
\sum_{x_2\in [a_2,b_2]} \mu_2(a_2,x_2)\zeta_2(x_2,b_2) & 分配律\\
&= (u_1*\zeta_1)(a_1,b_1) (u_1*\zeta_2)(a_2,b_2) \\
&= \delta_1(a_1,b_1)\delta_2(a_2,b_2)\\
&=\delta(a,b)
\end{aligned}
$$

故$\mu'=\zeta^{-1}=\mu$，即:$\mu(a,b)=\mu_1(a_1,b_1)\mu_2(a_2,b_2)$

## 反演

### 二项式反演

设$n$次多项式$p_n(x)=x^n,q_n(x)=(x-1)^n$，则有：

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

可以定义$(n+1)\times (n+1)$方阵$A,B$（下标从0开始）：

$$
\begin{aligned}
A_{i,j}&= \binom j i (-1)^{b-a} \\
B_{i,j}&= \binom j i \\
\end{aligned}
$$

可知：

* $A,B$均为单位上三角矩阵
* 构造$p,q$的系数向量可知：$AB=BA=I$，即$A,B$互为逆矩阵。

令$f(a,b)=A_{a,b},g(a,b)=B_{a,b}$。由于$A,B$均为单位上三角矩阵，
故$f,g$可以被看作以$[0,n]$整数区间，小于等于作为偏序关系的Incident algebra中的元素。
其可以和$(n+1)\times (n+1)$矩阵上乘法同构。

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

所以$f,g$互逆。

按照Incident algebra与一般函数之间的关系，对$[0,n]$上一整数$a$，下两式定义等价：

$$
\begin{aligned}
F(x)&=\sum_{k\in [a,x]}G(k)g(k,x)=\sum_{k\in[a,x]} \binom x k G(k) \\
G(x)&=\sum_{k\in[a,x]} F(k)f(k,x)=\sum_{k\in[a,x]}(-1)^{x-k} \binom x k F(k) \\
\end{aligned}
$$

特别地，对于$a=0$，我们有：

$$
\begin{aligned}
F(x)&=\sum_{k\in [0,x]}G(k)g(k,x)=\sum_{k\in[0,x]} \binom x k G(k) \\
G(x)&=\sum_{k\in[0,x]} F(k)f(k,x)=\sum_{k\in[0,x]}(-1)^{x-k} \binom x k F(k) \\
\end{aligned}
$$

一般，我们将此称作二项式反演公式。

### 莫比乌斯反演

将正整数集$\mathbb N^+$上的整除作为偏序关系。我们可以得到另一个Incident algebra实例。

其中：

$$
\begin{aligned}
\zeta(a,b)&=\begin{cases}
1 & a | b \\
0 & otherwise\\
\end{cases} \\
\\
\mu(a,b)&=\begin{cases}
1 & a=b \\
-\sum_{a\mid x \wedge a\neq x \wedge x\mid b} \mu(x,b) & a\mid b \wedge a\neq b \\
0 & otherwise
\end{cases}
\end{aligned}
$$

另外，通过数学归纳，注意到：

$$
\begin{aligned}
\mu(ka,kb) &= \begin{cases}
1 & ka = kb &\Leftrightarrow a=b \\
-\sum_{ka\mid kx \wedge ka\neq kx \wedge kx\mid kb} \mu(kx,kb)
& ka \mid kb \wedge ka\neq kb & \Leftrightarrow a \mid b\wedge a\neq b \\
0 & otherwise
\end{cases} \\
&= \mu(a,b)
\end{aligned}
$$

而且，当$a \mid b$时，$\mu(a,b)$有意义（或者说可能不为$0$）。
故我们可以构造函数$\mu'(\frac b a) = \mu(1,\frac b a)=\mu(a,b)$，即可简化计算。
那么，我们有：

$$
\mu'(p)=\begin{cases}
1 & p=1 \\
-\sum_{x\neq 1 \wedge x\mid p} \mu'(\frac p x) & otherwise
\end{cases}
$$

这个函数又被称作经典莫比乌斯函数。

按照Incident algebra与一般函数之间的关系，取下限$a=1$(故任取$k$均与$a$整除)，我们有下述两等价定义：

$$
\begin{aligned}
F(x) &= \sum_{k\mid x} G(k) \\
G(x) &= \sum_{k\mid x} F(k) \mu(k,x) = \sum_{k\mid x} F(k) \mu'(\frac x k)
\end{aligned}
$$

其中称下式为上式的莫比乌斯反演公式。
