#import "@preview/codly:1.3.0": *
#import "tufte-handout.typ": margin-note, template

#show: codly-init.with()
#codly(
  number-format: none,
  zebra-fill: none,
  display-name: false,
)

#let show-asm-toggle = false

#show raw.where(block: true): it => {
  if it.lang == "asm" {
    // set text(size: 0.8em)
    block(width: 100%, it)
  } else if it.lang == "asm-toggle" and show-asm-toggle {
    let lines = it.text.split("\n")
    let new-lines = lines.map(line => if line.starts-with(";; ") { line.slice(3) } else { line })
    let new-text = new-lines.join("\n")
    set text(size: 1.25em)
    block(width: 100%, raw(new-text, lang: "asm", block: true))
    // raw(it.text, lang: "asm", block: true)
  } else if it.lang == "asm-toggle" {
    set text(size: 1.25em)
    let lines = it.text.split("\n")
    let new-lines = lines.map(line => if line.starts-with(";;") { " " } else { line })
    let new-text = new-lines.join("\n")
    block(width: 100%, raw(new-text, lang: "asm", block: true))
  } else {
    block(width: 100%, it)
  }
}

#set page(footer: context align(center, text(size: 7pt, counter(page).display("1"))))

#show: doc => template(
  title: "CSE 231: Functions as Values in Asm",
  author: "Ranjit Jhala",
  date: "May 14, 2026",
  doc,
)

= Closures

Lets compile functions as *first-class values*. The key challenge: what is the _the value of a function_?

*Problem 1: Definitions*

What is _value_ of `rax` after executing `< (fun (f x) e) >` ?

*Problem 2: Calls*

How can we _use_ the value to _call_ a function value ?

= Example 00: Let-binding Functions

Lets write assembly for

```clojure
(let (inc                          ; 2. BIND-TO-NAME
       (fun (inc_def x) (add1 x))  ; 1. DEFINITION
      )
   (inc 5))                        ; 3. CALL
```

At a high level, the assembly will look like this:

```asm
our_code_starts_here:
push rbp              ; ----------STACK SETUP
mov rbp, rsp
sub rsp, 8*1000
mov [rbp - 8*1], rdi  ; save input
mov r11, rsi          ; save heap-pointer

; 1. DEFINITION <(fun (inc x) (add1 x))>

; 2. BIND-TO-NAME <(let (inc ...) ...)>

; 3. CALL <(inc 5)>

our_code_ends_here:   ; ----- STACK TEARDOWN
mov rsp, rbp
pop rbp
ret
```

#colbreak()

= Idea 1: Function = Code Label

*Idea* Lets try to use the _code label_ of the function as its value.

1. *Define* compile code for `inc`, save _entry-label_ in `rax`;
2. *Bind* by saving value of `rax` at stack slot for `inc`;
3. *Call* By `call`-ing the label stored at stack slot for `inc`.


== QUIZ: Definition

Assembly for `<(fun (inc_def x) (add1 x))>`

```asm-toggle
; DEFINITION for `<(fun (inc_def x) (add1 x))>`
;; jmp fun_finish_inc_def
fun_start_inc_def:
push rbp
mov rbp, rsp
sub rsp, 8*1000
;; mov rax, [rbp - 8*-2]
;; add rax, 2
mov rsp, rbp
pop rbp
ret
;; fun_finish_inc_def:
;; lea rax, [rel fun_start_inc_def]
```

== Example: Bind-to-Name

Assembly for `<let (inc ...)>`

```asm
mov [rbp - 8*2], rax  ; `inc` @ stack slot 2
```

== QUIZ: Call

Assembly for `<(inc 5)>`

```asm-toggle
;; mov rax, 10
;; push rax
;; call [rbp - 8*2]
;; add rsp, 8


```


= Example 01: Nameless Functions

Why *name* the `inc_def` function? How would `asm` change?

```clojure
(let (inc                 ; 2. BIND-TO-NAME
       (fn (x) (add1 x))  ; 1. ANONYMOUS-DEFINITION
      )
   (inc 5))               ; 3. CALL
```


= Example 02: Code Label is Not Enough!

Lets apply our strategy to the below code.

