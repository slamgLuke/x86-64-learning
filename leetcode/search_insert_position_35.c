int searchInsert(int* nums, int numsSize, int target) {
    
    /*
        i = 0;
        for (; i<numsSize; i++) {
            if (nums[i] >= target) break;
        }
        return i;
    */

    int screw_you_leetcode;
    __asm__("\
        pushq %%rbp;\n\
        movq %%rsp, %%rbp;\n\
        \
        xorq %%rax, %%rax;\n\
        \
        for1%=:\n\
        cmpl %%esi, %%eax;\n\
        jge endfor1%=;\n\
        \
        cmpl %%edx, (%%rdi, %%rax, 4);\n\
        jge endfor1%=;\n\
        \
        incl %%eax;\n\
        jmp for1%=;\n\
        endfor1%=:\n\
        \
        movq %%rbp, %%rsp;\n\
        popq %%rbp;\n\
        ret;": : );
    return screw_you_leetcode;
}
