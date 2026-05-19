```clojure
(let (one 1)
(let (inc (fn (x) (+ x one)))
    (inc 99)))
```

```clojure
(let (inc
        (let (var_one 1)
            (fn (x) (+ x var_one))))
    (inc 99))
```

; max_vars(e) = old_max_vars(e) + free(e)
; [lv_4]
; [lv_3]
; [lv_2]
; [lv_1]
; [fv_n]
; [fv3]
; [fv2]
; [fv1]

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
