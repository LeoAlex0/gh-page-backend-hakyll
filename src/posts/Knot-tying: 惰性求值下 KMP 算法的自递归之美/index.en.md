---
title: "Knot-tying: The Beauty of Self-Recursion in KMP Under Lazy Evaluation"
categories:
  - 计算机科学
  - 算法
tags:
  - Haskell
  - KMP
  - 惰性求值
  - 函数式编程
  - 算法
preview: 280
math: true
mermaid: true
date: 2026-05-28 12:00:00
comments: true
lang: en
---

## The Prefix Function and KMP

The string matching problem: given a pattern $pat$ and text $txt$, find all occurrences of $pat$ in $txt$. The naive approach compares character by character, and on a mismatch rewinds both the pattern and text pointers — $O(nm)$ worst case.

**KMP's key insight**: the text pointer never needs to go backwards. If $k$ characters have been matched, then the first $k-1$ characters of the pattern are identical to the just-scanned portion of the text. This overlap lets us slide the pattern forward to the next viable position without re-scanning.

This "overlap information" is captured by the **prefix function** $\pi$. For a pattern $s[0..n-1]$, $\pi(i)$ is defined as:

$$
\pi(i) = \max_{k=0..i}\big\{\,k \;\big|\; s[0..k-1] = s[i-(k-1)..i] \,\big\}
$$

That is, $\pi(i)$ is the length of the longest **proper prefix** of $s[0..i]$ that is also a **suffix**. $\pi(0)=0$.

Example: pattern `"aabaaab"` and its $\pi$:

| $i$ | 0 | 1 | 2 | 3 | 4 | 5 | 6 |
|-----|----|----|----|----|----|----|----|
| $s[i]$ | a | a | b | a | a | a | b |
| $\pi[i]$ | 0 | 1 | 0 | 1 | 2 | 2 | 3 |

Intuitively, $\pi(i)=k$ means $s[0..k-1]$ and $s[i-(k-1)..i]$ are identical. When a mismatch occurs at text position $j$ on character $s[k]$, we can keep the text pointer in place and **fall back** the pattern state to $\pi(k-1)$ instead of $0$ — because the first $\pi(k-1)$ characters have already been implicitly matched before the mismatch. This is what gives KMP its linear time.

---

## Haskell Implementation: Show Me the Code

Three functions. **Ready to run.**

```haskell
-- | Single-step transition: given prefix function pi, pattern pat,
-- current state s and character c, return the next state.
step :: (Eq tok) => A.Array Int Int -> A.Array Int tok -> Int -> tok -> Int
step pi pat s c
  | pat A.! s == c = s + 1                              -- match: advance
  | s == 0         = 0                                  -- at root: stop
  | otherwise      = step pi pat (pi A.! (s - 1)) c     -- follow pi failure chain
```

```haskell
-- | Prefix function pi, constructed in one pass via knot-tying with scanl.
prefix :: (Eq tok) => A.Array Int tok -> A.Array Int Int
prefix pat
  | null pat   = A.listArray (0, 0) [0]
  | otherwise  = pi
  where
    -- knot: pi shares the bounds of pat; scan step over itself to build it
    pi = A.listArray (A.bounds pat) (scanl (step pi pat) 0 (tail (A.elems pat)))
```

```haskell
-- | KMP matching: compute pi with prefix, advance state with scanl, detect match with any.
contains :: (Eq tok) => A.Array Int tok -> [tok] -> Bool
contains pat = any (== n) . scanl (step pi pat) 0
  where
    pi = prefix pat
    n  = A.rangeSize (A.bounds pat)
```

**That is all.** `step` in four lines, `prefix` in four lines, `contains` in three lines. $\pi$ directly reuses `pat`'s bounds via `A.bounds pat` — no separate `n = length pat` variable is needed. The `for i = 1 to n-1` boilerplate that clutters traditional implementations is absorbed by `scanl` + `tail` + `elems`.

---

## Code Breakdown

### `step`: the transition core

`step` is the only place that understands the KMP state-transition logic. Its signature is:

```haskell
step :: Array Int Int → Array Int tok → Int → tok → Int
```

