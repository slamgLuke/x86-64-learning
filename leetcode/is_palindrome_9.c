#include <stdbool.h>

bool isPalindrome(int x) {
    bool screw_you_leetcode;
    __asm__("\
    pushq %%rbp;\n\
    movq %%rsp, %%rbp;\n\
    cmpl $0, %%edi;\n\
    jge continue%=;\n\
    movl $0, %%eax;\n\
    jmp return%=;\n\
continue%=:;\n\
    subq $128, %%rsp;\n\
    andq $-16, %%rsp;\n\
    movl %%edi, -8(%%rbp);\n\
    movabsq $0x006425, %%rax;\n\
    movq %%rax, -32(%%rbp);\n\
    leaq -128(%%rbp), %%rdi;\n\
    leaq -32(%%rbp), %%rsi;\n\
    movl -8(%%rbp), %%edx;\n\
    xorq %%rax, %%rax;\n\
    call sprintf;\n\
    leaq -128(%%rbp), %%rdi;\n\
    movq %%rdi, %%rsi;\n\
    addq %%rax, %%rsi;\n\
    subq $1, %%rsi;\n\
    xorq %%r8, %%r8;\n\
    shrl $1, %%eax;\n\
while%=:;\n\
    cmpl %%eax, %%r8d;\n\
    jg end%=;\n\
    movb (%%rdi, %%r8, 1), %%r9b;\n\
    cmpb (%%rsi), %%r9b;\n\
    je true%=;\n\
    movl $0, %%eax;\n\
    jmp return%=;\n\
true%=:;\n\
    addq $1, %%r8;\n\
    addq $-1, %%rsi;\n\
    jmp while%=;\n\
end%=:;\n\
    movl $1, %%eax;\n\
return%=: ;\n\
    movq %%rbp, %%rsp;\n\
    popq %%rbp;\n\
    ret;" : :);

    return screw_you_leetcode;
}
