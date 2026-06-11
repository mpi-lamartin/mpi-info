// Written by A. Grimaud
// March 2026

#include <stdio.h>
// #include "list.h"
#include "graph.h"
#include <string.h>

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

int main(){
  // Q9
  char s[] = "16:34:18";
  temps t = parse_time(s);
  print_time(t); printf("\n");

  // Q10
  graph g = read_graph("stops.txt", "stop_times.txt");
  print_graph(g);
  
  return 0;
}
