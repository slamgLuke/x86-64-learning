

# node struct 
# struct {
#   struct node *left;  8B
#   struct node *right; 8B
#   char data;          1B
# }
# sizeof(struct node) = 17B
# 
# ==================
# node + 0  = left
# node + 8  = right
# node + 16 = data
# ==================


.section .rodata
sizeof_node: .int 17

fm_c:       .asciz "%c\n"
fm_lp:      .asciz "["
fm_rp:      .asciz "]\n"
fm_list:    .asciz "%c%s"
fm_comma:   .asciz ", "

fm_node:    .asciz "Node { left: %p, right: %p, data: %c }\n"



.section .data
size: .int 11
arr: .byte 'F', 'B', 'G', 'A', 'Q', 'I', 'C', 'Z', 'K', 'E', 'H'


.section .text
.globl _start

_start:
    movq %rsp, %rbp

    leaq arr(%rip), %rdi
    movl size(%rip), %esi
    call print_array


    # malloc root
    movl sizeof_node(%rip), %edi
    call malloc
    movq %rax, %rbx

    # root->data = {NULL, NULL, arr[0]}
    movq $0, 0(%rbx)
    movq $0, 8(%rbx)
    movq %rbx, %rdi
    addq $16, %rdi
    movb arr(%rip), %al
    movb %al, (%rdi)

    # printf(fm_node, root->left, root->right, root->data)
    leaq fm_node(%rip), %rdi
    movq 0(%rbx), %rsi
    movq 8(%rbx), %rdx
    movb 16(%rbx), %cl
    xorq %rax, %rax
    call printf

    # btree_insert(root, arr[1])
    movq %rbx, %rdi
    movb arr+1(%rip), %sil
    call bt_insert

    # printf(fm_node, rax->left, rax->right, rax->data)
    leaq fm_node(%rip), %rdi
    movq 0(%rax), %rsi
    movq 8(%rax), %rdx
    movb 16(%rax), %cl
    xorq %rax, %rax
    call printf

    # printf(fm_node, root->left, root->right, root->data)
    leaq fm_node(%rip), %rdi
    movq 0(%rbx), %rsi
    movq 8(%rbx), %rdx
    movb 16(%rbx), %cl
    xorq %rax, %rax
    call printf

    # free root
    movq %rbx, %rdi
    call free


_end:
    movq $60, %rax
    xorq %rdi, %rdi
    syscall


# node* btree_insert(node *root, char data)
bt_insert:
    pushq %rbp
    movq %rsp, %rbp
    subq $24, %rsp

    movq $0, %rax
    # if root == NULL, return
    cmpq $0, %rdi
    je _bt_insert_end
    # if root->data == data, return
    movb 16(%rdi), %al
    cmpb %sil, %al
    je _bt_insert_end

    # save root, data on stack
    movq %rdi, -8(%rbp)
    movb %sil, -16(%rbp)

    # malloc new_node
    movl sizeof_node(%rip), %edi
    call malloc
    # init new_node
    movq $0, 0(%rax)
    movq $0, 8(%rax)
    movb -16(%rbp), %dil 
    movb %dil, 16(%rax)

    movq -8(%rbp), %rdi
    # if root->data > data, root->left = new_node
    # else root->right = new_node
    cmpb %dil, %al
    jg _bt_insert_left
_bt_insert_right:
    movq %rax, 0(%rdi)
    jmp _bt_insert_end
_bt_insert_left:
    movq %rax, 8(%rdi)

_bt_insert_end:
    movq %rbp, %rsp
    popq %rbp
    ret



# void print_array(char *arr, int size)
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
    movq -8(%rbp), %rbx # rbx = *arr
    xorq %r12, %r12 # i = 0
    subl $1, -12(%rbp) # size -= 1
_print_array_for:
    cmpl -12(%rbp), %r12d
    jge _print_array_endfor

    # printf(fm_list, arr[i], fm_comma)
    leaq fm_list(%rip), %rdi
    movb (%rbx, %r12, 1), %sil
    leaq fm_comma(%rip), %rdx
    xorq %rax, %rax
    call printf

    incq %r12
    jmp _print_array_for
_print_array_endfor:
    # print last element
    # printf(fm_list, arr[i=size-1], fm_rp)
    leaq fm_list(%rip), %rdi
    movb (%rbx, %r12, 1), %sil
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