Three data inputs — $\pi$ (`pi`), the pattern (`pat`), the current state — plus a character, and it returns the next state. On a match: advance. On a mismatch: follow the $\pi$ failure chain. At the root: stop.

Key design: `step` does **not own** $\pi$ or the pattern — both are explicit parameters. `prefix` passes in a $\pi$ that is **under construction** (the knot); `contains` passes in a $\pi$ that is **already built** (ordinary call). Same `step`, two uses.

### `prefix`: holding up a mirror to itself

```haskell
pi = A.listArray (A.bounds pat) (scanl (step pi pat) 0 (tail (A.elems pat)))
```

This single line performs two actions:

1. `scanl`, starting from $0$, applies `step pi pat` sequentially to $pat[1..n-1]$, producing $\pi(0), \pi(1), \dots, \pi(n-1)$
2. `pi` simultaneously serves as an input to `step` — this is the **knot**: $\pi$ uses `step` scanning itself to be constructed, while `step` needs $\pi$ to follow the failure chain

Note that `pi` directly reuses `pat`'s bounds — `A.bounds pat` determines `pi`'s length, eliminating the need to manually compute and thread `n` through the code.

```mermaid
flowchart TD
    scanl["scanl (step pi pat)"] -->|"produces"| pi["pi"]
    pi -->|"pi A.! (s-1)"| step["step pi pat"]
    scanl -->|"applies"| step
```

In a strict language this would be the paradox of "reading from an unfinished data structure." In Haskell, `Data.Array` is lazy in its boxed elements: `scanl` produces thunks one by one from left to right, and when `step` needs $\pi(j-1)$ (where $j-1 <$ the current index), that thunk has already been sequentially forced by `scanl`.

### `contains`: scanning the text

```haskell
contains pat = any (== n) . scanl (step pi pat) 0
  where
    pi = prefix pat
    n  = A.rangeSize (A.bounds pat)
```

`scanl (step pi pat) 0` drives `step pi pat` as a state machine across the text, producing a state sequence; `any (== n)` checks whether the accepting state $n$ is ever reached. `prefix` supplies $\pi$. The data flow among the three:

```mermaid
flowchart LR
    prefix["prefix"] -->|"pi"| contains["contains"]
    prefix --> step["step"]
    contains --> step
```

---

## Correctness Proof

What follows is a rigorous mathematical proof. We define three mathematical objects — $\pi$, $\mathrm{step}$, $\{p_i\}$ — then prove that $\{p_i\}$ exactly equals $\{\pi(i)\}$.

### Definitions

**Definition 1 (Prefix function)** For a string $s[0:n]$ (all index intervals are half-open $[a,b)$), $\pi : \{0,\dots,n-1\} \to \mathbb{N}$:

$$
\pi(i) = \begin{cases}
0, & i = 0 \\
\max\{\,k \in [0,i] \mid s[0:k] = s[i+1-k : i+1]\,\}, & i \ge 1
\end{cases}
$$

**Definition 2 (Transition function)** Given $s$ and its $\pi$, $\mathrm{step} : \mathbb{N} \times \Sigma \to \mathbb{N}$ (where $\Sigma$ is the alphabet):

$$
\mathrm{step}(j, c) = \begin{cases}
j + 1, & \text{if } s[j] = c \\[2pt]
0,     & \text{if } s[j] \neq c \;\land\; j = 0 \\[2pt]
\mathrm{step}(\pi(j-1),\, c), & \text{if } s[j] \neq c \;\land\; j > 0
\end{cases}
$$

**Definition 3 (scanl sequence)** The sequence $\{p_i\}_{i=0}^{n-1}$:

$$
p_i = \begin{cases}
0, & i = 0 \\
\mathrm{step}(p_{i-1},\, s[i]), & i \ge 1
\end{cases}
$$

That is, $[p_0,\dots,p_{n-1}] = \mathrm{scanl\ step\ 0}\ [s[1],\dots,s[n-1]]$.

### Theorem

**Theorem** $\forall i \in [0, n-1]:\; p_i = \pi(i)$.

*Proof.* By induction on $i$.

**Base case** $i = 0$: $p_0 = 0 = \pi(0)$. QED

