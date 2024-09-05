#include <stdio.h>
#include <stdlib.h>

int knapsack(int C, int n, int *w, int *v) {
    int **dp = malloc((C + 1) * sizeof(int*));
    for (int i = 0; i < C + 1; i++) {
        dp[i] = malloc((n + 1) * sizeof(int));
        dp[i][0] = 0;
    }

    for (int k = 0; k < n + 1; k++)
        for (int c = 0; c < C + 1; c++) {
            dp[c][k] = dp[c][k - 1];
            if (w[k] <= c && dp[c][k] <= v[k] + dp[c - w[k]][k - 1])
                dp[c][k] = v[k] + dp[c - w[k]][k - 1];
        }
    return dp[C][n];
}

int main() {
    int weights[] = {2, 3, 6, 5, 8, 2, 2};
    int values[] = {1, 7, 10, 10, 13, 1, 1};
    printf("%d", knapsack(10, 7, weights, values)); // affiche 18
    return 0;
}