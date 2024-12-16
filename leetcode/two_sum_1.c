// This one was actually made following Low Level Learning's video
// https://www.youtube.com/watch?v=lALPErFlfNQ
// ... the video that inspired me to solve leetcode problems in assembly

/**
 * Note: The returned array must be malloced, assume caller calls free().
 */
int* twoSum(int* nums, int numsSize, int target, int* returnSize) {
    int* screw_you_leetcode;
    __asm__(".intel_syntax noprefix;\n\
    push rbx;\n\
    sub rsp, 0x40;\n\
    mov qword ptr [rsp+0x10], rdi;\n\
    mov dword ptr [rsp+0x18], esi;\n\
    mov dword ptr [rsp+0x20], edx;\n\
    mov qword ptr [rsp+0x28], rcx;\n\
    mov rdi, 8;\n\
    call malloc;\n\
    mov qword ptr [rsp+0x30], rax;\n\
    xor r8, r8;\n\
    for1%=:\n\
    mov r9, r8;\n\
    add r9, 1;\n\
    for2%=:\n\
    mov rbx, qword ptr [rsp+0x10];\n\
    xor rax, rax;\n\
    lea rbx, [rbx+r8*4];\n\
    add eax, dword ptr [rbx];\n\
    mov rbx, qword ptr [rsp+0x10];\n\
    lea rbx, [rbx+r9*4];\n\
    add eax, dword ptr [rbx];\n\
    mov ebx, dword ptr [rsp+0x20];\n\
    cmp ebx, eax;\n\
    jne continue%=;\n\
    mov rax, qword ptr [rsp+0x30];\n\
    mov dword ptr [rax], r8d;\n\
    lea rax, [rax+4];\n\
    mov dword ptr [rax], r9d;\n\
    mov rax, qword ptr [rsp+0x28];\n\
    mov dword ptr [rax], 0x2;\n\
    jmp leave%=;\n\
    continue%=:\n\
    inc r9;\n\
    cmp r9d, dword ptr [rsp+0x18];\n\
    jle for2%=;\n\
    inc r8;\n\
    cmp r8d, dword ptr [rsp+0x18];\n\
    jle for1%=;\n\
    leave%=:\n\
    mov rax, qword ptr [rsp+0x30];\n\
    add rsp, 0x40;\n\
    pop rbx;\n\
    ret;\n\
    .att_syntax;" : :);
    return screw_you_leetcode;
}
