![egg-eater](./egg-eater.jpg)

# Week 6-7: Egg Eater, Due Friday, May 13 (Open Collaboration)

In this assignment you'll implement _heap allocated structures_ in your
compiler.

## Setup

There is a mostly empty starter repository for this assignment.
You should pick a starting point for the compiler based on your
own previous work (e.g. `diamondback`). Functions are necessary,
but you can get away with 1- and 2-argument functions, so you
can start from code from class.

## Your Additions

You should add the following features:

1. Some mechanism for heap-allocation of an _arbitrary number_ of values. That
is, the `(vec <expr> <expr>)` from class would _not_ be sufficient because it
only supports two positions. The easiest thing might be to add tuples with any
number of positions in the constructor (e.g. `(vec <expr>+)`).

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

4. Any other features needed to express the programs listed in the section on
required tests below.

The following features are explicitly optional and **not** required:

- Updating elements of heap-allocated values
- Structural equality (`=` can mean physical/reference equality)
- Detecting when out-of-memory occurs. Your language should be able to allocate
  at least a few tens of thousands of words, but doesn't need to detect or
  recover from filling up memory.

## Required Tests

- `input/simple_examples.snek` – A program with a number of simple examples of
  constructing and accessing heap-allocated data in your language.
- `input/error-tag.snek` – A program with a runtime tag-checking error related
  to heap-allocated values.
- `input/error-bounds.snek` – A  program with a runtime error related to
  out-of-bounds indexing of heap-allocated values.
- `input/error3.snek` – A third program with a different error than the other
  two related to heap-allocated values.
- `input/points.snek` – A program with a function that takes an x and a y
  coordinate and produces a structure with those values, and a function that
  takes two points and returns a new point with their x and y coordinates added
  together, along with several tests that print example output from calling
  these functions.
- `input/bst.snek` – A program that illustrates how your language enables the
  creation of binary search trees, and implements functions to add an element
  and check if an element is in the tree. Include several tests that print
  example output from calling these functions.


## Handin and Design Document

There are no autograding tests or associated points, your submission will be
graded based on an associated design document you submit -- no more than 2 pages
in 10pt font -- summarized below.

Your PDF should contain:

1. The concrete grammar of your language, pointing out and describing the new
  concrete syntax beyond Diamondback/your starting point.  Graded on clarity
  and completeness (it’s clear what’s new, everything new is there) and if
  it’s accurately reflected by your parse implementation.
2. A diagram of how heap-allocated values are arranged on the heap, including
  any extra words like the size of an allocated value or other metadata. Graded
  on clarity and completeness, and if it matches the implementation of heap
  allocation in the compiler.
3. The required tests above. In addition to appearing in the code you submit,
  (they should be in the PDF). These will be partially graded on your
  explanation and provided code, and partially on if your compiler implements
  them according to your expectations.
  - For each of the `error` files, show running the compiled code at the
    terminal and explain in which phase your compiler and/or runtime catches
    the error.
  - For the others, include the actual output of running the program (in terms
    of stdout/stderr), the output you’d like them to have (if you couldn't get
    something working) and any notes on interesting features of that output.
4. Pick two other programming languages you know that support heap-allocated
   data, and describe why your language’s design is more like one than the
   other.
5. A list of the resources you used to complete the assignment, including
  message board posts, online resources (including resources outside the course
  readings like Stack Overflow or blog posts with design ideas), and students
  or course staff discussions you had in-person. Please do collaborate and give
  credit to your collaborators.

Write a professional document that could be shared with a team that works on
the language, or users of it, to introduce them to it.

Submit your code, including all tests, and **also including the same PDF in the root of the
repository as `design.pdf`**. This dual submission is best for us to review and grade the assignments.

Happy hacking!

## Extensions

- Add structure update (e.g. `setfst!` from class)
- Add structural equality (choose a new operator if you like)
- Update your compiler with extensions from previous assignments to support
  heap allocation (e.g. REPL, JIT, and so on). Leave out any new tag checks
  related to heap-allocated values as appropriate.

## Grading

Grading will generally based on clarity and completeness of your writing, and
based on implementing features and tests that match the descriptions above.
