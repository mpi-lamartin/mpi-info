int findChampion(int n, int** edges, int edgesSize, int* edgesColSize) {
    int** g = (int**)malloc(sizeof(int*) * n);
    for (int i = 0; i < n; i++) {
        g[i] = (int*)malloc(sizeof(int) * n);
        for (int j = 0; j < n; j++)
            g[i][j] = 0;
    }
    for (int i = 0; i < edgesSize; i++) {
        int u = edges[i][0], v = edges[i][1];
        g[u][v] = 1;
    }
    int c = -1;
    for(int j = 0; j < n; j++) {
        int deg = 0;
        for (int i = 0; i < n; i++)
            deg += g[i][j];
        if(deg == 0) {
            if(c != -1) {
                return -1;
            }
            c = j;
        }
    }
    return c;
}