## Source

```clojure
(let (one 1)
(let (inc (fn (x) (+ x one)))
    (inc 99)))
```

Why its hard to "pass free vars as extra params"

```clojure
(let (inc
        (let (var_one 1)
            (fn (x) (+ x var_one))))
    (inc 99))
```

; max_vars(e) = old_max_vars(e) + free(e)

## Stack Layout for Function

; [local_var_n]
; ...
; [localvar_3]
; [localvar_2]
; [localvar_1]
; [free_var_n]
; ...
; [free_var_3]
; [free_var_2]
; [free_var_1]
; [saved__rbp] <-- rbp
; [ret___addr]
; [param____0]
; [param____1]
; [param____2]
; ...
; [param____n]

## Assembly Code from Lecture

```asm
; SETUP STACK
push rbp
mov rbp rsp
sub rsp, 5000
mov r11, rsi

; let (one 1)
mov rax, 2
mov [rbp - 8*2], rax

; <(fn (x) (+ x one))>

; (a) CODE for fn
jmp fun_end_lambda_0
fun_start_lambda_0:
; SETUP
push rbp
mov rbp rsp
sub rsp, 5000

; 'self' is at [rbp + 16]
; 'x'    is at [rbp + 24]
; one -> 1
; mov "one" from "heap" to stack-slot-1
mov rbx, [rbp + 16]
sub rbx, 5
mov rax, [rbx + 16]
mov [rbp - 8*1], rax

; <(+ x one)>
mov rax, [rbp + 24]     ; load `x` into rax
add rax, [rbp - 8*1]    ; add `one` to  rax

; TEARDOWN
mov rsp, rbp
pop rbp
ret
fun_end_lambda_0:
; (b) ALLOC BLOCK [arity][codelabel][fv_1][...][fv_n]

; (let (inc ...))
mov [rbp - 8*3], rax

; <(inc 99)>
    ; (c) CALL (inc 99)

; TEAR DOWN
mov rsp, rbp
pop rbp
ret
```

## Computing the Free Variables

Fill in the definition of `free` which computes the free variables of an expression.

```rust
fn free(e: &Expr) -> im::HashSet<String> {
  match e {
    Num(_) | True | False | Input | Nil =>
      im::HashSet::new(),

    Add1(e) | Sub1(e) | Neg(e)
    | Loop(e) | Break(e) | Print(e) | Get(e, _) =>
      free(e)

    Call1(x, e) =>
      free(e) + { x }

    If(e1, e2, e3) =>
      free(e1) + free(e2) + free(e3)

    Bin(_, e1, e2) | Vec(e1, e2) =>
      free(e1) + free(e2)

    Call2(f, e1, e2) =>
      free(e1) + free(e2) + { f }

    Block(es) =>
      let mut fv = {};
      for e in es { fv = fv + free(e) }
      fv

    Var(x) =>
      {x}

    Let(x, e1, e2) =>
      free(e1) + ( free(e2) - {x} )

    Defn(defn) => // defn.params, defn.body, defn.name
      free(defn.body) - defn.params - defn.name
}
```
