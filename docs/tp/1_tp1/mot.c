#include <string.h>
#include <stdio.h>

int recherche(char* m, char* text) {
    int k = strlen(m);
    for(int i = 0; i < strlen(text) - k + 1; i++)
        for(int j = 0; text[i + j] == m[j]; j++)
            if(j == k - 1)
                return i;
    return -1;
}        

int main() {
    printf("%d\n", recherche("world", "hello world!"));
    printf("%d\n", recherche("elo", "hello"));
    return 0;
}