**Inductive step** Assume $p_k = \pi(k)$ for all $k < i$ (strong induction). Let $j = p_{i-1} = \pi(i-1)$. Then $p_i = \mathrm{step}(j, s[i])$.

The definition of $\mathrm{step}$ has three branches; we proceed by case analysis on them:

---

**Case A** $s[j] = s[i]$.

Here $p_i = \mathrm{step}(j, s[i]) = j+1$. We prove $\pi(i) = j+1$.

($\ge$)
$$
\begin{aligned}
s[0:j] &= s[i-j:i] && [j = \pi(i-1)] \\
s[j] &= s[i] && [\text{premise}] \\[2pt]
\implies s[0:j+1] &= s[i-j:i+1] && [\text{append}] \\
\implies \pi(i) &\ge j+1 && [\text{def. of } \pi]
\end{aligned}
$$

($\le$)
$$
\begin{aligned}
k = \pi(i)
&\implies s[0:k] = s[i+1-k:i+1] && [\text{def. of } \pi] \\
&\implies s[0:k-1] = s[i+1-k:i] && [\text{drop last char}] \\
&\implies \pi(i-1) \ge k-1 && [\text{def. of } \pi] \\
&\implies j \ge k-1 && [\pi(i-1)=j] \\
&\implies k \le j+1 \\
&\implies \pi(i) \le j+1
\end{aligned}
$$

From $(\ge)(\le)$: $\pi(i) = j+1 = p_i$. QED

---

**Case B** $s[j] \neq s[i]$ and $j = 0$.

Here $p_i = \mathrm{step}(j, s[i]) = 0$. We prove $\pi(i) = 0$.

Let $M_m = \{\,k \mid s[0:k] = s[m+1-k:m+1]\,\}$, so $\pi(m) = \max M_m$.

From $\pi(i-1) = 0$:
$$
M_{i-1} = \{0\} \tag{1}
$$

For any $k \ge 1$:
$$
\begin{aligned}
k \in M_i
&\implies s[0:k] = s[i+1-k:i+1] && [\text{def. of } M_i] \\
&\implies s[0:k-1] = s[i+1-k:i] && [\text{drop last char}] \\
&\implies k-1 \in M_{i-1} && [\text{def. of } M_{i-1}] \\
&\implies k-1 = 0 && [\text{by (1)}] \\
&\implies k = 1
\end{aligned}
$$

Also:
$$
\begin{aligned}
1 \in M_i
&\iff s[0:1] = s[i:i+1] && [\text{def. of } M_i] \\
s[0] &= s[j] \neq s[i] && [j=0,\ \text{premise}] \\[2pt]
&\Downarrow \\
1 &\notin M_i
\end{aligned}
$$

Thus $M_i$ contains no $k \ge 1$. Since $0 \in M_i$ always (empty match):
$$
M_i = \{0\},\qquad \pi(i) = \max M_i = 0 = p_i
$$

QED

---

**Case C** $s[j] \neq s[i]$ and $j > 0$.

Here $p_i = \mathrm{step}(j, s[i]) = \mathrm{step}(\pi(j-1), s[i])$.

From $s[j] \neq s[i]$ and $\pi(i-1)=j$:
$$
\pi(i) \le j \tag{2}
$$

Let $k = \pi(i)$, $k \le j$. By definition of $\pi$:
$$
\begin{aligned}
s[0:k] &= s[i+1-k:i+1] \\
&\Downarrow \\
s[0:k-1] &= s[i+1-k:i] && [\text{drop last char}] \\
&= s[j+1-k:j] && [k \le j,\ \text{using } s[0:j]=s[i-j:i]] \\
&\Downarrow \\
k-1 &\in \{\,\ell \mid s[0:\ell] = s[j-\ell:j]\,\} \\
s[k-1] &= s[i] && [\text{last char of match}]
\end{aligned}
$$

Therefore:
$$
\pi(i) = \max\{\,\ell+1 \mid s[0:\ell] = s[j-\ell:j],\; s[\ell] = s[i]\,\}
$$

