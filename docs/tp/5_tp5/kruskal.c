#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>

#include "graph.h"
#include "union_find.h"



edge *kruskal(graph_t *g, int *nb_chosen){
    int p;
    edge *edges = get_edges(g, &p);
    sort_edges(edges, p);
    partition_t *part = partition_new(g->n);
    edge *mst = malloc((g->n - 1) * sizeof(edge));
    int next_index = 0;
    for (int i = 0; i < p; i++) {
        if (nb_sets(part) == 1) break;
        edge e = edges[i];
        if (find(part, e.x) == find(part, e.y)) continue;
        merge(part, e.x, e.y);
        mst[next_index] = e;
        next_index++;
    }

    free(edges);
    partition_free(part);

    *nb_chosen = next_index;
    return mst;
}


float total_weight(edge *edges, int len){
    weight_t s = 0.;
    for (int i = 0; i < len; i++) {
        s += edges[i].rho;
    }
    return s;
}

int main(void){
   graph_t *g = read_graph(stdin);
   int nb_chosen;
   edge *edges = kruskal(g, &nb_chosen);
   bool connected = (nb_chosen == g->n - 1);
   if (connected) {
       printf("Minimum Spanning Tree:\n");
   } else {
       printf("Minimum Spanning Forest (%d trees):\n", g->n - nb_chosen);
   }
   printf("Nb edges: %d\n", nb_chosen);
   printf("Total weight: %.2f\n", total_weight(edges, nb_chosen));
   print_edge_array(edges, nb_chosen);
   free(edges);
   graph_free(g);
}
