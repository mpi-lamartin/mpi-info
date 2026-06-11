// Written by A. Grimaud
// March 2026

#include <stdio.h>
// #include "list.h"
#include "graph.h"
#include <string.h>
#include "ilist.h"
#include <limits.h>

double distance(double lat1, double long1, double lat2, double long2);

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

// Q18
graph read_graph_walk(char *stops_file, char *stop_times_file){
  int n = count_stops(stops_file);
  graph g = create_graph(n);

  // Read constrained transport edges
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

  // Read stop coordinates
  double *lat = malloc(n * sizeof(double));
  double *lon = malloc(n * sizeof(double));
  if (lat == NULL || lon == NULL){
    fprintf(stderr, "Memory allocation error\n");
    free(lat);
    free(lon);
    exit(EXIT_FAILURE);
  }

  f = fopen(stops_file, "r");
  if (f == NULL){
    fprintf(stderr, "Error opening file %s\n", stops_file);
    free(lat);
    free(lon);
    exit(EXIT_FAILURE);
  }

  // skip header line
  if (fgets(buffer, sizeof(buffer), f) == NULL){
    fclose(f);
    free(lat);
    free(lon);
    return g;
  }

  int stop_id;
  char stop_code[64];
  char stop_name[128];
  double stop_lat;
  double stop_lon;

  while (fscanf(f, "%d %63s %127s %lf %lf",
                &stop_id, stop_code, stop_name,
                &stop_lat, &stop_lon) == 5){
    lat[stop_id] = stop_lat;
    lon[stop_id] = stop_lon;
  }

  fclose(f);

  // Add walking edges
  for (int u = 0; u < n; u++){
    for (int v = u + 1; v < n; v++){
      if (distance(lat[u], lon[u], lat[v], lon[v]) < 0.1){
        add_walk_edge(g, u, v);
        add_walk_edge(g, v, u);
      }
    }
  }

  free(lat);
  free(lon);

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
    
    // Modification Q13 - début
    if (departure > T[d]){
      break;
    }
    // Modification Q13 - fin
    
    if (departure >= T[e.u] && arrival < T[e.v]){
      T[e.v] = arrival;
    }
    if (departure > T[d]){
      break;
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

// Q18
void print_minutes_as_time(int t){
  printf("%02d:%02d", t / 60, t % 60);
}

void print_path_rec(int s, int v, int pred[], bool pred_walk[],
                    int pred_dep[], int pred_arr[]){
  if (v == s){
    printf("%d", s);
    return;
  }

  if (pred[v] == -1){
    printf("(no path)");
    return;
  }

  print_path_rec(s, pred[v], pred, pred_walk, pred_dep, pred_arr);

  if (pred_walk[v]){
    printf("\n  -- walk (%d min) --> %d  [", pred_arr[v] - pred_dep[v], v);
    print_minutes_as_time(pred_dep[v]);
    printf(" -> ");
    print_minutes_as_time(pred_arr[v]);
    printf("]");
  }
  else{
    printf("\n  -- transport --> %d  [", v);
    print_minutes_as_time(pred_dep[v]);
    printf(" -> ");
    print_minutes_as_time(pred_arr[v]);
    printf("]");
  }
}

int earliest_arrival_walk(graph g, int s, int d, temps td){
  int *T = malloc(g.n * sizeof(int));
  int *pred = malloc(g.n * sizeof(int));
  bool *pred_walk = malloc(g.n * sizeof(bool));
  int *pred_dep = malloc(g.n * sizeof(int));
  int *pred_arr = malloc(g.n * sizeof(int));
  bool *done = malloc(g.n * sizeof(bool));

  if (T == NULL || pred == NULL || pred_walk == NULL ||
      pred_dep == NULL || pred_arr == NULL || done == NULL){
    fprintf(stderr, "Memory allocation error\n");
    exit(EXIT_FAILURE);
  }

  int infinity = INT_MAX / 4;
  for (int u = 0; u < g.n; u++){
    T[u] = infinity;
    pred[u] = -1;
    pred_walk[u] = false;
    pred_dep[u] = -1;
    pred_arr[u] = -1;
    done[u] = false;
  }

  int t0 = 60 * td.heure + td.minute;
  T[s] = t0;

  while (true){
    /* choose the unreached vertex with smallest arrival time */
    int u = -1;
    for (int i = 0; i < g.n; i++){
      if (!done[i] && T[i] < infinity){
        if (u == -1 || T[i] < T[u]){
          u = i;
        }
      }
    }

    if (u == -1){
      break; // no more reachable vertex 
    }

    if (u == d){
      break; // destination fixed
    }

    done[u] = true;

    list L = g.adj[u];
    while (!isEmpty(L)){
      arc e = value(L);
      int v = e.v;

      if (e.walk){
        int cand = T[u] + 2;   // 2 minutes per walking edge

        if (cand < T[v]){
          T[v] = cand;
          pred[v] = u;
          pred_walk[v] = true;
          pred_dep[v] = T[u];
          pred_arr[v] = cand;
        }
      }
      else{
        int departure = 60 * e.td.heure + e.td.minute;
        int arrival   = 60 * e.ta.heure + e.ta.minute;

        if (departure >= T[u] && arrival < T[v]){
          T[v] = arrival;
          pred[v] = u;
          pred_walk[v] = false;
          pred_dep[v] = departure;
          pred_arr[v] = arrival;
        }
      }

      L = next(L);
    }
  }

  if (T[d] >= infinity){
    printf("Destination unreachable\n");

    free(T);
    free(pred);
    free(pred_walk);
    free(pred_dep);
    free(pred_arr);
    free(done);

    return infinity;
  }

  printf("Chemin trouvé de %d vers %d :\n", s, d);
  print_path_rec(s, d, pred, pred_walk, pred_dep, pred_arr);
  printf("\nArrivée : ");
  print_minutes_as_time(T[d]);
  printf("\n");

  int result = T[d];

  free(T);
  free(pred);
  free(pred_walk);
  free(pred_dep);
  free(pred_arr);
  free(done);

  return result;
}

int main(){
  // Q10
  graph g = read_graph_walk("stops.txt", "stop_times.txt");
  
  // Q18
  printf("Arrival without walking : ");
  printf("%d\n", earliest_arrival(g, 108, 231, (temps){10,0}));
 
  printf("Arrival with walking : \n");
  printf("%d\n", earliest_arrival_walk(g, 108, 231, (temps){10,0}));
  
  return 0;
}
