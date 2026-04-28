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
  title: "Worksheet 5A",
  authors: (
    (name: "NAME: _________________________ ", id: "SID: _________________________________"),
  ),
  info-box-enabled: false,
  score-box-enabled: false,
  date: datetime(year: 2026, month: 4, day: 23),
)




#quiz(name: "Semantics of functions")[

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
]

#quiz(name: "Assembly: Caller")[

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
]

#quiz(name: "Assembly: Callee")[

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

    ```clojure
    (fun (go n acc)
      (if (= n 0)
        acc
        (go (sub1 n) (+ acc n))
      )
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
]


#quiz(name: "Frame Allocation")[
  How many stack slots do the following functions need to allocate for their frames?

  #grid(
    columns: (.5fr, .5fr),
    gutter: 1.3em,
    [_Program_], [_Stack Slots_],

    ```clojure
    (fun (incr n)
      (let (x1 (add1 n))
      (let (x2 (add1 x1))
        x2)))
    ```,
    ```asm





    ```,

    ```clojure
    (fun (incr n)
      (let (x1 (add1 n))
      (if (= n 99)
        x1
        (let (x2 (add1 x1))
          (+ x1 x2))))
    ```,
    ```asm







    ```,
  )

]

#quiz(name: "Your turn!")[

  What is something you found confusing in today's lecture (or earlier)?

  #rect(width: 100%, height: 3cm, stroke: 0.5pt)
]
