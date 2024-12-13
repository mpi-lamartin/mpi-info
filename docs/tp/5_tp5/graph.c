#include <stdlib.h>
#include <stdio.h>

#include "graph.h"

void graph_free(graph_t *g){
    free(g->degrees);
    for (int i = 0; i < g->n; i++) {
        free(g->adj[i]);
    }
    free(g->adj);
    free(g);
}

graph_t *read_graph(FILE *fp){
    int n;
    fscanf(fp, "%d", &n);
    int *degrees = malloc(n * sizeof(int));
    edge **adj = malloc(n * sizeof(edge*));
    for (int i = 0; i < n; i++){
        fscanf(fp, "%d", &degrees[i]);
        // printf("%d : %d\n", i, degrees[i]);
        adj[i] = malloc(degrees[i] * sizeof(edge));
        for (int j = 0; j < degrees[i]; j++) {
            edge e;
            e.x = i;
            fscanf(fp, " (%d, %lf)", &e.y, &e.rho);
            adj[i][j] = e;
        }
    }
    graph_t *g = malloc(sizeof(graph_t));
    g->degrees = degrees;
    g->n = n;
    g->adj = adj;
    return g;
}

void print_graph(graph_t *g, FILE *fp){
    fprintf(fp, "%d\n", g->n);
    for (int i = 0; i < g->n; i++) {
        fprintf(fp, "%d ", g->degrees[i]);
        for (int j = 0; j < g->degrees[i]; j++) {
            edge e = g->adj[i][j];
            fprintf(fp, "(%d, %.3f) ", e.y, e.rho);
        }
        fprintf(fp, "\n");
    }
}


int number_of_edges(graph_t *g){
    int p = 0;
    for (vertex x = 0; x < g->n; x++) {
        p += g->degrees[x];
    }
    return p / 2;
}

edge *get_edges(graph_t *g, int *nb_edges){
    int p = number_of_edges(g);
    *nb_edges = p;
    edge *arr = malloc(p * sizeof(edge));
    int next_index = 0;
    for (vertex x = 0; x < g->n; x++) {
        for (int i = 0; i < g->degrees[x]; i++) {
            edge e = g->adj[x][i];
            if (e.x < e.y) {
            arr[next_index] = g->adj[x][i];
            next_index++;
            }
        }
    }
    return arr;
}

int compare_weights(const void *e1, const void *e2){
    weight_t w1 = ((edge*)e1)->rho;
    weight_t w2 = ((edge*)e2)->rho;
    if (w1 < w2) return -1;
    if (w1 > w2) return 1;
    return 0;
}


void sort_edges(edge *edges, int p){
    qsort(edges, p, sizeof(edge), compare_weights);
}

void swap_edges(edge *arr, int i, int j){
    edge tmp = arr[i];
    arr[i] = arr[j];
    arr[j] = tmp;
}

int partition(edge *arr, int len){
    weight_t w = arr[0].rho;
    int i = 1;
    for (int j = 1; j < len; j++) {
        if (arr[j].rho <= w) {
            swap_edges(arr, i, j);
            i++;
        }
    }
    swap_edges(arr, 0, i - 1);
    return i - 1;
}

void quicksort_edges(edge *arr, int len){
    if (len <= 1) return;
    int pivot = partition(arr, len);
    quicksort_edges(arr, pivot);
    quicksort_edges(arr + pivot + 1, len - pivot - 1);
}


void print_edge_array(edge *edges, int len){
    for (int i = 0; i < len; i++) {
        edge e = edges[i];
        printf("%d %d %.2f\n", e.x, e.y, e.rho);
    }
    printf("\n");
}
