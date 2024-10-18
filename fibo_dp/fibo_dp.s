.section .data
arr: .zero 8*5
n: .quad 5

fm_ld: .asciz "%ld\n"
fm_lp: .asciz "["
fm_rp: .asciz "]\n"
fm_list: .asciz "%ld%s"
fm_comma: .asciz ", "
fm_empty: .asciz ""

.section .text
.globl _start

.extern printf
.extern puts


_start:
    call fibo_dp
    # call print_array
    jmp _end




_end:
    mov $60, %rax
    xor %rdi, %rdi
    syscall


# bottom-up fibo
fibo_dp:
    pushq %rbp
    movq %rsp, %rbp

    movq $0, arr(%rip)
    movq $1, arr+8(%rip)

    movq $2, %r8

fibo_dp_for:
    cmp %rsi, %r8
    jge fibo_dp_endfor

    # rdx = arr[i-2] + arr[i-1]
    subq $1, %r8
    movq arr(, %r8, 8), %rdx
    subq $1, %r8
    movq arr(, %r8, 8), %rax
    addq %rax, %rdx

    # arr[i] = rdx
    addq $2, %r8
    movq %rdx, arr(, %r8, 8)

    inc %r8
    jmp fibo_dp_for
fibo_dp_endfor:
    popq %rbp
    ret


print_array:
    # prep stack
    pushq %rbp
    pushq %r12
    movq %rsp, %rbp
    subq $8*3, %rsp

    # rbx = &arr
    lea arr(%rip), %rbx

    # print "["
    lea fm_lp(%rip), %rdi
    call printf

# =============================
# for (int i = 0; i < n-1; i++)
    # i = 0
    xor %r12, %r12
    # [rbp - 8] = n-1
    movq n(%rip), %rdi
    dec %rdi
    movq %rdi, -8(%rbp)
for1:
    cmp -8(%rbp), %r12 # break if (i >= n-1)
    jge endfor1
    
    # printf(fm_list, arr[i], fm_comma);
    lea fm_list(%rip), %rdi
    movq (, %r12, 8), %rsi
    lea fm_comma(%rip), %rdx
    call printf

    inc %r12
    jmp for1 
endfor1:
# =============================

    # print last element
    lea fm_list(%rip), %rdi
    movq (, %r12, 8), %rsi
    lea fm_rp(%rip), %rdx
    call printf

    # restore stack
    add $8*3, %rsp
    popq %r12
    popq %rbp
    ret

