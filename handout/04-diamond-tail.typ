#import "@preview/codly:1.3.0": *
#import "tufte-handout.typ": margin-note, template

#show: codly-init.with()
#codly(
  number-format: none,
  zebra-fill: none,
  display-name: false,
)
#show raw.where(block: true): it => {
  if it.lang == "asm" {
    set text(size: 0.8em)
    block(inset: (x: 0.75em, y: 0.65em), width: 100%, it)
  } else {
    block(inset: (x: 0.75em, y: 0.65em), width: 100%, it)
  }
}

#set page(footer: context align(center, text(size: 7pt, counter(page).display("1"))))

#let examples(col2) = grid(
  columns: (1fr, .5fr),
  row-gutter: 0.5em,
  column-gutter: 1.3em,
  [_Program_], [_#(col2)_],

  ```lisp
  (let (x 5)
    (set! x 10))
  ```,
  [],

  {
    ```lisp
    (let (x 10)
      (let (y (set! x (+ x 5)))
        (+ x y))
    ```
  },
  [],

  ```lisp
  (let (x 5)
    (block
      (set! x (+ x 100))
      x))
  ```,
  [],
)


#show: doc => template(
  title: "CSE 231: Functions",
  author: "Ranjit Jhala",
  date: "April 16, 2026",
  doc,
)

= Functions

#codly(highlights: (
  (line: 2, start: 8, end: 12, fill: yellow.lighten(0%)),
  (line: 3, start: 5, end: 7, fill: purple.lighten(0%)),
  (line: 4, start: 6, end: 8, fill: orange.lighten(0%)),
  (line: 4, start: 11, end: 16, fill: green.lighten(0%)),
  (line: 4, start: 20, end: 26, fill: blue.lighten(0%)),
))
```clojure
(fun (sum n acc)
  (if (= n 0)
    acc
    (sum (sub1 n) (+ acc n))))

(sum 10 0)
```

= Assembly

```asm
fun_start_sum:
  push rbp
  mov rbp, rsp
  sub rsp, 8*3
fun_body_sum:
  ;; << (= n 0) >>
  cmp rax, 1
je label_else_2
  mov rax, [rbp + 8*3]
  jmp label_exit_2
label_else_2:
  ;; << (sub1 n) >>
  mov [rbp - 8*1], rax
  ;; << (+ acc n) >>
  push rax
  mov rax, [rbp - 8*1]
  push rax
  call fun_start_sum
  add rsp, 8*2
label_exit_2:
  mov rsp, rbp
  pop rbp
  ret
```
