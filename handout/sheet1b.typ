#import "@preview/sheetstorm:0.4.0": *

#let quiz(name: none, ..args, body) = task(task-prefix: "Quiz", name: name, ..args, body)

#show raw.where(block: true, lang: "rkt"): it => block(
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

#show: assignment.with(
  course: smallcaps[CSE 231 Spring 2026],
  title: "Worksheet 1B",
  authors: (
    (name: "NAME: _________________________ ", id: "SID: _________________________________"),
  ),
  info-box-enabled: false,
  score-box-enabled: false,
  date: datetime(year: 2026, month: 4, day: 2),
)

#quiz(name: "Code Generation")[

  What assembly should we produce for `(sub1 (add1 (add1 10)))`?

  ```
  __________________________________________________________________________

  __________________________________________________________________________

  __________________________________________________________________________

  __________________________________________________________________________


  ```
]

#quiz(name: "Abstract Syntax")[
  Fill in the Rust `enum` for the abstract syntax of Boa

  ```rust
  enum Expr {
      _________________________________ ,   // numbers

      _________________________________ ,   // add1

      _________________________________ ,   // sub1

      _________________________________ ,   // let-bindings

      _________________________________ ,   // variables
  }
  ```
]


#quiz(name: "Semantics")[

  #grid(
    columns: (0.8fr, 1fr),
    gutter: 1.3em,

    [_Program_], [_Result_],

    ```rkt
    (let (x 10)
      (let (y (add1 x))
        (let (z (add1 y))
          (add1 z))))
    ```,
    [],

    ```rkt
    (let (x 10)
      (let (x (add1 x))
        (add1 x))))
    ```,
    [],

    ```rkt
    (let (a 1)
      (let (c
        (let (b (add1 a))
          add1(b)))
      add1 c))
    ```,
    [],
  )
]

#pagebreak()

#quiz(name: "Variable Storage")[

  #grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    [_Program_], [_Number of variables_],
    ```rkt
    (let (x 10)
      (let (y (add1 x))
        (let (z (add1 y))
          (add1 z))))
    ```,
    [],

    ```rkt
    (let (a 1)
      (let (c
        (let (b (add1 a))
          add1(b)))
      add1 c))
    ```,
    [],
  )
]


#quiz(name: "Stack Position")[

  Which stack position do we store `c` in this program?

  ```rkt
    (let (a 1)
      (let (c
        (let (b (add1 a))
          add1(b)))
      add1 c))
  ```
]

#quiz(name: "Assembly")[

  #grid(
    columns: (.5fr, 0.05fr, .5fr),
    gutter: 1em,
    [_Program_], [], [_Assembly_],
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
]

#quiz(name: "Your turn!")[

  What is something you found confusing in today's lecture (or earlier)?

  #rect(width: 100%, height: 3cm, stroke: 0.5pt)
]
