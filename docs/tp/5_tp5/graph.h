#ifndef GRAPH_H
#define GRAPH_H

#include <stdio.h>

typedef double weight_t;
typedef int vertex;

struct edge {
    vertex x;
    vertex y;
    weight_t rho;
};

typedef struct edge edge;

struct graph {
    int n;
    int *degrees;
    edge **adj;
};

typedef struct graph graph_t;


void graph_free(graph_t *g);

graph_t *read_graph(FILE *fp);

void print_graph(graph_t *g, FILE *fp);

int number_of_edges(graph_t *g);

edge *get_edges(graph_t *g, int *nb_edges);

void sort_edges(edge *edges, int p);

void quicksort_edges(edge *edges, int p);

void print_edge_array(edge *edges, int len);

#endif
