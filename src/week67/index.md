![egg-eater](./egg-eater.jpg)

# Week 6-7: Egg Eater, Due Friday, May 15

In this assignment you'll implement _heap allocated structures_ in your
compiler.

## Setup

There is a mostly empty starter repository for this assignment --
the same starting code as `diamondback`, so you can start by
adding _your_ code from `diamondback` to it. Functions are
necessary, but you can get away with 1- and 2-argument
functions, so you can start from code from class.

## Your Additions

You should add the following features:

```
<expr>
  ::= ...
    | nil
    | (vec <expr> <expr> <expr> ... <expr>)
    | (vec-get <expr> <expr>)
```

1. A `nil` construct, that is a special constant that can represent
   an _empty vector_; `nil` should be considered _distinct_ from all
   other vectors, so `(= nil (vec ...))` should evaluate to `false`.
   For simplicity, you might as well make _other_ comparisons like
   `(= nil 3)`, `(= nil true)`, `(= nil false)`, _also_ evaluate to
   _false_, but we will not test this;

2. An extension `(vec ...)` for heap-allocation of an _arbitrary non-zero number_ of values.
   This is a _generalization_ of the `(vec <expr> <expr>)` from class. (The mechanism from
   class by itself is _not_ be sufficient because it only supports two-element vectors).
   The easiest thing might be to add tuples with any number of positions in the constructor
   (e.g. `(vec <expr>+)`);

3. An expression for _lookup_ that allows computed indexed access.
   That is, in `(vec-get <expr> <expr>)` the first expression evaluates
   to a _vec_ and the second evaluates to a _number_, and the value at
   that index is returned. This expression _must_ report a dynamic error
   if an **out-of-bounds** index is given;

4. If a heap-allocated value is the result of a program or printed by `print`,
   all of its contents should be printed in some format that makes it clear which
   values are part of the same heap data. For example, in the output all the
   values associated with a particular location may be printed as `(vec ...)`
   as in the sample tests (see below);

5. You should be able to _detect_ when out-of-memory occurs; your language
   should be able to allocate at least a few thousands of words, but if it
   runs out of space, it should exit with a message `"out of heap space"`.

6. Any other features needed to express the programs listed in the section on
   required tests below (we will _not require_ implementing `vec-len` and `vec-set` but
   of course, you are most welcome, or even encouraged to do so.)

7. As before the `input` value will, as before only be a number or boolean.

The following features are explicitly optional and **not** required:

- Updating elements of heap-allocated values
- Structural equality (`=` can mean physical/reference equality)

## Required Tests

We have given some of the below tests, but you should also at least add
more, e.g. `bst.snek`.

- `input/simple_examples.snek` – A program with a number of simple examples of
  constructing and accessing heap-allocated data in your language.
- `input/error-tag.snek` – A program with a runtime tag-checking error related
  to heap-allocated values.
- `input/error-bounds.snek` – A program with a runtime error related to
  out-of-bounds indexing of heap-allocated values.
- `input/error3.snek` – A third program that tests that your compiled code
  is able to detect when you are `out of heap space`, and exits with that
  message.
- `input/points.snek` – A program with a function that takes an x and a y
  coordinate and produces a structure with those values, and a function that
  takes two points and returns a new point with their x and y coordinates added
  together, along with several tests that print example output from calling
  these functions.
- `input/bst.snek` – A program that illustrates how your language enables the
  creation of binary search trees, and implements functions to add an element
  and check if an element is in the tree. Include several tests that print
  example output from calling these functions.

Happy hacking!
