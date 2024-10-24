.section .text
.globl _start

_start:

_end:
    movq $60, %rax
    xorq %rdi, %rdi
    syscall


# int function_that_returns()
function_that_returns:
    # prepare the stack (unnecessary in this case)
    pushq %rbp
    movq %rsp, %rbp

    movl $42, %eax  # rax: return value

    # restore the stack and return
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

# int function_with_10_args(int a, int b, int c, int d, int e, int f, int g, int h, int i, int j)
function_with_10_args:
    pushq %rbp
    movq %rsp, %rbp

    # stack diagram:
    # =================
    # | 10th arg      | 28(%rbp)
    # | 9th arg       | 24(%rbp)
    # | 8th arg       | 20(%rbp)
    # | 7th arg       | 16(%rbp)
    # | return addr   | 8(%rbp)
    # ================
    # | old rbp       | 0(%rbp)
    # =================
    # | local vars... | -8...(%rbp)
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
    addl 20(%rbp), %eax # 8th arg
    addl 24(%rbp), %eax # 9th arg
    addl 28(%rbp), %eax # 10th arg

    movq %rbp, %rsp
    popq %rbp
    ret

# now let's try a function with 12 different sized args and 2 local vars
# int crazy_func(int a, int b, int c, char d, char* e, char** f, int g, short h, void* i, int j, char k, char l)
crazy_func:
    pushq %rbp
    movq %rsp, %rbp

    # stack diagram:
    # =================
    # | j (4B int)    | 
    # | i (8B void*)  | 22(%rbp)
    # | h (2B short)  | 20(%rbp)
    # | g (4B int)    | 16(%rbp)
    # | return addr   | 8(%rbp)
    # =================
    # | old rbp       | 0(%rbp)
    # =================
    # | x             | -8(%rbp)
    # | y             | -16(%rbp)
    # ================
