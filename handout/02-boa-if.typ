#import "tufte-handout.typ": margin-note, template

#show raw.where(block: true): it => block(
  stroke: 0.5pt + luma(150),
  inset: (x: 0.75em, y: 0.65em),
  radius: 2pt,
  width: 100%,
  it,
)

#set page(footer: context align(center, text(size: 7pt, counter(page).display("1"))))

#let if_examples(col2) = grid(
  columns: (1fr, .5fr),
  gutter: 1.3em,
  [_Program_], [_#(col2)_],
  ```rkt
  (if true 22 33)
  ```,
  [],

  ```rkt
  (if false 22 33)
  ```,
  [],

  ```rkt
  (let (x (if false 22 99))
    (if true (add1 x) 999))
  ```,
  [],
)


#let eq_examples(col2) = grid(
  columns: (1fr, .5fr),
  gutter: 1.3em,
  [_Program_], [_#(col2)_],
  ```rkt
  (= 10 20)
  ```,
  [],

  ```rkt
  (= 10 (+ 5 5))
  ```,
  [],

  ```rkt
  (let (x (if false 22 99))
    (if (= x 99) (add1 x) 999))
  ```,
  [],
)


#show: doc => template(
  title: "CSE 231: Branches, Types and Tags",
  author: "Ranjit Jhala",
  date: "April 7, 2026",
  doc,
)

= Branches and Tags

Next, lets add

- *booleans* i.e. `true` and `false`,
- *equality* i.e. to _compare_ values,
- *branches* i.e. `if-then-else`,
- *types* to distinguish _numbers_ and _booleans_.

This will teach us about

- control flow *labels* and *conditional jumps* in assembly,
- *tagged data representation* using one machine word.

#v(1em)

= Concrete Syntax

```
<expr> := ...
        | true                       -- bool `true`
        | false                      -- bool `false`
        | input                      -- user input
        | (= <expr> <expr>)          -- equality test
        | (if <expr> <expr> <expr>)  -- if-then-else
```

#v(1em)

= QUIZ: Abstract Syntax

First, lets fill in the cases for `true`, `false`, `input`, `eq`, and `if` in the abstract syntax.

```rust
enum Expr {
  // cases for Number, Add1, Sub1, Let, Var






}
```

#colbreak()

= QUIZ: Semantics

#if_examples("Result")

#v(1em)

= QUIZ: Evaluator

Lets fill in the cases for the `eval` function.

*Challenge:* How can we *represent* `True` and `False` as `i64`?

// #margin-note[
//   How to *represent* `True` and `False` as `i64`?
// ]

```rust
fn eval(expr: &Expr, env: &Env) -> i64 {
  match expr {
    // cases for Number, Add1, Sub1, Let, Var

    Expr::True => ____________________________,

    Expr::False => ___________________________,

    Expr::Eq(e1, e2) => {

      ________________________________________

      ________________________________________
    }

    Expr::If(cond, e1, e2) => {

      ________________________________________

      ________________________________________

      ________________________________________
    }
  }
}
```

= Naive Representation

Let's start old-school, C-style

#margin-note[Why is this a *bad* idea?]

- `false` is `0`
- `true` is any non-zero value...

#colbreak()



= Strategy: Branches

Compile `if` with *labels*, *comparisons* and *jumps*

= Labels

```asm
our_code_label:
  ...
```

- Landmarks where execution can _start_ or be _diverted_

= Comparisons

```asm
cmp a1, a2
```

- *Compare* the values in `a1` and `a2`
- Store the result in a special *processor flag*

= Jump: Unconditional

*Unconditional*

```asm
jmp LABEL  # jump to LABEL
```

- Just jump to LABEL, no questions asked!

= Jump: Conditional

```asm
je  LABEL  # jump IF last comparison was EQUAL
jne LABEL  # jump IF last comparison was NOT-EQUAL
```

- Jump _depending on_ result of last comparison
- Else, carry on with next instruction...

= QUIZ: Assembly

Suppose `false` is `0` and `true` is `1`. Write the assembly code for

#grid(
  columns: (.3fr, 0.01fr, .5fr),
  gutter: 1em,
  [_Program_], [], [_Assembly_],
  ```rkt
  (if true 22 33)
  ```,
  [],
  [
    ```asm
    mov rax, 1







    ```
  ],

  ```rkt
  (if false 22 33)
  ```,
  [],
  [
    ```asm
    mov rax, 0







    ```
  ],

  ```rkt
  (if cond e1 e2)
  ```,
  [],
  [
    ```asm
    ;; strategy for `if`












    ```
  ],
)

