/**
 * Note: The returned array must be malloced, assume caller calls free().
 */
int* plusOne(int* digits, int digitsSize, int* returnSize) {
    /*
        malloc((size+1) << 2)
        retsize = size;
        p = (rdi, rsi, 4) - 4 // arr + (size-1)*4
        pnew = (rax, rsi, 4)  // rax + size*4 
        
        c = 1;
        for (i=0; i<size; i++) {
            x = *p + c;
            if (x >= 10) {
                c = 1;
                x -= 10;
            } else c = 0;
            *pnew = x;
            p -= 4; pnew -= 4;
        }
        *pnew = c;
        retsize += c;
        c = 1 - c;
        rax += c << 2;
    */

    __asm__("\
        pushq %%rbp;\n\
        movq %%rsp, %%rbp;\n\
        subq $32, %%rsp;\n\
        movq %%rdi, -8(%%rbp);\n\
        movl %%esi, -16(%%rbp);\n\
        movq %%rdx, -24(%%rbp);\n\
        movl %%esi, (%%rdx);\n\
        \
        movl %%esi, %%edi;\n\
        addl $1, %%edi;\n\
        shll $2, %%edi;\n\
        call malloc;\n\
        \
        movq -8(%%rbp), %%rdi;\n\
        movl -16(%%rbp), %%r8d;\n\
        leaq (%%rdi, %%r8, 4), %%rdi;\n\
        subq $4, %%rdi;\n\
        leaq (%%rax, %%r8, 4), %%rdx;\n\
        movl $1, %%ecx;\n\
        xorq %%r8, %%r8;\n\
        \
        for%=:\n\
        cmpl -16(%%rbp), %%r8d;\n\
        jge endfor%=;\n\
        \
        movl (%%rdi), %%r10d;\n\
        addl %%ecx, %%r10d;\n\
        \
        cmpl $10, %%r10d;\n\
        jl else%=;\n\
        movl $1, %%ecx;\n\
        subl $10, %%r10d;\n\
        jmp endif%=;\n\
        else%=:\n\
        xorl %%ecx, %%ecx;\n\
        endif%=:\n\
        \
        movl %%r10d, (%%rdx);\n\
        \
        subq $4, %%rdi;\n\
        subq $4, %%rdx;\n\
        incq %%r8;\n\
        jmp for%=;\n\
        endfor%=:\n\
        \
        movl %%ecx, (%%rdx);\n\
        movq -24(%%rbp), %%rsi;\n\
        addl %%ecx, (%%rsi);\n\
        movl $1, %%r8d;\n\
        subl %%ecx, %%r8d;\n\
        shll $2, %%r8d;\n\
        addq %%r8, %%rax;\n\
        \
        movq %%rbp, %%rsp;\n\
        popq %%rbp;\n\
        ret;" : :);
    return (int*)0;
}
