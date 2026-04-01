#import "@preview/sheetstorm:0.4.0": *

#let quiz(name: none, ..args, body) = task(task-prefix: "Quiz", name: name, ..args, body)

#show: assignment.with(
  course: smallcaps[CSE 231 Spring 2026],
  title: "Worksheet 1A",
  authors: (
    (name: "NAME: _________________________ ", id: "SID: _________________________________"),
  ),
  info-box-enabled: false,
  score-box-enabled: false,
  date: datetime(year: 2026, month: 3, day: 31),
)


#quiz(name: "Abstract Syntax")[
  The Adder language has the following concrete syntax

  ```
  <expr> :=
    | <number>
    | (add1 <expr>)
    | (sub1 <expr>)
    | (negate <expr>)
  ```

  Fill in the Rust `enum` for the abstract syntax of Adder

  ```rust
  enum Expr {
      _________________________________ ,   // numbers

      _________________________________ ,   // add1

      _________________________________ ,   // sub1

      _________________________________ ,   // negate
  }
  ```
]


#quiz(name: "Interpreter: Test")[
 
  What should the following evaluate to?

  ```
  eval( Add1(Box::new(Negate(Box::new(Sub1(Box::new(Num(3))))))) )  =  _______
  ```
]



#quiz(name: "Interpreter: Code")[
  Fill in the interpreter for Adder

  ```rust
  fn eval(e: &Expr) -> i32 {
      match e {
          Expr::Num(n)     =>  __________________________________________ ,

          Expr::Add1(e1)   =>  __________________________________________ ,

          Expr::Sub1(e1)   =>  __________________________________________ ,

          Expr::Negate(e1) =>  __________________________________________ ,
      }
  }
  ```
]

#pagebreak()

#quiz(name: "Code Generation")[
  Fill in the code generator. Recall: compiling an expression means generating
  instructions that leave the result in `rax`.

  ```rust
  fn compile_expr(e: &Expr) -> String {
      match e {
          Expr::Num(n)     => format!("mov rax, {}", *n),

          Expr::Add1(e1)   => compile_expr(e1) + _________________________ ,

          Expr::Sub1(e1)   => compile_expr(e1) + _________________________ ,

          Expr::Negate(e1) => compile_expr(e1) + _________________________ ,
      }
  }
  ```
]

#quiz(name: "Code Generation")[

  What assembly should we produce for `(sub1 (add1 (add1 10)))`?

  ```
  ___________________________________________

  ___________________________________________

  ___________________________________________
 
  ___________________________________________
 
  ___________________________________________
  ```
]


#quiz(name: "Your turn!")[

  What is something you found confusing in today's lecture (or earlier)?

  #rect(width: 100%, height: 5cm, stroke: 0.5pt)
]
