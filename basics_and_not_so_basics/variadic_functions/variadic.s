# Variadic functions in x86-64 assembly

.section .data
example_str_1:
    .asciz "Hello, {}!"
strlen1:
    .quad . - example_str_1

example_str_2:
    .asciz "Hi {}, my name is {}."
strlen2:
    .quad . - example_str_2


# Let's make our own println function
.section .text

.global _start

_start:

_end:
    movq $60, %rax
    xorq %rdi, %rdi
    syscall


println:
