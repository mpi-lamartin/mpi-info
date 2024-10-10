#include <math.h>

int minPathSum(int** grid, int gridSize, int* gridColSize) {
    int n = gridSize, p = gridColSize[0]; // nombres de lignes et colonnes
    int** d = malloc(n*sizeof(int*));
    for(int i = 0; i < n; i++) {
        d[i] = malloc(p*sizeof(int));
        for(int j = 0; j < p; j++) {
            int a = -1;
            if(i == 0 && j == 0)
                a = 0;
            if(i > 0)
                a = d[i - 1][j];
            if(j > 0 && (a == -1 || d[i][j - 1] < a))
                a = d[i][j - 1];
            d[i][j] = a + grid[i][j];
        }
    }
    return d[n - 1][p - 1];
}
