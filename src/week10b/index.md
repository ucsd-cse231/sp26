# Indigo

![Indigo](https://orianne.wpenginepowered.com/wp-content/uploads/2022/04/DSC_0246_Eastern-Indigo-Snake_Ben-Stegenga.jpg)

## Language

The surface language is identical to `fer-de-lance` (heap allocated tuples, closures, etc.)
but there are significant differences in the *implementation*.


### Registers

x86\_64 is useful because it gives us 8 more registers

```rust
pub const REGISTERS: [Reg; 8] = [
    Reg::RBX,   // R1
    Reg::RDX,   // R2
    Reg::R8,    // R3
    Reg::R9,    // R4
    Reg::R10,   // R5
    Reg::R12,   // R6
    Reg::R13,   // R7
    Reg::R14,   // R8
];
```

(We will write R1...R8 below instead of the actual register name, for simplicity.)

The main change you will deal with is that local variables are stored in
the above `REGISTERS` as much as possible.  The details are below.

### Using Registers for Variables

So far, we've allocated stack space for every variable in our program.  It
would be more efficient to use registers when possible.  Take this program as an
example:

```clojure
(let ((n (* 5 5))
      (m (* 6 6))
      (x (+ n 1))
      (y (+ m 1)))
  (+ x y)
)
```

In the main body of this program, there are 4 variables – `n`, `m`, `x`, and
`y`.  In our compiler without register allocation, we would assign these 4
variables to 4 different locations on the stack.  It would be nice to assign
them to registers instead, so that we could generate better assembly.  Assuming
we have 4 registers available, this is easy; we could pick

- `n` ↔`R1`
- `m` ↔`R2`
- `x` ↔`R3`
- `y` ↔`R4`

and then generate assembly like

```
mov R1, 10 ; store the result for n in R1 directly
sar R1, 1
mul R1, 10
mov R2, 12 ; store the result for m in R2 directly
sar R2, 1
mul R2, 12
mov R3, R1 ; store the result for x in R3 directly
add R3, 2
mov R4, R2 ; store the result for y in R4 directly
add R4, 2
mov RAX, R3 ; store the answer in RAX directly (our new RAX)
add RAX, R4
```

This avoids four extra `mov`s into memory, and allows us to use registers
directly, rather than memory, as we would have in the initial verson:

```
mov RAX, 10
sar RAX, 1
mul RAX, 10
mov [RBP-8], RAX ; extra store
mov RAX, 12
sar RAX, 1
mul RAX, 12
mov [RBP-16], RAX ; extra store
mov RAX, [RBP-8] ; memory rather than register access
add RAX, 2
mov [RBP-24], RAX ; extra store
mov RAX, [RBP-16] ; memory rather than register access
add RAX, 2
mov [RBP-32], RAX ; extra store
mov RAX, [RBP-24] ; memory rather than register access
add RAX, [RBP-32] ; memory rather than register access
```

Making this change would be require a few alterations to the compiler:

**Step 1.** We'd need to have our environment allow variables to be bound to
   _registers_, rather than just a stack offset.

**Step 2.** We need to change the goal of the compiler from “get the answer into RAX”
   to “get the answer into <<<insert location here>>>”

**Step 3** Whenever we _call_ a function, that function may overwrite the values of
   registers the current context is using for variables.  This demands that we
   save the contents of in-use registers before calling a function.

### Step 1: Computing a (Location) Allocation

To handle (**Step 1**), we define a new datatype, called `location`:

```rust
pub enum Loc {
    Reg(Reg),       // Register
    Stack(i32),     // Stack    [rbp - 8 * offset]
}
```

And we change the compiler's `env` parameter to have type `&Alloc`, which is a
map from `String` to `Loc` which can be either registers or stack offsets.

```rust
pub struct Alloc(HashMap<String, Loc>, usize);
```

### Step 2: Compiling into Destination Location

To handle (**Step 2**), we add a new parameter `dst : &Loc`
to the compiler (i.e. to `compile_expr`), which is where to
store the result of the computation, that you will then use
to suitably implement the missing cases in `compile_expr`.

- For function bodies and main, this will be `Reg::RAX`,
  so that return values are handled in the usual way.

- For `(let (x e1) e2)` bindings, we will use the `Loc` for `x` in the
  precomputed environment to choose the `dst` parameter for the `e1`
  part of the compilation.


### Step 3: Saving Registers

There are a few options for handling (**Step 3**):

- We could have each function save and restore all of the registers it uses, so
  callers do not have to store anything.
- We could have each caller store the registers in use in its context
- We could blend the first two options, which gives us the notion of
  caller-save vs. callee-save registers

The first option is the simplest so it's what the compiler does. It requires
one wrinkle – when calling an _external_ function like `print`, we need to
save all the registers the current function is using.  The current
implementation simply stores all the registers in `env` by pushing and popping
their values before and after the call.  It's interesting (though not part of
the assignment) to think about how we could do better than that.

