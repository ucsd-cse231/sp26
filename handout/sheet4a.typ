#import "@preview/sheetstorm:0.4.0": *

#let quiz(name: none, ..args, body) = task(task-prefix: "Quiz", name: name, ..args, body)

#let examples(col2) = grid(
  columns: (1fr, 1fr),
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
  title: "Worksheet 4A",
  authors: (
    (name: "NAME: _________________________ ", id: "SID: _________________________________"),
  ),
  info-box-enabled: false,
  score-box-enabled: false,
  date: datetime(year: 2026, month: 4, day: 21),
)

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

#quiz(name: "Semantics of loop and break")[

  #examples("Result")

]

#quiz(name: "Assembly for loop and break")[

  Lets _complete_ the assembly code for

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
]

#quiz(name: "Your turn!")[

  What is something you found confusing in today's lecture (or earlier)?

  #rect(width: 100%, height: 3cm, stroke: 0.5pt)
]
