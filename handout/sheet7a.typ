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
  title: "Worksheet 7A",
  authors: (
    (name: "NAME: _________________________ ", id: "SID: _________________________________"),
  ),
  info-box-enabled: false,
  score-box-enabled: false,
  date: datetime(year: 2026, month: 5, day: 12),
)

#quiz(name: "Semantics: Functions as Values")[
  What should the following programs _evaluate_ to?

  #grid(
    columns: (0.55fr, 0.55fr),
    gutter: 0.5em,
    [*Program*], [*Result*],
    ```clojure
    (fun (f it)
      (it 5))

    (fun (inc x)
      (+ x 1))

    (f inc)
    ```,
    ```sh




    ```,
  )
]

#quiz(name: "Evaluator")[
  Fill in the blanks to extend `eval` to handle function definitions and calls.

  ```rust
  fn eval(&self, e: &Expr, env: &mut Env) -> Val {
    match e {
      ...
      Expr::Defn(defn) =>
        ____________________________,
      Expr::Call1(f, e1) => {
        let v1 = eval(e1, env)?;

        ___________________________________________

        ___________________________________________

        ___________________________________________

        ___________________________________________

        ___________________________________________

      }
      ...
    }
  }
  ```
]

#quiz(name: "Compiler: Fun Call")[
  Fill in the blanks to compile function calls.

  ```rust
  Call1(f, e1) =>

    ___________________________________________

    ___________________________________________

    ___________________________________________



  ```
]


#quiz(name: "Semantics: Anonymous Functions")[
  What should the following program _evaluate_ to?

  #grid(
    columns: (0.55fr, 0.55fr),
    gutter: 0.5em,
    [*Program*], [*Result*],
    ```clojure
    ; anon function that takes `it`
    ; and returns `it 5`
    (let (f   (fn (it) (it 5)))

    ; anon function that takes `z`
    ; and returns `(+ z 1)`
    (let (inc (fn (z) (+ z 1)))

      (f inc)

    ))
    ```,
    ```sh




    ```,
  )
]

#quiz(name: "Semantics: Arity")[
  What should the following program _evaluate_ to?

  #grid(
    columns: (0.55fr, 0.55fr),
    gutter: 0.5em,
    [*Program*], [*Result*],
    ```clojure
    (let (f   (fn (it)    (it 5)))

    (let (add (fn (x1 x2) (+ x1 x2)))

      (f add)

    ))
    ```,
    ```sh




    ```,
  )
]

#quiz(name: "Your turn!")[

  What is something you found confusing in today's lecture (or earlier)?

  #rect(width: 100%, height: 4cm, stroke: 0.5pt)
]
