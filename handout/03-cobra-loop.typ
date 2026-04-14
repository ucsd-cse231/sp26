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
  columns: (1.2fr, .5fr),
  gutter: 1.3em,
  [_Program_], [_#(col2)_],

  ```lisp
  (let (i 0)
    (loop
      (if (= i input)
        (break i)
        (set! i (+ i 1)))))
  ```,
  [],

  ```lisp
  (let (res 0)
    (let (i 0)
      (loop
        (if (= i input)
            (break res)
            (block
               (set! res (+ res i))
               (set! i (+ i 1)))))))
  ```,
  [],
)


#show: doc => template(
  title: "CSE 231: Loops",
  author: "Ranjit Jhala",
  date: "April 16, 2026",
  doc,
)

= Loops

Now lets add constructs for _iteration_, specifically

- *loop* _repeatedly_ evaluates an expression, and
- *break* which gives us a way to _stop_ iteration.

= Concrete Syntax

```
<expr> := ...
        | (loop e)
        | (break e)
```

*Idea*

- `loop e` evaluates `e` repeatedly _until_ it hits
- `break e` which exits returning the value of `e`

= QUIZ: Semantics of `loop` and `break`

#examples("Result")

#v(1em)

= Evaluator

Lets extend the `eval` function for `loop` and `break`.

*Problem* How to `break` out of a `loop` during evaluation.

Where does the value of `break` _go_? What can we _do_ with it?

#colbreak()

= `loop` and `break` via "exceptions"

To evaluate `loop e`

- "Try" to evaluate `e` (and recursing to iterate)
- "Throw" an exception if you hit a `break`
- "Catch" the exception and return the value of `break`

= Exceptions

We can define a type of *exceptions* to "throw" and "catch" during evaluation.

```rust
pub enum Exn {
  Break(Val),
  UnboundVar(String),
  TypeError(String),
}
```

= Results

The `Result` type lets us represent computations that either
- succeed with a value `T` or
- fail with an error `E`.

```rust
enum Result<T, E> {
  Ok(T),
  Err(E),
}
```


= Evaluation: Returns an `Result<Val, Exn>`

#margin-note[
  *Note* we have to update all the other cases using `?` to propagate errors.
  See this link for more details on how to use `Result` in Rust: https://doc.rust-lang.org/book/ch09-02-recoverable-errors-with-result.html

]

```rust
fn eval(expr: &Expr, env: &Env) -> Result<Val, Exn> {
 match expr {
  // ...
  Expr::Loop(body) => {
    match eval(body, env) {
      Ok(_) => eval(e, env),       // continue!
      Err(Err::Break(v)) => Ok(v), // exit!
      Err(e) => Err(e),            // other error!
    }
  }
  Expr::Break(e) => {
    match eval(e, env) {
      Ok(v) => Err(Exn::Break(v)), // throw break exn
      Err(e) => Err(e),            // other error!
    }
  }
}
```

= QUIZ: Assembly for `loop` and `break`

Lets _complete_ the assembly code for

#margin-note[What extra _control-flow labels_ do we need?]
#grid(
  columns: (.5fr, .55fr),
  gutter: 1em,
  [_Program_], [_Assembly_],
  ```lisp
  (let (i 0)
  (loop
    (if (= i 5)
      (break 99)
      (set! i (+ i 1)))))
  ```,
  [
    ```asm
    our_code_starts_here:
      mov rax, 0
      mov [rbp - 8*1], rax

    ________________________

      ; <(= i 5)>
      cmp rax, 1
      je if_false_1

    if_true_1:

    ________________________

    ________________________

    ________________________

    if_false_1:
      ; <set! i (+ i 1)>

    if_exit_1:

    ________________________

    ________________________
    ```
  ],
)

= QUIZ: Strategy for `loop` and `break`

#grid(
  columns: (.62fr, .5fr),
  gutter: 1em,

  ```lisp
  (loop e)
  ```,
  [
    ```yasm




    ```
  ],

  ```lisp
  (break e)
  ```,
  [
    ```yasm






    ```
  ],
)


== Compilation Code

What extra information does `compile_expr` need to track?

#colbreak()

```rust
fn compile_expr(expr: &Expr, env: &Env,            )
   -> String
{
  match expr {
    // other cases ...
    Expr::Loop(body) => {








    }

    Expr::Break(e) => {










    }
}
```
