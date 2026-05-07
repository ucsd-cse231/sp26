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

1. Some mechanism for heap-allocation of an _arbitrary number_ of values. That
   is, the `(vec <expr> <expr>)` from class would _not_ be sufficient because it
   only supports two positions. The easiest thing might be to add tuples with any
   number of positions in the constructor (e.g. `(vec <expr>+)`).

```
(vec <expr> <expr> <expr> ... <expr>)
```

2. An expression for _lookup_ that allows computed indexed access. That is, you
   should have an expression like

```
(vec-get <expr> <expr>)
```

where the first expression evaluates to a _vec_ and the second
evaluates to a _number_, and the value at that index is returned.

This expression _must_ report a dynamic error if an **out-of-bounds**
index is given.

3. If a heap-allocated value is the result of a program or printed by `print`,
   all of its contents should be printed in some format that makes it clear which
   values are part of the same heap data. For example, in the output all the
   values associated with a particular location may be printed as `(vec ...)`
   as in the sample tests (see below).

4. You should be able to _detect_ when out-of-memory occurs; your language
   should be able to allocate at least a few thousands of words, but if it
   runs out of space, it should exit with a message `"out of heap space"`.

5. Any other features needed to express the programs listed in the section on
   required tests below.

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
