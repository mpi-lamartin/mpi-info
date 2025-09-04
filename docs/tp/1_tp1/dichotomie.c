#include <stdbool.h>
#include <stdio.h>

bool dichotomie(int* t, int e, int i, int j) {
    if (i > j) {
        return false;
    }
    int m = (i + j) / 2;
    if (t[m] == e) {
        return true;
    } 
    if (t[m] < e) {
        return dichotomie(t, e, m + 1, j);
    }
    return dichotomie(t, e, i, m - 1);
}

int main() {
    int t[10] = {-4, -2, 0, 1, 3, 5, 7, 9, 11, 13};
    printf("%d\n", dichotomie(t, 13, 0, 10));
    printf("%d\n", dichotomie(t, 13, 0, 9));
    return 0;
}