// Written by A. Grimaud
// March 2026

#include <stdio.h>
// #include "list.h"
#include "graph.h"
#include <string.h>
#include "ilist.h"

// Q4
bool before_or_equal(temps t1, temps t2){
  if (t1.heure < t2.heure) return true;
  if (t1.heure > t2.heure) return false;
  return t1.minute <= t2.minute;
}

// Q9
temps parse_time(char *s){
  temps t;
  int sec;
  if (sscanf(s, "%d:%d:%d", &t.heure, &t.minute, &sec) != 3){
    fprintf(stderr, "Invalid time format\n");
    exit(EXIT_FAILURE);
  }
  return t;
}

// Q10
int count_stops(char *filename){
  FILE *f = fopen(filename, "r");
  if (f == NULL){
    fprintf(stderr, "Error opening file %s\n", filename);
    exit(EXIT_FAILURE);
  }

  int count = 0;
  char buffer[256];
  /* skip header line */
  if (fgets(buffer, sizeof(buffer), f) == NULL){
    fclose(f);
    return 0;
  }
  /* count remaining lines */
  while (fgets(buffer, sizeof(buffer), f) != NULL){
    count++;
  }
  fclose(f);
  return count;
}

bool read_stop_time_line(FILE *f, char *trip_id, temps *t, int *stop_id){
  char time_str[16];
  int unused1, unused2;
  int n = fscanf(f, "%s %s %d %d %d",
                 trip_id, time_str, stop_id, &unused1, &unused2);
  if (n != 5){
    return false;
  }
  *t = parse_time(time_str);
  return true;
}

graph read_graph(char *stops_file, char *stop_times_file){
  int n = count_stops(stops_file);
  graph g = create_graph(n);

  FILE *f = fopen(stop_times_file, "r");
  if (f == NULL){
    fprintf(stderr, "Error opening file %s\n", stop_times_file);
    exit(EXIT_FAILURE);
  }

  char buffer[256];
  // skip header line
  if (fgets(buffer, sizeof(buffer), f) == NULL){
    fclose(f);
    return g;
  }

  char prev_trip[64];
  char trip[64];
  int prev_stop;
  int stop;
  temps prev_time;
  temps time;
  // read first useful line
  if (!read_stop_time_line(f, prev_trip, &prev_time, &prev_stop)){
    fclose(f);
    return g;
  }
  // read remaining lines
  while (read_stop_time_line(f, trip, &time, &stop)){
    if (strcmp(prev_trip, trip) == 0){
      add_edge(g, prev_stop, stop, prev_time, time);
    }
    strcpy(prev_trip, trip);
    prev_stop = stop;
    prev_time = time;
  }
  fclose(f);
  return g;
}

// Q12
int count_edges(graph g){
  int count = 0;
  for (int u = 0; u < g.n; u++){
    list L = g.adj[u];
    while (!isEmpty(L)){
      count++;
      L = next(L);
    }
  }
  return count;
}

void fill_edges(graph g, arc edges[]){
  int k = 0;
  for (int u = 0; u < g.n; u++){
    list L = g.adj[u];
    while (!isEmpty(L)){
      edges[k] = value(L);
      k++;
      L = next(L);
    }
  }
}

int compare_edges(const void *a, const void *b){
  arc e1 = *(const arc *)a;
  arc e2 = *(const arc *)b;
  int t1 = 60 * e1.td.heure + e1.td.minute;
  int t2 = 60 * e2.td.heure + e2.td.minute;
  if (t1 < t2) return -1;
  if (t1 > t2) return 1;
  return 0;
}

int first_edge_after(arc edges[], int m, temps td){
  int target = 60 * td.heure + td.minute;
  int left = 0;
  int right = m;
  while (left < right){
    int mid = (left + right) / 2;
    int departure = 60 * edges[mid].td.heure + edges[mid].td.minute;
    if (departure < target){
      left = mid + 1;
    }
    else{
      right = mid;
    }
  }
  return left;
}

