#import "@preview/codly:1.3.0": *
#import "tufte-handout.typ": margin-note, template

#show: codly-init.with()
#codly(
  number-format: none,
  zebra-fill: none,
  display-name: false,
)


#let show-toggle = false

#show raw.where(block: true): it => {
  if it.lang == "asm" {
    block(width: 100%, it)
  } else if it.lang == "asm-toggle" and show-toggle {
    let lines = it.text.split("\n")
    let new-lines = lines.map(line => if line.starts-with(";; ") { line.slice(3) } else { line })
    let new-text = new-lines.join("\n")
    set text(size: 1.25em)
    block(width: 100%, raw(new-text, lang: "asm", block: true))
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
  title: "CSE 231: Register Allocation",
  author: "Ranjit Jhala",
  date: "May 21, 2026",
  doc,
)

= Memory Hierarchy ...

Not all _memory_ is created equal!

#image("img/memory-latency.png", width: 120%)


= ... Stack is an Expensive Place to Store Values

#image("img/asm-opt.png", width: 110%)

*Much faster* to access _registers_ than _main memory_!

```
$ time ./test/reg_slow.fun.run 1000000000
97
Executed in    1.84 secs    ...

$ time ./test/reg_opt.fun.run 1000000000
97
Executed in  763.37 millis  ...
```

= Optimization: Register Allocation

Lets use *registers* instead of defaulting to *stack* storage.

Why is this tricky?

```asm











```

= QUIZ: Register Optimized Code


#grid(
  columns: (1fr, 1fr),
  gutter: 1em,
  [_Program_], [_Optimized Asm_],
  ```clojure
  (let ((a1 (+ 10 10))
        (a2 (* 2 a1))
        (a3 (* 3 a2)))
    (* 10 a3))


  ```,
  [
    ```asm-toggle
    ;; mov rax, 20
    ;; mov rbx, 40
    ;; mov rcx, 120
    ;; imul rax, rax, 10
    ;; imul rbx, rbx, 10

    ```
  ],

  ```clojure
  (let ((n (* 5 5))
        (m (* 6 6))
        (x (+ n 1))
        (y (+ m 1)))
      (+ x y))


  ```,
  [
    ```asm-toggle
    ;; mov rax, 5
    ;; add rax, 5
    ;; mov rbx, 6
    ;; mul rax, 6
    ;; add rax, 1
    ;; add rbx, 1
    ;; add rax, rbx
    ```
  ],

  ```clojure
  (defn (f a)
    (let ((x (* a 2))
          (y (+ x 7)))
        y))


  ```,
  [
    ```asm-toggle
    ; a --> [rbp + 16]
    ;;mov rax, [rbp + 16]
    ;; mul rax, 2
    ;; add rax, 7


    ```
  ],

  ```clojure
  (defn (f a)
    (let ((x (* a 2))
          (y (+ x 7)))
      (g x y)))


  ```,
  [
    ```asm-toggle
    ; a --> [rbp + 16]
    ;; mov rax, [rbp + 16]
    ;; mov rbx, rax
    ;; add rbx, 7


    ```
  ],
)

#colbreak()

= Optimization Relies on Variables?

What if the programmer _instead_ wrote code like

*Example 1*

```clojure
(* 10 (* 3 (* 2 (+ 10 10))))
```

*Example 2*

```clojure
(+ (+ (* 5 5) 1) (+ (* 6 6) 1))
```

*Example 3*

```clojure
(defn (f a)
  (+ (* a 2) 7))
```

Yikes, how to optimize without _names_?


= Register Optimization Pipeline

Change the compiler with 3 new steps.

#image("img/pipeline2.png", width: 120%)

1. *Transform* to ANF _intermediate representation_,
2. *Allocation* of variables to _registers_,
3. *Compile* using _allocation_.

= Administrative Normal Form (ANF) Transform

- *Immediate:* _constants or variable lookups_ whose values
  can be loaded with a single machine instruction

- *ANF:* every call or prim-op's arguments are _immediate_.

Step 1 transforms `(+ (+ (* 5 5) 1) (+ (* 6 6) 1))` to ANF

```clojure
(let ((n (* 5 5))
      (m (* 6 6))
      (x (+ n 1))
      (y (+ m 1)))
    (+ x y))
```

Lets look at these steps _backwards_ starting with Step 3 (compilation), then Step 2 (allocation), and finally, ANF transform lecture.

= Step 3: Allocation (Assigning Vars to Registers)

== Registers: Fast Storage for Variables

Some fixed set of registers that we can use to store variables.

```rust
enum Reg {
    RAX, RBX, RCX, RDX,
    R8, R9, R10, R11, ...
}
```

== Locations: Where to Store a Variable

A `Loc` is a _location_ where a variable can be stored,
- a _register_ or
- a _stack offset_

```rust
pub enum Loc {
  /// Register
  Reg(Reg),
  /// Stack local:  [rbp - 8 * offset]
  Stack(i32),
}
```

== Allocation: Mapping Variables to Locations

An `Alloc` is a mapping from variable names to `Loc`:

```rust
pub struct Alloc(HashMap<String, Loc>);
```

== Computing an Allocation

How to compute `Alloc` for a given function body (`Expr`)?

#image("img/pipeline3.png", width: 120%)

*Step 1:* Build _conflict graph_ over function variables

*Step 2:* Color variables so _adjacent vars have different_ colors.

#colbreak()

== 1. Conflict Graph

