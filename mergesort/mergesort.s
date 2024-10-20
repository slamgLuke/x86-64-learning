.section .rodata
n: .long 21
inf: .long 2147483647

fm_d: .asciz "%d\n"
fm_lp: .asciz "["
fm_rp: .asciz "]\n"
fm_list: .asciz "%d%s"
fm_comma: .asciz ", "
fm_empty: .asciz ""

fm_hello: .asciz "hello!\n"

.section .data
arr: .long 7, 1, -6, 3, 9, -1, 0, 5, 8, 2, 4, 10, 6, -2, 11, -3, -5, 14, -4, 12, 13 

.section .text
.globl _start

_start:
    leaq arr(%rip), %rdi
    movl n(%rip), %esi
    call print_array

    leaq arr(%rip), %rdi
    movl $0, %esi
    movl n(%rip), %edx
    call mergesort 

    leaq fm_hello(%rip), %rdi
    call printf

    leaq arr(%rip), %rdi
    movl n(%rip), %esi
    call print_array
    jmp _end


_end:
    movq $60, %rax
    xorq %rdi, %rdi
    syscall




# void mergesort(int *arr, int left, int right)
mergesort:
    pushq %rbp
    movq %rsp, %rbp
    subq $24, %rsp

    # if left >= right, return
    cmpl %edx, %esi
    jge _mergesort_end

    # =================
    # rbp - 8  = *arr
    # rbp - 12 = left
    # rbp - 16 = mid
    # rbp - 20 = right
    # =================
    # sp = rbp - 24
    movq %rdi, -8(%rbp)
    movl %esi, -12(%rbp)
    movl %edx, -20(%rbp)

    # mid = (left + right) / 2
    movl -12(%rbp), %eax
    addl -20(%rbp), %eax
    sarl $1, %eax
    movl %eax, -16(%rbp)

    # mergesort(*arr, left, mid)
    movq -8(%rbp), %rdi
    movl -12(%rbp), %esi
    movl -16(%rbp), %edx
    call mergesort

    # mergesort(*arr, mid+1, right)
    movq -8(%rbp), %rdi
    movl -16(%rbp), %esi
    addl $1, %esi
    movl -20(%rbp), %edx
    call mergesort

    # merge(*arr, left, mid, right)
    movq -8(%rbp), %rdi
    movl -12(%rbp), %esi
    movl -16(%rbp), %edx
    movl -20(%rbp), %ecx
    call merge

_mergesort_end:
    # return
    movq %rbp, %rsp
    popq %rbp
    ret




# void merge(int *arr, int left, int mid, int right)
merge:
    pushq %rbp
    movq %rsp, %rbp
    subq $48, %rsp

    # =================
    # rbp - 8  = *arr
    # rbp - 16 = *L
    # rbp - 24 = *R
    # rbp - 28 = left
    # rbp - 32 = mid
    # rbp - 36 = right
    # rbp - 40 = n1
    # rbp - 44 = n2
    # =================
    # sp = rbp - 48
    movq %rdi, -8(%rbp)
    movl %esi, -28(%rbp)
    movl %edx, -32(%rbp)
    movl %ecx, -36(%rbp)

    # n1 = mid - left + 1
    subl %esi, %edx
    addl $1, %edx
    movl %edx, -40(%rbp)

    # n2 = right - mid
    subl -32(%rbp), %ecx
    movl %ecx, -44(%rbp)
    
    # L = malloc((n1+1) * 4)
    movl -40(%rbp), %edi
    addl $1, %edi
    sall $2, %edi
    call malloc
    movq %rax, -16(%rbp)

    # R = malloc((n2+1) * 4)
    movl -44(%rbp), %edi
    addl $1, %edi
    sall $2, %edi
    call malloc
    movq %rax, -24(%rbp)


    # rax = *arr
    movq -8(%rbp), %rax 

    # COPY arr[left..=mid] INTO L
    # ============================
    # i = 0
    # do {
    #   L[i] = arr[left+i]
    #   i++;
    # } while (i < n1)
    # ============================

    xorq %rdi, %rdi # i = 0
    movq -16(%rbp), %rcx # rcx = *L
_merge_copy_l:

    addl -28(%rbp), %edi
    movl (%rax, %rdi, 4), %esi # esi = arr[left+i]
    subl -28(%rbp), %edi
    movl %esi, (%rcx, %rdi, 4) # L[i] = esi

    incq %rdi
    cmpl -40(%rbp), %edi # while (i < n1)
    jl _merge_copy_l

    # L[i=n1] = inf
    movl inf(%rip), %esi
    movl %esi, (%rcx, %rdi, 4)


    # COPY arr[mid+1..=right] INTO R
    # ============================
    # j = 0
    # do {
    #   L[j] = arr[mid+1+j]
    #   j++;
    # } while (j < n2)
    # ============================
    
    xorq %rdi, %rdi # j = 0
    movq -24(%rbp), %rcx # rcx = *R
_merge_copy_r:

    addl -32(%rbp), %edi
    addl $1, %edi
    movl (%rax, %rdi, 4), %esi # esi = arr[mid+1+j]
    subl -28(%rbp), %edi
    subl $1, %edi
    movl %esi, (%rcx, %rdi, 4) # R[i] = esi

    incq %rdi
    cmpl -44(%rbp), %edi # while (j < n2)
    jl _merge_copy_r

    # R[j=n2] = inf
    movl inf(%rip), %esi
    movl %esi, (%rcx, %rdi, 4)


    # MERGE
    # ============================
    # i = 0, j = 0
    # for (k = p; k < r)


    # free L
    movq -16(%rbp), %rdi
    call free
    # free R
    movq -24(%rbp), %rdi
    call free

    # return
    movq %rbp, %rsp
    popq %rbp
    ret




# void print_array(int *arr, int size)
print_array:
    pushq %rbp
    movq %rsp, %rbp
    subq $16, %rsp

    # =================
    # rbp - 8  = *arr
    # rbp - 12 = size
    # =================
    movq %rdi, -8(%rbp)
    movl %esi, -12(%rbp)

    # printf(fm_lp)
    lea fm_lp(%rip), %rdi
    call printf

    pushq %rbx
    pushq %r12
# =============================
# for (int i = 0; i < size-1; i++)

    # rbx = *arr
    movq -8(%rbp), %rbx
    # i = 0
    xorq %r12, %r12
    # size -= 1
    subl $1, -12(%rbp)

_print_array_for:
    cmpl -12(%rbp), %r12d
    jge _print_array_endfor

    # printf(fm_list, arr[i], fm_comma)
    leaq fm_list(%rip), %rdi
    movl (%rbx, %r12, 4), %esi
    leaq fm_comma(%rip), %rdx
    call printf

    incq %r12
    jmp _print_array_for
_print_array_endfor:
    # print last element
    # printf(fm_list, arr[i=size-1], fm_rp)
    leaq fm_list(%rip), %rdi
    movl (%rbx, %r12, 4), %esi
    leaq fm_rp(%rip), %rdx
    call printf
# =============================
    popq %r12
    popq %rbx

    # return
    movq %rbp, %rsp
    popq %rbp
    ret
