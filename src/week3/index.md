![cobra](./cobra.jpg)

# Week 3: Cobra, Due Friday, April 26 (Open Collaboration)

In this assignment you'll implement a compiler for a small language called Cobra,
which extends Boa with booleans, conditionals, variable assignment, and loops.

## Setup


Get the assignment at <https://classroom.github.com/a/tnyP6D51>
This will make a private-to-you copy of the repository hosted within the course's
organization.  

## The Cobra Language

### Concrete Syntax

The concrete syntax of Cobra is:

```
<expr> :=
  | <number>
  | true
  | false
  | input
  | <identifier>
  | (let (<binding>+) <expr>)
  | (<op1> <expr>)
  | (<op2> <expr> <expr>)
  | (set! <name> <expr>)
  | (if <expr> <expr> <expr>)
  | (block <expr>+)
  | (loop <expr>)
  | (break <expr>)

<op1> := add1 | sub1 | isnum | isbool
<op2> := + | - | * | < | > | >= | <= | =

<binding> := (<identifier> <expr>)
```

`true` and `false` are literals. Names used in `let` cannot have the name of
other keywords or operators (like `true` or `false` or `let` or `block`).
Numbers should be representable as a signed 63-bit number (e.g. from
-4611686018427387904 to 4611686018427387903).

### Abstract Syntax

You can choose the abstract syntax you use for Cobra. We recommend something like this:

```
enum Op1 { Add1, Sub1, IsNum, IsBool, }

enum Op2 { Plus, Minus, Times, Equal, Greater, GreaterEqual, Less, LessEqual, }

enum Expr {
    Number(i32),
    Boolean(bool),
    Id(String),
    Let(Vec<(String, Expr)>, Box<Expr>),
    UnOp(Op1, Box<Expr>),
    BinOp(Op2, Box<Expr>, Box<Expr>),
    Input,
    If(Box<Expr>, Box<Expr>, Box<Expr>),
    Loop(Box<Expr>),
    Break(Box<Expr>),
    Set(String, Box<Expr>),
    Block(Vec<Expr>),
}
```

### Semantics

A "semantics" describes the languages' behavior without giving all of the
assembly code for each instruction.

A Cobra program always evaluates to a single integer, a single boolean, or ends
with an error. When ending with an error, it should print a message to
_standard error_ (`eprintln!` in Rust works well for this) and a non-zero exit
code (`std::process::exit(N)` for nonzero `N` in Rust works well for this).

- `input` expressions evaluate to the first command-line argument given to the
  program. The command-line argument can be any Cobra value: a valid number or
  `true` or `false`. If no command-line argument is provided, the value of
  `input` is `false`. When running the program the argument should be provided
  as `true`, `false`, or a base-10 number value.
- All Boa programs evaluate in [the same way as before](../week2/index.md), with one
  exception: if numeric operations would overflow a 63-bit integer, the program
  should end in error, **reporting `"overflow"` as a part of the error**.
- If the operators other than `=` are used on booleans, an error should be
  raised from the running program, and **the error should contain "invalid
  argument"**. Note that this is not a compilation error, nor can it be in all
  cases due to `input`'s type being unknown until the program starts.
- The relative comparison operators like `<` and `>` evaluate their arguments
  and then evaluate to `true` or `false` based on the comparison result.
- The equality operator `=` evaluates its arguments and compares them for
  equality. It should raise an error if they are not both numbers or not both
  booleans, and the error should contain **"invalid argument"** if the types
  differ.
- Boolean expressions (`true` and `false`) evaluate to themselves
- `if` expressions evaluate their first expression (the condition) first. If it's
  `false`, they evaluate to the third expression (the “else” block), and to
  the second expression if any other value (including numbers).
- `block` expressions evaluate the subexpressions in order, and evaluate to the
  result of the _last_ expression. Blocks are mainly useful for writing
  sequences that include `set!`, especially in the body of a loop.
- `set!` expressions evaluate the expression to a value, and change the value
  stored in the given variable to that value (e.g. variable assignment). The
  `set!` expression itself evaluates to the new value. If there is no surrounding
  let binding for the variable the identifier is considered unbound and an error
  should be reported.
