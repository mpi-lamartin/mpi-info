// Solution en O(l) avec un parcours en profondeur, où l = np est le nombre de cases de la grille
// Plutôt qu'utiliser une matrice de booléens vus, on peut mettre les cases visitées à 0 pour éviter de les revisiter

void dfs(char** grid, int n, int p, int i, int j) {
    if(grid[i][j] == '0') return;
    grid[i][j] = '0';
    if(i > 0) // chaque sommet a 4 voisins
        dfs(grid, n, p, i - 1, j);
    if(i < n - 1)
        dfs(grid, n, p, i + 1, j);
    if(j > 0)
        dfs(grid, n, p, i, j - 1);
    if(j < p - 1)
        dfs(grid, n, p, i, j + 1);
}

int numIslands(char** grid, int gridSize, int* gridColSize) {
    int n = gridSize, p = gridColSize[0];
    int k = 0;
    for(int i = 0; i < n; i++)
        for(int j = 0; j < p; j++)
            if(grid[i][j] == '1') {
                dfs(grid, n, p, i, j);
                k++;
            }
    return k;
}
