# This is a hello world program written in x86-64 assembly.
# It is not as simple as in other languages, because we need to:
#  - have a string allocated in memory
#  - make a system call to print to stdout
#  - make another system call to exit the program safely


.section .rodata
# .rodata is the read-only section of the program. We store constants here.
# here we define a string, and assign it to the label 'str'

str: .string "Hello, World!\n"

# here we define a 32-bit integer, and assign it to the label 'len'

len: .int 14



.section .text
# .text is the section of the program that contains the actual code.
# We define a global label '_start', which is where the program will start executing.
.globl _start

_start:
    # now we make a system call to write to stdout:
    # write(1, str, len)

    movq $1, %rax    # syscall number for sys_write
    movq $1, %rdi    # file descriptor 1 is stdout
    movq $str, %rsi  # address of the string
    movq $len, %rdx  # length of the string
    syscall


    # finally, we make another syscall to exit the program:
_end:
    movq $60, %rax   # syscall number for sys_exit
    xorq %rdi, %rdi  # exit code 0
    syscall


# PS: There are lot's of other ways to write a hello world program in assembly.
# This is just one of them.
