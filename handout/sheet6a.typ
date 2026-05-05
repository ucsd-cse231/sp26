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
  title: "Worksheet 6A",
  authors: (
    (name: "NAME: _________________________ ", id: "SID: _________________________________"),
  ),
  info-box-enabled: false,
  score-box-enabled: false,
  date: datetime(year: 2026, month: 5, day: 4),
)

// #show: assignment.with(
//   // course: smallcaps[CSE 231 Spring 2026],
//   title: "Worksheet 6B",
//   authors: (),
//   info-box-enabled: false,
//   score-box-enabled: false,
//   date: none,
// )

// #place(top + left, dy: -2.5cm)[
//   #text(size: 14pt, weight: "bold")[CSE 231 Spring 2026: Worksheet 6B]
// ]
// #place(top + right, dy: -2.5cm, rect(width: 7cm, height: 1.2cm, stroke: 1.5pt, inset: 0.5em)[
//   #align(top + left)[#text(size: 14pt, weight: "bold", fill: black)[Name:]]
// ])

#quiz(name: "Tail calls")[
  Circle the calls that are tail calls.

  #text(size: 0.75em)[
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
]

#quiz(name: "Which expressions can have tail calls?")[

  - *Circle* the expression that _can have_ tail calls
  - *Cross out* the expressions that _cannot have_ tail calls

  ```
  e ::= n | true | false | input | x | (add1 e) | (print e) | (+ e1 e2) | (= e1 e2)
      | (let (x e1) e2) | (if e1 e2 e3) | (set x e) | (block e1...en) | (loop e) | (break e)
      | (f e1) | (f e1 e2)
  ```
]

#quiz(name: "Identify Tail Calls")[

  #text(size: 0.75em)[
    ```rust
    fn compile_expr(e: &Expr, env: &Stack, funs: &FunEnv, lbl:&str, tr: bool) -> String {
      match e {
        Add1(e1) => {
          let e1_code = compile_expr(e1, env, funs, lbl,             );
          ...
        }
        Plus(e1, e2) => {
          let e1_code = compile_expr(e1, env, funs, lbl,         );
          let e2_code = compile_expr(e2, env, funs, lbl,         );
          ...
        }
        Let(x, e1, e2) => {
          let e1_code = compile_expr(e1, env, funs, lbl,         );
          let e2_code = compile_expr(e2, &newenv, funs, lbl,     );
          ...
        }
        If(cond, e_then, e_else) => {
          let cnd_code = compile_expr(e_cnd,  env, funs, lbl,        );
          let thn_code = compile_expr(e_then, env, funs, lbl,        );
          let els_code = compile_expr(e_else, env, funs, lbl,        );
          ...
        }
        Set(x, e) => {
          let e_code = compile_expr(e, env, funs, lbl,        );
          ...
        }
        Block(es) => {
          let n = es.len();
          let e_codes: Vec<String> = es.iter().enumerate()
              .map(|(i, e)| compile_expr(e, env, funs, lbl,         ))
              .collect();
          ...
        }
        Loop(e) => {
          let e_code = compile_expr(e, env, funs, &loop_exit,        );
          ...
        }
        Break(e) => {
          let e_code = compile_expr(e, env, funs, lbl,          );
          ...
        }
        Print(e) => {
          let e_code = compile_expr(e, env, funs, lbl,          );
          ...
        }
        Call2(f, e1, e2) => {
          let e1_code = compile_expr(e1, env, funs, lbl,        );
          let e2_code = compile_expr(e2, env, funs, lbl,        );
          ...
        }
      }
    }
    ```
  ]
]

#quiz(name: "Modify Assembly to Use `jmp` for Tail Calls")[

  // *Definitions*

  #text(size: 0.8em)[
    ```rust
    fn compile_defn(&mut self, defn: &expr::Defn) -> String {
      let label = entry_label(&defn.name);

      let entry = compile_entry(&defn.body);
      let stack = Stack::new(&defn.params[..]);
      let exit = exit_label();
      let body = self.compile_expr(&defn.body, &stack, &exit, true);
      let exit = compile_exit();
      format!(
        "{label}:\n\
         {entry}\n\

         {body}\n\
         {exit}"
      )
    }

    fn compile_expr(&mut self, e: &Expr, env: &Stack, lbl: &str, tr: bool) -> String {
      match e { // ...
        Call2(f, e1, e2) => {
          let e1_code = self.compile(e1, env, lbl, false);
          let e2_code = self.compile(e2, env, lbl, false);
          let call_code = if tr {
            format!(
              "{e1_code}\n\

               {e2_code}\n\



              "
            )
          } else { ... };
        }
      }
    }
    ```
  ]
]

#quiz(name: "Your turn!")[

  What is something you found confusing in today's lecture (or earlier)?

  #rect(width: 100%, height: 4cm, stroke: 0.5pt)
]
