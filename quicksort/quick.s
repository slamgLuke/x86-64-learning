.section .data
arr: .long 7, 1, 3, 9, -1, 0, 5, 8, 2, 4, 10, 6, -2
n: .long 13

fm_d: .asciz "%d\n"
fm_lp: .asciz "["
fm_rp: .asciz "]\n"
fm_list: .asciz "%d%s"
fm_comma: .asciz ", "
fm_empty: .asciz ""

.section .text
.globl _start

_start:
    call print_array

    movl $0, %edi
    movl n(%rip), %esi
    call quicksort

    call print_array
    jmp _end


_end:
    movq $60, %rax
    xorq %rdi, %rdi
    syscall



# quicksort(arr, p=0, r=n)
# 1. if p >= r, return
# 2. q = partition(arr, p, r) // last element as pivot
# 3. quicksort(arr, p, q-1)
# 4. quicksort(arr, q+1, r)

quicksort:
# edi = p
# esi = r
    pushq %rdi
    pushq %rsi

    # if p >= r, return
    cmp %esi, %edi
    jge quicksort_end

    # q: ebx = partition(arr, p, r)
    call partition

    # quicksort(arr, p, q-1)
    pushq %rsi
    movl %eax, %esi
    dec %esi
    call quicksort
    popq %rsi

    # quicksort(arr, q+1, r)
    movl %eax, %edi
    inc %edi
    call quicksort

quicksort_end:
    popq %rsi
    popq %rdi
    ret



# partition(arr, p, r) -> r
# 1. x = arr[r]
# 2. i = p-1
# 3. for j = p to r-1
# 4.     if arr[j] <= x
# 5.         i++
# 6.         swap arr[i] and arr[j]
# 7. swap arr[i+1] and arr[r]
# 8. return i+1

partition:
# edi = p
# esi = r
    # x: eax = arr[r]
    movl arr(, %esi, 4), %eax
    # i: ecx = p-1
    movl %edi, %ecx
    dec %ecx
    # for j: e8 = p to r-1
    movl %edi, %r8d
partition_for:
    cmp %esi, %r8d
    jge partition_endfor

    # edx = arr[j]
    movl arr(, %r8d, 4), %edx

    # if arr[j] <= x
    cmp %eax, %edx
    jg partition_else

    # i++
    inc %ecx
    # swap arr[i] and arr[j]
    movl arr(, %ecx, 4), %r9d
    movl %edx, arr(, %ecx, 4) # arr[i] <- arr[j]
    movl %r9d, arr(, %r8d, 4)   # arr[j] <- arr[i]

partition_else:
    inc %r8d
    jmp partition_for
partition_endfor:

    # swap arr[i+1] and arr[r]
    inc %ecx
    movl arr(, %ecx, 4), %r9d
    movl %eax, arr(, %ecx, 4) # arr[i+1] <- x
    movl %r9d, arr(, %esi, 4) # arr[r] <- arr[i+1]

    # return i+1
    movl %ecx, %eax
    ret



# adapted for 32-bit ints
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
