.section .data
array:
    .quad 1, 2, 3, 4, 5   # Example 5-element array


.section .text
.global _start
_start:
    xor %rdi, %rdi              # rdi = 0 (index)

loop:
    cmp $5, %rdi                # Check if index < 5
    jge end                     # Exit if done

    lea array(%rip), %rax       # Load address of 'array'
    addq (%rax,%rdi,8), %rbx     # Add array[rdi] to rbx

    inc %rdi                    # Increment index
    jmp loop                    # Repeat loop

end:
    mov $60, %rax               # Exit syscall
    xor %rdi, %rdi              # Status: 0
    syscall
