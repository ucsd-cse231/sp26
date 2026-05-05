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
  title: "Worksheet 4B",
  authors: (
    (name: "NAME: _________________________ ", id: "SID: _________________________________"),
  ),
  info-box-enabled: false,
  score-box-enabled: false,
  date: datetime(year: 2026, month: 4, day: 23),
)




#quiz(name: "Semantics of print")[

  #grid(
    columns: (1fr, .5fr),
    row-gutter: 1.0em,
    column-gutter: 1.3em,
    [_Program_], [_Expected Output_],
    ```clojure
    (print 42)
    ```,
    ```


    ```,

    ```clojure
    (let (x1 100)
    (let (x2 200)
      (block
        (print x1)
        (print x2))))
    ```,
    ```





    ```,
  )
]

#quiz(name: "Assembly for print")[

  #grid(
    columns: (.5fr, 1fr),
    row-gutter: 1.0em,
    column-gutter: 1.3em,
    [_Program_], [_Assembly_],

    ```clojure
    (print 42)
    ```,

    ```asm




    ```,

    ```clojure
    (print e)
    ```,

    ```asm




    ```,
  )
]

#quiz(name: "Passing parameters with rdi")[

  _Like_ with `snek_error`, we used `rdi` to pass the param to `snek_print`.

  _Unlike_ with `snek_error`, we're coming back!

  Can you write a test that will _break_ our compiler?

  #rect(width: 100%, height: 3cm, stroke: 0.5pt)
]

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
  )
]

#quiz(name: "Your turn!")[

  What is something you found confusing in today's lecture (or earlier)?

  #rect(width: 100%, height: 3cm, stroke: 0.5pt)
]
