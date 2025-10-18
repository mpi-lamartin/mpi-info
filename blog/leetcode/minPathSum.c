#include <math.h>

// On utilise la récurrence suivante :
// d[i][j] = grid[i][j] + min(d[i - 1][j], d[i][j - 1])

int minPathSum(int** grid, int gridSize, int* gridColSize) {
    int n = gridSize, p = gridColSize[0]; // nombres de lignes et colonnes
    int** d = malloc(n*sizeof(int*)); // d[i][j] = poids min d'un chemin de (0,0) à (i,j)
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
