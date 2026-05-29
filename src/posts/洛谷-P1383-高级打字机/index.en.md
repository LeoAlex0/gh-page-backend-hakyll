---
title: Luogu P1383 Advanced Typewriter — Haskell Solution
categories:
  - Online Judge
  - 洛谷
tags:
  - 算法
  - 数据结构
preview: 300
date: 2020-05-20 00:23:53
math: true
comments: true
lang: en
---
<!-- # Luogu P1383 Advanced Typewriter -->

If you're using Haskell, this problem can be solved trivially with `Data.Sequence` from the `containers` package, because `Seq` itself is a persistent `FingerTree` — a tree-of-trees approach gives excellent time and space complexity.

Lazy evaluation keeps it an online algorithm. It can even undo undos (return to the state before the undo).

```haskell
{-# OPTIONS_GHC -O2 #-}
import           Control.Monad
import           Data.Functor  (($>))
import           Data.Maybe    (fromJust)
import           Data.Sequence
import           Text.Printf   (printf)

(!) = index

main :: IO ()
main = do
    n <- readLn :: IO Int
    fromList [fromList []] `foldM_'` [1..n] $ \seq _ -> do
        [[op],c] <- words <$> getLine
        case op of
            'T' -> pure $ (seq!0 |> head c) <| seq
            'U' -> pure $ (seq!read c) <| seq
            'Q' -> printf "%c\n" (seq!0!(read c-1))  $> seq

foldM_' z l f = foldM_ f z l
```

The code is straightforward.

* Space complexity: $O(n\log n)$, where $n$ is the total number of characters.
* Appending a character: $O(1)$.
* Printing the $i$-th character: $O(\log(\min(i,n-i)))$.
* Undoing: $O(\log(\min(i,n-i)))$, where $n$ is the total number of modifications and $i$ the undo steps.
* Overall: $O(n\log n)$.

If you're interested in the FingerTree internals or want to use this as an opportunity to learn Haskell, see below. The original paper is also a good reference.

References:

* Hinze R, Paterson R. Finger trees: a simple general-purpose data structure[J]. Journal of functional programming, 2006, 16(2): 197-217.
* https://hackage.haskell.org/package/fingertree
* https://hackage.haskell.org/package/container
* https://wiki.haskell.org/Functional_dependencies

## FingerTree Overview

When it comes to persistence, you think Immutable. When you think Immutable, you think functional programming languages. When you think functional programming, you think Haskell. And when you think purely functional data structures, you can't avoid FingerTree.

FingerTree is a theoretically very general and efficient data structure. Inserting at either end takes amortized $O(1)$, and "random" access takes $O(\log\min(i,n-i))$.
> $i$ is the index, so accessing the ends is indeed $O(1)$.

The paper can be found [here](https://www.staff.city.ac.uk/~ross/papers/FingerTree.pdf). This isn't the earliest paper, but it's the one I read.

Why "theoretically"? Like Fibonacci heaps, the constant factor is large. (~~The main factor is that immutable languages need a GC for garbage collection.~~)

> [Update] I later implemented FingerTree in Rust and found its time and memory consumption both larger than Haskell's, so the overhead probably isn't due to GC.
>
> Though it could just be my poor constant factors.
>
> See: [submission record](https://www.luogu.com.cn/record/60755672)

Why "random"? Because fully generalized FingerTree access depends not on indices but on a **Monoid** called a **Measure**.

> A monoid is a set $X$ with a binary operation $\cdot:X\times X\to X$ satisfying:
>
> * Associativity: $\forall x,y,z\in X: (x\cdot y)\cdot z = x\cdot (y\cdot z)$
> * Identity: $\exists e:(\forall x: e\cdot x=x\cdot e=x)$
>
> For example, $\mathbb N$ with addition $+$ forms a monoid (which gives us traditional indexing).
>
> The Cartesian product of two monoids is also a monoid. If $(X,\cdot_1)$ and $(Y,\cdot_2)$ are monoids, define $\cdot:(X\times Y)\times(X\times Y)\to X\times Y$ as:
>
> * $(x_1,y_1) \cdot (x_2,y_2)=(x_1\cdot_1 x_2,y_1\cdot_2 y_2)$
>
> This extends our indexing capabilities (e.g., the paper uses a $\max$ monoid to implement max-heap/priority queues).

## Haskell Basics

First, define a monoid in Haskell (the standard library provides this):

```haskell
class Monoid a where
    mempty :: a
    mappend :: a -> a -> a
```

Unlike C-like languages' `class`, in Haskell this is a type class — a constraint on type `a`, similar to an interface or abstract class.

Next, `Foldable` represents the ability to traverse a type (actually a kind — a type constructor that produces types) in some order. Similar to `reduce` in Java 8. This is also in the standard library.

```haskell
class Foldable f where
    foldl :: (b -> a -> b) -> b -> f a -> b
    foldr :: (a -> b -> b) -> b -> f a -> b
