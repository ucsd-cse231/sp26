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

Lets change the compiler's _pipeline_ for register allocation.

#image("img/pipeline2.png", width: 120%)

Optimzation via three new steps:

1. *Transform* to ANF _intermediate representation_,
2. *Allocation* of variables to _registers_,
3. *Compile* using _allocation_.
