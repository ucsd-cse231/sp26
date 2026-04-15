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

#show: assignment.with(
  course: smallcaps[CSE 231 Spring 2026],
  title: "Worksheet 2B",
  authors: (
    (name: "NAME: _________________________ ", id: "SID: _________________________________"),
  ),
  info-box-enabled: false,
  score-box-enabled: false,
  date: datetime(year: 2026, month: 4, day: 16),
)

#quiz(name: "Compiling Equality")[
  Suppose `false` is `0` and `true` is `1`. Write the assembly code for

  #grid(
    columns: (.3fr, 0.01fr, .5fr),
    gutter: 1em,
    [_Program_], [], [_Assembly_],
    ```lisp
    (= 10 20)
    ```,
    [],
    [
      ```asm
      mov rax, 10








      ```
    ],

    ```lisp
    (= e1 e2)
    ```,
    [],
    [
      ```asm
      ;; strategy for `eq`









      ```
    ],
  )
]

#quiz(name: "Compiler Tag Checking Strategy")[
  Write the asm to check if `rax`'s value has a given `<tag>`

  ```asm

  ______________________________; save rax

  ______________________________; extract LSB

  ______________________________; compare with <tag>

  ______________________________; jump to err if not-eq

  ```
]

#quiz(name: "Semantics of Blocks")[

  #grid(
    columns: (.4fr, .6fr),
    gutter: 0.5em,
    [_Program_], [_Result_],
    ```lisp
    (let (x 5)
      (set! x 10))
    ```,
    [```lisp



    ```],

    ```lisp
    (let (x 10)
      (let (y (set! x (+ x 5)))
        (+ x y))
    ```,
    [```lisp




    ```],

    ```lisp
    (let (x 5)
      (block
        (set! x (+ x 100))
        x))
    ```,
    [```lisp





    ```],
  )
]

#quiz(name: "Assembly for `set!` and `block`")[

  Complete the assembly code for

  #grid(
    columns: (.32fr, .5fr),
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
]


#quiz(name: "Your turn!")[

  What is something you found confusing in today's lecture (or earlier)?

  #rect(width: 100%, height: 3cm, stroke: 0.5pt)
]