// Algorithme 1 - arrivée le plus tôt
int earliest_arrival(graph g, int s, int d, temps td){
  int m = count_edges(g);
  arc *edges = malloc(m * sizeof(arc));
  if (edges == NULL){
    fprintf(stderr, "Memory allocation error\n");
    exit(EXIT_FAILURE);
  }
  fill_edges(g, edges);

  qsort(edges, m, sizeof(arc), compare_edges);
  int *T = malloc(g.n * sizeof(int));
  if (T == NULL){
    fprintf(stderr, "Memory allocation error\n");
    free(edges);
    exit(EXIT_FAILURE);
  }

  int infinity = 24 * 60 + 1;
  for (int u = 0; u < g.n; u++){
    T[u] = infinity;
  }

  int t0 = 60 * td.heure + td.minute;
  T[s] = t0;
  int i0 = first_edge_after(edges, m, td);
  for (int i = i0; i < m; i++){
    arc e = edges[i];
    int departure = 60 * e.td.heure + e.td.minute;
    int arrival = 60 * e.ta.heure + e.ta.minute;
    
    // Q13 - début
    if (departure > T[d]){
      break;
    }
    // Q13 - fin
    
    if (departure >= T[e.u] && arrival < T[e.v]){
      T[e.v] = arrival;
    }
  }
  int result = T[d];
  free(T);
  free(edges);
  return result;
}

// Q12 - print path
int earliest_arrival_path(graph g, int s, int d, temps td){
  int m = count_edges(g);

  arc *edges = malloc(m * sizeof(arc));
  if (edges == NULL){
    fprintf(stderr, "Memory allocation error\n");
    exit(EXIT_FAILURE);
  }
  fill_edges(g, edges);
  qsort(edges, m, sizeof(arc), compare_edges);

  int *T = malloc(g.n * sizeof(int));
  arc *pred = malloc(g.n * sizeof(arc));
  bool *has_pred = malloc(g.n * sizeof(bool));

  if (T == NULL || pred == NULL || has_pred == NULL){
    fprintf(stderr, "Memory allocation error\n");
    free(edges);
    free(T);
    free(pred);
    free(has_pred);
    exit(EXIT_FAILURE);
  }

  int infinity = 24 * 60 + 1;
  for (int u = 0; u < g.n; u++){
    T[u] = infinity;
    has_pred[u] = false;
  }

  int t0 = 60 * td.heure + td.minute;
  T[s] = t0;

  int i0 = first_edge_after(edges, m, td);

  for (int i = i0; i < m; i++){
    arc e = edges[i];
    int departure = 60 * e.td.heure + e.td.minute;
    int arrival = 60 * e.ta.heure + e.ta.minute;

    // Modification Q13 - début
    if (departure > T[d]){
      break;
    }
    // Modification Q13 - fin

    if (departure >= T[e.u] && arrival < T[e.v]){
      T[e.v] = arrival;
      pred[e.v] = e;
      has_pred[e.v] = true;
    }
  }

  int result = T[d];

  if (result == infinity){
    printf("Destination unreachable\n");
  }
  else{
    int *path_vertices = malloc(g.n * sizeof(int));
    if (path_vertices == NULL){
      fprintf(stderr, "Memory allocation error\n");
      free(T);
      free(pred);
      free(has_pred);
      free(edges);
      exit(EXIT_FAILURE);
    }

    int len = 0;
    int v = d;

    while (v != s){
      if (!has_pred[v]){
        printf("Path reconstruction error\n");
        free(path_vertices);
        free(T);
        free(pred);
        free(has_pred);
        free(edges);
        return result;
      }
      path_vertices[len] = v;
      len++;
      v = pred[v].u;
    }

    printf("Path:\n");
    for (int i = len - 1; i >= 0; i--){
      print_edge(pred[path_vertices[i]]);
    }

    free(path_vertices);
  }

  free(T);
  free(pred);
  free(has_pred);
  free(edges);

  return result;
}