```clojure
(let (inc                   ; 2. BIND-TO-NAME;
       (fn (x y) (+ x y)))  ; 1. ANONYMOUS-DEFINITION
   (inc 5))                 ; CALL
```

Or even this code

```clojure
(let (inc 0)
   (inc 5))
```



What might go wrong?

What _other_ information is needed about `inc`'s *definition*?

= Idea 2: Function = (Arity, Code Label)

When compiling a call `(f e1 ... en)` we need to know

1. That `f` is a _function_, and not, e.g. a number,
2. That the function's _arity_ equals the number of arguments.

*Idea* Represent function as a pair of its _arity_ and _code label_.

#grid(
  columns: (1in, 1in),
  rect(width: 100%, align(center, `arity`)), rect(width: 100%, align(center, `code-label`)),
)

Store a *function value* as *pointer* to a `Vec`-like structure

- `arity`       (at [offset 0])
- `code-label`  (at [offset 8])


*Problem* how to _distinguish_ from _other_ `vec`-like values?

= Tags

Modify last-4-bits tagging scheme to use `0101` for functions.

(*Other* types unchanged.)

#grid(
  columns: (0.15fr, 0.5fr),
  gutter: 1em,
  // align: center,
  [*Value*], [*4 LSB*],
  [`number`], [`xxx0`],
  [`false`], [`x011`],
  [`true`], [`x111`],
  [`nil`], [`1001`],
  [`(vec ...)`], [`0001`],
  [`(fun ...)`], [`0101`],
)

#colbreak()

= Runtime Type Checking

Lets recompile using our new representation

```clojure
(let (inc                   ; 2. BIND-TO-NAME;
       (fn (x y) (+ x y)))  ; 1. ANONYMOUS-DEFINITION
   (inc 5))                 ; CALL
```

The high-level assembly will still be the same

```asm
; 1. DEFINITION   <(fn (x y) (+ x y))>
; 2. BIND-TO-NAME <(let (inc ...) ...)>
; 3. CALL         <(inc 5)>
```

== QUIZ: Definition using (Arity, Code Label)

Complete the `asm` for `<(fn (x y) (+ x y))>`.

Use `r11` to fill in the `arity` and `code-label` fields.

Then set the tag before assigning into `rax`.

```asm-toggle
; 1. CODE FOR (fn (x y) (...))
;; jmp fun_finish_#lambda_0          ; skip function
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



; 2. WRITE (arity, label) at [r11], [r11 + 8]
;; mov rcx, 2
;; mov [r11], rcx
;; lea rcx, [rel fun_start_#lambda_0]
;; mov [r11 + 8], rcx

; 3. INCREMENT r11, and set/tag rax
;; mov rax, r11
;; add r11, 16
;; add rax, 5


```


== QUIZ: Call using (Arity, Code Label)

What asm would we get for `<(inc 5)>`?

Lets _use_ the tag + arity to check `inc` is a function that takes the given number of parameters.

```asm-toggle
; 1. compute/push params
;; mov rax, 10
;; push rax

; 2. LOAD `fn` from stack-slot into `rax`
;; mov rax, [rbp - 8*2]

; 3. CHECK `rax` has function tag 0101
;; mov rcx, rax
;; and rcx, 7
;; cmp rcx, 5
;; mov rcx, 88            ; not a function error
;; cmovne rdi, rcx
;; jne label_error

; 4. STRIP tag
;; sub rax, 5

; 5. CHECK arity
;; mov rcx, [rax]
;; cmp rcx, 1
;; mov rdx, 77            ; arity mismatch error
;; cmovne rdi, rdx
;; jne label_error

; 6. CALL code-label
;; mov rax, [rax+8]
;; call rax
;; add rsp, 8

```

Now, instead of `SEGFAULT`-ing if we call a non-function, or use the wrong number of params, we abort appropriately.

= Free Variables

What if the function uses variables that are *not* parameters?

```clojure
(let (one 1)
(let (inc (fn (x) (+ x one)))
   (inc 99)
))
```

== Problem: "Free" Variables

The variable `one` is _free_ in the body of `inc`.

- It is not a _parameter_ of the function,
- It is not _let-bound_ in the function.

Where do we get its value from?

