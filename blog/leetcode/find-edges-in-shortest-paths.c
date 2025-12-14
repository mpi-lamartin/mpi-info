#include <stdbool.h>

int** createGraph(int n, int** edges, int edgesSize, int* edgesColSize) { // matrice d'adjacence
    int **g = (int**)malloc(n * sizeof(int*));
    for (int i = 0; i < n; i++) {
        g[i] = (int*)malloc(n * sizeof(int));
        for (int j = 0; j < n; j++)
            g[i][j] = -1;
    }
    for (int i = 0; i < edgesSize; i++) {
        int a = edges[i][0];
        int b = edges[i][1];
        int w = edges[i][2];
        g[a][b] = w;
        g[b][a] = w;
    }
    return g;
}

int** floydWarshall(int n, int** g) {
    int** dist = (int**)malloc(n * sizeof(int*));
    for (int i = 0; i < n; i++) {
        dist[i] = (int*)malloc(n * sizeof(int));
        for (int j = 0; j < n; j++) {
            if (i == j)
                dist[i][j] = 0;
            else if (g[i][j] != -1)
                dist[i][j] = g[i][j];
            else
                dist[i][j] = 1e9;
        }
    }
    for (int k = 0; k < n; k++)
        for (int i = 0; i < n; i++)
            for (int j = 0; j < n; j++)
                if (dist[i][k] + dist[k][j] < dist[i][j])
                    dist[i][j] = dist[i][k] + dist[k][j];
    return dist;
}

bool* findAnswer(int n, int** edges, int edgesSize, int* edgesColSize, int* returnSize) {
    int** g = createGraph(n, edges, edgesSize, edgesColSize);
    int** dist = floydWarshall(n, g);
    bool* answer = (bool*)malloc(edgesSize * sizeof(bool));
    for (int i = 0; i < edgesSize; i++) {
        int a = edges[i][0];
        int b = edges[i][1];
        int w = edges[i][2];
        if (dist[0][a] + w + dist[b][n - 1] == dist[0][n - 1] ||
            dist[0][b] + w + dist[a][n - 1] == dist[0][n - 1])
            answer[i] = true;
        else
            answer[i] = false;
    }
    *returnSize = edgesSize;
    for (int i = 0; i < n; i++) {
        free(g[i]);
        free(dist[i]);
    }
    free(g);
    free(dist);
    return answer;
}
