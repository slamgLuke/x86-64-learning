# Here is a simple example of a program that uses a global array
.section .data
# we can define each element of the array
array:
    .quad 1, 2, 3, 4, 5   # Example 5-element array

# or we can define a size to be zeroed
zeroed_array:
    .zero 8*1000          # 1000-element array of 64-bit zeros


.section .text
.global _start
_start:
    xor %rdi, %rdi              # rdi = 0 (index)

loop:
    cmp $5, %rdi                # Check if index < 5
    jge end                     # Exit if done

    # we can load the array address using instruction-pointer-relative addressing:
    leaq array(%rip), %rax
    # or we could use absolute addressing:
    movq $array, %rax
    # this last method needs the -no-pie flag to work

    addq (%rax,%rdi,8), %rbx     # Add array[rdi] to rbx

    inc %rdi                    # Increment index
    jmp loop                    # Repeat loop

end:
    mov $60, %rax               # Exit syscall
    xor %rdi, %rdi              # Status: 0
    syscall
