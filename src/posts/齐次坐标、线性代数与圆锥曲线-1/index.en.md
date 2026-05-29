---
title: 'Homogeneous Coordinates, Linear Algebra, and Conic Sections - Part 1'
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
lang: en
---

## Introduction

This article is more a summary of [this article (in Chinese)](https://zhuanlan.zhihu.com/p/103884912) than an original work.

The goal is to view high-school conic section problems from a higher perspective, with as few external assumptions as possible.

## Basic Elements

Consider an arbitrary quadratic curve:

$$
Ax^2+Bxy+Cy^2+Dx+Ey+F=0
$$

First, apply the following change of variables:

$$
\begin{cases}
  x'=\frac x z\\
  y'=\frac y z\\
\end{cases}
$$

where $z$ is any real number. Then:

$$
Ax^2+Bxy+Cy^2+Fz^2+Dxz+Eyz=0
$$

This can be written in matrix form:

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

Hence a quadratic curve can be represented by a real symmetric matrix.

If we temporarily treat $(x,y,z)$ in homogeneous coordinates as 3D spatial coordinates, then this quadratic form describes a quadratic cone passing through the origin. The conic section we see in Cartesian coordinates is the intersection of this cone with the affine plane $z=1$.

[GeoGebra: Cone of a homogeneous quadratic form and its $z=1$ section.](homogeneous-conic-3d.geogebra)

For a line, we can also apply the same change of variables and represent it as a vector. To avoid ambiguity with points/coordinates, we adopt the convention: row vectors represent lines, column vectors represent points/coordinates.

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

### Summary

| Concept               | Cartesian coordinates                                 | Homogeneous coordinates (matrix form)                           |
| --------------------- | ---------------------------------------------------- | --------------------------------------------------------------- |
| Point                 | $(x_p,y_p)$                                          | $\forall z:\begin{bmatrix} x_p/z\\y_p/z\\z \end{bmatrix}$       |
| Line                  | $Ax+By+C=0$                                          | $\begin{bmatrix}A&B&C\end{bmatrix}$                             |
| Quadratic curve       | $Ax^2+Bxy+Cy^2+Dx+Ey+F=0$                            | $\begin{bmatrix}A&B/2&D/2\\B/2&C&E/2\\D/2&E/2&F\\\end{bmatrix}$ |
| Point $p$ on line $l$     | $l(p)=0$                                             | $lp=0$                                                          |
| Point $p$ on curve $c$    | $c(p)=0$                                             | $p^Tcp=0$                                                       |

## Basic Primitives

### Point-Line Duality

Two distinct points determine a line; two non-parallel lines intersect at a point. What does this look like in homogeneous coordinates?

> One can also view the point at infinity as the intersection of two parallel lines, and the line at infinity as the line through two identical points. The duality is preserved.

First, consider the intersection of two lines. Given lines $l_1,l_2$, their intersection $p$ must satisfy:

$$
\begin{cases}
  l_1p=0\\
  l_2p=0\\
\end{cases}
$$

This has the same form as "find a vector orthogonal to two given vectors" in solid geometry.

The simplest solution is the cross product of the two vectors. By duality, we define the cross product of two row matrices as a column matrix, and vice versa.

> In vector terms, the cross product can be defined as:
>
> $$
> a\times b = \det\left(\begin{matrix}
> \vec i & \vec j & \vec k \\
> a_1 & a_2 & a_3 \\
> b_1 & b_2 & b_3 \\
> \end{matrix}\right)
> $$
>
> where $\vec i,\vec j,\vec k$ are the unit vectors along each axis. Note that:
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
> Similarly for $b$, so for $c=a\times b$, any $\lambda_1,\lambda_2$ satisfy $c\cdot (\lambda_1 a+\lambda_2 b) = 0$.

The solution to the system above is therefore: $p=l_1\times l_2$.

> Strictly speaking, the solution space is $c\cdot l_1\times l_2$ where $c$ is a scalar.
> The magnitude of $c$ does not affect the corresponding position in Cartesian coordinates, so we take $c=1$.

Next, consider the line through two points. Given points $p_1,p_2$, the line $l$ satisfies:

$$
\begin{cases}
  lp_1 = 0 \\
  lp_2 = 0 \\
\end{cases}
$$

This has the same form when transposed, so the solution is: $l=p_1 \times p_2$.

| Concept                          | Cartesian coordinates                                  | Homogeneous coordinates (matrix form) |
| -------------------------------- | ------------------------------------------------------ | ------------------------------------- |
| Intersection of $l_1,l_2$        | solution of $l_1(p)=l_2(p)=0$                          | $p=l_1\times l_2$                     |
| Line through $p_1,p_2$           | $(x-x_1)(y_1-y_2)=(y-y_1)(x_1-x_2)$                   | $l=p_1\times p_2$                     |

### Linear Combinations of Lines and Points

For the intersection $p=l_1\times l_2$, any linear combination $l=\lambda_1 l_1 + \lambda_2 l_2$ gives:

$$
\begin{aligned}
l p &= \lambda_1 l_1 p + \lambda_2 l_2 p \\
    &= 0 + 0 = 0
\end{aligned}
$$

Hence any linear combination of the two lines also passes through their intersection. This corresponds to a pencil of lines in Cartesian coordinates.

Dually, for the line $l=p_1 \times p_2$ through two points, any linear combination $p=\lambda_1 p_1 + \lambda_2 p_2$ satisfies:

$$
\begin{aligned}
  lp &= \lambda_1 lp_1 + \lambda_2 lp_2 \\
     &= 0 + 0 = 0
\end{aligned}
$$

Thus it lies on the line determined by the two points. This mirrors the Cartesian case.

### Parallelism

Consider the special "line" $l_\infty = \begin{bmatrix} 0&0&1 \end{bmatrix}$.

Its linear combination with any line $l$, namely $l' = \lambda_1 l_\infty + \lambda_2 l$, intersects $l$ at a point that cannot be represented in Cartesian coordinates:

$$
\begin{aligned}
l' \times l &= \lambda_1 l_\infty \times l \\
 &= \lambda_1 \begin{bmatrix}-l_y & l_x & 0\end{bmatrix}
\end{aligned}
$$

In Cartesian coordinates, this direction vector is exactly parallel to $l$. Hence we can consider any line differing from $l$ by a multiple of $l_\infty$ as parallel to $l$.

Dually, $\begin{bmatrix} 0\\0\\1 \end{bmatrix}$ represents the origin.
