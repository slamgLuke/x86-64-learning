.section .text
.globl _start
_start:
    andq $-16, %rsp
    movl $1000001, %edi
    call is_palindrome

    subq $16, %rsp
    movabsq $0x000a6425, %rdi
    movq %rdi, 0(%rsp)
    leaq 0(%rsp), %rdi
    movl %eax, %esi
    xorq %rax, %rax
    call printf

    movq $60, %rax
    xorq %rdi, %rdi
    syscall


is_palindrome:
    pushq %rbp
    movq %rsp, %rbp
    cmpl $0, %edi
    jge continue__
    movl $0, %eax
    jmp return__
continue__:
    subq $128, %rsp
    andq $-16, %rsp
    movl %edi, -8(%rbp)
    movabsq $0x006425, %rax
    movq %rax, -32(%rbp)
    leaq -128(%rbp), %rdi
    leaq -32(%rbp), %rsi
    movl -8(%rbp), %edx
    xorq %rax, %rax
    call sprintf


    leaq -128(%rbp), %rdi
    movq %rdi, %rsi
    addq %rax, %rsi
    subq $1, %rsi
    xorq %r8, %r8
    shrl $1, %eax
while__:
    cmpl %eax, %r8d
    jg end__
    movb (%rdi, %r8, 1), %r9b
    cmpb (%rsi), %r9b
    je true__
    movl $0, %eax
    jmp return__
true__:
    addq $1, %r8
    addq $-1, %rsi
    jmp while__
end__:
    movl $1, %eax
return__: 
    movq %rbp, %rsp
    popq %rbp
    ret