These changes have been mostly made for you -- but you have to fill in the
missing `todo!()` in `compile_expr` to properly use the register allocator
in your compiler. In particular, you will need to fill in the code for

* `save_used_regs` and
* `restore_used_regs`

so that `compile_defn` can properly save and restore all the registers it uses.

## Register Allocation

For programs that use fewer variables than the number of available registers,
the strategy above works well.  This leaves open what we should do if the
number of variables _exceeds_ the number of available registers.

An easy solution is to put N variables into N registers, and some onto the
stack.  But we can do better in many cases.  Let's go back to the example
below, and imagine that we only have _three_ registers available, rather than
four.  Can we still come up with a register assignment for the four variables
that works?


```clojure
(let ((n (* 5 5))
      (m (* 6 6))
      (x (+ n 1))
      (y (+ m 1)))
  (+ x y)
)
```


The key observation is that once we compute the value for `x`, we no longer
need `n`.  So we need space for `n`, `m`, and `x` all at the same time, but
once we get to computing the value for `y`, we only need to keep track of `m`
and `x`.  That means the following assignment of variables to registers works:

- `n` ↔`R1`
- `m` ↔`R2`
- `x` ↔`R3`
- `y` ↔`R1`

```
mov R1, 10 ; store the result for n in R1 directly
sar R1, 1
mul R1, 10
mov R2, 12 ; store the result for m in R2 directly
sar R2, 6
mul R2, 12
mov R3, R1 ; store the result for x in R3 directly
add R3, 2
mov R1, R2 ; store the result for y in R1, overwriting n, which won't be used from here on
add R1, 2
mov RAX, R3 ; store the answer in RAX directly (our new RAX)
add RAX, R1 ; R1 here holds the value of y
```

It was relatively easy for us to tell that this would work.  Encoding this idea
in an algorithm—that multiple variables can use the same register, as long as
they aren't in use at the same time—is known as _register allocation_.

One way to understand register allocation is to treat the variables in the
program as the vertices in a (undirected) graph, **whose edges represent
dependencies between variables that must be available at the same time.**

So, for example, in the picture above we'd have a graph like:

```
n --- m
  \ / |
   ╳  |
  / \ |
y --- x
```

If we wrote an longer sequence of lets, we could see more interesting graph
structures emerge; in the example below, `z` is the only link between the first
4 lets and the last 3.

```clojure
(let* ((n (5 * 5))
       (m (6 * 6))
       (x (n + 1))
       (y (m + 1))
       (z (x + y))
       (k (z * z))
       (g (k + 5)))
  (+ k 3))
```

we get a graph like

```
n --- m
  \ / |
   ╳  |
  / \ |
y --- x
|   /
|  /
| /
z --- k --- g

```

Here, we can _still_ use just three registers.  Since we don't use `x` and `y`
after computing `z`, we can reassign their registers to be used for `k` and
`g`.  So this assignment of variables to registers works:

- `n` ↔`R1`
- `m` ↔`R2`
- `x` ↔`R3`
- `y` ↔`R1`
- `z` ↔`R2`
- `k` ↔`R1`
- `g` ↔`R3`

(We could also have assigned `g` to `R2` – it just couldn't overlap with `R1`,
the register we used for `k`.)

Again, if we stare at these programs for a while using our clever human eyes
and brains, we can generate these graphs of dependencies and convince ourselves
that they are correct.

To make our compiler do this, we need to generalize this behavior into an
algorithm.  There are two steps to this algorithm:

1. Create the graph
2. Figure out assignments given a graph to create an environment

