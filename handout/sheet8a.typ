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
  title: "Worksheet 8A",
  authors: (
    (name: "NAME _________________________ ", id: ""),
    (name: "SID _________________________ ", id: ""),
  ),
  info-box-enabled: false,
  score-box-enabled: false,
  date: datetime(year: 2026, month: 5, day: 19),
)


#quiz(name: "Definition: Function Body and Closure Vector")[
  Fill in the assembly for the _function body_ and _closure vector_ for `(fn (x) (+ x one))` where `one` is a free variable.

  #grid(
    columns: (1fr, 1fr),
    gutter: 0.5em,
    [*Function Body*], [*Closure Vector* (arity, label, num-free, free-values)],
    ```asm
    jmp fun_finish_#lambda_0
    fun_start_#lambda_0:
    ; setup
    push rbp
    mov rbp, rsp
    sub rsp, 8*3
    ; load free variables ... from where?

    ___________________________________________

    ___________________________________________

    ___________________________________________

    ___________________________________________
    ; <(+ x one)>
    ___________________________________________

    ___________________________________________
    ; teardown
    mov rsp, rbp
    pop rbp
    ret
    fun_finish_#lambda_0:
    ```,
    ```asm
    ; write arity
    ___________________________________________

    ___________________________________________
    ; write label
    ___________________________________________

    ___________________________________________

    ; write number of free vars (why?)
    ___________________________________________

    ___________________________________________

    ; write free vars
    ___________________________________________

    ___________________________________________

    ; bump r11 and set/tag rax
    mov rax, r11

    add r11, _________________ ; how much?
    add rax, 5
    ```,
  )
]

#quiz(name: "Fill in the Asm for `(inc 99)`")[
  ```asm
  ___________________________________________ ; push the args

  ___________________________________________

  ___________________________________________ ; load the closure pointer

  ___________________________________________ ; check tag & arity & strip tag

  ___________________________________________

  ___________________________________________ ; get call-target

  ___________________________________________ ; push "closure" as first arg!

  ___________________________________________

  ___________________________________________ ; call!

  ___________________________________________
  ```
]


#quiz(name: "Free Variables")[
  Fill in the definition of `free` which computes the free variables of an expression.

  ```rust
  fn free(e: &Expr) -> im::HashSet<String> {
    match e {
      Num(_) | True | False | Input | Nil =>
        _______________________________________

      Add1(e) | Sub1(e) | Neg(e)
      | Loop(e) | Break(e) | Print(e) | Get(e, _) =>
        _______________________________________

      Call1(x, e) | Set(x, e) =>
        _______________________________________

      If(e1, e2, e3) =>
        _______________________________________

      Bin(_, e1, e2) | Vec(e1, e2) =>
        _______________________________________

      Call2(f, e1, e2) =>
        _______________________________________

      Block(es) =>
        _______________________________________

      Var(x) =>
        _______________________________________

      Let(x, e1, e2) =>
        _______________________________________

      Defn(defn) =>
        _______________________________________
        _______________________________________
  }
  ```
]

#quiz(name: "Your turn!")[

  What is something you found confusing in today's lecture (or earlier)?

  #rect(width: 100%, height: 5cm, stroke: 0.5pt)
]