// Q14
// Algorithme - départ le plus tard
int latest_departure(graph g, int s, int d, temps ta){
  int m = count_edges(g);

  arc *edges = malloc(m * sizeof(arc));
  if (edges == NULL){
    fprintf(stderr, "Memory allocation error\n");
    exit(EXIT_FAILURE);
  }

  fill_edges(g, edges);
  qsort(edges, m, sizeof(arc), compare_edges);

  int *T = malloc(g.n * sizeof(int));
  if (T == NULL){
    fprintf(stderr, "Memory allocation error\n");
    free(edges);
    exit(EXIT_FAILURE);
  }

  // initialize
  for (int i = 0; i < g.n; i++){
    T[i] = -1;  /* -∞ */
  }

  int t_dest = 60 * ta.heure + ta.minute;
  T[d] = t_dest;

  // backward traversal
  for (int i = m - 1; i >= 0; i--){
    arc e = edges[i];

    int departure = 60 * e.td.heure + e.td.minute;
    int arrival = 60 * e.ta.heure + e.ta.minute;

    if (arrival <= T[e.v] && departure > T[e.u]){
      T[e.u] = departure;
    }
  }

  int result = T[s];
  free(T);
  free(edges);

  return result;
}

// Q14 - print path
int latest_departure_path(graph g, int s, int d, temps ta){
  int m = count_edges(g);

  arc *edges = malloc(m * sizeof(arc));
  if (edges == NULL){
    fprintf(stderr, "Memory allocation error\n");
    exit(EXIT_FAILURE);
  }

  fill_edges(g, edges);
  qsort(edges, m, sizeof(arc), compare_edges);

  int *T = malloc(g.n * sizeof(int));
  arc *succ = malloc(g.n * sizeof(arc));
  bool *has_succ = malloc(g.n * sizeof(bool));

  if (T == NULL || succ == NULL || has_succ == NULL){
    fprintf(stderr, "Memory allocation error\n");
    free(edges);
    free(T);
    free(succ);
    free(has_succ);
    exit(EXIT_FAILURE);
  }

  for (int i = 0; i < g.n; i++){
    T[i] = -1;
    has_succ[i] = false;
  }

  int t_dest = 60 * ta.heure + ta.minute;
  T[d] = t_dest;

  // backward traversal
  for (int i = m - 1; i >= 0; i--){
    arc e = edges[i];

    int departure = 60 * e.td.heure + e.td.minute;
    int arrival = 60 * e.ta.heure + e.ta.minute;

    if (arrival <= T[e.v] && departure > T[e.u]){
      T[e.u] = departure;
      succ[e.u] = e;
      has_succ[e.u] = true;
    }
  }

  int result = T[s];

  if (result == -1){
    printf("No valid departure found\n");
  }
  else{
    printf("Path:\n");

    int u = s;
    while (u != d){
      if (!has_succ[u]){
        printf("Path reconstruction error\n");
        break;
      }

      print_edge(succ[u]);
      u = succ[u].v;
    }
  }

  free(T);
  free(succ);
  free(has_succ);
  free(edges);

  return result;
}

// Q16
bool meilleur(intervalle c1, intervalle c2){
  return before_or_equal(c2.td, c1.td) && before_or_equal(c1.ta, c2.ta);
}

// Q17 
// Algorithme 2 - le plus rapide
ilist add_interval(ilist L, intervalle c){
  ilist cur = L;
  ilist prev = NULL;

  while (cur != NULL){
    intervalle x = value_iList(cur);

    /* if an interval already in the list is better than c, do not add c */
    if (meilleur(x, c)){
      return L;
    }

    /* if c is better than x, remove x */
    if (meilleur(c, x)){
      if (prev == NULL){
        L = deleteBegin_iList(L);
        cur = L;
      }
      else{
        prev->next = deleteBegin_iList(cur);
        cur = prev->next;
      }
    }
    else{
      prev = cur;
      cur = cur->next;
    }
  }

  return insertBegin_iList(L, c);
}