- `loop` and `break` expressions work together. Loops evaluate their subexpression
  in an infinite loop until `break` is used. Break expressions evaluate their
  subexpression and the resulting value becomes the result of the entire loop.
  Typically the body of a loop is written with `block` to get a sequence of
  expressions in the loop body.
- `isnum` and `isbool` are primitive operations that **test** their argument's type;
  `isnum(v)` evaluates to `true` if `v` is a number and `false` otherwise, and 
  `isbool(v)` evaluates to `true` if `v` is a boolean and `false` otherwise.


There are several examples further down to make this concrete.

The _compiler_ should stop and report an error if:

* There is a binding list containing two or more bindings with the same name.
  **The error should contain the string `"Duplicate binding"`**
* An identifier is unbound (there is no surrounding let binding for it) **The
  error should contain the string `"Unbound variable identifier {identifier}"`
  (where the actual name of the variable is substituted for `{identifier}`)**
* A `break` appears outside of any surrounding `loop`. **The error should
  contain "break"**
* An invalid identifier is used (it matches one of the keywords). **The error
  should contain "keyword"**

If there are multiple errors, the compiler can report any non-empty subset of
them.

Here are some examples of Cobra programs.

#### Example 1

**Concrete Syntax**

```scheme
(let ((x 5))
     (block (set! x (+ x 1))))
```

**Abstract Syntax Based on Our Design**

```rust
Let(vec![("x".to_string(), Number(5))],
    Box::new(Block(
      vec![Set("x".to_string(),
               Box::new(BinOp(Plus, Id("x".to_string()),
                                    Number(1)))])))
```

**Result**

```
6
```


#### Example 2

```scheme
(let ((a 2) (b 3) (c 0) (i 0) (j 0))
  (loop
    (if (< i a)
      (block
        (set! j 0)
        (loop
          (if (< j b)
            (block (set! c (sub1 c)) (set! j (add1 j)))
            (break c)
          )
        )
        (set! i (add1 i))
      )
      (break c)
    )
  )
)
```

**Result**

```
-6
```

#### Example 3

This program calculates the factorial of the input.
```scheme
(let
  ((i 1) (acc 1))
  (loop
    (if (> i input)
      (break acc)
      (block
        (set! acc (* acc i))
        (set! i (+ i 1))
      )
    )
  )
)
```

### Implementing a Compiler for Cobra

