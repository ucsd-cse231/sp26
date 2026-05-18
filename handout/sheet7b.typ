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
  title: "Worksheet 7B",
  authors: (
    (name: "NAME: _________________________ ", id: "SID: _________________________________"),
  ),
  info-box-enabled: false,
  score-box-enabled: false,
  date: datetime(year: 2026, month: 5, day: 14),
)

#quiz(name: "Definition and Call using Code-Label")[
  Fill in the assembly for defining and calling `inc`.

  #grid(
    columns: (1fr, 1fr),
    gutter: 0.5em,
    [*Definition:* `<(fun (inc_def x) (add1 x))>`], [*Call:* `<(inc 5)>` (where `inc` is at stack slot 2)],
    ```asm
    ; DEFINITION

    ___________________________________________
    fun_start_inc_def:
    push rbp
    mov rbp, rsp
    sub rsp, 8*1000

    ___________________________________________

    ___________________________________________
    mov rsp, rbp
    pop rbp
    ret

    ___________________________________________

    ___________________________________________
    ```,
    ```asm

    ___________________________________________

    ___________________________________________

    ___________________________________________

    ___________________________________________

    ___________________________________________









    ```,
  )
]

#quiz(name: "Definition and Call using (Arity, Code Label)")[
  Fill in the assembly for defining and calling `inc` using the (arity, code-label) representation.

  #grid(
    columns: (1fr, 1fr),
    gutter: 0.5em,
    [*Definition:* `<(fn (x y) (+ x y))>`], [*Call:* `<(inc 5)>`],

    ```asm

    ___________________________________________
    fun_start_#lambda_0:
    push rbp
    mov rbp, rsp
    sub rsp, 8*2
    mov rax, [rbp - 8*-2]
    add rax, [rbp - 8*-3]
    mov rsp, rbp
    pop rbp
    ret
    fun_finish_#lambda_0:

    ; 2. WRITE (arity, label) at [r11], [r11+8]
    ___________________________________________
    ___________________________________________
    ___________________________________________
    ___________________________________________

    ; 3. INCREMENT r11, and set/tag rax
    ___________________________________________
    ___________________________________________
    ___________________________________________


    ```,
    ```asm
    ; 1. compute/push params
    ___________________________________________
    ___________________________________________
    ; 2. LOAD `fn` from stack-slot into `rax`
    ___________________________________________
    ; 3. CHECK `rax` has function tag 0101
    ___________________________________________
    ___________________________________________
    ___________________________________________
    ___________________________________________
    ___________________________________________
    ___________________________________________
    ; 4. STRIP tag
    ___________________________________________
    ; 5. CHECK arity
    ___________________________________________
    ___________________________________________
    ___________________________________________
    ___________________________________________
    ___________________________________________
    ; 6. CALL code-label
    ___________________________________________
    ___________________________________________
    ___________________________________________
    ```,
  )
]

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

#quiz(name: "Call using Closure")[
  Fill in the assembly for the call `(inc 99)` where `inc` is a closure.

  ```asm
  ; push the args
  ___________________________________________
  ___________________________________________
  ; load closure pointer
  ___________________________________________
  ; check tag & arity & strip tag
  ___________________________________________
  ; get call-target
  ___________________________________________
  ; push "closure" as first arg!
  ___________________________________________
  ___________________________________________
  ; call!
  ___________________________________________
  ___________________________________________
  ```
]


#quiz(name: "Your turn!")[

  What is something you found confusing in today's lecture (or earlier)?

  #rect(width: 100%, height: 2cm, stroke: 0.5pt)
]

// #quiz(name: "Free Variables")[
//   Fill in the definition of `free` which computes the free variables of an expression.

//   ```rust
//   fn free(e: &Expr) -> im::HashSet<String> {
//     match e {
//       Num(_) | True | False | Input | Nil =>
//         _______________________________________

//       Add1(e) | Sub1(e) | Neg(e)
//       | Loop(e) | Break(e) | Print(e) | Get(e, _) =>
//         _______________________________________

//       Call1(x, e) | Set(x, e) =>
//         _______________________________________

//       If(e1, e2, e3) =>
//         _______________________________________

//       Bin(_, e1, e2) | Vec(e1, e2) =>
//         _______________________________________

//       Call2(f, e1, e2) =>
//         _______________________________________

//       Block(es) =>
//         _______________________________________

//       Var(x) =>
//         _______________________________________

//       Let(x, e1, e2) =>
//         _______________________________________

//       Defn(defn) =>
//         _______________________________________
//         _______________________________________
//   }
//   ```
// ]

// #quiz(name: "Your turn!")[

//   What is something you found confusing in today's lecture (or earlier)?

//   #rect(width: 100%, height: 4cm, stroke: 0.5pt)
// ]
