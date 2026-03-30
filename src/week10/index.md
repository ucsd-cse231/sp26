![green](./green.jpg)

# Week 10: Green Snake, Due Sunday, June 11th (Open Collaboration)

In this assignment you'll either:

- Optimize a Forest Flame compiler to improve its runtime and/or code size
- Fix and extend a previous assignment to demonstrate mastery

## Optimization

If you choose to optimize Forest Flame, you're free to use our starter code,
your solution that includes garbage collection, your own compiler, and so on as
a starting point.

### Task

You'll write a compiler that implements Forest Flame, and we'll run and compare
your compiler to our reference compiler on a suite of tests. For each test,
we'll check:

- That the output is exactly the same as for the starter Forest Flame code
- Whether your optimized version generates an assembly file with _fewer
  instructions_ than the starter code
- Whether your optimized version generates the answer in _less wall-clock time_
  than the starter code (as measured by `time`)

We'll make code for timing and testing available in the week of June 5.

In your submission, include a README.md or a README.pdf that describes the
optimizations you chose. It's helpful to us if you highlight some programs
where your optimizations do especially well.

This assignment is emphatically _open to collaboration_, feel free to discuss,
share ideas and code, etc. On this assignment, if you want to work directly on
the same codebase as another student, feel free to do that as well.

### Grading

Focus on doing cool stuff, and getting _some_ amount of optimization to work.
We'll check that your submission can make some programs better in a meaningful
way, and you _don't break anything in the existing tests_.

Submit your code to the `green-optimization` assignment on Gradescope.

## Fix and Extend a Previous Assignment

As another option for this assignment, you can implement one of two
extensions to either Diamondback or Egg-Eater. If you choose to do that,
we'll apply the grade for this assignment as both the 8th assignment grade and
a _replacement_ of your grade for that previous assignment as well.

You can only choose and implement **one** of these, not both.

### Extending Egg-Eater

Write or extend your compiler that implements everything required from
Egg-Eater, but also:

- Implement _structural update_ (like `setfst!` from class)
- Implement both _structural equality_ and _reference equality_ (you'll need
  new concrete syntax for one of them) for the heap-allocated data you designed.
- Make sure that structural equality and printing heap values doesn't result in
  an infinite loop, but prints/returns something meaningful when a cycle is
  reached
- Write a new test `input/equal.snek` that demonstrates how structural and
  reference equality work on non-cyclic values. Make sure to include enough
  examples, including cases that return `true` and `false`, to demonstrate the
  behavior thoroughly.
- Write 3 new tests `input/cycle-print[1-3].snek` that demonstrate how cyclic
  printing works for three different examples of cyclic values
- Write 3 new tests `input/cycle-equal[1-3].snek` that demonstrate how cyclic
  equality works for three different examples of cyclic values

Also _add_ to your Egg-Eater writeup (with any updates you want to make), the
following at the end:

- A description of your approach to handling structural equality, including
  relevant snippets of Rust or generated assembly
- A description of your approach to handling cycles, including relevant
  snippets of Rust or generated assembly
- Show each of your required tests' code and output when compiled and run
- Describe any features _other than_ structural equality and update that you
  improved since your egg-eater submission
- A list of resources you used to complete the assignment (other code sources,
  message board posts, LLMs, stack overflow, etc)

Submit your code to `green-egg-eater-code` and the writeup to
`green-egg-eater-written`.

### Extending Diamondback

Write or extend your compiler that implements everything from Diamondback, but
also:

- Make the calling convention support proper safe-for-space tail calls.
- Make sure your implementation passes all of the Diamondback tests.
- Write three new tests `input/tail[1-3].snek` that demonstrate tail calls;
  they should include function and calls that produce stack overflows without
  tail calls, but succeed with them enabled. Include:
  - A test with _self_ recursion only
  - A test with two mutually-recursive functions that tail call one another
  - Another test of your choice that demonstrates tail call behavior


Also create a PDF writeup with the following components:

- A description of your approach to handling tail calls, including
  relevant snippets of Rust or generated assembly
- For one of the tests, a memory diagram showing what the stack looks like
  right before a tail call happens, what the stack looks like during that call,
  and what the stack looks like when returning from that call
- Show each of your required tests' code and output when compiled and run
- Describe any features _other than_ proper tail calls that you
  improved since your egg-eater submission
- A list of resources you used to complete the assignment (other code sources,
  message board posts, LLMs, stack overflow, etc)

Submit the code to `green-diamondback-code` and the PDF to
`green-diamondback-pdf`

