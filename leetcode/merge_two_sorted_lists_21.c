/**
 * Definition for singly-linked list.
 * struct ListNode {
 *     int val;
 *     struct ListNode *next;
 * };
 */
struct ListNode* mergeTwoLists(struct ListNode* list1, struct ListNode* list2) {
    /*
        head: rdi = 0
        ptr: rsi = ?
        it1: rdx, it2: rcx
        while (it1 != 0 && it2 != 0) {
            if (*(it1) <= *(it2))
                rax = it1
                it1 = *(it1 + 4)
            else
                rax = it2
                it2 = *(it2 + 4)
            
            if (head == 0)
                    head = rax
                    ptr = rax
                else
                    *(ptr + 4) = rax
                    ptr = rax
        }

        while (it1 != 0) {
            if (head == 0)
                    head = it1
                    ptr = it1
                else
                    *(ptr + 4) = it1
                    ptr = it1
            it1 = *(it1 + 4)
        }

        while (it2 != 0) {
            if (head == 0)
                    head = it2
                    ptr = it2
                else
                    *(ptr + 4) = it2
                    ptr = it2
            it2 = *(it2 + 4)
        }
    */

    /*
        stack diagram:
        rbp - 8  = list1
        rbp - 16 = list2
    */
    struct ListNode* screw_you_leetcode;
    __asm__ (
    "movq %%rdi, %%rdx;\n"
    "movq %%rsi, %%rcx;\n"
    "xorq %%rdi, %%rdi;\n"
    "xorq %%rsi, %%rsi;\n"
    "loop0%=:\n"
    "cmpq $0, %%rdx;\n"
    "je endloop0%=;\n"
    "cmpq $0, %%rcx;\n"
    "je endloop0%=;\n"
    "movl (%%rdx), %%eax;\n"
    "cmpl (%%rcx), %%eax;\n"
    "jg else1%=;\n"
    "movq %%rdx, %%rax;\n"
    "movq 8(%%rdx), %%rdx;\n"
    "jmp endif1%=;\n"
    "else1%=:\n"
    "movq %%rcx, %%rax;\n"
    "movq 8(%%rcx), %%rcx;\n"
    "endif1%=:\n"
    "cmpq $0, %%rdi;\n"
    "jne else2%=;\n"
    "movq %%rax, %%rdi;\n"
    "movq %%rax, %%rsi;\n"
    "jmp endif2%=;\n"
    "else2%=:\n"
    "movq %%rax, 8(%%rsi);\n"
    "movq %%rax, %%rsi;\n"
    "endif2%=:\n"
    "jmp loop0%=;\n"
    "endloop0%=:\n"
    "loop1%=:\n"
    "cmpq $0, %%rdx;\n"
    "je endloop1%=;\n"
    "cmpq $0, %%rdi;\n"
    "jne else3%=;\n"
    "movq %%rdx, %%rdi;\n"
    "movq %%rdx, %%rsi;\n"
    "jmp endif3%=;\n"
    "else3%=:\n"
    "movq %%rdx, 8(%%rsi);\n"
    "movq %%rdx, %%rsi;\n"
    "endif3%=:\n"
    "movq 8(%%rdx), %%rdx;\n"
    "jmp loop1%=;\n"
    "endloop1%=:\n"
    "loop2%=:\n"
    "cmpq $0, %%rcx;\n"
    "je endloop2%=;\n"
    "cmpq $0, %%rdi;\n"
    "jne else4%=;\n"
    "movq %%rcx, %%rdi;\n"
    "movq %%rcx, %%rsi;\n"
    "jmp endif4%=;\n"
    "else4%=:\n"
    "movq %%rcx, 8(%%rsi);\n"
    "movq %%rcx, %%rsi;\n"
    "endif4%=:\n"
    "movq 8(%%rcx), %%rcx;\n"
    "jmp loop2%=;\n"
    "endloop2%=:\n"
    "movq %%rdi, %%rax;\n"
    "ret" : : );

    return screw_you_leetcode;
}
