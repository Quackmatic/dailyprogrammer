    #include <stdio.h>
    
    int main(int c, char * _[]) {
        unsigned int a = 0, b = 0;
		scanf("%u %u", &a, &b);
        printf("%g%% compatibility\n"
               "%u should avoid %u\n"
               "%u should avoid %u\n",
               3.125 * __builtin_popcount(a ^ ~b), a, ~a, b, ~b);
    }
