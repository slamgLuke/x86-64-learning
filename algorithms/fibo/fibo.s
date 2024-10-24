.section .data
var_n: .quad 14
format_1: .asciz "fibo(%d) = %d\n"



.section .text
.globl _start

.extern printf


_start:
    add $16, %rsp

    # loading variable from data to stack
    movq var_n(%rip), %rdi
    movq %rdi, 8(%rsp)

    movq 8(%rsp), %rdi
    call fibo
    movq %rax, (%rsp) # save

    # [sp + 16 = prev sp]
    # [sp + 8 = n]
    # [sp + 0 = fibo(n)]

    # printf("Fibo(%d) = %d\n", n, fibo(n))
    lea format_1(%rip), %rdi
    movq 8(%rsp), %rsi
    movq (%rsp), %rdx
    call printf

    jmp _exit


_exit:
    mov $60, %rax
    xor %rdi, %rdi
    syscall




fibo:
    cmp $1, %rdi
    jg fibo_rec
    # base case (n <= 1)
    movq %rdi, %rax
    ret

    # [sp + 16 = prev sp]
    # sp + 8 = n
    # sp + 0 = fibo(n-1)

fibo_rec:
    sub $16, %rsp

    # fibo(n-1)
    movq %rdi, 8(%rsp)
    sub $1, %rdi
    call fibo
    movq %rax, (%rsp) # save
    # fibo(n-2)
    movq 8(%rsp), %rdi
    sub $2, %rdi
    call fibo

    # fibo(n-1) + fibo(n-2)
    addq (%rsp), %rax

    add $16, %rsp
    ret

