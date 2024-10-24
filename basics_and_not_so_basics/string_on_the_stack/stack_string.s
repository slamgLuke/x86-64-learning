# No data section here!
# We'll be only using the stack to manually load and print strings

.section .text
.globl _start

_start:
    movq %rsp, %rbp 
    andq $-16, %rsp # align the stack to 16 bytes
    subq $48, %rsp

    # x86_64 uses little-endian
    # for example:
    # addr: 0x00 points to the lower byte of 0x00-0x07
    # addr: 0x07 points to the higher byte of 0x00-0x07
    # addr: 0x08 points to the lower byte of 0x08-0x0f


    # let's try to print "abcdefghijlkmnopqrstuvwxyz" using only the stack
    # start with the lowest address, and go up

    # we can insert whole 64-bit immediate values using movabsq
    movabsq $0x6867666564636261, %rax # "abcdefgh"
    movq %rax, -32(%rbp)
    movabsq $0x706f6e6d6c6b6a69, %rax # "ijklmnop"
    movq %rax, -24(%rbp)
    movabsq $0x7877767574737271, %rax # "qrstuvwx"
    movq %rax, -16(%rbp)
    # or byte by byte
    movb $0x79, -8(%rbp) # 'y'
    movb $0x7a, -7(%rbp) # 'z'
    movb $0x0a, -6(%rbp) # '\n'
    movb $0x00, -5(%rbp) # '\0'

    # write(1, &str, 32-4);
    movq $1, %rax # syscall_write
    movq $1, %rdi
    leaq -32(%rbp), %rsi
    movq $32-4, %rdx
    syscall



    # you can prefix a string by using an address that is lower than the string beginning
    movq $0x203a66746e697270, %rax  # "printf: "
    # adding as a prefix to the alphabet string
    movq %rax, -40(%rbp) 


    # also try iterating over the string
    # since memory is byte-addressable, we can iterate over the string byte by byte

    # uppercasing all the letters with a simple do-while loop
    leaq -32(%rbp), %rdi # start
    leaq -6(%rbp), %rsi  # end
uppercase:
    movb (%rdi), %al
    subb $0x20, %al 
    movb %al, (%rdi)
    incq %rdi
    cmpq %rsi, %rdi
    jl uppercase

    # now with printf(&str)
    leaq -40(%rbp), %rdi
    xorq %rax, %rax
    call printf




    # Finally, for a more complex example, let's use multiple strings in the same stack
    # Note: im using python to generate the immediate values
    #  >> 'my8Bytes'.encode()[::-1].hex()

    # We want to make the following strings:

    # main_str = "Hi, my name is %s, my name is %s, my name is %s, %s!\n"
    # str_1 = "(what?)"
    # str_2 = "(who?)"
    # str_3 = "(chika-chika)"
    # str_4 = "Slim Shady"

    # And then finally, we'll print them all using printf!!!
    # printf(main_str, str_1, str_2, str_3, str_4);

    # let's allocate new space in the stack
    pushq %rbp
    movq %rsp, %rbp
    subq $96, %rsp

    # main_str
    movabsq $0x6e20796d202c6948, %rax # "Hi, my n"
    movq %rax, -48(%rbp)
    movabsq $0x2520736920656d61, %rax # "ame is %"
    movq %rax, -40(%rbp)
    movabsq $0x616e20796d202c73, %rax # "s, my na"
    movq %rax, -32(%rbp)
    movabsq $0x732520736920656d, %rax # "me is %s"
    movq %rax, -24(%rbp)
    movabsq $0x6d616e20796d202c, %rax # ", my nam"
    movq %rax, -16(%rbp)
    movabsq $0x2c73252073692065, %rax # "e is %s,"
    movq %rax, -8(%rbp)
    movabsq $0x0000000a21732520, %rax # ", %s!\n\0\0\0"
    movq %rax, -0(%rbp)

    # other strings
    # str_1
    movabsq $0x00293f7461687728, %rax # "(what?)\0"
    movq %rax, -56(%rbp)
    # str_2
    movabsq $0x0000293f6f687728, %rax # "(who?)\0\0"
    movq %rax, -64(%rbp)
    # str_3
    movabsq $0x632d616b69686328, %rax # "(chika-c"
    movq %rax, -80(%rbp)
    movabsq $0x00000029616b6968, %rax # "hika)\0\0"
    movq %rax, -72(%rbp)
    # str_4
    movabsq $0x616853206d696c53, %rax # "Slim Sha"
    movq %rax, -96(%rbp)
    movb $0x64, -88(%rbp) # 'd'
    movb $0x79, -87(%rbp) # 'y'
    movb $0x00, -86(%rbp) # '\0'

    # printf(main_str, str_1, str_2, str_3, str_4);
    # remember that lowest address of each string stores the first char
    leaq -48(%rbp), %rdi
    leaq -56(%rbp), %rsi
    leaq -64(%rbp), %rdx
    leaq -80(%rbp), %rcx
    leaq -96(%rbp), %r8
    xorq %rax, %rax
    call printf


    # deallocate the stack
    movq %rbp, %rsp
    popq %rbp


    # Now we know how to use strings only using the stack
    # This can be useful when we don't have access to the data section. I use it, for example, when solving LeetCode problems with inline assembly.
    # And we also did get to learn a lot about byte addressing in the process

    # However, most of the time, it's better to use the data section for pre-defined strings
    # and only use the stack for temporary variables
    # Use this knowledge wisely!!!


    movq $rbp, %rsp
_end:
    movq $60, %rax
    xorq %rdi, %rdi
    syscall
