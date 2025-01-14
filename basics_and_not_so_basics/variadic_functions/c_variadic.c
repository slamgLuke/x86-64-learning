#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>


int max_from_list(int list_size, ...) {
    va_list args;
    va_start(args, list_size);
    int max = va_arg(args, int);
    for (int i = 1; i < list_size; i++) {
        int current = va_arg(args, int);
        if (current > max) {
            max = current;
        }
    }
    va_end(args);
    return max;
}

int main() {
    int max = max_from_list(10, -1, 4, 2, -9, 2, 4, 0, 1, -5, 5, 3);
    printf("max: %d\n", max);

    return 0;
}
