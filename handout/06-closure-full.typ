
= Closures

In a few steps, we will extend our language with the ability to treat functions as first-class values.

1. Labels
2. Anonymous functions
3. Arity
4. Free Variables
5. Recursion

== Part 1: Functions as Values

=== Test

```clojure
(fun (f it)
  (it 5))

(fun (inc x)
  (+ x 1))

(f inc)
```

=== Abstract Syntax

```rust
pub struct Defn {
  name: String,
  params: Vec<String>,
  body: Expr,
}

pub enum Expr { ...
    Fun(Defn),
}
```

=== Parser

No need for `Prog`! But need to change the parser, to produce a single `Expr` instead of a `Prog`.

```rust
fn prog(defns: Vec<Defn>, e: Expr) -> Expr {
  let mut e = e;
  for defn in defns.into_iter().rev() {
    let name = defn
            .name
            .clone()
            .unwrap_or_else(|| panic!("top-level fun missing name"));
     e = Expr::Let(name, Box::new(Expr::Defn(defn)), Box::new(e));
  }
  e
}
```

=== Evaluator

The type of `Val` is extended to include `Fun`

```rust
pub enum Val { ...
    Fun(Defn),
}
```

Extend `eval` to remove `funs` from the environment

```rust
fn eval(&self, e: &Expr, env: &mut Env) -> Val {
  match e {
    ...
    Expr::Defn(defn) => Ok(Val::Fun(defn.clone())),
    Expr::Call1(f, e1) => {
      let v1 = eval(e1, env)?;
      let Val::Fun(f_def) = env.get(f).unwrap() else {
        return Err(Err::TypeError(...))
      };
      let mut f_env = Env::new().update(f_def.params[0].clone(), v1);
      eval(&f_def.body, &mut f_env)
    }
    ...
  }
}
```

=== Compiler: Fun Call

```rust
Call1(f, e1) => {
  let Some(f_pos) = stack.get(f) else {
    panic!("ERROR: unbound variable `{f}`")
  };
  let e1_code = self.compile_expr(e1, stack, brk_lbl);
  format!(
    "{e1_code}\n\
     push rax\n\
     call [rbp - 8*{f_pos}]\n\
     add rsp, 8"
  )
}
Fun(defn) => self.compile_defn(defn),
```

=== Compiler: Fun Definition

```rust
fn compile_defn(&mut self, defn: &expr::Defn) -> String {
  let name = defn.name.clone();
  // labels
  let entry_label = entry_label(&name);
  let finish_label = finish_label(&name);
  let body_label = body_label(&name);
  // setup, body, exit
  let entry = compile_entry(&defn.body);
  let stack = Stack::new(&defn.params[..]);
  let body = self.compile_expr(&defn.body, &stack, &exit_label());
  let exit = compile_exit();
  // code
  format!(
    "jmp {finish_label}\n\
     {entry_label}:\n\
     {entry}\n\
     {body_label}:\n\
     {body}\n\
     {exit}\n\
     {finish_label}:\n\
     lea rax, [rel {entry_label}]"
  )
}
```

=== QUIZ: Stack Allocation

What is `max_vars` for a `Defn`?

== Part 2: Anonymous functions

Since `fun` are also `let`-bound values, we can just use `let` to name them. So we can write:

=== QUIZ: Semantics

What should the following code evaluate to?

```clojure
; anon function that takes `it` and returns `it 5`
(let (f   (fn (it) (it 5)))

; anon function that takes `z` and returns `(+ z 1)`
(let (inc (fn (z) (+ z 1)))

  (f inc)

))
```

=== Abstract Syntax

We just need to support *nameless* definitions, so we can reuse `Defn` with an optional name.

```rust
pub struct Defn {
  name: Option<String>,
  params: Vec<String>,
  body: Expr,
}
```

Update the parser to support `fn` as well as `fun`...

Evaluation, Compilation is unchanged!

== Part 3: Arity

But wait a minute... what if we call a function with the wrong number of arguments?

=== QUIZ: Semantics What should the following code evaluate to?

```clojure
(let (f   (fn (it)    (it 5)))

(let (add (fn (x1 x2) (+ x1 x2)))

  (f add)

))
```

=== Representation

Have to track the _arity_ of each function, i.e. the number of parameters it takes.

Store a *function value* as *pointer* to a `Vec`-like structure

- arity       (at [offset 0])
- code-label  (at [offset 8])

#grid(
  columns: (1in, 1in),
  rect(width: 100%, align(center, `arity`)),
  rect(width: 100%, align(center, `label`)),
)

*Problem* need to _distinguish_ this from _other_ values, e.g. `int` or `bool` or `vec`!

=== Tags

Modify tagging scheme for `vec` to use the `0101` tag for function values.

Leaves *other* types unchanged.

#grid(
  columns: (0.15fr, 0.5fr),
  gutter: 1em,
  [*Value*], [*Representation*],
  [`number`], [`xxx0`],
  [`false`], [`x011`],
  [`true`], [`x111`],
  [`nil`], [`1001`],
  [`(vec ...)`], [`0001`],
  [`(fun ...)`], [`0101`],
)

=== Runtime Types

```rust
pub enum Ty { ...
  Fun,
}

const CLOSURE: i64 = 5;

fn test_type(ty: Ty) -> String {
  let (mask, expected) = match ty {
    Ty::Num => (0b1, 0),
    Ty::Bool => (0b11, 3),
    Ty::Vec => (0b111, 1),
    Ty::Fun => (0b111, 5),
  };
  format!(
    "mov rcx, rax\n\
     and rcx, {mask}\n\
     cmp rcx, {expected}\n\
     mov rcx, {code}\n\
     cmovne rdi, rcx\n\
     jne label_error"
  )
}
```

=== Compiler: Call

```rust
fn compile_callee(f: &String, arity: usize) -> String {
  ...
  format!(
    "; load closure point\n\
     mov rax, [rbp - 8*{f_pos}]\n\
     {check_closure}\n\
     ; strip tag\n\
     mov rcx, rax\n\
     sub rcx, {CLOSURE}\n\
     ; check arity\n\
     mov rcx, [rcx]\n\
     cmp rcx, {arity}\n\
     mov rdx, 77\n\
     cmovne rdi, rdx\n\
     jne label_error")
  )
}
```

```rust
fn compile_expr(e: &Expr, stack: &Stack) -> String {
  match e {
    Call1(f, e1) => {
      let e1_code = self.compile_expr(e1, stack,...);
      let f_code = self.compile_callee(f, stack, 1);
      format!(
        "{e_code}\n\
         push rax\n\
         {f_code}\n\
         sub rax, {CLOSURE}\n\
         call rax\n\
         add rsp, 8")
    }
  }
}
```

=== Compiler: Definition

```rust
fn compile_defn(&mut self, defn: &expr::Defn) -> String {
    "jmp {finish_label}\n\
     {entry}\n\
     {body_label}:\n\
     {body}\n\
     {exit}\n\
     {finish_label}:\n\
     ; write arity \n\
     mov rcx, {arity}\n\
     mov [r11], rcx\n\
     ; write label \n\
     lea rcx, [rel {entry_label}]\n\
     mov [r11 + 8], rcx\n\
     ; set closure address\n\
     mov rax, r11\n\
     add r11, 16\n\
     add rax, {CLOSURE}"
}
```
== Part 4: Free Variables

== Part 5: Recursion
