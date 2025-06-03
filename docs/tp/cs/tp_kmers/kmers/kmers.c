#include "kmers.h"

const u64 P[5] = {4242424243, 4242424261, 4242424271, 4242424331, 4242424363};
const u64 B[5] = {257, 259, 263, 275, 289};
const u64 M = 10000000;

char* ex_seq = "ATGCCACAGCTAGATACATCCACCTGATTTATTATAATCTTTTCAATATTTCTCACCCTCTTCATCCTATTTCAACTAAAAATTTCAAATCACTACTACCCAGAAAACCCGATAACCAAATCTGCTAAAATTGCTGGTCAACATAATCCTTGAGAAAACAAATGAACGAAAATCTATTCGCTTCTTTCGCTGCCCCCTCAATAA";

u64 hash(char *s, int k, u64 b, u64 p) {
  assert(s != NULL && k > 0 && b > 1 && p > 1);
  /* À MODIFIER */
  return 0;
}

hashtbl* hashtbl_create(int m, u64 b, u64 p) {
  assert(m > 0 && b > 1 && p > 1 && p > (u64)m);
  /* À MODIFIER */
  return NULL;
}

void hashtbl_add_one(hashtbl* h, char* s, int k) {
  int i = hash(s, k, h->b, h->p) % (u64)h->m;
  cell* c = h->table[i];
  while (c != NULL) {
    if (strncmp(c->kmer, s, k) == 0) {
      c->count++;
      return;
    }
    c = c->next;
  }
  cell* new = malloc(sizeof(cell));
  new->kmer = malloc(k + 1);
  strncpy(new->kmer, s, k);
  new->kmer[k] = '\0';
  new->count = 1;
  new->next = h->table[i];
  h->table[i] = new;
}

void hashtbl_print(hashtbl* h) {
  for (int i = 0; i < h->m; i++) {
    cell* c = h->table[i];
    while (c != NULL) {
      printf("%s : %d\n", c->kmer, c->count);
      c = c->next;
    }
  }
}

int hashtbl_size(hashtbl* h) {
  int nb = 0;
  for (int i = 0; i < h->m; i++) {
    cell* c = h->table[i];
    while (c != NULL) {
      nb++;
      c = c->next;
    }
  }
  return nb;
}

void hashtbl_delete(hashtbl* h) {
  assert(h != NULL);
  /* À MODIFIER */
}

hashtbl* build(char* file_name, int k) {
  FILE* f = fopen(file_name, "r");
  if (f == NULL) {
    fprintf(stderr, "ERROR : could not open file %s\n", file_name);
    abort();
  }
  char line[20001]; // On admet qu'il n'y aura pas de dépassement
  hashtbl* h = hashtbl_create(M, B[0], P[0]);
  while (fscanf(f, "%s", line) != EOF) {
    int len = strlen(line);
    for (int i = 0; i <= len - k; i++) {
      hashtbl_add_one(h, &line[i], k);
    }
  }
  fclose(f);
  return h;
}

int main(void) {

}
