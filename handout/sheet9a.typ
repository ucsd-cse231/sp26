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
  title: "Worksheet 9A",
  authors: (
    (name: "NAME _________________________ ", id: ""),
    (name: "SID _________________________ ", id: ""),
  ),
  info-box-enabled: false,
  score-box-enabled: false,
  date: datetime(year: 2026, month: 5, day: 26),
)

#quiz(name: "Recursive Data")[


  #grid(
    columns: (0.23fr, 0.3fr),
    gutter: 1em,
    [
      #image("img/gc4.png", width: 100%)
    ],
    [
      What is the value of `l` at the point indicated by the red arrow?

      1. `0x30`
      2. `0x31`
      3. `0x50`
      4. `0x51`
      5. `0x60`

    ],
  )
]

#quiz(name: "Live Cells")[
  #grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    [
      #image("img/gc5.png", width: 90%)
    ],
    [
      #image("img/gc7.png", width: 90%)
    ],
  )
]

#quiz(name: "What should be printed?")[
  #image("img/gc6.png", width: 60%)
]

#colbreak()

#quiz(name: "Register Optimized Code")[

  #grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    [_Program_], [_Optimized Asm_],
    ```clojure
    (let ((a1 (+ 10 10))
          (a2 (* 2 a1))
          (a3 (* 3 a2)))
      (* 10 a3))


    ```,
    [
      ```asm






      ```
    ],

    ```clojure
    (let ((n (* 5 5))
          (m (* 6 6))
          (x (+ n 1))
          (y (+ m 1)))
        (+ x y))


    ```,
    [
      ```asm







      ```
    ],

    ```clojure
    (defn (f a)
      (let ((x (* a 2))
            (y (+ x 7)))
          y))


    ```,
    [
      ```asm
      ; a --> [rbp + 16]





      ```
    ],

    ```clojure
    (defn (f a)
      (let ((x (* a 2))
            (y (+ x 7)))
        (g x y)))


    ```,
    [
      ```asm
      ; a --> [rbp + 16]





      ```
    ],
  )
]

#quiz(name: "Your turn!")[

  What is something you found confusing in today's lecture (or earlier)?

  #rect(width: 100%, height: 5cm, stroke: 0.5pt)
]
