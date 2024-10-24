.section .rodata
debug:  .byte 1
n:      .long 21
inf:    .long 0x7fffffff

fm_d:       .asciz "%d\n"
fm_lp:      .asciz "["
fm_rp:      .asciz "]\n"
fm_list:    .asciz "%d%s"
fm_comma:   .asciz ", "
fm_empty:   .asciz ""

fm_LA:      .asciz "L = "
fm_RA:      .asciz "R = "
fm_merge:   .asciz "Merged: "
fm_hello:   .asciz "Finished doing mergesort!\n"


.section .data
arr:    .long 7, 1, -6, 3, 9, -1, 0, 5, 8, 2, 4, 10, 6, -2, 11, -3, -5, 14, -4, 12, 13 


.section .text
.globl _start

_start:
    leaq arr(%rip), %rdi
    movl n(%rip), %esi
    call print_array

    leaq arr(%rip), %rdi
    movl $0, %esi
    movl n(%rip), %edx
    subl $1, %edx
    movl $0, %r8d
    call mergesort 

    leaq fm_hello(%rip), %rdi
    xorq %rax, %rax
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
    subq $40, %rsp

    # if left >= right, return
    cmpl %edx, %esi
    jge _mergesort_end

    # =================
    # rbp - 8  = *arr
    # rbp - 12 = left
    # rbp - 16 = mid
    # rbp - 20 = right
    # rbp - 24 = debug
    # =================
    # sp = rbp - 40
    movq %rdi, -8(%rbp)
    movl %esi, -12(%rbp)
    movl %edx, -20(%rbp)
    movl %ecx, -24(%rbp)

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
    subq $56, %rsp

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
    # sp = rbp - 56
    movq %rdi, -8(%rbp)
    movl %esi, -28(%rbp)
    movl %edx, -32(%rbp)
    movl %ecx, -36(%rbp)
    movl %r8d, -48(%rbp)

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


    # COPY arr[left..=mid] INTO L
    # ============================
    # i = 0
    # do {
    #   L[i] = arr[left+i]
    #   i++;
    # } while (i < n1)
    # ============================

    xorq %rdi, %rdi # i = 0
    movq -8(%rbp), %rax # rax = *arr
    movq -16(%rbp), %rcx # rcx = *L
    movl -28(%rbp), %edx # edx = left
_merge_copy_l:

    movl (%rax, %rdx, 4), %esi # esi = arr[left+i]
    movl %esi, (%rcx, %rdi, 4) # L[i] = esi

    incq %rdi
    incl %edx
    cmpl -40(%rbp), %edi # while (i < n1)
    jl _merge_copy_l

    # L[i=n1] = inf
    movl inf(%rip), %esi
    movl %esi, (%rcx, %rdi, 4)

    ## ======= DEBUGGING =======
    ## PRINT ARRAY FOR DEBUGGING
    cmpb $0, debug(%rip)
    je _merge_skip_debug_l
    leaq fm_LA(%rip), %rdi
    xorq %rax, %rax
    call printf
    movq -16(%rbp), %rdi
    movl -40(%rbp), %esi
    call print_array
    _merge_skip_debug_l:
    ## ======= DEBUGGING =======


    # COPY arr[mid+1..=right] INTO R
    # ============================
    # j = 0
    # do {
    #   L[j] = arr[mid+1+j]
    #   j++;
    # } while (j < n2)
    # ============================

    xorq %rdi, %rdi # j = 0
    movq -8(%rbp), %rax # rax = *arr
    movq -24(%rbp), %rcx # rcx = *R
    movl -32(%rbp), %edx # edx = mid + 1
    addl $1, %edx
_merge_copy_r:

    movl (%rax, %rdx, 4), %esi # esi = arr[mid+1+j]
    movl %esi, (%rcx, %rdi, 4) # R[i] = esi

    incq %rdi
    incl %edx
    cmpl -44(%rbp), %edi # while (j < n2)
    jl _merge_copy_r

    # R[j=n2] = inf
    movl inf(%rip), %esi
    movl %esi, (%rcx, %rdi, 4)

    ## ======= DEBUGGING =======
    ## PRINT ARRAY FOR DEBUGGING
    cmpb $0, debug(%rip)
    je _merge_skip_debug_r
    leaq fm_RA(%rip), %rdi
    xorq %rax, %rax
    call printf
    movq -24(%rbp), %rdi
    movl -44(%rbp), %esi
    call print_array
    _merge_skip_debug_r:
    ## ======= DEBUGGING =======


    # MERGE
    # ============================
    # i = 0, j = 0
    # for (k = left; k <= right)
    #   if (L[i] <= R[j])
    #     arr[k] = L[i]
    #     i++
    #   else
    #     arr[k] = R[j]
    #     j++
    # ============================

    xorq %rdi, %rdi # i = 0
    xorq %rsi, %rsi # j = 0
    movl -28(%rbp), %r8d # k = left
    movq -8(%rbp), %rax # rax = *arr
    movq -16(%rbp), %rcx # rcx = *L
    movq -24(%rbp), %rdx # rdx = *R
_merge_merge:
    cmpl -36(%rbp), %r8d
    jg _merge_merge_end

    movl (%rcx, %rdi, 4), %r9d  # L[i]
    movl (%rdx, %rsi, 4), %r10d # R[j]
    # if (L[i] <= R[j])
    cmpl %r10d, %r9d
    jg _merge_else

    # arr[k] = L[i]
    movl %r9d, (%rax, %r8, 4)
    incq %rdi # i++
    jmp _merge_endif
_merge_else:

    # arr[k] = R[j]
    movl %r10d, (%rax, %r8, 4)
    incq %rsi # j++
_merge_endif:

    incq %r8 # j++
    jmp _merge_merge
_merge_merge_end:

    ## ======= DEBUGGING =======
    ## PRINT ARRAY FOR DEBUGGING
    cmpb $0, debug(%rip)
    je _merge_skip_debug_merge
    leaq fm_merge(%rip), %rdi
    xorq %rax, %rax
    call printf
    movq -8(%rbp), %rdi
    movl -28(%rbp), %esi
    salq $2, %rsi
    addq %rsi, %rdi
    movl -36(%rbp), %esi
    subl -28(%rbp), %esi
    addl $1, %esi
    call print_array
    leaq fm_empty(%rip), %rdi
    call puts
    _merge_skip_debug_merge:
    ## ======= DEBUGGING =======


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
    subq $40, %rsp

    # if size <= 0, return 
    cmpl $0, %esi
    jle _print_array_end

    # =================
    # rbp - 8  = *arr
    # rbp - 12 = size
    # rbp - 16 = #### (padding)
    # rbp - 24 = rbx
    # rbp - 32 = r12
    # =================
    movq %rdi, -8(%rbp)
    movl %esi, -12(%rbp)
    movq %rbx, -24(%rbp)
    movq %r12, -32(%rbp)

    # printf(fm_lp)
    leaq fm_lp(%rip), %rdi
    xorq %rax, %rax
    call printf

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
    xorq %rax, %rax
    call printf

    incq %r12
    jmp _print_array_for
_print_array_endfor:
    # print last element
    # printf(fm_list, arr[i=size-1], fm_rp)
    leaq fm_list(%rip), %rdi
    movl (%rbx, %r12, 4), %esi
    leaq fm_rp(%rip), %rdx
    xorq %rax, %rax
    call printf
# =============================

    # restore callee-saved registers
    movq -24(%rbp), %rbx
    movq -32(%rbp), %r12

_print_array_end:
    # return
    movq %rbp, %rsp
    popq %rbp
    ret
