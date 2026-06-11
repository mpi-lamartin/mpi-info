// Written by A. Grimaud
// March 2026

#include <stdio.h>
#include <stdlib.h>
#include "graph.h"
#include "list.h"

graph create_graph(int n){
  graph g;
  g.n = n;
  g.adj = (list *)malloc(n * sizeof(list));
  if (g.adj == NULL){
    fprintf(stderr, "Memory allocation error while creating graph\n");
    exit(EXIT_FAILURE);
  }

  for (int vertex = 0; vertex < n; vertex++){
    g.adj[vertex] = createList();
  }

  return g;
}

void add_edge(graph g, int u, int v, temps td, temps ta){
  if (u < 0 || u >= g.n || v < 0 || v >= g.n){
    fprintf(stderr, "Invalid vertex index\n");
    exit(EXIT_FAILURE);
  }
  
  arc new_edge;
  new_edge.u = u;
  new_edge.v = v;
  new_edge.td = td;
  new_edge.ta = ta;
  new_edge.walk = false;

  g.adj[u] = insertBegin(g.adj[u], new_edge);
}

void add_walk_edge(graph g, int u, int v){
  if (u < 0 || u >= g.n || v < 0 || v >= g.n){
    fprintf(stderr, "Invalid vertex index\n");
    exit(EXIT_FAILURE);
  }
  
  arc new_edge;
  new_edge.u = u;
  new_edge.v = v;
  new_edge.td = (temps){0, 0};
  new_edge.ta = (temps){0, 0};
  new_edge.walk = true;

  g.adj[u] = insertBegin(g.adj[u], new_edge);
}

void print_time(temps t){
  printf("%02d:%02d", t.heure, t.minute);
}

void print_edge(arc e){
  if (e.walk){
    printf("(%d -> %d, walk, 2 min)\n", e.u, e.v);
  }
  else{
    printf(" (%d -> %d, ", e.u, e.v);
    print_time(e.td);
    printf(", ");
    print_time(e.ta);
    printf(")");
  }
}

void print_graph(graph g){
  for (int vertex = 0; vertex < g.n; vertex++){
    printf("Adj[%d] :", vertex);

    list current = g.adj[vertex];
    while (!isEmpty(current)){
      arc current_edge = value(current);
      print_edge(current_edge);
      current = next(current);
    }

    printf("\n");
  }
}