The [starter code](https://github.com/ucsd-cse231/03-cobra) makes a
few infrastructural suggestions. You can change these as you feel is
appropriate in order to meet the specification.

#### Reporting Dynamic Errors

We've provided some infrastructure for reporting errors via the
[`snek_error`](https://github.com/ucsd-cse231/03-cobra/blob/main/runtime/start.rs#L13)
function in `start.rs`. This is a function that can be _called from the
generated program_ to report an error. for now we have it take an error code as
an argument; you might find the error code useful for deciding which error
message to print.  This is also listed as an `extern` in [the generated
assembly startup
code](https://github.com/ucsd-cse231/03-cobra/blob/main/src/main.rs#L17).

#### Calculating Input

We've provided a
[`parse_input`](https://github.com/ucsd-cse231/03-cobra/blob/main/runtime/start.rs#L27)
stub for you to fill in to turn the command-line argument to `start.rs` into a
value suitable for passing to `our_code_starts_here`. As a reminder/reference,
the first argument in the x86_64 calling convention is stored in `rdi`. This
means that, for example, moving `rdi` into `rax` is a good way to get “the
answer” for the expression `input`.

#### Representations

In class we chose representations with `0` as a tag bit for numbers and `1` for
booleans with the values `3` for `true` and `1` for `false`. You **do not**
have to use those, though it's a great starting point and we recommend it. Your
only obligation is to match the behavior described in the specification, and if
you prefer a different way to distinguish types, you can use it. (Keep in mind,
though, that you still must generate assembly programs that have the specified
behavior!)

### Running and Testing

The test format changed slightly to require a _test name_ along with a _test
file name_. This is to support using the same _test file_ with different
_command line arguments_. You can see several of these in the [sample
tests](https://github.com/ucsd-cse231/03-cobra/blob/main/tests/all_tests.rs).
Note that providing `input` is optional. These also illustrate how to check for
errors.

If you want to try out a single file from the command line (and perhaps from a
debugger like `gdb` or `lldb`), you can still run them directly from the
command line with:

```
$ make tests/some-file.run
$ ./tests/some-file.run 1234
```

where the `1234` could be any valid command-line argument.

As a note on running all the tests, the best option is to use `make test`,
which ensures that `cargo build` is run first and independently before `cargo
test`.

## Grading

As with the previous assignment, a lot of the credit you get will be based on
us running autograded tests on your submission. You'll be able to see the
result of some of these on while the assignment is out, but we may have more
that we don't show results for until after assignments are all submitted.

We'll combine that with some amount of manual grading involving looking at your
testing and implementation strategy. You should have your own thorough test
suite (it's not unreasonable to write many dozens of tests; you probably don't
need hundreds), and you need to have recognizably implemented a compiler. For
example, you _could_ try to calculate the answer for these programs and
generate a single `mov` instruction: don't do that, it doesn't demonstrate the
learning outcomes we care about.

Any credit you lose will come with instructions for fixing similar mistakes on
future assignments.

## FAQ

**Some of my tests fail with a `No such file or directory` error**

The initial version of the starter code contained an error in the testing infrastructure. If you
cloned before we fixed it, you'll have to update the code. You can update the code by running:

```console
git remote add upstream https://github.com/ucsd-cse231/03-cobra
git pull upstream main --allow-unrelated-histories
```

This will merge all commits from the template into your repository. Alternatively, you can also
clone <https://github.com/ucsd-cse231/03-cobra> and manually replace your `tests/`
directory.

## Extension: Using Dynamic Information to Optimize

A compiler for Cobra needs to generate extra instructions to check for booleans
being used in binary operators. We could use a static type-checker to avoid
these, but at the same time, the language is fundamentally dynamic because the
compiler cannot know the type of `input` until the program starts running
(which happens after it is compiled). This is the general problem that systems
for languages like JavaScript and Python face; it will get worse when we
introduce functions in the next assignment.

However, if our compiler can make use of some dynamic information, we can do
better.

There are two instructive optimizations we can make with dynamic information,
one for standalone programs and one at the REPL.

### Eval

Add a new command-line option, `-e`, for “eval”, that evaluates a program
directly after compiling it with knowledge of the command-line argument. The
usage should be:

```
cargo run -- -e file.snek <arg>
```

That is, you provide both the file and the command-line argument. When called
this way, the compiler should skip any instructions used for checking for
errors related to `input`. For example, for this program, if a number is given
as the argument, we could omit all of the tag checking related to the `input`
argument (and since `1` is a literal, we could recover essentially the same
compilation as for Boa).

```
(+ 1 input)
```

For this program, if `input` is a boolean, we should preserve that the program
throws an error as usual.

### Known Variables at the REPL

Similarly, after a `define` statement evaluates at the REPL, we can know that
variable's tag and use that information to compile future entries. For example,
in this REPL sequence, we define a numeric variable and use it in an operator
later. We could avoid tag checks for `x` in the later use:

```
> (define x (+ 3 4))
> (+ x 10)
```

Note a pitfall here – if you allow `set!` on `define`d variables, their types
could change mid-expression, so there are some restrictions on when this should
be applied. Make sure to test this case.

Happy hacking!

### Discussion

It's worth re-emphasizing that a static type-checker could recover a lot of
this performance, and for Cobra it's pretty straightforward to implement a
type-checker (especially for expressions that don't involve `input`).

However, we'll soon introduce functions, which add a whole new layer of
potential dynamism and unknown types (because of function arguments), so the
same principles behind these simple cases become much more pronounced. And a
language with functions and a static type system is quite different from a
language with functions and no static type system.

