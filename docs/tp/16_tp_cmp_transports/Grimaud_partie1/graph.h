// Written by A. Grimaud
// March 2026

#ifndef GRAPH_H
#define GRAPH_H

#include "list.h"

typedef struct {
  list *adj;   // list of adj
  int n;       // number of vertices
} graph;

graph create_graph(int n);
void add_edge(graph g, int u, int v, temps td, temps ta);
void print_time(temps t);
void print_edge(arc e);
void print_graph(graph g);

#endif