#v(1em)

== QUIZ: Compilation Code

Fill in the cases for `compile_expr` for `true` and `false` and `if`

#margin-note[How to get _labels_?]

```rust
fn compile_expr(expr: &Expr, env: &Env) -> String {
  match expr {
    // other cases ...

    Expr::True => ____________________________,

    Expr::False => ___________________________,

    Expr::If(cond, e1, e2) => {


















    }
}
```

= QUIZ: Compiling Equality

Suppose `false` is `0` and `true` is `1`. Write the assembly code for

#grid(
  columns: (.3fr, 0.01fr, .5fr),
  gutter: 1em,
  [_Program_], [], [_Assembly_],
  ```rkt
  (= 10 20)
  ```,
  [],
  [
    ```asm
    mov rax, 10













    ```
  ],

  ```rkt
  (= e1 e2)
  ```,
  [],
  [
    ```asm
    ;; strategy for `eq`
















    ```
  ],
)

*EXERCISE* Try to do it _without_ jumps!

#v(1em)

= Data Representation

Why is it a *bad* idea to represent `true` as `1` and `false` as `0`?

#v(5em)


How can we *track type* at runtime?

#colbreak()


= Data Representation with Tag Bits

Can distinguish *two types* -- number v bool -- with a *one bit*.

Least Significant Bit (LSB) is

- `0` for number
- `1` for boolean

*Question:* Why not `0` for boolean and `1` for number?

#v(2em)

= Tagged Numbers

So `number` is the binary representation shifted left by 1 bit

- Lowest bit is always `0`
- Remaining bits are number's binary representation

#table(
  columns: 3,
  align: (right, right, right),
  [*Value*], [*Binary Repr.*], [*Hex Repr.*],
  [`3`], [`0b00000110`], [`0x06`],
  [`5`], [`0b00001010`], [`0x0a`],
  [`12`], [`0b00011000`], [`0x18`],
  [`42`], [`0b01010100`], [`0x54`],
)

= Tagged Booleans

*Least Significant Bit* (LSB) is

* `1` for `true`
* `0` for `false`

#table(
  columns: 3,
  align: (right, right, right),
  [*Value*], [*Binary Repr.*], [*Hex Repr.*],
  [`true`], [`0b11`], [`0x03`],
  [`false`], [`0b01`], [`0x01`],
)

= QUIZ: Updating Compilation with Tags

Which parts of the compiler do we need to update to account for tagged data representation?


```rust









```

= Update Runtime Too!

We need to update the `start.rs` runtime to account for tagged data representation too!

```rust
fn main() {
  let res: i64 = unsafe { our_code_starts_here() };
  match res {
    3 => println!("true"),
    1 => println!("false"),
    _ => println!("{}", res >> 1),
  }
}
```

= Semantics of Numbers and Booleans

Wait a minute!

#grid(
  columns: (.5fr, .4fr),
  gutter: 1em,
  [_Program_], [_Result_],

  ```rkt
  (= 10 true)
  ```,
  [],

  ```rkt
  (+ 10 true)
  ```,
  [],

  ```rkt
  (if 10 20 30)
  ```,
  [],
)

#v(1em)


= Runtime Tag Checking

Avoid garbage results by *checking tags* at runtime.

We have a special `label_error` to jump to on type error.

```asm
global our_code_starts_here
extern snek_error
label_error:      ;; special error label
  push rsp        ;; save stack pointer
  call snek_error ;; call back into runtime
```

Where `snek_error` in our `runtime/start.rs` just prints an error message and exits the program.

```rust
#[export_name = "\x01snek_error"]
fn snek_error(code: i64) {
  println!("YIKES! A run-time error {code} 🤯️");
  std::process::exit(1);
}
```

#colbreak()

= QUIZ: Compiler Tag Checking Strategy

Write the asm to check if `rax`'s value has a given `<tag>`

```asm

______________________________; save rax

______________________________; extract LSB

______________________________; compare with <tag>

______________________________; jump to err if not-eq


```

*Update* `compile_expr` for `if`, `eq`, `+` to check tags for operands.
