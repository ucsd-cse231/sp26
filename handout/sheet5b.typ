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
  title: "Worksheet 5B",
  authors: (
    (name: "NAME: _________________________ ", id: "SID: _________________________________"),
  ),
  info-box-enabled: false,
  score-box-enabled: false,
  date: datetime(year: 2026, month: 4, day: 30),
)

#place(top + right, rect(width: 7cm, height: 2cm, stroke: 1.5pt, inset: 0.5em)[
  #text(size: 14pt, weight: "bold")[Name:]
])

#v(1.5cm)

// #quiz(name: "What happens when we run?")[

//   #grid(
//     columns: (0.65fr, 0.5fr),
//     row-gutter: 1.0em,
//     column-gutter: 1.3em,
//     [_Program_], [_Result_],

//     ```clojure
//     (fun (foo n)
//       (if (<= n 0)
//         99
//         (foo (sub1 n))
//       )
//     )

//     (foo input)
//     ```,
//     ```sh
//     $ make foo.run

//     $ ./foo.run 100
//     _____________________

//     $ ./foo.run 1000000
//     _____________________


//     ```,

//     ```clojure
//     (fun (sum n acc)
//       (if (= n 0)
//         0
//         (+ n (sum (sub1 n)))
//       )
//     )

//     (sum input)
//     ```,
//     ```sh
//     $ make sum.run

//     $ ./sum.run 100
//     _____________________

//     $ ./sum.run 1000000
//     _____________________


//     ```,
//   )
// ]


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

#quiz(name: "How many stack frames?")[

  How many stack frames are created when we run `(sum 1000000)`? `_____________________`
]


#quiz(name: "Tail calls")[
  Circle the calls that are tail calls.

  ```clojure
  (fun (fac n acc)
    (if (= n 0)
      acc
      (if (= n 2)
          (* 2 (fac (sub1 n) (* acc n)))
          (fac (sub1 n) (* acc n))
      )
    )
  )
  ```
]

#quiz(name: "Which expressions can have tail calls?")[

  - *Circle* the expression that _can have_ tail calls
  - *Cross out* the expressions that _cannot have_ tail calls

  ```
  e ::= n | true | false | input | x | (add1 e) | (print e)
      | (+ e1 e2) | (= e1 e2)
      | (let (x e1) e2) | (if e1 e2 e3)
      | (set x e) | (block e1...en)
      | (loop e) | (break e)
      | (f e1) | (f e1 e2)
  ```
]

#colbreak()

#quiz(name: "Modify assembly to reuse stack frame")[

  Given the source:

  ```clojure
  (fun (helper n acc)
    (if (= n 0)
      acc
      (helper (sub1 n) (+ acc n))))
  ```

  #grid(
    columns: (0.65fr, 0.5fr),
    row-gutter: 1.0em,
    column-gutter: 1.3em,
    [*Original Assembly*], [*Optimized Assembly*],
    text(size: 0.867em)[
      ```asm
      fun_start_helper:
      push rbp               ; SETUP FRAME
      mov rbp, rsp
      sub rsp, 8*3

      mov rax, [rbp - 8*-2]  ; IF (= n 0)
      mov [rbp - 8*1], rax
      mov rax, 0
      cmp rax, [rbp - 8*1]
      mov rcx, 3
      mov rdx, 1
      cmove  rax, rcx
      cmovne rax, rdx
      cmp rax, 1
      je if_false_0          ; THEN BRANCH
      if_true_0:
      mov rax, [rbp - 8*-3]
      jmp if_exit_0
      if_false_0:            ; ELSE BRANCH
      mov rax, [rbp - 8*-2]
      sub rax, 2
      mov [rbp - 8*1], rax   ; (sub1 n)
      mov rax, [rbp - 8*-3]
      mov [rbp - 8*2], rax
      mov rax, [rbp - 8*-2]
      add rax, [rbp - 8*2]   ; (+ acc n)

      push rax               ; (helper ..)
      mov rax, [rbp - 8*1]
      push rax
      call fun_start_helper
      add rsp, 16
      if_exit_0:

      mov rsp, rbp           ; TEARDOWN FRAME
      pop rbp
      ret
      ```
    ],
    ```asm


    ; here?




















    ? here?









    ```,
  )
]



#quiz(name: "Your turn!")[

  What is something you found confusing in today's lecture (or earlier)?

  #rect(width: 100%, height: 3cm, stroke: 0.5pt)
]
