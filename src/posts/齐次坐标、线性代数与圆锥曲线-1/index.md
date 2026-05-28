---
title: 齐次坐标、线性代数与圆锥曲线-1
categories:
  - 数学
  - 几何
tags:
  - 数学
  - 齐次坐标
preview: 220
math: true
geogebra: true
date: 2021-04-30 21:09:12
comments: true
---

## 简介

本文与其说是一篇文章，不如说是对于[这篇文章](https://zhuanlan.zhihu.com/p/103884912)的简化与总结。

最终目的是通过引入尽可能少的外部假定，使得我们可以从一个更高的视角看高中的圆锥曲线题。

## 基础要素

观察一个任意二次曲线

$$
Ax^2+Bxy+Cy^2+Dx+Ey+F=0
$$

首先，我们可以做如下换元：

$$
\begin{cases}
  x'=\frac x z\\
  y'=\frac y z\\
\end{cases}
$$

其中$z$为任意实数，则我们可以有：

$$
Ax^2+Bxy+Cy^2+Fz^2+Dxz+Eyz=0
$$

我们均可以将其写成矩阵相乘的形式:

$$
\begin{bmatrix}
  x \\ y \\ z
\end{bmatrix}^T
\begin{bmatrix}
  A   & B/2 & D/2 \\
  B/2 & C   & E/2 \\
  D/2 & E/2 & F   \\
\end{bmatrix}
\begin{bmatrix}
 x \\ y \\  z
\end{bmatrix}
= 0
$$

故我们可以用一个实对称矩阵来表示一个二次曲线。

如果把齐次坐标中的$(x,y,z)$暂时当成三维空间坐标，那么这个二次型描述的是一个过原点的二次锥面。
我们平时在直角坐标系中看到的圆锥曲线，可以理解为这个锥面与仿射平面$z=1$的截线。

[GeoGebra：齐次二次型的锥面与 $z=1$ 截面。](homogeneous-conic-3d.geogebra)

另外对于一条直线，如果我们做同样的换元，我们也可以以一个向量来表述它。
但为了不与点/坐标产生歧义，我们约定后文以行向量表示直线，列向量表示点/坐标。

$$
Ax+By+C=0 \Longleftrightarrow
\begin{bmatrix}
  A & B & C
\end{bmatrix}
\begin{bmatrix}
  x \\ y \\ z
\end{bmatrix}
= 0
$$

### 小结

| 概念                 | 直角坐标系中              | 矩阵表示的齐次坐标中                                            |
| -------------------- | ------------------------- | --------------------------------------------------------------- |
| 点                   | $(x_p,y_p)$               | $\forall z:\begin{bmatrix} x_p/z\\y_p/z\\z \end{bmatrix}$       |
| 直线                 | $Ax+By+C=0$               | $\begin{bmatrix}A&B&C\end{bmatrix}$                             |
| 二次曲线             | $Ax^2+Bxy+Cy^2+Dx+Ey+F=0$ | $\begin{bmatrix}A&B/2&D/2\\B/2&C&E/2\\D/2&E/2&F\\\end{bmatrix}$ |
| 点$p$在直线$l$上     | $l(p)=0$                  | $lp=0$                                                          |  |
| 点$p$在二次曲线$c$上 | $c(p)=0$                  | $p^Tcp=0$                                                       |

## 基础原语

### 点线关系

我们都知道两相异的点可以定义出一条直线，两非平行直线也相交于一点。那么在其次坐标中会如何呢？

> 也可以选择把无穷远点看作两平行线交点，无穷远线看作相同两点连成的直线。
> 这样一样对偶。

首先看两直线的交点，若存在两直线$l_1,l_2$，则其交点$p$需要同时满足：

$$
\begin{cases}
  l_1p=0\\
  l_2p=0\\
\end{cases}
$$

可以看到这与立体几何中“求与两向量同时垂直的第三个向量”这一类问题拥有完全相同的形式。

而这一问题最简单直接的解法就是作两向量的叉乘。但出于对偶性的要求，此处定义两行矩阵叉乘得到列矩阵，列矩阵叉乘得到行矩阵。

> 在向量意义上，简单地，叉乘可以定义为：
>
> $$
> a\times b = \det\left(\begin{matrix}
> \vec i & \vec j & \vec k \\
> a_1 & a_2 & a_3 \\
> b_1 & b_2 & b_3 \\
> \end{matrix}\right)
> $$
>
> 其中,$\vec i,\vec j,\vec k$为各方向上的单位向量。
> 注意到：
>
> $$
> \begin{aligned}
> (a\times b)\cdot a &= \det\left(\begin{matrix}
> \vec i & \vec j & \vec k \\
> a_1 & a_2 & a_3 \\
> b_1 & b_2 & b_3 \\
> \end{matrix}\right) \cdot a\\
> &= \det\left(\begin{matrix}
> a_1 & a_2 & a_3 \\
> a_1 & a_2 & a_3 \\
> b_1 & b_2 & b_3 \\
> \end{matrix}\right) \\
> &= 0
> \end{aligned}
> $$
>
> 对于$b$同理，所以对于$c=a\times b$，任取$\lambda_1,\lambda_2$，
> 我们有：$c\cdot (\lambda_1 a+\lambda_2 b) = 0$

那么我们可以直接写出上述方程组的解：$p=l_1\times l_2$。

> 严格意义上是解系$cl_1\times l_2$，其中$c$是常数。
>
> 但常数$c$大小与解在平面直角坐标系上的对应位置无关，故此处取$c=1$

接下来看过两点的直线，若存在点$p_1,p_2$，则其连成的直线$l$满足：

$$
\begin{cases}
  lp_1 = 0 \\
  lp_2 = 0 \\
\end{cases}
$$

对等式两边翻转可以得到和上面一样的形式，故其解为：$l=p_1 \times p_2$

| 概念                | 直角坐标中                          | 矩阵表示的齐次坐标中 |
| ------------------- | ----------------------------------- | -------------------- |
| 直线$l_1,l_2$的交点 | $l_1(p)=l_2(p)=0$ 的解              | $p=l_1\times l_2$    |
| 过$p_1,p_2$的直线   | $(x-x_1)(y_1-y_2)=(y-y_1)(x_1-x_2)$ | $l=p_1\times p_2$    |

### 直线与点的线性组合

注意到，对于两直线的交点$p=l_1\times l_2$，对于任意$\lambda_1,\lambda_2$，
对两直线的线性组合$l=\lambda_1 l_1 + \lambda_2 l_2$有：

$$
\begin{aligned}
l p &= \lambda_1 l_1 p + \lambda_2 l_2 p \\
    &= 0 + 0 = 0
\end{aligned}
$$

故可知其线性组合亦通过两直线的交点。这对应直角坐标系的一个直线系。

对偶地，对于两点联结的直线:$l=p_1 \times p_2$。对$p_1,p_2$的任意一个线性组合：
$p=\lambda_1 p_1 + \lambda_2 p_2$。我们有：

$$
\begin{aligned}
  lp &= \lambda_1 lp_1 + \lambda_2 lp_2 \\
     &= 0 + 0 = 0
\end{aligned}
$$

其也在二者构成的直线上。

这与直角坐标系上类似。

### 平行

注意一条特殊的“直线”$l_\infty = \begin{bmatrix} 0&0&1 \end{bmatrix}$。

其与任意直线$l$的线性组合$l' = \lambda_1 l_\infty + \lambda_2 l$与$l$的交点均无法在直角坐标系内表示。

$$
\begin{aligned}
l' \times l &= \lambda_1 l_\infty \times l \\
 &= \lambda_1 \begin{bmatrix}-l_y & l_x & 0\end{bmatrix}
\end{aligned}
$$

且其在平面直角坐标系上的表示正好与$l$平行。故我们可以将所有与$l$相差任意倍$l_\infty$的直线认为其与$l$平行。

但对偶地，$\begin{bmatrix} 0\\0\\1 \end{bmatrix}$却代表原点。
