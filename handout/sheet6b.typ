#import "@preview/sheetstorm:0.4.0": *

#let quiz(name: none, ..args, body) = task(task-prefix: "Quiz", name: name, ..args, body)

#show raw.where(block: true, lang: "lisp"): it => block(
  stroke: 0.5pt + luma(150),
  inset: (x: 0.75em, y: 0.65em),
  radius: 2pt,
  width: 100%,
  it,
)

#show raw.where(block: true, lang: "asm"): it => block(
  stroke: 0.5pt + luma(150),
  inset: (x: 0.75em, y: 0.65em),
  radius: 2pt,
  width: 100%,
  it,
)

#show raw.where(block: true, lang: "sh"): it => block(
  stroke: 0.5pt + luma(150),
  inset: (x: 0.75em, y: 0.65em),
  radius: 2pt,
  width: 100%,
  it,
)

#show raw.where(block: true, lang: "rust"): it => block(
  stroke: 0.5pt + luma(150),
  inset: (x: 0.75em, y: 0.65em),
  radius: 2pt,
  width: 100%,
  it,
)

#show raw.where(block: true, lang: "clojure"): it => block(
  stroke: 0.5pt + luma(150),
  inset: (x: 0.75em, y: 0.65em),
  radius: 2pt,
  width: 100%,
  it,
)

#show: assignment.with(
  course: smallcaps[CSE 231 Spring 2026],
  title: "Worksheet 6B",
  authors: (
    (name: "NAME: _________________________ ", id: "SID: _________________________________"),
  ),
  info-box-enabled: false,
  score-box-enabled: false,
  date: datetime(year: 2026, month: 5, day: 5),
)

#quiz(name: "Semantics")[
  What should the following programs _evaluate_ to?

  #grid(
    columns: (0.55fr, 0.55fr),
    gutter: 0.5em,
    [*Program*], [*Result*],
    ```clojure
    nil
    ```,
    ```sh


    ```,

    ```clojure
    (vec (+ 5 5) (+ 10 10))
    ```,
    ```sh


    ```,

    ```clojure
    (let (p (vec 10 20)) (+ (head p) (tail p)))
    ```,
    ```sh


    ```,

    ```clojure
    (fun (sum l)
      (let (r 0)
      (loop
        (if (= l nil)
          (break r)
          (block (set! r (+ r (head l)))
                 (set! l (tail l)))))))

    (sum (vec 10 (vec 20 (vec 30 nil))))
    ```,
    ```sh










    ```,
  )
]

#quiz(name: "Abstract Syntax")[
  Write the _abstract syntax_ for our language.

  #grid(
    columns: (0.55fr, 0.55fr),
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
]

#quiz(name: "Evaluator Value")[
  How to extend `Val` and `eval` to support `vec`?

  // #grid(
  //   columns: (0.35fr, 0.75fr),
  //   gutter: 0.5em,
  //   ```rust
  //   enum Expr {
  //     Num(i32),
  //     Bool(bool),


  //   }
  //   ```,
  //   ```rust
  //   enum Val {
  //     Num(i32),
  //     Bool(bool),


  //   }
  //   ```,
  // )


  ```rust
  fn eval(e, env, funs) -> Val {
    match e {
      Expr::Nil         => { ____________________________ }

      Expr::Vec(e1, e2) => { ____________________________

                             ____________________________

                             ____________________________ }

      Expr::Get(e, i) =>   { ____________________________

                             ____________________________

                             ____________________________ }
  }
  ```
]

#colbreak()

#quiz(name: "Assembly")[

  Let's write the assembly code for evaluating `vec` and `vec-get`!

  #grid(
    columns: (0.2fr, 0.5fr),
    gutter: 0.5em,
    [*Program*], [*Assembly*],
    ```clojure
    nil
    ```,
    ```asm




    ```,

    ```clojure
    (vec 10 100)
    ```,
    ```asm






    ```,

    ```clojure
    (vec e1 e2)
    ```,
    ```asm







    ```,

    ```clojure
    (let (p (vec 10 100))
      (vec-get p 0))
    ```,
    ```asm
    ; <(vec 10 100)>






    ```,

    ```clojure
    (let (p (vec 10 100))
      (vec-get p 1))
    ```,
    ```asm
    ; <(vec 10 100)>






    ```,

    ```clojure
    (vec-get e idx)
    ```,
    ```asm
    ; <e>






    ```,
  )
]

#quiz(name: "Your turn!")[

  What is something you found confusing in today's lecture (or earlier)?

  #rect(width: 100%, height: 4cm, stroke: 0.5pt)
]
