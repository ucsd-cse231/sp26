#import "tufte-handout.typ": margin-note, template

#show raw.where(block: true): it => block(
  stroke: 0.5pt + luma(150),
  inset: (x: 0.75em, y: 0.65em),
  radius: 2pt,
  width: 100%,
  it,
)

#set page(footer: context align(center, text(size: 7pt, counter(page).display("1"))))

#show: doc => template(
  title: "CSE 231: Printing using the Runtime",
  author: "Ranjit Jhala",
  date: "April 23, 2026",
  doc,
)

= Printing

Lets add support for *printing* expressions

A stepping stone to _user-defined functions_ and _calls_

```
<expr> := ... | (print <expr>)
```

= QUIZ: Semantics

#grid(
  columns: (1fr, .5fr),
  row-gutter: 1.0em,
  column-gutter: 1.3em,
  [_Program_], [_Expected Output_],
  ```clojure
  (print 42)
  ```,
  ```


  ```,

  ```clojure
  (let (x1 100)
  (let (x2 200)
    (block
      (print x1)
      (print x2))))
  ```,
  ```






  ```,
)


= Abstract Syntax

```rust
enum Expr { // ...
  Print(Box<Expr>),
}
```

= Evaluation

```rust
fn eval(expr: &Expr, env: &mut Env) -> Value {
  match expr { // ...
    Expr::Print(e) => {


    }
  }
}
```

= Strategy

#margin-note[Similar to how we exposed `snek_error` for tag errors]
1. Expose `snek_print` in the *runtime* (`start.rs`),
2. Compile `print` to *call* `snek_print`.

= Exposing `snek_print`


== In the Runtime

```rust
#[export_name = "\x01snek_print"]
fn snek_print(val: i64) -> i64 { ... }
```

== In the Assembly

```asm
global our_code_starts_here
extern snek_print
extern snek_error
...
```

= QUIZ: Assembly for `print`


#grid(
  columns: (.5fr, 1fr),
  row-gutter: 1.0em,
  column-gutter: 1.3em,
  [_Program_], [_Assembly_],

  ```clojure
  (print 42)
  ```,

  ```





  ```,

  ```clojure
  (print e)
  ```,

  ```





  ```,
)

= QUIZ: Passing parameters with `rdi`

_Like_ with `snek_error`

- We used `rdi` to pass the param to `snek_print`

_Unlike_ with `snek_error`

- We're coming back!

But _unlike_ with `snek_error`, we're coming back!

Can you write a test that will _break_ our compiler?

```clojure





```

= Saving RDI

What were we using `rdi` for before?
How can we save it?
