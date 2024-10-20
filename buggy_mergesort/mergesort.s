.section .rodata
n: .long 21
inf: .long 2147483647

fm_d: .asciz "%d\n"
fm_lp: .asciz "["
fm_rp: .asciz "]\n"
fm_list: .asciz "%d%s"
fm_comma: .asciz ", "
fm_empty: .asciz ""

.section .data
arr: .long 7, 1, -6, 3, 9, -1, 0, 5, 8, 2, 4, 10, 6, -2, 11, -3, -5, 14, -4, 12, 13 

.section .text
.globl _start

_start:
    call print_array

    movl $0, %edi
    movl n(%rip), %esi
    call mergesort 

    call print_array
    jmp _end


_end:
    movq $60, %rax
    xorq %rdi, %rdi
    syscall




# mergesort(p, r)
# 1. if p >= r-1, return
# 2. q = (p + r) / 2
# 3. mergesort(p, q)
# 4. mergesort(q+1, r)
# 5. merge(p, q, r)

mergesort:
# edi = p
# esi = r
    pushq %rbp
    movq %rsp, %rbp

    # if p >= r, return
    cmp %esi, %edi
    jge mergesort_end

    # q = (p + r) / 2
    movl %edi, %eax
    addl %esi, %eax
    sarl $1, %eax

    pushq %rdi
    pushq %rax
    pushq %rsi

# ==============
# rbp - 8 = p
# rbp - 16 = q
# rbp - 24 = r
# ==============

    # mergesort(p, q)
    movl %eax, %esi # esi = q
    call mergesort

    # mergesort(q+1, r)
    movq -8(%rbp), %rdi # edi = q+1
    addl $1, %edi
    movq -24(%rbp), %rsi # esi = r
    call mergesort

    # merge(p, q, r)
    movq -8(%rbp), %rdi # edi = p
    movq -16(%rbp), %rsi # esi = q
    movq -24(%rbp), %rdx # edx = r
    call merge

mergesort_end:
    movq %rbp, %rsp
    popq %rbp
    ret





# merge(p, q, r)
# 1. n1 = q - p + 1
# 2. n2 = r - q
# 3. let L[n1+1] and R[n2+1] be new arrays
# 4. for (i = 0; i < n1)
# 5.     L[i] = A[p + i - 1]
# 6. L[n1] = inf
# 7. for (j = 0; i < n2)
# 8.     R[j] = A[q + j]
# 9. R[n2] = inf
# 10. i = 0
# 11. j = 0
# 12. for (k = p; k < r; k++)
# 13.     if L[i] <= R[j]
# 14.         A[k] = L[i]
# 15.         i = i + 1
# 16.     else
# 17.         A[k] = R[j]
# 18.         j = j + 1
# 19. delete L and R

merge:
# edi = p
# esi = q
# edx = r
    pushq %rbp
    movq %rsp, %rbp
    pushq %rdi
    pushq %rsi
    pushq %rdx

    # n1 = q - p + 1
    movl %esi, %eax # eax = q
    subl %edi, %eax # eax = q - p
    addl $1, %eax # eax = q - p + 1 = n1

    # n2 = r - q
    movl %edx, %ecx # ecx = r
    subl %esi, %ecx # ecx = r - q = n2

    pushq %rax
    pushq %rcx

    # allocate LR[0..(n1+n2+2)]
    movl %eax, %edi
    addl %ecx, %edi
    addl $2, %edi
    sall $2, %edi
    call malloc # malloc((n1+n2+2)*4)

    # rax = L
    pushq %rax # save L

    # R = L + (n1+1)*4
    movq -32(%rbp), %rdi
    addq $1, %rdi
    salq $2, %rdi
    addq %rdi, %rax # rax = L + (n1+1)*4
    pushq %rax # save R


