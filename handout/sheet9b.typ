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
  title: "Worksheet 9B",
  authors: (
    (name: "NAME _________________________ ", id: ""),
    (name: "SID _________________________ ", id: ""),
  ),
  info-box-enabled: false,
  score-box-enabled: false,
  date: datetime(year: 2026, month: 5, day: 28),
)

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


#quiz(name: "Conflict Graphs")[

  Draw the *edges* between the *conflicting variables* for the code examples below
  #grid(
    columns: (.7fr, 1fr),
    gutter: 1em,
    [_Program_], [_Conflict Graph_],
    ```clojure
    (let ((a0 92))
          (a1 (+ a0 1))
          (a2 (+ a1 1))
          (a3 (+ a2 1))
          (a4 (+ a3 1))
          (a5 (+ a4 1)))
      a5)
    ```,
    ```asm
    a0        a1

    a2        a3

    a4        a5



    ```,

    ```clojure
    (let ((n (* 5 5))
          (m (* 6 6))
          (x (+ n 1))
          (y (+ m 1)))
        (+ x y))

    ```,
    [
      ```asm
      n        m



      y        x
      ```
    ],
  )
]

#colbreak()

#quiz(name: "Live Variables")[

  Lets identify the live/conflicts in the quiz above: after _each semicolon_ `;`
  fill in the names of the variables *live* at that point in the program.

  ```clojure
                            ;      LIVE Variables

                            ;
  (let (a0 92)
                            ;
   (let (a1 (+ a0 1))
                            ;
    (let (a2 (+ a1 1))
                            ;
     (let (a3 (+ a2 1))
                            ;
      (let (a4 (+ a3 1))
                            ;
       (let (a5 (+ a4 1))
                            ;
          a5))))))
  ```


  ```clojure
                            ;      LIVE Variables

                            ;
  (let (n (* 5 5))
                            ;
   (let (m (* 6 6))
                            ;
    (let (x (+ n 1))
                            ;
     (let (y (+ m 1))
                            ;
        (+ x y)))))
  ```
]

#quiz(name: "Your turn!")[

  What is something you found confusing in today's lecture (or earlier)?

  #rect(width: 100%, height: 5cm, stroke: 0.5pt)
]
