

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

fm_c:       .asciz "|%c|\n"
fm_lp:      .asciz "["
fm_rp:      .asciz "]\n"
fm_list:    .asciz "%c%s"
fm_comma:   .asciz ", "
fm_empty:   .asciz ""

fm_node:    .asciz "Node: %p { left: %p, right: %p, data: %c }\n"
fm_depth:   .asciz "    "



.section .data
arr: .byte 'F', 'B', 'G', 'A', 'Q', 'I', 'C', 'Z', 'K', 'E', 'H'
size: .int 11


.section .text
.globl _start

_start:
    movq %rsp, %rbp

    # print_array(arr, size)
    leaq arr(%rip), %rdi
    movl size(%rip), %esi
    call print_array

    # root = NULL
    xorq %rbx, %rbx

    # for (i = 0; i < size; i++) bt_insert(root, arr[i])
    xorq %r12, %r12 # i = 0
for1:
    cmpl size(%rip), %r12d
    jge endfor1

    # bt_insert(root, arr[i])
    movq %rbx, %rdi
    movb arr(, %r12, 1), %sil
    call bt_insert
    movq %rax, %rbx

    incq %r12
    jmp for1
endfor1:

    # bt_inorder_debug(root)
    movq %rbx, %rdi
    xorl %esi, %esi
    call bt_pretty_print

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

    # save root, data on stack
    movq %rdi, -8(%rbp)
    movb %sil, -16(%rbp)

    # if root == NULL, malloc new_node and return
    # else keep going down recursively
    cmpq $0, %rdi
    jne _bt_insert_recursion

    # malloc new_node
    movl sizeof_node(%rip), %edi
    call malloc
    # init node { NULL, NULL, data }
    movq $0, 0(%rax)
    movq $0, 8(%rax)
    movb -16(%rbp), %dil
    movb %dil, 16(%rax)
    # return new_node
    jmp _bt_insert_end

_bt_insert_recursion:
    # if root->data == data, return
    # else if data < root->left, root->left = new_node
    # else root->right = new_node
    movb 16(%rdi), %al
    cmpb %sil, %al
    je _bt_insert_end # if root->data == data, return
    jl _bt_insert_left
_bt_insert_right:
    # new_node = bt_insert(root->right, data)
    movq -8(%rbp), %rdi
    movq 8(%rdi), %rdi # root->right
    movb -16(%rbp), %sil
    call bt_insert
    # root->right = new_node
    movq -8(%rbp), %rdi
    movq %rax, 8(%rdi)
    # return root
    movq -8(%rbp), %rax
    jmp _bt_insert_end
_bt_insert_left:
    # new_node = bt_insert(root->left, data)
    movq -8(%rbp), %rdi
    movq (%rdi), %rdi # root->left
    movb -16(%rbp), %sil
    call bt_insert
    # root->left = new_node
    movq -8(%rbp), %rdi
    movq %rax, (%rdi)
    # return root
    movq -8(%rbp), %rax
_bt_insert_end:
    movq %rbp, %rsp
    popq %rbp
    ret



# void bt_inorder_debug(node *root)
bt_inorder_debug:
    pushq %rbx
    subq $8, %rsp
    # if root == NULL, return
    cmpq $0, %rdi
    je _bt_inorder_debug_end

    movq %rdi, %rbx # save root on callee-saved register

    # bt_inorder_debug(root->left)
    movq 0(%rbx), %rdi
    call bt_inorder_debug

    # printf(fm_node, root, root->left, root->right, root->data)
    leaq fm_node(%rip), %rdi
    movq %rbx, %rsi
    movq 0(%rbx), %rdx
    movq 8(%rbx), %rcx
    movb 16(%rbx), %r8b
    xorq %rax, %rax
    call printf

    # bt_inorder_debug(root->right)
    movq 8(%rbx), %rdi
    call bt_inorder_debug
_bt_inorder_debug_end:
    addq $8, %rsp
    popq %rbx
    ret



# void bt_pretty_print(node *root, int depth)
bt_pretty_print:
    pushq %rbp
    pushq %r12
    movq %rsp, %rbp
    subq $16, %rsp
    # if root == NULL, puts(fm_empty) and return
    cmpq $0, %rdi
    jne _bt_pretty_print_continue
    leaq fm_empty(%rip), %rdi
    call puts
    jmp _bt_pretty_print_ret

_bt_pretty_print_continue:
    # =================
    # rbp - 8  = root
    # rbp - 12 = depth
    # =================
    movq %rdi, -8(%rbp)
    movl %esi, -12(%rbp)

    # bt_pretty_print(root->left, depth+1)
    movq 0(%rdi), %rdi
    incl %esi
    call bt_pretty_print

    # for (i = 0; i < depth; i++) printf(fm_depth)
    xorl %r12d, %r12d
_bt_pretty_print_for:
    cmpl -12(%rbp), %r12d
    jge _bt_pretty_print_endfor
    leaq fm_depth(%rip), %rdi
    xorq %rax, %rax
    call printf
    incl %r12d
    jmp _bt_pretty_print_for
_bt_pretty_print_endfor:

    # printf(fm_c, root->data)
    leaq fm_c(%rip), %rdi
    movq -8(%rbp), %rsi
    movb 16(%rsi), %sil
    xorq %rax, %rax
    call printf

    # bt_pretty_print(root->right, depth+1)
    movq -8(%rbp), %rdi
    movq 8(%rdi), %rdi
    movl -12(%rbp), %esi
    incl %esi
    call bt_pretty_print

_bt_pretty_print_ret:
    movq %rbp, %rsp
    popq %r12
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