(or $0$ if the set is empty). This is precisely what $\mathrm{step}$ computes
by traversing the $\pi$-chain $\pi(j-1),\pi(\pi(j-1)-1),\dots,0$ in descending
order. By strong induction all $\pi$ values on this chain are correct,
so $\mathrm{step}(\pi(j-1), s[i]) = \pi(i)$.

Hence $p_i = \pi(i)$. QED

---

Thus, by mathematical induction, $\forall i:\; p_i = \pi(i)$. QED

---

## Lazy Evaluation: Why This Works

The `prefix` function contains an apparently circular dependency: `pi`'s definition references `step pi pat`, and `step`'s third argument is `pi` itself. In most languages this would crash immediately — you cannot read from a data structure that is still under construction.

To understand why Haskell can, we need to look at **evaluation strategy**.

### Strict vs Lazy Evaluation

Mainstream languages (Rust, C++, Java, Python, etc.) use **strict evaluation** (also called eager evaluation): before a function is called, all its arguments must be fully computed to concrete values. Compute first, then call.

Haskell uses **lazy evaluation**: an expression is computed only when its result is **actually demanded**. Function arguments are not evaluated at the call site; instead they are packaged as **thunks** — deferred computations that say "figure this out when needed." Only when an operation must know the actual value of a thunk (e.g., pattern matching, output, arithmetic) does the runtime **force** the thunk, execute the computation, and replace the thunk with the result.

### What Are Spines and Thunks?

Take `Data.Array` as an example. An array in memory consists of two things:

- **spine**: the index structure and bounds — "this is an array of length n."
- **elements**: the values stored in each slot.

`A.listArray` forces the **spine** to validate that the bounds are legal, but does **not** force the element values. Each slot can hold a thunk — an unevaluated but type-correct expression.

As `scanl` sweeps left to right over the pattern, it produces $\pi(0), \pi(1), \dots$ in order. Each $\pi(i)$ is a thunk containing the expression `step pi pat` applied to the previous state. When `step` needs to read $\pi(j-1)$ (where $j-1 < i$), that thunk has already been forced by `scanl` in an earlier iteration — so it is already a concrete integer, safe to read.

```
Timeline (scanl left to right):
  index 0: force thunk₀ → π(0)=0           ✓ no dependency
  index 1: force thunk₁ → step needs π(0)   ✓ π(0) ready
  index 2: force thunk₂ → step needs π(1)   ✓ π(1) ready
  ...
  index i: force thunkᵢ → step needs π(j-1) ✓ j-1 < i, ready
```

The key property: **the data dependency index is always less than the index currently being computed**. This guarantees the computation graph is **directed acyclic** — there is no true forward reference, only "referring to a prefix of the same array." Lazy evaluation allows this self-referential structure to be unwound left to right, with each step only reading from the already-computed prefix.

### What Happens in Other Languages?

In a strict language, `A.listArray` would force not only the spine but also **all elements immediately** — because the array constructor requires every element to be ready at creation time. This means at the moment $\pi$ is being constructed, every step of `scanl` must be computed right then, and the very first step needs to access $\pi$ (which doesn't exist yet), causing a deadlock.

A KMP implementation in Rust or C++ must use explicit two-pass loops: the first pass computes partial information, the second pass fills in the rest — or use a `for` loop that manually maintains state, with each iteration only accessing positions that have already been written. This is essentially hand-coding the topological sort into the program.

Haskell's lazy arrays let the programmer **delegate the topological sort to the runtime** — as long as data dependencies are forward ($j < i$), lazy evaluation automatically serializes the computation. This is the essence of knot-tying: **exploit the topological ordering of evaluation to transform a cyclic dependency into a directed acyclic computation graph.**

---

## Closing

```
step     — transition logic (pi and pattern are both explicit parameters; four lines)
prefix   — scan step over itself, knot-tying builds pi (the core, one line)
contains — use prefix + scanl + any to match text (three core lines)
```

The self-referential structure of KMP — $\pi(i)$ depending on $\pi(j)$ ($j < i$) — is not an obstacle to be worked around in a lazy language; it is program text that can be written directly. `step` abstracts "following the failure chain" into a pure function, and `prefix` uses `scanl` to apply that same function simultaneously for construction and consumption. This is a beautiful example of "expressing control flow through data flow" in functional programming.
