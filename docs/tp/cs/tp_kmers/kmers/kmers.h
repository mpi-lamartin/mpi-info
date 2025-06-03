#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
#include <string.h>
#include <stdint.h>
#include <assert.h>

typedef uint64_t u64;

struct cell {
  char* kmer;
  int count;
  struct cell* next;
};
typedef struct cell cell;

struct hashtbl {
  cell** table;
  int m;
  u64 b;
  u64 p;
};
typedef struct hashtbl hashtbl;

struct filter {
  int m;
  int r;
  int* count;
};
typedef struct filter filter;

u64 exp_mod(u64 x, u64 n, u64 p);

u64 hash(char *s, int k, u64 b, u64 p);

hashtbl* hashtbl_create(int m, u64 b, u64 p);

void hashtbl_add_one(hashtbl* h, char* s, int k);

void hashtbl_print(hashtbl* h);

int hashtbl_size(hashtbl* h);

void hashtbl_delete(hashtbl* h);

hashtbl* build(char* file_name, int k);

filter* filter_create(int m, int r);

void filter_add_one(filter* f, char* kmer, int k);

bool filter_mem(filter* f, char* kmer, int k, int c);

void filter_delete(filter* f);

hashtbl* fast_build(char* file_name, int k, int c);