= Idea 3: Function = (Arity, Code Label, Free Vars)

Let's *package* the values of the free variables with function.


*Idea* Extend our "vec-like" function representation to _package_ the values of free variables together with the code label and arity.

#grid(
  columns: (0.9in, .9in, .9in, .9in, .9in, .9in),
  rect(width: 100%, align(center, `arity`)),
  rect(width: 100%, align(center, `code-label`)),
  rect(width: 100%, align(center, `#vars (n)`)),
  rect(width: 100%, align(center, `fv_1`)),
  rect(width: 100%, align(center, `...`)),
  rect(width: 100%, align(center, `fv_n`)),
)


- _arity_ : the number of parameters, (offset 0)
- _code label_ : the entry point of the function's code (offset 8),
- _number of_ : free variables : in the body (offset 16).
- _values of_ : free variables in the body (offset 24...).

Let's try to compile using this new representation.

```clojure
(let (one 1)                ; 1. BIND   `one`
(let (inc                   ; 3. BIND   `inc`
       (fn (x) (+ x one)))  ; 2. DEFINE `fn (x) ...`
   (inc 99)                 ; 4. CALL   `inc`
))
```

How will the `DEFINE` code change?


```








```


How will the `CALL` code change?

```








```

The assembly for the above will look like

```asm
mov qword ptr [rbp - 8*2], 2    ; <(let (one ...))>
; 1. DEFINE: <(fn (x) (+ x one))>
;   1a. CODE for `fn (x) ...`
;   1b. CODE for closure-vector
mov [rbp - 8*3], rax            ; <(let (inc ...))>
; 2. CALL <(inc 99)>
```

As before the `DEFINE` will have two parts

- the code for the _function body_, and
- the code to create the _closure-vector_ on the heap.


== QUIZ: Definition's Function Body

Fill in the code for the _function body_ for `fn (x) (+ x one)`.

```asm-toggle
jmp fun_finish_#lambda_0
fun_start_#lambda_0:
; setup
push rbp
mov rbp, rsp
sub rsp, 8*3

; load free variables ... from where?
;; mov rax, [rbp + 16]
;; sub rax, 5
;; mov rcx, [rax + 8*3]
;; mov [rbp - 8*1], rcx

; <(+ x one)>
;; mov rax, [rbp - 8*-3]
;; add rax, [rbp - 8*1]

; teardown
mov rsp, rbp
pop rbp
ret
fun_finish_#lambda_0:
```

== QUIZ: Definition's Closure Vector

Next, lets fill in the definition of the closure vector itself.

Recall, there are _four_ parts

1. _Arity_
2. _Code-label_
3. _Number_ of free vars  (*how* do we know which ones?)
4. _Values_ of free vars  (*where* do these values live?)

```asm-toggle
; write arity
mov rcx, 1
mov [r11], rcx

; write label
lea rcx, [rel fun_start_#lambda_0]
mov [r11 + 8], rcx

; write free arity
mov rcx, 1
mov [r11 + 16], rcx

; write free vars
mov rcx, [rbp - 8*2]
mov [r11 + 24], rcx

; bump r11 and set/tag rax to closure address
mov rax, r11
add r11, 32
add rax, 5
```

== QUIZ: Call using Closure

Fill in the assembly for the *call* `(inc 99)`

- What is the call-target?
- What are the params?


```asm-toggle
; push the args
;; mov rax, 198
;; push rax        ; push 1-th arg
; load closure pointer
;; mov rax, [rbp - 8*3]
; check tag & arity & strip tag
;; sub rax, 5
; get call-target
;; mov rbx, [rax+8]
; push "closure" as first arg!
;; add rax, 5
;; push rax
; call!
;; call rbx
;; add rsp, 16
```

#colbreak()

= How to determine which variables are "free"?

```rust
fn free_vars_defn(defn: &Defn) -> Vec<String> {
  let expr = Defn(defn.clone()));
  let vars = free(&expr);
  let mut vars = vars.into_iter().collect();
  vars.sort(); vars.dedup();
  vars
}
```

== QUIZ: Fill in the definition of `fv`

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

= Recursion

What problems do _you_ anticipate with recursive functions?

```asm












```




How might _you_ solve them?

```asm












```
