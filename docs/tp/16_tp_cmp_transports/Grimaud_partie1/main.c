// Written by A. Grimaud
// March 2026

#include <stdio.h>
// #include "list.h"
#include "graph.h"

// Q2
int Difference(temps t1, temps t2){
  int m1 = t1.heure * 60 + t1.minute;
  int m2 = t2.heure * 60 + t2.minute;
  return abs(m2 - m1);
}

// Q4
bool before_or_equal(temps t1, temps t2){
  if (t1.heure < t2.heure) return true;
  if (t1.heure > t2.heure) return false;
  return t1.minute <= t2.minute;
}

int min_time_path(graph g, int vertices[], int p, temps t){
  if (p <= 1){
    return 0;
  }
  
  temps t0 = t;
  temps cur = t;

  for (int i = 0; i < p - 1; i++){
    int start = vertices[i];
    int end = vertices[i + 1];
    list L = g.adj[start];
    bool found = false;
    arc best;

    while (!isEmpty(L)){
      arc e = value(L);
      if (e.v == end && before_or_equal(cur, e.td)){
        if (!found || before_or_equal(e.td, best.td)){
          best = e;
          found = true;
        }
      }
      L = next(L);
    }
    
    if (!found){
      return -1;
    }
    cur = best.ta;
    print_edge(best);
  }

  return Difference(t0, cur);
}

// Q7 
int min_time_path24(graph g, int vertices[], int p, temps t){
  if (p <= 1){
    return 0;
  }

  int day = 24 * 60;
  int t0 = 60 * t.heure + t.minute;
  int cur = t0;

  for (int i = 0; i < p - 1; i++){
    int start = vertices[i];
    int end = vertices[i + 1];
    list L = g.adj[start];
    bool found = false;
    int best_arrival = 0;
    arc best_edge;

    while (!isEmpty(L)){
      arc e = value(L);
      if (e.v == end){
        int departure = 60 * e.td.heure + e.td.minute;
        int arrival = 60 * e.ta.heure + e.ta.minute;
        // shift departure to the first feasible occurrence
        int departure_abs = departure;
        if (departure_abs < cur){
          departure_abs +=
	    ((cur - departure_abs + day - 1) / day) * day;
        }
        // arrival follows the same duration 
        int arrival_abs = departure_abs + (arrival - departure);
        if (!found || arrival_abs < best_arrival){
          best_arrival = arrival_abs;
	  best_edge = e;
          found = true;
        }
      }
      L = next(L);
    }

    if (!found){
      return -1;
    }
    cur = best_arrival;
    print_edge(best_edge);
  }
  return cur - t0;
}

int main(){
  // Q2
  temps t1 = {10, 15}; // 10h15
  temps t2 = {11, 45}; // 11h45
  int d = Difference(t1, t2);
  printf("Difference entre %02dh%02d et %02dh%02d : %d minutes\n",
         t1.heure, t1.minute, t2.heure, t2.minute, d);

  // Q6 Graphe - Convention : A=0, B=1, C=2, D=3, E=4 
  graph g = create_graph(5);
  add_edge(g, 0, 1, (temps){10, 8},  (temps){10, 13});
  add_edge(g, 0, 4, (temps){10, 48},  (temps){10, 51});
  add_edge(g, 1, 2, (temps){10, 15}, (temps){10, 27});
  add_edge(g, 2, 1, (temps){10, 42}, (temps){10, 49});
  add_edge(g, 2, 3, (temps){10, 31}, (temps){10, 34});
  add_edge(g, 3, 0, (temps){10, 42}, (temps){10, 46}); 
  add_edge(g, 3, 1, (temps){10, 33}, (temps){10, 38}); 
  add_edge(g, 4, 3, (temps){10, 0},  (temps){10, 3}); 
  add_edge(g, 4, 3, (temps){10, 53}, (temps){10, 56}); 
  // Arc ajouté à la question 6
  add_edge(g, 3, 0, (temps){10, 4}, (temps){10, 6}); 
  print_graph(g);

  // Q4
  printf("\n");
  int path1[] = {0, 1, 2, 3};
  int mint1 = min_time_path(g, path1, 4, (temps){10, 0});
  printf("\nMinimal duration (0,1,2,3): %d minutes\n", mint1);

  int path2[] = {4, 3, 1, 2};
  int mint2 = min_time_path(g, path2, 4, (temps){10, 0});
  printf("\nMinimal duration (4,3,1,2): %d minutes\n", mint2);

  int path3[] = {0, 4, 3};
  int mint3 = min_time_path(g, path3, 3, (temps){10, 0});
  printf("\nMinimal duration (0,4,3): %d minutes\n", mint3);

  // Q7
  printf("\n");
  //int path1[] = {0, 1, 2, 3};
  int mint1bis = min_time_path24(g, path1, 4, (temps){10, 0});
  printf("\nMinimal duration (0,1,2,3): %d minutes\n", mint1bis);

  //int path2[] = {4, 3, 1, 2};
  int mint2bis = min_time_path24(g, path2, 4, (temps){10, 0});
  printf("\nMinimal duration (4,3,1,2): %d minutes\n", mint2bis);

  //int path3[] = {0, 4, 3};
  int mint3bis = min_time_path24(g, path3, 3, (temps){10, 0});
  printf("\nMinimal duration (0,4,3): %d minutes\n", mint3bis);

  return 0;
}
