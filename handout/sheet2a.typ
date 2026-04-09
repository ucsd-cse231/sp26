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
  title: "Worksheet 2A",
  authors: (
    (name: "NAME: _________________________ ", id: "SID: _________________________________"),
  ),
  info-box-enabled: false,
  score-box-enabled: false,
  date: datetime(year: 2026, month: 4, day: 7),
)

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


#quiz(name: "Addition Semantics")[

  #grid(
    columns: (0.8fr, .5fr),
    gutter: 1.3em,
    [_Program_], [_Result_],

    ```rkt
    (+ (+ 1 2) (+ 3 4))
    ```,
    [
      ```rkt


      ```
    ],

    ```rkt
    (+ (let (x 10) (add1 x))
       (let (y 7) (+ x y)))
    ```,
    [
      ```rkt



      ```
    ],

    ```rkt
    (+ (let (x 10) (add1 x))
       (let (y 7) (+ 10 y)))
    ```,
    [
      ```rkt



      ```
    ],
  )
]

#quiz(name: "Stack Layout")[
  #grid(
    columns: (0.8fr, .5fr),
    gutter: 1.3em,
    [_Program_], [_Stack Layout_],

    ```rkt
    (+ (+ 1 2) 3)
    ```,
    [],

    ```rkt
    (let (x 10)
      (let (y 10)
        (+ x y)))
    ```,
    [],

    ```rkt
    (+ (let (x 10) (add1 x))
       (let (y 7) (+ 10 y)))
    ```,
    [],
  )
]

#quiz(name: "Assembly")[

  #grid(
    columns: (.2fr, 0.05fr, .5fr),
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
]

#quiz(name: "Your turn!")[

  What is something you found confusing in today's lecture (or earlier)?

  #rect(width: 100%, height: 3cm, stroke: 0.5pt)
]
