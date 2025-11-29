bool dfs(int u, int c, int* colors, int** g, int n) {
    colors[u] = c;
    for (int v = 1; v <= n; v++) {
        if (g[u][v]) { // il y a une arête entre u et v
            if (colors[v] == 0) {
                if (!dfs(v, -c, colors, g, n))
                    return false;
            } else if (colors[v] == c) {
                return false;
            }
        }
    }
    return true;
}

bool possibleBipartition(int n, int** dislikes, int dislikesSize, int* dislikesColSize) {
    int* colors = (int*)calloc(n + 1, sizeof(int)); // 0: non coloré, 1: rouge, -1: bleu
    int** g = (int**)malloc((n + 1) * sizeof(int*));
    for (int i = 0; i <= n; i++)
        g[i] = (int*)calloc(n + 1, sizeof(int));
    for (int i = 0; i < dislikesSize; i++) {
        int u = dislikes[i][0];
        int v = dislikes[i][1];
        g[v][u] = g[u][v] = 1;
    }

    for (int i = 1; i <= n; i++) {
        if (colors[i] == 0 && !dfs(i, 1, colors, g, n))
            return false;
    }
    return true;
}