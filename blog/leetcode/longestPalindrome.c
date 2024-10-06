#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char* subword(char* s, int i, int j) {
    char* t = malloc(j - i + 2);
    for(int k = i; k <= j; k++)
        t[k - i] = s[k];
    t[j - i + 1] = '\0';
    return t;
}

char* longestPalindrome(char* s) {
    int n = strlen(s);
    bool** b = malloc(n*sizeof(bool*));
    for(int i = 0; i < n; i++) {
        b[i] = malloc(n*sizeof(bool));
        for(int j = 0; j < n; j++) {
            b[i][j] = true;
        }
    }

    int imax = 0, kmax = 0;
    for(int k = 1; k < n; k++)
        for(int i = 0; i < n - k; i++) {
            b[i][i + k] = s[i] == s[i + k] && b[i + 1][i + k - 1];
            if(b[i][i + k]) {
                kmax = k;
                imax = i;
            }
        }
    return subword(s, imax, imax + kmax);
}