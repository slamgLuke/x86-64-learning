.section .rodata
fm_ld:      .asciz "%ld"
fm_lp:      .asciz "["
fm_rp:      .asciz "]\n"
fm_list:    .asciz "%ld%s"
fm_comma:   .asciz ", "
fm_empty:   .asciz ""
fm_newline: .asciz "\n"

fm_primes: .asciz "Number of primes: %ld\n"


.section .data
array: .zero 8*100000
size: .quad 0
end: .quad 200000

.section .text
.globl _start


_start:
    # generate primes between 2 and 200000
    movq $2, %r8
for1:
    cmpq end(%rip), %r8
    jge endfor1

    movq $2, %r9
    for2:
        cmpq %r8, %r9
        jge endfor2

        xorq %rdx, %rdx
        movq %r8, %rax
        divq %r9

        cmpq $0, %rdx
        je not_prime
        
        incq %r9
        jmp for2

    endfor2:

        movq size(%rip), %rdi
        movq %r8, array(, %rdi, 8)
        incq %rdi
        movq %rdi, size(%rip)

    not_prime:

    incq %r8
    jmp for1
endfor1:

    # print primes
    leaq array(%rip), %rdi
    movq size(%rip), %rsi
    call print_array

    # print number of primes
    leaq fm_primes(%rip), %rdi
    movq size(%rip), %rsi
    xorq %rax, %rax
    call printf


_end:
    movq $60, %rax
    xorq %rdi, %rdi
    syscall




# void print_array(quad *arr, quad size)
print_array:
    pushq %rbp
    movq %rsp, %rbp
    subq $40, %rsp

    # =================
    # rbp - 8  = *arr
    # rbp - 16 = size
    # rbp - 24 = rbx
    # rbp - 32 = r12
    # =================
    movq %rdi, -8(%rbp)
    movq %rsi, -16(%rbp)
    movq %rbx, -24(%rbp)
    movq %r12, -32(%rbp)

    # printf(fm_lp)
    leaq fm_lp(%rip), %rdi
    xorq %rax, %rax
    call printf

    # if size <= 0, skip for
    movq -16(%rbp), %rsi
    cmpq $0, %rsi
    jle _print_array_end

# =============================
# for (int i = 0; i < size-1; i++)

    # rbx = *arr
    movq -8(%rbp), %rbx
    # i = 0
    xorq %r12, %r12
    # size -= 1
    subq $1, -16(%rbp)

_print_array_for:
    cmpq -16(%rbp), %r12
    jge _print_array_endfor

    # printf(fm_list, arr[i], fm_comma)
    leaq fm_list(%rip), %rdi
    movq (%rbx, %r12, 8), %rsi
    leaq fm_comma(%rip), %rdx
    xorq %rax, %rax
    call printf

    incq %r12
    jmp _print_array_for
_print_array_endfor:
    # print last element
    # printf(fm_ld, arr[i=size-1])
    leaq fm_ld(%rip), %rdi
    movq (%rbx, %r12, 8), %rsi
    xorq %rax, %rax
    call printf
# =============================

    # restore callee-saved registers
    movq -24(%rbp), %rbx
    movq -32(%rbp), %r12

_print_array_end:

    # printf(fm_rp)
    leaq fm_rp(%rip), %rdi
    xorq %rax, %rax
    call printf

    # return
    movq %rbp, %rsp
    popq %rbp
    ret
