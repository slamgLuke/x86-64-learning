.section .rodata
.str: 
    .string "Hello, World!\n"

.len = . - .str

.section .text
.globl _start

_start:
    movq $1, %rax
    movq $1, %rdi
    movq $.str, %rsi
    movq $.len, %rdx
    syscall

_end:
    movq $60, %rax
    xorq %rdi, %rdi
    syscall