The second part corresponds directly to a well-known (NP-complete) problem
called [Graph Coloring](https://en.wikipedia.org/wiki/Graph_coloring).

Given a graph, we need to come up with a “color”—in our case a register—for each
vertex such that no two adjacent vertices share a color.  We will use a rust
crate ([heuristic-graph-coloring](https://crates.io/crates/heuristic-graph-coloring)
to handle this for us.

The first part is an interesting problem for us as compiler designers.

Given an input expression, can we create a graph that represents all of the
dependencies between variables, as described above?  If we can, we can use
existing coloring algorithms (and fast heuristics for them, if we don't want to
wait for an optimal solution).  This graph creation is the fragment of the
compiler you will implement in this assignment.

In particular you'll implement two functions (which may each come with their own helpers):

### Computing the LIVE variable Dependency Graph `live`

The first function you will implement is

```rust
fn live(
    graph: &mut ConflictGraph,        /// graph of edges
    e: &Expr,                         /// expression to analyze
    binds: &HashSet<String>,          /// let-bound variables defined (outside e)
    params: &HashSet<String>,         /// function params (allocated on stack)
    out: &HashSet<String>,            /// variables whose values are "LIVE" *after* `e`
) -> HashSet<String>                  /// variables who are "LIVE" *before*
```

- Recall that the variables `x1...xn` are LIVE for `e` if we need to know the values of `x1...xn`
  to evaluate `e`.

- The `graph` is `mut`able as we will be adding edges to the graph while traversing the expression.

### Computing the Coloring `allocate`

Next, you will implement

```rust
fn allocate(
  &self,            /// Conflict Graph
  regs: &[Reg],     /// List of usable registers
  offset: usize     /// Offset from which to start saving stack vars [offset+1,offset+2...]
) -> HashMap<String, Loc> /// Mapping of variables to locations
```

The `allocate` function, should **always succeed** no matter how many registers are provided.
It should

1. find out how many colors are needed for the given graph, (by calling `self.color()`),
and then
2. produce aenvironment with the following constraints:

- Variables given the same color by the coloring should be mapped to the same
  location in the environment, and variables mapped to different colors should
  be mapped to different locations in the environment.
- If there are equal or fewer _colors_ than registers provided, then all the
  variables should be mapped to `Reg` locations, and no more than `C` Reg
  locations should be created, where `C` is the number of colors.
- If there are more _colors_ than registers provided, then some variables
  should map to stack locations.  In the resulting environment, there should be
  `C - R` stack locations (`Stack`) created, where `R` is the number of registers
  and `C` is the number of colors.  The `Stack` indices should go from `offset + 1`
  to (`offset + C - R`).  In the resulting environment, there should be `R`
  register locations `Reg`.

For example, given the code

```clojure
(let ((b 4)
      (x 10)
      (i (if true
            (let (z 11) (+ z b))
            (let (y 9)  (+ y 1))))
      (a (+ 5 i)))
  (+ a x))
```

There is a valid 3-coloring for the induced graph:

```
a: 1 (green)
b: 1 (green)
i: 2 (red)
z: 2 (red)
y: 2 (red)
x: 3 (blue)
```

Let's assume we have 2 registers available, `RBX` and `RDX`.
Then we need to create (`3 - 2`) `Stack` locations, counting
from 1, and 2 `Reg` locations.

So the locations in our environment are:

```
Reg(RBX)
Reg(RDX)
Stack(1)
```

Now we need to build an environment that matches variables to these, following the coloring rules.  One answer is:

```
a: Reg(RBX)
b: Reg(RBX)
i: Stack(1)
z: Stack(1)
y: Stack(1)
x: Reg(RDX)
```

Another valid answer is:

```
a: Reg(RBX)
b: Reg(RBX)
i: Reg(RDX)
z: Reg(RDX)
y: Reg(RDX)
x: Stack(1)
```

Either of these are correct answers from the point of view of register
allocation (it's fun to think about if one is better, but neither is wrong).

Example 2: let's consider that we have 0 registers available.  Then we need to
choose (3 - 0) locations on the stack, and 0 registers:

```
Stack(1)
Stack(2)
Stack(3)
```

A valid environment is:

```
a: Stack(2)
b: Stack(2)
i: Stack(3)
z: Stack(3)
y: Stack(3)
x: Stack(1)
```

These rules accomplish the overall goal of putting as many values as possible
into registers, and also reusing as much space as possible, while still running
programs that need more space than available registers.

## Testing

You can compile programs with differing numbers of registers available by
passing in a number of registers (max 8).

So, for example, you can create an input file called `tests/longloop.snek`
that looks like

```clojure
(let (k 0)
(let (a (loop
     (if (= k 1000000000) (break 0)
        (block
          (set! k (+ k 1))
          (let* ((n (* 5 5))
                 (m (* 6 6))
                 (x (+ n 1))
                 (y (+ m 1)))
              (+ x y))))))
      k))
```

populate it with the long loop at the beginning of the writeup above, and run:

```
$ NUM_REGS=3 make tests/longloop.run
```

And this will trigger the build for `longloop` with just 3 registers.  This can
be fun for testing the performance of long-running programs with different
numbers of registers available.  Setting `NUM_REGS` to `0` somewhat emulates
the performance of our past compilers, since it necessarily allocates all
variables on the stack (but still uses the live/conflict analysis to agressively
reuse the same stack slot for multiple variables.)

**With 3 registers**

```
$ NUM_REGS=3 make tests/longloop.run

$ time tests/longloop.run
1000000000
________________________________________________________
Executed in    1.19 secs    fish           external
   usr time    1.18 secs    0.28 millis    1.18 secs
   sys time    0.01 secs    1.21 millis    0.01 secs
```

**With 0 registers**

```
$ NUM_REGS=0 make tests/longloop.run
$ time tests/longloop.run
1000000000
________________________________________________________
Executed in    1.66 secs    fish           external
   usr time    1.50 secs  121.00 micros    1.50 secs
   sys time    0.00 secs  482.00 micros    0.00 secs
```

**With no Live/Conflict Analysis**

```
$ cd ../08-harlequin
$ make tests/longloop.run
$ time tests/longloop.run
1000000000
________________________________________________________
Executed in    4.21 secs    fish           external
   usr time    3.99 secs    0.26 millis    3.99 secs
   sys time    0.01 secs    1.13 millis    0.01 secs
```

So our register allocation gives about a 4x speedup!