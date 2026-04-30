#import "@preview/codly:1.3.0": *
#import "tufte-handout.typ": margin-note, template

#show: codly-init.with()
#codly(
  number-format: none,
  zebra-fill: none,
  display-name: false,
)
// #show raw.where(block: true): it => {
//   if it.lang == "asm" {
//     set text(size: 0.8em)
//     block(inset: (x: 0.75em, y: 0.65em), width: 100%, it)
//   } else {
//     block(inset: (x: 0.75em, y: 0.65em), width: 100%, it)
//   }
// }

#set page(footer: context align(center, text(size: 7pt, counter(page).display("1"))))

#show: doc => template(
  title: "CSE 231: Functions",
  author: "Ranjit Jhala",
  date: "April 23, 2026",
  doc,
)

= User-defined Functions

*Program*

- A list of _function definitions_
- A _main expression_

```
<prog> := <func>* <expr>
```

*Function Definitions*

- A _name_,
- A _parameter_ (for now),
- A _body_ expression.

```
<func> := (fun (<name> <ident>) <expr>)
```

*Expressions*

- ... as before
- plus _function calls_


```
<expr> := ... | (<name> <expr>)
```


= QUIZ: Abstract Syntax

```rust
struct Prog {



}

struct Defn {



}

enum Expr {




}
```

= QUIZ: Semantics

Fill in the result of evaluating the following programs.

#grid(
  columns: (1.2fr, .5fr),
  gutter: 1.3em,
  [_Program_], [_Result_],

  ```clojure
  (fun (incr n)
    (add1 n)
  )

  (incr 100)
  ```,
  [
    ```




    ```
  ],

  ```clojure
  (fun (fac n)
    (if (= n 0)
      1
      (* n (fac (sub1 n)))
    )
  )

  (fac 5)
  ```,
  [
    ```




    ```
  ],
)

= Evaluation

```rust
fn eval(e: &Expr, env: &mut Env,                  )
   -> Result<Val, Err>
{
  match e { // ...
    Call1(f, arg) => {



    }
  }
}
```

#colbreak()


= Callers, Callees, and Frames

*Caller*

#image("img/stack-frame-1.png", width: 120%),

*Callee*

#image("img/stack-frame-2.png", width: 120%),

#colbreak()

= QUIZ: Assembly: Caller

#grid(
  columns: (.25fr, .5fr),
  gutter: 1.3em,
  [_Program_], [_Assembly_],

  ```clojure
  (incr 100)
  ```,
  [
    ```asm
    mov rax, 200




    ```
  ],

  ```clojure
  (f e)
  ```,
  [
    ```asm
    ; << e >>




    ```
  ],
)

= QUIZ: Assembly: Callee

#grid(
  columns: (.25fr, .5fr),
  gutter: 1.3em,
  [_Program_], [_Assembly_],

  ```clojure
  (fun (incr n)
    (add1 n)
  )
  ```,
  [
    ```asm
    ; setup frame



    ; body



    ; teardown frame




    ```
  ],
)

= Compiling Calls

```rust
fn compile_expr(e: &Expr) -> String {

}
```

= Compiling Definitions

```rust
fn compile_defn(defn: &Defn) -> String {


}
```

= Frame Setup (`frame_setup`)

```rust
fn frame_setup(e: &Expr) -> String {




}
```

= Frame Teardown (`frame_teardown`)

```rust
fn frame_teardown(e: &Expr) -> String {




}
```

= Frame Allocation

How much _space_ should we allocate for a frame?

How much should we float `rsp` up?



```rust
fn max_vars(e: &Expr) -> usize {














}
```
