#import "tufte-handout.typ": margin-note, template

#show raw.where(block: true): it => block(
  stroke: 0.5pt + luma(150),
  inset: (x: 0.75em, y: 0.65em),
  radius: 2pt,
  width: 100%,
  it,
)

#set page(footer: context align(center, text(size: 7pt, counter(page).display("1"))))

#let examples(col2) = grid(
  columns: (1fr, .5fr),
  gutter: 1.3em,
  [_Program_], [_#(col2)_],
  ```rkt
  ((+ 1 2) 3)
  ```,
  [],

  ```rkt
  (+ (+ 1 2) (+ 3 4))
  ```,
  [],

  ```rkt
  (let (x 10)
    (let (y 10)
      (+ x y)))
  ```,
  [],

  ```rkt
  (let (x 10)
    (let (x (add1 x))
      (+ x 10))))
  ```,
  [],

  ```rkt
  (+ (let (x 10) (add1 x))
     (let (y 7) (+ x y)))
  ```,
  [],

  ```rkt
  (+ (let (x 10) (add1 x))
     (let (y 7) (+ 10 y)))
  ```,
  [],
)

#show: doc => template(
  title: "CSE 231: Boa (Binary Operators)",
  author: "Ranjit Jhala",
  date: "April 7, 2026",
  doc,
)

= Binary Operators in Boa

Next, lets build on the machinery for scoping and stacks to add
*binary operators* (`+`, `-`, `*`)

Recall the three pieces to define the language

+ *Concrete syntax* --- the text the programmer writes
+ *Abstract syntax* --- a Rust datatype our compiler uses
+ *Semantics* --- what values programs produce

#v(1em)

== Concrete Syntax

#margin-note[
  *s-expression* parenthesized prefix notation, so
  `+`, `-`, `*` are binary operators in *prefix* form, e.g. `(+ 1 2)`
]


```text
<expr> :=
  | <number>
  | (add1 <expr>)
  | (sub1 <expr>)
  | (let (<ident> <expr>) <expr>)
  | <ident>

  | (+ <expr> <expr>)       -- binary addition
  | (- <expr> <expr>)       -- binary subtraction
  | (* <expr> <expr>)       -- binary multiplication
```

#v(1em)

== QUIZ: Abstract Syntax

#margin-note[Recall `Box<T>` is a heap pointer --- always a fixed 64-bit size, enabling recursive types.]

```rust
enum Expr {
    Number(i32),
    Add1(Box<Expr>),
    Sub1(Box<Expr>),
    Let(Ident, Box<Expr>, Box<Expr>),
    Var(Ident),
    // Fill in the cases for +, -, *




}
```

#colbreak()

== QUIZ: Semantics


#examples("Result")

#v(1em)

== Recall: Stack and Local Variables

#figure(
  grid(
    columns: (1fr, 1.75fr),
    // Two auto-sized columns
    gutter: 0.2em,
    // Space between the images
    image("img/memory-layout.png", width: 70%), image("img/stack-layout.png", width: 100%),
  ),
  caption: [Store i#super[th] stack-variable at address `RBP - 8 * i`.],
)

*Required*

Map from vars (`x`, `y`, `z`, …)  to stack positions (1, 2, 3 …)

But what about the *sub-expressions* `(+ e1 e2)`?


*Solution*

The structure of the `let` is stack-like too!

Maintain an `Env` that maps `Id` $arrow$ `StackPosition`

#v(1em)


== QUIZ: Where to *store*?

#examples("Stack Layout")

== QUIZ

Which stack position do we store `c` in this program?

```rkt
  (let (a 1)
    (let (c
      (let (b (add1 a))
        add1(b)))
    add1 c))
```

#v(2em)

== Compilation Strategy: Definition

To compile *definition* `(let (x e1) e2)`

1. Compile `e1` using `env` (result in `rax`),
2. Move `rax` into `[RBP - 8 * i]`
3. Compile `e2` using `env[ x := i]`

#v(1em)

== Compilation Strategy: Use

To compile *use* `x`

1. Look up `x` in `env` to get its stack position `i`
2. Load the value at `[RBP - 8 * i]` into `rax`

#colbreak()

== QUIZ: Compilation Examples

#grid(
  columns: (.5fr, 0.05fr, .5fr),
  gutter: 1em,
  [_Program_], [], [_Assembly_],
  ```rkt
  (let (x 10)
    (add1 x))
  ```,

  [],
  [
    ```asm
    mov rax, 10





    ```
  ],

  ```rkt
  (let (x 10)
    (let (y (add1 x))
      (add1 y)))
  ```,
  [],
  [
    ```asm
    mov rax, 10











    ```
  ],

  ```rkt
  (let (a 1)
    (let (c
      (let (b (add1 a))
        add1(b)))
    add1 c))
  ```,
  [],
  [
    ```asm
    mov rax, 1















    ```

  ],
)
