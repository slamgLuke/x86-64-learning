int lengthOfLastWord(char* s) {
    /*
        sp = 0
        len = 0
        do {
            if (*s == ' ') sp = 1, goto continue
            else if (sp) len = 0
            sp = 0
            len++

        continue:
            s++;
        } while (*s != 0)
    */
    int screw_you_leetcode;
    __asm__("\
        pushq %%rbp;\n\
        movq %%rsp, %%rbp;\n\
        \
        xorl %%r8d, %%r8d;\n\
        xorl %%eax, %%eax;\n\
        \
        loop%=:\n\
        cmpb $0x20, (%%rdi);\n\
        jne else%=;\n\
        movl $1, %%r8d;\n\
        jmp continue%=;\n\
        else%=:\n\
        \
        cmpl $0, %%r8d;\n\
        je else2%=;\n\
        xorl %%eax, %%eax;\n\
        else2%=:\n\
        \
        xorl %%r8d, %%r8d;\n\
        incl %%eax;\n\
        \
        continue%=:\n\
        incq %%rdi;\n\
        cmpb $0, (%%rdi);\n\
        jne loop%=;\n\
        \
        leave%=:\n\
        movq %%rbp, %%rsp;\n\
        popq %%rbp;\n\
        ret;" : :);
    return screw_you_leetcode;
}
