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
  (+ 1 2)
  ```,
  [],

  ```rkt
  (+ (+ 1 2) 3)
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

*Problem*

But what about the *sub-expressions* `(+ e1 e2)`?


#colbreak()

== Compilation Strategy: Binary Addition

To compile `(+ e1 e2)`

1. _Compile_ `e1` into `rax`
2. _Save_ the value of `e1`
3. _Compile_ `e2` into `rax`
4. _Add_ the two values.

But *where* do we stash the value of `e1`?

#v(1em)

== QUIZ: Where to *store*?

#examples("Stack Layout")

#v(1em)

#v(1em)

#colbreak()

== QUIZ: Assembly

#grid(
  columns: (.5fr, 0.05fr, .5fr),
  gutter: 1em,
  [_Program_], [], [_Assembly_],
  ```rkt
  (+ (+ 1 2) (+ 3 4))
  ```,

  [],
  [
    ```asm
    mov rax, 1





    ```
  ],

  ```rkt
  (let (x 10)
    (let (y 10)
      (+ (+ x y) 99)))
  ```,
  [],
  [
    ```asm
    mov rax, 10











    ```
  ],
)

#v(1em)

== QUIZ: Compilation Code

Fill in the cases for `compile_expr` for `let` and `+`

```rust
fn compile_expr(expr: &Expr, env: &Env) -> String {
  match expr {
   // cases for Number, Add1, Sub1, Var
    Expr::Let(x, e1, e2) => {
    // 1. compute e1 into RAX
    // 2. save RAX at the position for x
    // 3. compute e2





    }
    Expr::Plus(e1, e2) => {
      // 1. compute e1 into RAX
      // 2. save RAX at TMP position
      // 3. compute e2 into RAX
      // 4. ADD RAX and TMP
      )





    }
}
```