# ==============
# rbp - 8  = p
# rbp - 16 = q
# rbp - 24 = r
# rbp - 32 = n1
# rbp - 40 = n2
# rbp - 48 = L
# rbp - 56 = R
# ==============

# copying L and R
    # for i = 0; i < n1
    xorq %r8, %r8     # r8 = i
    movq -32(%rbp), %r9 # r9 = n1
    movq -8(%rbp), %r10 # r10 = p
    movq -48(%rbp), %rax # rax = L
_merge_copy_L:
    cmpq %r9, %r8
    jge _merge_copy_L_end

    # L[i] = A[p + i]
    addl %r10d, %r8d
    movl arr(, %r8, 4), %edi # edi = A[p + i]
    subl %r10d, %r8d
    movl %edi, (%rax, %r8, 4) # L[i] = A[p + i]

    incq %r8
    jmp _merge_copy_L
_merge_copy_L_end:
    # L[n1] = inf
    movl inf(%rip), %edi
    movl %edi, (%rax, %r8, 4)


    # for j = 0; j < n2
    xorq %r8, %r8     # r8 = j
    movq -40(%rbp), %r9  # r9 = n2
    movq -16(%rbp), %r10 # r10 = q
    movq -56(%rbp), %rax # rax = R
_merge_copy_R:
    cmp %r9d, %r8d
    jge _merge_copy_R_end

    # R[j] = A[q + j]
    addl %r10d, %r8d
    movl arr(, %r8, 4), %edi # edi = A[q + j]
    subl %r10d, %r8d
    movl %edi, (%rax, %r8, 4) # R[j] = A[q + j]

    incq %r8
    jmp _merge_copy_R
_merge_copy_R_end:
    # R[n2] = inf
    movl inf(%rip), %edi
    movl %edi, (%rax, %r8, 4)


# merging L and R
    # i, j = 0
    xorq %r8, %r8
    xorq %r9, %r9 

    # for k = p; k < r; k++
    movq -8(%rbp), %rdi # edi = p
    movq -24(%rbp), %rdx # edx = r
    movq -48(%rbp), %rax # L = rax
    movq -56(%rbp), %rsi # R = rsi

_merge_mergefor:
    cmpq %rdx, %rdi
    jge _merge_mergefor_end

    # if L[i] <= R[j]
    # if (rax + r8*4) <= (rsi + r9*4)
    movl (%rax, %r8, 4), %r10d # r10d = L[i]
    movl (%rsi, %r9, 4), %r11d # r11d = R[j]
    cmpl %r11d, %r10d
    jg _merge_else
    
    # A[k] = L[i]
    movl %r10d, arr(, %rdi, 4)
    # i = i + 1
    incq %r8
    jmp _merge_endif
_merge_else:
    # A[k] = R[j]
    movl %r11d, arr(, %rdi, 4)
    # j = j + 1
    incq %r9
_merge_endif:

    incq %rdi
    jmp _merge_mergefor
_merge_mergefor_end:

    # free L and R
    movq %rax, %rdi
    call free

    movq %rbp, %rsp
    popq %rbp
    ret








    




# adapted for 32-bit ints
print_array:
    # prep stack
    pushq %rbp
    movq %rsp, %rbp
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
    movl n(%rip), %edi
    dec %rdi
    movq %rdi, -8(%rbp)
print_array_for:
    cmp -8(%rbp), %r12 # break if (i >= n-1)
    jge print_array_endfor
    
    # printf(fm_list, arr[i], fm_comma);
    lea fm_list(%rip), %rdi
    movl arr(, %r12, 4), %esi
    lea fm_comma(%rip), %rdx
    call printf

    inc %r12
    jmp print_array_for
print_array_endfor:
# =============================

    # print last element
    lea fm_list(%rip), %rdi
    movl arr(, %r12, 4), %esi
    lea fm_rp(%rip), %rdx
    call printf

    # restore stack
    addq $8*3, %rsp
    popq %r12
    popq %rbp
    ret
