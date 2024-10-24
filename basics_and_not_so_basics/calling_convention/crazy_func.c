#include <stdio.h>

// input this into compile explorer to see how the arguments are passed
// and how the stack is set up

int crazy_func(int a, int b, int c, char d, char* e, char** f, int g, short h, void* i, int j, char k, char l) {
    long long x = g + h;
    int y = j + k + l;
    return (int)(x + y);
}

int main() {
    char *str = "Hello";
    int ret = crazy_func(1, 2, 3, 'a', str, &str, 4, 5, (int*)123, 6, 'b', 'c');
    printf("%d\n", ret);
    return 0;
}
