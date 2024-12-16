int strStr(char* haystack, char* needle) {
    int screw_you_leetcode;
    __asm__ volatile ("\
        movl $-1, %%eax;\n\
        xorq %%r8, %%r8;\n\
        \
        for1%=:\n\
        movb (%%rdi, %%r8, 1), %%cl;\n\
        cmpb $0, %%cl;\n\
        je endfor1%=;\n\
        \
        xorq %%r9, %%r9;\n\
        movq %%r8, %%r10;\n\
        for2%=:\n\
        movb (%%rdi, %%r10, 1), %%cl;\n\
        movb (%%rsi, %%r9, 1), %%dl;\n\
        cmpb $0, %%dl;\n\
        jne continue%=;\n\
        movl %%r8d, %%eax;\n\
        jmp endfor1%=;\n\
        \
        continue%=:\n\
        cmpb %%dl, %%cl;\n\
        jne endfor2%=;\n\
        \
        incq %%r9;\n\
        incq %%r10;\n\
        jmp for2%=;\n\
        endfor2%=:\n\
        \
        incq %%r8;\n\
        jmp for1%=;\n\
        endfor1%=:\n"
        : "=a" (screw_you_leetcode)
        : "D" (haystack),
          "S" (needle)
        : "r8", "r9", "r10", "cl", "dl" // clobbered regs
    );
    return screw_you_leetcode;
}
