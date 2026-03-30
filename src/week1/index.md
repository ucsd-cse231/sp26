![adder](./adder.jpg)

# Adder

In this assignment you'll implement a compiler for a small language called
Adder, that supports 32-bit integers and three operations – `add1`, `sub1`,
and `negate`.  There is no starter code for this assignment; you'll do it _from
scratch_ based on the instructions here.

## Setup

You can start by

- accepting the assignment on [github](TODO), and then
- opening the assignment CodeSpaces

The necessary tools will be present in the CodeSpace.

You may also want to work on your own computer, in which case you'll need to install `rust` and `cargo`

[https://www.rust-lang.org/tools/install](https://www.rust-lang.org/tools/install)

You may also (depending on your system) need to install [`nasm`](https://www.nasm.us/).

On my mac I used `brew install nasm`; on other systems your package manager of choice likely
has a version. On Windows you should use [Windows Subsystem for Linux (WSL)](https://learn.microsoft.com/en-us/windows/wsl/)

**The assignments assume that your computer can build and run x86-64-bit
binaries.  This is true of most (but not all) mass-market Windows and Linux
laptops. Newer Macs use a different ARM architecture, _but_ can also run legacy
x86-64-bit binaries, so those are fine as well.  You should ensure that
whatever you do to build your compiler also runs on the github codespace,
standard environment for testing your work.**

## Rust 101

The first few sections of the [Rust Book](https://doc.rust-lang.org/book/ch01-00-getting-started.html) walk you
through installing Rust, as well. We'll assume you've gone through the
“Programming a Guessing Game” chapter of that book before you go on, so
writing and running a Rust program isn't too weird to you.


## Implementing a Compiler for Numbers

We're going to start by _just_ compiling **numbers**, so we can see how all the
infrastructure works. We _won't_ give starter code for this so that you see how
to build this up from scratch.

By _just_ compiling numbers, we mean that we'll write a compiler for a language
where the “program” file just contains a single number, rather than
full-fledged programs with function definitions, loops, and so on. (We'll get
there!)

### Creating a Project

First, make a new project with

```console
$ cargo new adder
```

This creates a new directory, called `adder`, set up to be a Rust project.

The main entry point is in `src/main.rs`, which is where we'll develop the
compiler. There's also a file called `Cargo.toml` that we'll use in a little
bit, and a few other directories related to building that we won't be too
concerned with in this assignment.

### The Runner

We'll start by just focusing on **numbers**.

It's useful to set up the goal of our compiler, which we'll come back to
repeatedly in this course:

> “Compiling” an expression means generating assembly instructions that
> evaluate it and leave the answer in the `rax` register.

Given this, before writing the compiler, it's useful to spend some time
thinking about how we'll run these assembly programs we're going to generate.
That is, what commands do we run at the command line in order to get from our
soon-to-be-generated assembly to a running program?

We're going to use a little Rust program to kick things off. It will look like
this; you can put this into a file called `runtime/start.rs`:

```rust
#[link(name = "our_code")]
extern "C" {
    // The \x01 here is an undocumented feature of LLVM (which Rust uses) that ensures
    // it does not add an underscore in front of the name, which happens on OSX
    // Courtesy of Max New
    // (https://maxsnew.com/teaching/eecs-483-fa22/hw_adder_assignment.html)
    #[link_name = "\x01our_code_starts_here"]
    fn our_code_starts_here() -> i64;
}

fn main() {
  let i : i64 = unsafe {
    our_code_starts_here()
  };
  println!("{i}");
}
```

This file says:

- We're expecting there to be a precompiled file called `libour_code` that we
  can load and link against (we'll make it in a few steps)
- That file should define a global function called `our_code_starts_here`. It
  takes no arguments and returns a 64-bit integer.
- For the `main` of this Rust program, we will call the `our_code_starts_here`
  function in an `unsafe` block. It has to be in an `unsafe` block because Rust
  doesn't and cannot check that `our_code_starts_here` actually takes no
  arguments and returns an integer; it's trusting us, the programmer, to ensure
  that, which is `unsafe` from its point of view. The `unsafe` block lets us do
  some kinds of operations that would otherwise be compile errors in Rust.
- Then, print the result.

Let's next see how to build a `libour_code` file out of some x86-64 assembly
that will work with this file. Here's a simple assembly program that has a
global label for `our_code_starts_here` that has a “function body” that
returns the value `31`:

```x86asm
section .text
global our_code_starts_here
our_code_starts_here:
  mov rax, 31
  ret
```

Put this into a file called `test/31.s` if you like, to test things out (you
should now have a `runtime/` and a `test/` directory that you created).

We can create a standalone binary program that combines these with these
commands (substitute `macho64` for `elf64` on OSX and if you're on an M1/M2
machine change the invocation to `rustc --target x86_64-apple-darwin ...`.
You may have to run `rustup target add x86_64-apple-darwin`):

```console
$ nasm -f elf64 test/31.s -o runtime/our_code.o
$ ar rcs runtime/libour_code.a runtime/our_code.o
$ ls runtime
libour_code.a          our_code.o             start.rs
$ rustc -L runtime/ runtime/start.rs -o test/31.run
$ ./test/31.run
31
```

The first command _assembles_ the assembly code to an object file. The basic
work there is generating the machine instructions for each assembly
instruction, and enough information about labels like `our_code_starts_here` to
do later linking. The `ar` command takes this object file and puts it in a
standard format for library linking used by `#[link` in Rust. Then
`rustc` combines that `.a` file and `start.rs` into a single executable binary
that we named `31.run`.

We haven't written a compiler yet, but we _do_ know how to go from files
containing assembly code to runnable binaries with the help of `nasm` and
`rustc`. Our next task is going to be writing a program that generates assembly
files like these.

### Generating Assembly

Let's revisit our definition of compiling:

> “Compiling” an expression means generating assembly instructions that
> evaluate it and leave the answer in the `rax` register.

Since, for now, our programs are going to be single expressions (in fact just
single numbers), this means that for a program like “5”, we want to generate
assembly instructions that put the constant `5` into `rax`.

Let's write a Rust function that does that, with a simple `main` function that
shows it working on a single hardcoded input; this goes in `src/main.rs` and is
the start of our compiler:

```rust
/// Compile a source program into a string of x86-64 assembly
fn compile(program: String) -> String {
    let num = program.trim().parse::<i32>().unwrap();
    return format!("mov rax, {}", num);
}

fn main() {
    let program = "37";
    let compiled = compile(String::from(program));
    println!("{}", compiled);
}
```

You can compile and run this with `cargo run`:

```console
$ cargo run
   Compiling adder v0.1.0 ...
mov rax, 37
```

Really all I did here was look up the documentation in Rust about converting a
string to an integer and template the number into a `mov` command. The input
`37` is hardcoded, and to use the output like we did above, we'd need to
copy-paste the `mov` command into a larger assembly file with
`our_code_starts_here`, and so on.

Here's a more sophisticated `main` that takes two command-line arguments: a
source file to read and a target file to write the resulting assembly to. It
also puts the generated command into the template we designed for our generated
assembly:

```rust
use std::env;
use std::fs::File;
use std::io::prelude::*;

fn main() -> std::io::Result<()> {
    let args: Vec<String> = env::args().collect();

    let in_name = &args[1];
    let out_name = &args[2];

    let mut in_file = File::open(in_name)?;
    let mut in_contents = String::new();
    in_file.read_to_string(&mut in_contents)?;

    let result = compile(in_contents);

    let asm_program = format!("
section .text
global our_code_starts_here
our_code_starts_here:
  {}
  ret
", result);

    let mut out_file = File::create(out_name)?;
    out_file.write_all(asm_program.as_bytes())?;

    Ok(())
}
```

Since this now expects _files_ rather than hardcoded input, let's make a test
file in `test/37.snek` that just contains `37` as contents. Then we'll read the
“program” (still just a number) from `37.snek` and store the resulting
assembly in `37.s`. (`snek` is a silly spelling of snake, which is a theme of
the languages in this course.)

Then we can run our compiler with these command line arguments:

```console
$ cat test/37.snek
37
$ cargo run -- test/37.snek test/37.s
$ cat test/37.s

section .text
global our_code_starts_here
our_code_starts_here:
  mov rax, 37
  ret
```

Then we can use the same sequence of commands from before to run the program:

```console
$ nasm -f elf64 test/37.s -o runtime/our_code.o
$ ar rcs runtime/libour_code.a runtime/our_code.o
$ rustc -L runtime/ runtime/start.rs -o test/37.run
$ ./test/37.run
37
```

We're close to saying we've credibly built a “compiler”, in that we've taken
some source program and gone all the way to a generated binary.

The next steps will be to clean up the clumsiness of running 3 post-processing
commands (`nasm`, `ar`, and `rustc`), and then adding some nontrivial
functionality.

### Cleaning up with a Makefile

There are a lot of thing we could do to try and assemble and run the program,
and we'll discuss some later in the course. For now, we'll simply tidy up our
workflow by creating a Makefile that runs through the compile-assemble-link
steps for us. Put these rules into a file called `Makefile` in the root of the
repository (use `elf64` on Linux):

```makefile
test/%.s: test/%.snek src/main.rs
	cargo run -- $< test/$*.s

test/%.run: test/%.s runtime/start.rs
	nasm -f elf64 test/$*.s -o runtime/our_code.o
	ar rcs runtime/libour_code.a runtime/our_code.o
	rustc -L runtime/ runtime/start.rs -o test/$*.run
```

Note: on MACOS

1. Write `macho64` instead of `elf64` and
2. Write `rustc --target x86_64-apple-darwin ...` (if you have an M1/M2 machine)

(Note that `make` requires tabs not spaces, but we can only use spaces on the
website, so please replace the four spaces indentation with tab characters when
you copy it.)

And then you can run just `make test/<file>.run` to do the build steps:

```console
$ make test/37.run
cargo run -- test/37.snek test/37.s
    Finished dev [unoptimized + debuginfo] target(s) in 0.07s
     Running `target/x86_64-apple-darwin/debug/adder test/37.snek test/37.s`
nasm -f macho64 test/37.s -o runtime/our_code.o
ar rcs runtime/libour_code.a runtime/our_code.o
rustc -L runtime/ runtime/start.rs -o test/37.run
```

The `cargo run` command will re-run if the `.snek` file or the compiler
(`src/main.rs`) change, and the assemble-and-link commands will re-run if the
assembly (`.s` file) or the runtime (`runtime/start.rs`) change.


## The Adder Language

In each of the next several assignments, we'll introduce a language that we'll
implement.  We'll start small, and build up features incrementally.  We're
starting with Adder, which has just a few features –numbers and three
operations.

There are a few pieces that go into defining a language for us to compile:

- A description of the concrete syntax – the text the programmer writes.
- A description of the abstract syntax – how to express what the
  programmer wrote in a data structure our compiler uses.
- A _description of the behavior_ of the abstract syntax, so our compiler
  knows what the code it generates should do.

### Concrete Syntax

The concrete syntax of Adder is:

```text
<expr> :=
  | <number>
  | (add1 <expr>)
  | (sub1 <expr>)
  | (negate <expr>)
```

### Abstract Syntax

The abstract syntax of Adder is a Rust datatype, and corresponds nearly
one-to-one with the concrete syntax. We'll show just the parts for `add1` and
`sub1` in this tutorial, and leave it up to you to include `negate` to get
practice.

```rust
enum Expr {
    Num(i32),
    Add1(Box<Expr>),
    Sub1(Box<Expr>)
}
```

The `Box` type is necessary in Rust to create recursive types like these (see
[Enabling Recursive Types with Boxes](https://doc.rust-lang.org/book/ch15-01-box.html#enabling-recursive-types-with-boxes)).
If you're familiar with C, it serves roughly the same role as introducing a
pointer type in a struct field to allow recursive fields in structs.

The reason this is necessary is that the Rust compiler calculates a size and
tracks the contents of each field in each variant of the `enum`. Since an
`Expr` could be an `Add1` that contains another `Add1` that contains another
`Add1`... and so on, there's no way to calculate the size of an enum variant like

```rust
    Add1(Expr)
```

(What error do you get if you try?)

Values of the `Box` type always have the size of a single reference (probably
represented as a 64-bit address on the systems we're using). The address will
refer to an `Expr` that has already been allocated somewhere.  `Box` is one of
several _smart pointer_ types whose memory are carefully, and automatically,
memory-managed by Rust.

### Semantics

A ``semantics'' describes the languages' behavior without giving all of the
assembly code for each instruction.

An Adder program always evaluates to a single i32.

- Numbers evaluate to themselves (so a program just consisting of `Num(5)`
  should evaluate to the integer `5`).
- `add1` and `sub1` expressions perform addition or subtraction by one on their argument.
- `negate` produces the result of the argument multiplied by `-1`

There are several examples further down to make this concrete.

Here are some examples of Adder programs:

#### Example 1

**Concrete Syntax**

```scheme
(add1 (sub1 5))
```

**Abstract Syntax**

```rust
Add1(Box::new(Sub1(Box::new(Num(5)))))
```

**Result**

```rust
5
```

#### Example 2

**Concrete Syntax**

```scheme
4
```

**Abstract Syntax**

```rust
Num(4)
```

**Result**

```rust
4
```

#### Example 3

**Concrete Syntax**

```scheme
(negate (add1 3))
```

**Abstract Syntax**

```rust
Negate(Box::new(Add1(Box::new(Num(3)))))
```

**Result**

```rust
-4
```

## Implement an Interpreter for Adder

As a warm up exercise, implement an *interpreter* for `Adder` which is to say,
a plain `rust` function that evaluates the `Expr` datatype we defined above.

```rust
fn eval(e: &Expr) -> i32 {
    match e {
        Expr::Num(n) => ...,
        Expr::Add1(e1) => ...,
        Expr::Sub1(e1) => ...,
    }
}
```

Write a few tests to convince yourself that your interpreter is working as expected.

In the file `src/main.rs`, you can add a `#[cfg(test)]` section to write tests

```rust
#[cfg(test)]
mod tests {
    #[test]
    fn test1() {
      let expr1 = Expr::Num(10);
      let result = eval(expr1);
      assert_eq!(result, 10);
    }
}
```

And then you can run the test either in `vscode` or by running `cargo test` in the terminal.



## Implementing a Compiler for Adder

The overall syntax for the `Adder` language admits many more features than just
numbers. With the definition of `Adder` above, we can have programs like `(add1
(sub1 6))`, for example. There can be any numbers of layers of nesting of the
parentheses, which means we need to think about **parsing** a little bit more.

### Parsing

We're going to design our syntax carefully to avoid thinking too much about
parsing, though. The parenthesized style of Adder is a subset of what's called
**s-expressions**. The Scheme and Lisp family of languages are some of the more
famous examples of languages built in s-expressions, but recent ones like
WebAssembly also use this syntax, and it's a common choice for language
development to simplify decision around syntax, which can become quite tricky
and won't be our focus in this course.

A grammar for s-expressions looks something like:

```text
s-exp := number
       | symbol
       | string
       | ( <s-exp>* )
```

That is, an s-expression is either a number, symbol (think of symbol like an
identifier name), string, or a parenthesized sequence of s-expressions. Here
are some s-expressions:

```scheme
(1 2 3)
(a (b c d) e "f" "g")

(hash-table ("a" 100) ("b" 1000) ("c" 37"))

(define (factorial n)
  (if (== n 1)
      1
      (factorial (* n (- n 1)))))

(class Point
  (int x)
  (int y))

(add1 (sub1 37))
```

One attractive feature of s-expressions is that most programming languages have
libraries for parsing them. There are several crates available for parsing
s-expressions in Rust. You're free to pick another one if you like it, but I'm
going to use [sexp](https://crates.io/crates/sexp) because its type definitions
work pretty well with pattern-matching and I find that helpful.
([lexpr](https://docs.rs/lexpr/latest/lexpr/) also looks interesting, but the
`Value` type is really clumsy with pattern matching so it's not great for this
tutorial.)

### Parsing with S-Expressions

We can add this package to our project by adding it to `Cargo.toml`, which was
created when you used `cargo new`. Make it so your `Cargo.toml` looks like this:

```toml
[package]
name = "adder"
version = "0.1.0"
edition = "2021"

[dependencies]
sexp = "1.1.4"
```

Then you can run `cargo build` and you should see stuff related to the `sexp`
crate be downloaded.

We can then use it in our program like this:

```rust
use sexp::*;
use sexp::Atom::*;
```

Then, a function call like this can turn a string into a `Sexp`:

```rust
    let sexp = parse("(add1 (sub1 (add1 73)))").unwrap()
```

(As a reminder, the `.unwrap()` is our way of telling Rust that we are trusting
this parsing to succeed, and we'll `panic!` and stop the program if the parse
doesn't succeed. We will talk about giving better error messages in these cases
later.)

Our goal, though, is to use a datatype that we design for our expressions, which we introduced as:

```rust
enum Expr {
    Num(i32),
    Add1(Box<Expr>),
    Sub1(Box<Expr>),
}
```

So we should next write a function that takes `Sexp`s and turns them into
`Expr`s (or gives an error if we give an s-expression that doesn't match the
grammar of Adder). Here's a function that will do the trick:

```rust
fn parse_expr(s: &Sexp) -> Expr {
    match s {
        Sexp::Atom(I(n)) => Expr::Num(i32::try_from(*n).unwrap()),
        Sexp::List(vec) => {
            match &vec[..] {
                [Sexp::Atom(S(op)), e] if op == "add1" => Expr::Add1(Box::new(parse_expr(e))),
                [Sexp::Atom(S(op)), e] if op == "sub1" => Expr::Sub1(Box::new(parse_expr(e))),
                _ => panic!("parse error"),
            }
        },
        _ => panic!("parse error"),
    }
}
```

(A Rust note – the `parse_expr` function takes a reference to `Sexp` (the type
`&Sexp`) which means `parse_expr` will have read-only, borrowed access to some
`Sexp` that was allocated and stored somewhere else.)

This uses Rust **pattern matching** to match the specific cases we care about
for Adder – plain numbers and lists of s-expressions. In the case of lists, we
match on two the two specific cases that look like `add1` or `sub1` followed by
some other s-expression. In those cases, we recursively parse, and use
`Box::new` to match the signature we set up in `enum Expr`.

### Code Generation

So we've got a way to go from more structure text—s-expressions—stored in
files and produce our `Expr` structure. Now we just need to go from the `Expr`
ASTs to generated assembly. Here's one way to do that:

```rust
fn compile_expr(e: &Expr) -> String {
    match e {
        Expr::Num(n) => format!("mov rax, {}", *n),
        Expr::Add1(subexpr) => compile_expr(subexpr) + "\nadd rax, 1",
        Expr::Sub1(subexpr) => compile_expr(subexpr) + "\nsub rax, 1",
    }
}
```

And putting it all together in `main`:

```rust
fn main() -> std::io::Result<()> {
    let args: Vec<String> = env::args().collect();

    let in_name = &args[1];
    let out_name = &args[2];

    let mut in_file = File::open(in_name)?;
    let mut in_contents = String::new();
    in_file.read_to_string(&mut in_contents)?;

    let expr = parse_expr(&parse(&in_contents).unwrap());
    let result = compile_expr(&expr);
    let asm_program = format!("
section .text
global our_code_starts_here
our_code_starts_here:
  {}
  ret
", result);

    let mut out_file = File::create(out_name)?;
    out_file.write_all(asm_program.as_bytes())?;

    Ok(())
}
```

### Testing our compiler

Then we can write tests like this `add.snek`:

```console
$ cat test/add.snek
(sub1 (sub1 (add1 73)))
```

And run our whole compiler end-to-end:

```console
$ make test/add.run
cargo run -- test/add.snek test/add.s
    Finished dev [unoptimized + debuginfo] target(s) in 0.02s
     Running `target/x86_64-apple-darwin/debug/adder test/add.snek test/add.s`
nasm -f macho64 test/add.s -o runtime/our_code.o
ar rcs runtime/libour_code.a runtime/our_code.o
rustc -L runtime/ runtime/start.rs -o test/add.run
$ cat test/add.s

section .text
global our_code_starts_here
our_code_starts_here:
  mov rax, 73
add rax, 1
sub rax, 1
sub rax, 1
  ret
$ ./test/add.run
72
```

Note: `make test/add.run` may delete `test/add.s` as an intermediate file.
If so, run `make test/add.s` before running `cat test/add.s`.

This is, of course, a very simple language. This tutorial serves mainly to make
us use all the pieces of infrastructure that we'll build on throughout the quarter:

1. An assembler (`nasm`) and a Rust main program (`runtime/start.rs`) to build binaries
2. A definition of abstract syntax (`enum Expr`)
3. A parser for text (`parse` from the `sexp` crate) and a parser for our abstract syntax (`parse_expr`)
4. A code generator (`compile_expr`) that generates assembly from `Expr`s

Most of our future assignments will be built from just these pieces, plus extra
infrastructure added as we need it.

## Your TODOs

1. Do the whole tutorial above, creating the project repository as you go. Write
several tests to convince yourself that things are working as expected.
2. Then, add support for `negate` as described in the beginning, and write several
tests for `negate` as well.
3. In your terminal, demonstrate your compiler working on at least 5 different
examples by using `cat` on a source `snek` file, then showing `make` running,
using `cat` on the resulting `.s` file, and then running the resulting binary.
Copy this interactino into a file called `transcript.txt`

Hand in your entire repository to the `01-adder` assignment on `github`.

**That is you only need to commit and push your cloned assignment**

There is no automated grading for this assignment; we want you to
practice gaining your own confidence that your solution works (and
demonstrating that to us).
