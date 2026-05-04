#import "@preview/codly:1.3.0": *
#import "tufte-handout.typ": margin-note, template

#show: codly-init.with()
#codly(
  number-format: none,
  zebra-fill: none,
  display-name: false,
)
#show raw.where(block: true): it => {
  if it.lang == "asm" {
    set text(size: 0.8em)
    // block(inset: (x: 0.75em, y: 0.65em), width: 100%, it)
    block(width: 100%, it)
  } else {
    // block(inset: (x: 0.75em, y: 0.65em), width: 100%, it)
    block(width: 100%, it)
  }
}

#set page(footer: context align(center, text(size: 7pt, counter(page).display("1"))))

#show: doc => template(
  title: "CSE 231: Heap Allocated Data",
  author: "Ranjit Jhala",
  date: "May 5, 2026",
  doc,
)


= Big Data!

The stack suffices for _little_ data like `int`, `bool` whose size known at compile time,
but what of _unbounded_ structures like _lists_, _trees_, _graphs_?

= (Two-element) Arrays

Lets us write _structs_, _lists_, ...

```
<expr> := ... | nil  | (vec <expr> <expr>)
        | (vec-get <expr> 0) | (vec-get <expr> 1)
```

- `nil` is the _empty_ vector
- `(vec e1 e2)` constructs a vector of _two_ elements
- `(vec-get e i)` returns the `i`th element of vector `e`

= Helpers: Head and Tail

Lets define some _helpers_ to work with `vec`

```clojure
(fun (head v) (vec-get v 0)) ; get first element
(fun (tail v) (vec-get v 1)) ; get second element
```

= QUIZ: Semantics

What should the following programs _evaluate_ to

#grid(
  columns: (0.85fr, 0.15fr),
  gutter: 0.5em,
  [*Program*], [*Result*],
  ```clojure
  nil
  ```,
  ```shell-unix-generic


  ```,

  ```clojure
  (vec (+ 5 5) (+ 10 10))
  ```,
  ```shell-unix-generic


  ```,

  ```clojure
  (let (p (vec 10 20)) (+ (head p) (tail p)))
  ```,
  ```shell-unix-generic


  ```,

  ```clj
  (fun (sum l)
    (let (r 0)
    (loop
      (if (= l nil)
        (break r)
        (block (set! r (+ r (head l)))
               (set! l (tail l)))))))

  (sum (vec 10 (vec 20 (vec 30 nil))))
  ```,
  ```shell-unix-generic










  ```,
)


= QUIZ: Abstract Syntax

Lets write the _abstract syntax_ for our language

#grid(
  columns: (0.75fr, 0.35fr),
  gutter: 0.5em,
  ```rust
  enum Expr { // ...



  }
  ```,
  ```rust
  enum Index {



  }
  ```,
)


= QUIZ: Evaluator `Value`

How to extend `Val` and `eval` to support `vec`?


```rust
enum Val {
  Num(i32),
  Bool(bool),


}
```


#grid(
  columns: (0.35fr, 0.75fr),
  gutter: 0.5em,
  ```rust
  enum Expr {
    Num(i32),
    Bool(bool),


  }
  ```,
  ```rust
  fn eval(e, env, funs) -> Val {
    match e {
      Expr::Nil => {

        ____________________________
      }
      Expr::Vec(e1, e2) => {

        ____________________________

        ____________________________

        ____________________________

      }
      Expr::Get(e, i) => {

        ____________________________

        ____________________________

        ____________________________

      }
  }
  ```,
)

= QUIZ: Where to _store_ the vectors?

Why can't we _just_ store them on the stack?

```clojure









```

= Stack vs Heap

#grid(
  columns: (0.7fr, 0.3fr),
  gutter: 0.5em,
  [
    Why do we need a *stack* _and_ *heap*?

    #v(2em)

    What would happen _without_ the *stack*?

    #v(2em)

    What would happen _without_ the *heap*?
  ],
  [
    #image("img/memory-layout.png", width: 75%)
  ],
)

= Compiling Vectors

This program defines and uses a `let`-bound vector `p`

```clojure
(let (p (vec 10 20))
  (+ (vec-get p 0) (vec-get p 1)))
```


1. What *stack slot* does `p` live in?

2. What *value* should we put in that slot?


= Representing Vectors

#grid(
  columns: (0.15fr, 0.5fr),
  gutter: 1em,
  [*Value*], [*Representation*],
  [`number`], [`xxx0`],
  [`false`], [`x011`],
  [`true`], [`x111`],
  [`nil`], [`1001`],
  [`(vec ...)`], [`0001`],
)


= TODO

```
[week6-heap-runtime]
- runtime
  - alloc
  - print

[week6-heap-compile-vec]
- compile: vec

[week6-heap-compile-get]
- compile: vec-get
```