Undirected graph where:

- *Vertices* are _variables_
- *Edges* between `x`, `y` if both _must be available at same time_

#v(1em)

== QUIZ: Fill in the Conflict Graphs

#grid(
  columns: (.7fr, 1fr),
  gutter: 1em,
  [_Program_], [_Conflict Graph_],
  ```clojure
  (let ((a0 92))
        (a1 (+ a0 1))
        (a2 (+ a1 1))
        (a3 (+ a2 1))
        (a4 (+ a3 1))
        (a5 (+ a4 1)))
    a5)
  ```,
  ```asm-toggle
  ;; a0        a1

  ;; a2        a3

  ;; a4        a5



  ```,

  ```clojure
  (let ((n (* 5 5))
        (m (* 6 6))
        (x (+ n 1))
        (y (+ m 1)))
      (+ x y))

  ```,
  [
    ```asm-toggle
    ;; n --- m
    ;;   \ / |
    ;;    ╳  |
    ;;   / \ |
    ;; y --- x

    ```
  ],
)

== 2. Coloring

- Label each _vertex_ with a *color* (register)
- Ensuring *adjacent* vertices have *different* colors.

#margin-note[
  What if we _require_ $n$ colors, but only _have_ $r < n$ registers?
  *_Spill_* the remaining $n - r$ variables onto the stack!
]

#v(1em)
#grid(
  columns: (.4fr, .3fr, .3fr),
  gutter: 1em,
  [_Program_], [_Conflict Graph_], [_Coloring_],
  ```clojure
  (let ((n (5 * 5))
        (m (6 * 6))
        (x (n + 1))
        (y (m + 1))
        (z (x + y))
        (k (z * z))
        (g (k + 5)))
    (+ k 3))


  ```,
  [
    ```asm-toggle
    n --- m
      \ / |
       ╳  |
      / \ |
    y --- x
    |   /
    |  /
    | /
    z -- k -- g
    ```
  ],
  [
    ```
    VAR       REG
    -------------
    n   ---->
    m   ---->
    x   ---->
    y   ---->
    z   ---->
    k   ---->
    g   ---->
    ```
  ],
)



= Conflict Graph from Live Variables

We _stared_ at the code to find "conflicts". How to _automate_?

Vars `{x1...xn}` are *live for* `e` if we _need_ the values of `x1`...`xn` to evaluate `e`.

1. Identify *live variables* at each point,
2. Conflicts between *pairs of concurrently live* variables.


== QUIZ: Live Variables

Lets identify the live/conflicts in the quiz above.

```clojure
                          ;      LIVE Variables

                          ;
(let (a0 92)
                          ;
 (let (a1 (+ a0 1))
                          ;
  (let (a2 (+ a1 1))
                          ;
   (let (a3 (+ a2 1))
                          ;
    (let (a4 (+ a3 1))
                          ;
     (let (a5 (+ a4 1))
                          ;
        a5))))))
```


```clojure
                          ;      LIVE Variables

                          ;
(let (n (* 5 5))
                          ;
 (let (m (* 6 6))
                          ;
  (let (x (+ n 1))
                          ;
   (let (y (+ m 1))
                          ;
      (+ x y)))))
```

Similar to *free variables* for closure (but not quite same...)

== Implementing `live` in your compiler

Your compiler will implement a function

```rust
fn live(
 graph: &mut ConflictGraph, /// graph of edges
 e: &Expr,                  /// expression to analyze
 binds: &HashSet<String>,   /// let-binds outside e
 params: &HashSet<String>,  /// funparams (on stack)
 out: &HashSet<String>,     /// vars "LIVE" after `e`
) -> HashSet<String>        /// vars "LIVE" *before*
```

`graph` is `mut`: Add _conflict edges_ while traversing `e`.


= Step 2: Compilation

== Use Allocated Registers (not only `rax`)

Suppose that

- `imm1` and `imm2` _immediate_ values,
- `Alloc` maps `imm1` to `<imm1>` and `imm2` to `<imm2>`,
- we want to compile `(+ imm1 imm2)` to `<dst>`.

How to compile ANF code using the `Alloc` mapping?

#margin-note[What if `dst` is on the stack? What if `dst` is a register?]
#grid(
  columns: (.82fr, 1fr),
  gutter: 1em,
  [_ANF Code_], [_Compiled Asm_],
  ```clojure
  (+ imm1 imm2)
  ```,
  ```asm-toggle
  ;; mov rax, <imm1>
  ;; add rax, <imm2>
  ;; mov <dst>, rax


  ```,

  ```clojure
  (let ((a0 92))
        (a1 (+ a0 1))
        (a2 (+ a1 1))
        (a3 (+ a2 1))
        (a4 (+ a3 1))
        (a5 (+ a4 1)))
    a5)
  ```,
  ```asm-toggle
  ; ALLOC a0...a5 --> rax
  ;; mov rax, 92
  ;; add rax, 1
  ;; add rax, 1
  ;; add rax, 1
  ;; add rax, 1


  ```,
)

== Saving Registers

_Callee_ functions can overwrite _caller_ registers!

#margin-note[
  Starter code does "callee save"; beware calls into _runtime_.
]

*1. Callee saves* Each function saves & restores all of the registers it uses; callers do not have to store anything.

*2. Caller saves* Each caller saves & restores all of the registers it uses; callees do not have to store anything.

*3. Hybrid* Combine the two options; some registers are _caller-saved_ others are _callee-saved_