```

Also worth mentioning is Haskell's most basic data structure, the list (a singly-linked list with basic operations):

```haskell
data [] a = [] | a:([] a)
```

A list of type `a` is either empty or an `a` element consed with another list using the `:` operator. (An infix constructor — C++ can't do this.)

Another common `data` type is `Maybe`, equivalent to:

```haskell
data Maybe a = Nothing | Just a
```

This is where Haskell's character starts to show. Data structures in Haskell are built not from *fields* and *operations*, but from combinations of constructors. They can implement the two type classes above. I won't go into detail here.

## FingerTree Implementation (Brief Summary of the Paper)

![FingerTree diagram](https://www.staff.city.ac.uk/~ross/papers/FingerTree/example-tree.svg)

Basic definitions:

```haskell
-- | Things that can be measured.
class (Monoid v) => Measured v a | a -> v where
    measure :: a -> v

data Node v a = Node2 v a a | Node3 v a a a
data Digit a
    = One a
    | Two a a
    | Three a a a
    | Four a a a a
data FingerTree v a
     = Empty
     | Single a
     | Deep v (Digit a) (FingerTree v (Node v a)) (Digit a)
```

Here we encounter the `Measured` type class mentioned earlier. It abstracts a function that *measures* an element into a `Monoid`. This monoid has important uses.

The syntax uses a `Functional Dependencies` extension (see [wiki](https://wiki.haskell.org/Functional_dependencies)). It guarantees that a given type maps to exactly one measure type — a type `a` to type `v` is an injection.

The type variable $v$ is the `Monoid` that will be maintained and used for indexing.

A `Node` has 2-3 elements; a `Digit` has 1-4 elements (as shown in the diagram). Digits and Nodes can be interconverted and concatenated.

Notably, if the current layer of FingerTree caches type `a`, the next layer caches type `Node v a`. This means each lower layer is "thicker" than the one above.

Naturally, we can make `Node` and `Digit` instances of `Foldable`, but I won't show that here.

How to conveniently maintain the $v` value? Write a smart constructor:

```haskell
deep :: (Measured v a) =>
      Digit a -> FingerTree v (Node v a) -> Digit a -> FingerTree v a
 deep pr m sf = Deep ((measure pr `mappend` measure m) `mappend` measure sf) pr m sf
```

Now we don't need to maintain $v$ manually — just replace `Deep` with `deep`.

FingerTree itself can also be `Measured`:

```haskell
instance (Measured v a) => Measured v (FingerTree v a) where
      measure Empty           =  mempty
      measure (Single x)      =  measure x
      measure (Deep v _ _ _)  =  v
```

This uses Haskell's **pattern matching** — the data structure is deconstructed the same way it was constructed.

> Pattern matching works on multiple levels. See Haskell's 20-line red-black tree for an example.

For `Deep`, we directly use the cached $v$ field, giving $O(1)$ access to a subtree's measure (if measure on a single element is also $O(1)$).

`Node` and `Digit` can also be `Measured` — the implementation is left as an exercise.

Next, the definition of cons (left insertion):

```haskell
infixr 5 <|
-- | /O(1)/. Add an element to the left end of a sequence.
-- Mnemonic: a triangle with the single element at the pointy end.
(<|) :: Measured v a => a -> FingerTree v a -> FingerTree v a
a <| Empty              =  Single a
a <| Single b           =  deep (One a) Empty (One b)
a <| Deep v (Four b c d e) m sf
    = Deep (measure a `mappend` v) (Two a b) (node3 c d e <| m) sf
a <| Deep v pr m sf     = Deep (measure a `mappend` v) (consDigit a pr) m sf
```

We define a custom operator with precedence 5, right-associative.

`consDigit` prepends an element to `pr`. If it's full, it would error, but the pattern match above prevents that.

Similarly for snoc (right insertion):

```haskell
infixl 5 .>
-- | /O(1)/. Add an element to the right end of a sequence.
-- Mnemonic: a triangle with the single element at the pointy end.
(|>) :: (Measured v a) => FingerTree v a -> a -> FingerTree v a
Empty |> a              =  Single a
Single a |> b           =  deep (One a) Empty (One b)
Deep v pr m (Four a b c d) |> e
    = Deep (v `mappend` measure e) pr (m |> node3 a b c) (Two d e)
Deep v pr m sf |> x     = Deep (v `mappend` measure x) pr m (snocDigit sf x)
```

The code is symmetric to cons.

A splitting primitive (right side is symmetric):

