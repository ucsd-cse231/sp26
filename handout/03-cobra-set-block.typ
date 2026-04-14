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

  ```lisp
  (let (x 5)
    (set! x 10)
  )
  ```,
  [],

  ```lisp
  (let (x 10)
    (let (y (set! x (+ x 5)))
      (+ x y))
  ```,
  [],

  ```lisp
  (let (x 5)
    (block
      (set! x (+ x 100))
      x
    )
  )
  ```,
  [],
)


#show: doc => template(
  title: "CSE 231: Assignments and Blocks",
  author: "Ranjit Jhala",
  date: "April 16, 2026",
  doc,
)

= Assignments and Blocks

Next, we add *imperative* features, starting with

- *assignments* that let us _update_ values of variables,
- *blocks* that let us _sequence_ multiple expressions.

These are a stepping stone towards then adding *loops*.

= Concrete Syntax

```
<expr> := ...
        | (set! <ident> <expr>)   -- update variable
        | (block <expr>+)         -- sequence exprs
```


= QUIZ: Abstract Syntax

First, lets fill in the cases for `set!` and `block`

```rust
enum Expr {
  // ...


}
```

= QUIZ: Semantics of `set!` and `block`

#examples("Result")

#v(1em)

= QUIZ: Evaluator

Lets fill in the cases for the `eval` function.

#margin-note[
  How to
  - _Update_ a variable?
  - _Sequence_ expressions?
]

```rust
fn eval(expr: &Expr, env: &Env) -> i64 {
  match expr {
    // ...
    Expr::Set(x, e) => {

      ____________________________________________

      ____________________________________________

      ____________________________________________
    }
    Expr::Block() => {

      ________________________________________

      ________________________________________

      ________________________________________

      ________________________________________

      ________________________________________
    }
  }
}
```

= QUIZ: Assembly for `set!` and `block`

Complete the assembly code for

#grid(
  columns: (.62fr, .5fr),
  gutter: 1em,
  [_Program_], [_Assembly_],
  ```lisp
  (let (x 10)
    (let (y (set! x (+ x 1)))
      x)
  ```,
  [
    ```asm
    mov rax, 20
    mov [rbp - 8.1], rax
    mov rax, [rbp - 8.1]
    add rax, 2
    _____________________
    _____________________
    _____________________


    ```
  ],

  ```lisp
  (let (x 10)
    (block
      (set! x (+ x 1))
      x
    )
  )
  ```,
  [
    ```asm
    mov rax, 20
    mov [rbp - 8.1], rax
    mov rax, [rbp - 8.1]
    add rax, 2
    _____________________
    _____________________
    _____________________


    ```
  ],
)

#colbreak()

= QUIZ: Strategy for `set!` and `block`

#grid(
  columns: (.62fr, .5fr),
  gutter: 1em,

  ```lisp
  (set! x e)
  ```,
  [
    ```yasm




    ```
  ],

  ```lisp
  (block
    e0
    e1
    e2
  )
  ```,
  [
    ```yasm






    ```
  ],
)


== Compilation Code

Lets fill in the cases for `compile_expr` for `set!` and `block`

```rust
fn compile_expr(expr: &Expr, env: &Env) -> String {
  match expr {
    // other cases ...
    Expr::Set(x, e) => {








    }

    Expr::Block(es) => {








    }
}
```