int best_start_before(ilist L, temps limit){
  bool found = false;
  int best_start = -1;
  int best_arrival = -1;
  int limit_min = 60 * limit.heure + limit.minute;

  while (!isEmpty_iList(L)){
    intervalle c = value_iList(L);
    int arrival = 60 * c.ta.heure + c.ta.minute;

    if (arrival <= limit_min){
      if (!found || arrival > best_arrival){
        best_arrival = arrival;
        best_start = 60 * c.td.heure + c.td.minute;
        found = true;
      }
    }

    L = L->next;
  }

  return best_start;
}

int fastest_path(graph g, int s, int d, intervalle c){
  int m = count_edges(g);

  arc *edges = malloc(m * sizeof(arc));
  if (edges == NULL){
    fprintf(stderr, "Memory allocation error\n");
    exit(EXIT_FAILURE);
  }

  fill_edges(g, edges);
  qsort(edges, m, sizeof(arc), compare_edges);

  int *T = malloc(g.n * sizeof(int));
  ilist *L = malloc(g.n * sizeof(ilist));

  if (T == NULL || L == NULL){
    fprintf(stderr, "Memory allocation error\n");
    free(edges);
    exit(EXIT_FAILURE);
  }

  int infinity = 24 * 60 + 1;
  //int td = 60 * c.td.heure + c.td.minute;
  int ta = 60 * c.ta.heure + c.ta.minute;

  for (int u = 0; u < g.n; u++){
    T[u] = infinity;
    L[u] = create_iList();
  }

  T[s] = 0;

  int i0 = first_edge_after(edges, m, c.td);

  for (int i = i0; i < m; i++){
    arc e = edges[i];
    int arrival = 60 * e.ta.heure + e.ta.minute;

    if (arrival > ta){
      continue;
    }

    if (e.u == s){
      intervalle start_interval = {e.td, e.td};
      L[s] = add_interval(L[s], start_interval);
    }

    int start = best_start_before(L[e.u], e.td);
    if (start != -1){
      intervalle new_interval = {
        (temps){start / 60, start % 60},
        e.ta
      };

      L[e.v] = add_interval(L[e.v], new_interval);

      if (arrival - start < T[e.v]){
        T[e.v] = arrival - start;
      }
    }
  }

  int result = (T[d] == infinity) ? -1 : T[d];

  free(T);
  free(L);
  free(edges);

  return result;
}


int main(){
  // Q10
  graph g = read_graph("stops.txt", "stop_times.txt");
  /* print_graph(g); */

  // Q12 - Q13
  printf("Departure time from 108: 10:00\n");
  int arrival = earliest_arrival_path(g, 108, 231, (temps){10, 0});
  if (arrival <= 24 * 60){
    printf("\n Arrival time at 231: %02d:%02d\n\n", arrival/60, arrival%60);
  }
  else{
    printf("\n Destination unreachable\n\n");
  }

  // Q14
  printf("Arrival time at 231 from 108: 11:00\n");
  int departure = latest_departure_path(g, 108, 231, (temps){11, 0});
  if (departure >= 0){
    printf("\n Latest departure time: %02d:%02d\n\n", departure/60, departure%60);
  }
  else{
    printf("\n No valid departure found\n\n");
  }

  // Q17
  printf("Fastest path from 108 to 231 on [09:00,10:00]: ");
  intervalle c = { (temps){9, 0}, (temps){10, 0} };
  int d = fastest_path(g, 108, 231, c);
  if (d >= 0){
    printf("%d minutes\n", d);
  }
  else{
    printf("No valid path.\n");
  }

  return 0;
}