```haskell
-- | View of the left end of a sequence.
data ViewL s a
     = EmptyL        -- ^ empty sequence
     | a :< s a      -- ^ leftmost element and the rest of the sequence

-- | /O(1)/. Analyse the left end of a sequence.
viewl :: (Measured v a) => FingerTree v a -> ViewL (FingerTree v) a
viewl Empty                     =  EmptyL
viewl (Single x)                =  x :< Empty
viewl (Deep _ (One x) m sf)     =  x :< rotL m sf
viewl (Deep _ pr m sf)          =  lheadDigit pr :< deep (ltailDigit pr) m sf

rotL :: (Measured v a) => FingerTree v (Node v a) -> Digit a -> FingerTree v a
rotL m sf      =   case viewl m of
    EmptyL  ->  digitToTree sf
    a :< m' ->  Deep (measure m `mappend` measure sf) (nodeToDigit a) m' sf
```

`lheadDigit` and `ltailDigit` get the leftmost element of a Digit and the rest. If the Digit has only one element, `ltailDigit` would error, but the pattern match prevents that.

`digitToTree` converts a Digit to a FingerTree (constant number of elements, so $O(1)$).

`nodeToDigit` converts a Node (2 or 3 elements) to a Digit.

`case ... of` is Haskell's analog of C++'s `switch`, but it has a return value — more like a multi-branch `?:` operator.

`viewl` constructs a left view of the tree, extracting the leftmost element (or `EmptyL` if none).

Note that `viewl` and `rotL` are mutually recursive.

There's a symmetric `viewr` implementation.

With `viewl`, we can handle the case where the prefix (the first Digit in Deep) is empty/missing:

```haskell
deepL :: (Measured v a) =>
    Maybe (Digit a) -> FingerTree v (Node v a) -> Digit a -> FingerTree v a
deepL Nothing m sf      =   rotL m sf
deepL (Just pr) m sf    =   deep pr m sf
```

`Nothing` means the prefix doesn't exist — need a left rotation. `Just` calls `deep` directly.

When would the left/right be empty? During splitting.

Finally, search and split:

```haskell
data Split t a = Split t a t
data SearchResult v a
    = Position (FingerTree v a) a (FingerTree v a)
        -- ^ A tree opened at a particular element: the prefix to the
       -- left, the element, and the suffix to the right.
   | OnLeft
       -- ^ A position to the left of the sequence, indicating that the
       -- predicate is 'True' at both ends.
   | OnRight
       -- ^ A position to the right of the sequence, indicating that the
       -- predicate is 'False' at both ends.
   | Nowhere
       -- ^ No position in the tree, returned if the predicate is 'True'
       -- at the left end and 'False' at the right end.  This will not
       -- occur if the predicate in monotonic on the tree.

search :: (Measured v a) =>
    (v -> v -> Bool) -> FingerTree v a -> SearchResult v a
search p t
  | p_left && p_right = OnLeft
  | not p_left && p_right = case searchTree p mempty t mempty of
         Split l x r -> Position l x r
  | not p_left && not p_right = OnRight
  | otherwise = Nowhere
   where
     p_left = p mempty vt
     p_right = p vt mempty
     vt = measure t

searchTree :: (Measured v a) =>
     (v -> v -> Bool) -> v -> FingerTree v a -> v -> Split (FingerTree v a) a
searchTree _ _ Empty _ = illegal_argument "searchTree"
searchTree _ _ (Single x) _ = Split Empty x Empty
searchTree p vl (Deep _ pr m sf) vr
  | p vlp vmsr  =  let  Split l x r     =  searchDigit p vl pr vmsr
                   in   Split (maybe Empty digitToTree l) x (deepL r m sf)
  | p vlpm vsr  =  let  Split ml xs mr  =  searchTree p vlp m vsr
                        Split l x r     =  searchNode p (vlp `mappend` measure ml) xs (measure mr `mappend` vsr)
                   in   Split (deepR pr ml l) x (deepL r mr sf)
  | otherwise   =  let  Split l x r     =  searchDigit p vlpm sf vr
                   in   Split (deepR pr m l) x (maybe Empty digitToTree r)
  where
    vlp     =  vl `mappend` measure pr
    vlpm    =  vlp `mappend` vm
    vmsr    =  vm `mappend` vsr
    vsr     =  measure sf `mappend` vr
    vm      =  measure m
```

I've only shown `searchTree` here. `searchNode` and `searchDigit` are similar — they find the first position where the predicate returns False on the left side and True on the right side, then recurse down.

The `maybe` function has type `b -> (a -> b) -> Maybe a -> b`. Its signature reveals its purpose.

Note the `where` clause. It's like a constant definition, but post-posed and lazy. (Without explicit annotation, the entire Haskell program is lazy.)

We're now only missing one piece: indexing with a `Monoid` that can be`Measured` for any type (since each element counts as 1):

```haskell
newtype Size = Size Int
newtype Elem a = Elem a
instance Monoid Size where
    mempty = Size 0
    mappend (Size a) (Size b) = Size (a+b)
instance Measured Size (Elem a) where
    measure _ = Size 1
```

Note: since we used `Functional Dependencies`, we need a new wrapper type. We use `newtype` instead of `data` (both cost nothing at runtime in this context).

From here, `Seq` can be implemented — see the `containers` package source or the original paper for details.
