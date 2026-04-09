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
  title: "Worksheet 2B",
  authors: (
    (name: "NAME: _________________________ ", id: "SID: _________________________________"),
  ),
  info-box-enabled: false,
  score-box-enabled: false,
  date: datetime(year: 2026, month: 4, day: 9),
)

#quiz(name: "Semantics")[
  What should the following evaluate to?

  #grid(
    columns: (1fr, .5fr),
    gutter: 1.3em,
    [_Program_], [_Result_],
    ```rkt
    (if true 22 33)
    ```,
    [],

    ```rkt
    (if false 22 33)
    ```,
    [],

    ```rkt
    (let (x (if false 22 99))
      (if true (add1 x) 999))
    ```,
    [],
  )
]

#quiz(name: "Assembly")[
  Suppose `false` is `0` and `true` is `1`. Write the assembly code for

  #grid(
    columns: (.3fr, 0.01fr, .5fr),
    gutter: 1em,
    [_Program_], [], [_Assembly_],
    ```rkt
    (if true 22 33)
    ```,
    [],
    [
      ```asm
      mov rax, 1




      ```
    ],

    ```rkt
    (if false 22 33)
    ```,
    [],
    [
      ```asm
      mov rax, 0




      ```
    ],

    ```rkt
    (if cond e1 e2)
    ```,
    [],
    [
      ```asm
      ;; strategy for `if`






      ```
    ],
  )
]


#quiz(name: "Compiling Equality")[
  Suppose `false` is `0` and `true` is `1`. Write the assembly code for

  #grid(
    columns: (.3fr, 0.01fr, .5fr),
    gutter: 1em,
    [_Program_], [], [_Assembly_],
    ```rkt
    (= 10 20)
    ```,
    [],
    [
      ```asm
      mov rax, 10








      ```
    ],

    ```rkt
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

  *Update* `compile_expr` for `if`, `eq`, `+` to check tags for operands.
]

#quiz(name: "Your turn!")[

  What is something you found confusing in today's lecture (or earlier)?

  #rect(width: 100%, height: 3cm, stroke: 0.5pt)
]
