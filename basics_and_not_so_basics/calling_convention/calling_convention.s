.section .data
fmt: .asciz "return value: %d\n"

.section .text
.globl _start

# Here we will try to use the System V AMD64 ABI calling convention
# to standardize the way functions are called in our assembly code

# Check below to see the way to define our functions
# Here in our _start function we see how to call them


# helper function to print our return values
print_ret:
    subq $8, %rsp
    leaq fmt(%rip), %rdi
    movq %rax, %rsi
    xorq %rax, %rax
    call printf
    addq $8, %rsp
    ret


_start:
    # function_that_returns_42()
    # no arguments, so we just call it
    call function_that_returns_42
    # eax should contain 42 here
    call print_ret

    # function_with_2_args(1, 2)
    movq $1, %rdi
    movq $2, %rsi
    call function_with_2_args
    # rax should contain 3 here
    call print_ret

    # function_with_6_args(1, 2, 3, 4, 5, 6)
    movl $1, %edi
    movl $2, %esi
    movl $3, %edx
    movl $4, %ecx
    movl $5, %r8d
    movl $6, %r9d
    call function_with_6_args
    # eax should contain 21 here
    call print_ret

    # function_with_10_args(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
    movq %rsp, %rbp
    pushq $10
    pushq $9
    pushq $8
    pushq $7
    movl $6, %r9d
    movl $5, %r8d
    movl $4, %ecx
    movl $3, %edx
    movl $2, %esi
    movl $1, %edi
    call function_with_10_args
    # we have to restore the stack after the call
    movq %rbp, %rsp
    # eax should contain 55 here
    call print_ret

    # also check the crazy_func below, we won't be calling it here


_end:
    movq $60, %rax
    xorq %rdi, %rdi
    syscall



# int function_that_returns_42()
function_that_returns_42:
    # prepare the stack (unnecessary in this case)
    pushq %rbp
    movq %rsp, %rbp

    movl $42, %eax  # rax: return value

    # restore the stack and return
    movq %rbp, %rsp
    popq %rbp
    ret


# long long function_with_2_args(long long a, long long b)
function_with_2_args:
    pushq %rbp
    movq %rsp, %rbp

    movq %rdi, %rax # rdi: 1st arg (a)
    addq %rsi, %rax # rsi: 2nd arg (b)

    movq %rbp, %rsp
    popq %rbp
    ret


# int function_with_6_args(int a, int b, int c, int d, int e, int f)
function_with_6_args:
    pushq %rbp
    movq %rsp, %rbp

    movl %edi, %eax # rdi: 1st arg (a)
    addl %esi, %eax # rsi: 2nd arg (b)
    addl %edx, %eax # rdx: 3rd arg (c)
    addl %ecx, %eax # rcx: 4th arg (d)
    addl %r8d, %eax  # r8: 5th arg (e)
    addl %r9d, %eax  # r9: 6th arg (f)

    movq %rbp, %rsp
    popq %rbp
    ret


# when we use more than 6 args, the stack is used
# the caller must pass the remaining args on the stack in reverse order

# int function_with_10_args(int a, int b, int c, int d, int e, int f, int g, int h, int i, int j)
function_with_10_args:
    pushq %rbp
    movq %rsp, %rbp

    # stack diagram:
    # =================
    # | 10th arg (j)  | 40(%rbp) 
    # | 9th arg  (i)  | 32(%rbp)
    # | 8th arg  (h)  | 24(%rbp)
    # | 7th arg  (g)  | 16(%rbp)
    # | return addr   | 8(%rbp)
    # ================
    # | old rbp       | 0(%rbp)
    # =================
    # | local vars... | -4...(%rbp)
    # | / saved regs  | 
    # ================
    # red zone start    0(%rsp)
    # 
    #  - you can use this space without saving/restoring the stack pointer
    #  - though be careful!
    # 
    # red zone end      -128(%rsp)
    # ================

    movl %edi, %eax # rdi: 1st arg
    addl %esi, %eax # rsi: 2nd arg
    addl %edx, %eax # rdx: 3rd arg
    addl %ecx, %eax # rcx: 4th arg
    addl %r8d, %eax  # r8: 5th arg
    addl %r9d, %eax  # r9: 6th arg
    addl 16(%rbp), %eax # 7th arg
    addl 24(%rbp), %eax # 8th arg
    addl 32(%rbp), %eax # 9th arg
    addl 40(%rbp), %eax # 10th arg

    movq %rbp, %rsp
    popq %rbp
    ret



# now let's see how a function with 12 different sized args and 2 local vars works
# this will force us to use padding, to keep the rsp and its contents aligned

# int crazy_func(int a, int b, int c, char d, char* e, char** f, int g, short h, void* i, int j, char k, char l)
crazy_func:
    pushq %rbp
    movq %rsp, %rbp

    # let's look how gcc would compile this function, using compiler explorer: https://godbolt.org/
    # check ./crazy_func.c to check it for yourself!

    # stack diagram:
    # =================
    ###################
    # | l (1B char)   | 56(%rbp) - 7B padding
    # | k (1B char)   | 48(%rbp) - 7B padding
    # | j (4B int)    | 40(%rbp) - 4B padding
    # | i (8B void*)  | 32(%rbp)
    # | h (2B short)  | 24(%rbp) - 6B padding
    # | g (4B int)    | 16(%rbp) - 4B padding
    # | return addr   | 8(%rbp)
    # =================
    # | old rbp       | 0(%rbp)
    # =================
    # | x (8B long)   | -8(%rbp)
    # | y (4B int)    | -12(%rbp)
    # =================

    # the stack use is not really optimized, but generally it's safer to use a whole qword for each arg
    # we could theoretically use less space, but it's not worth the trouble

    ret
