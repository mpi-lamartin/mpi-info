/*::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::*/
/* Nicolas Pécheux <info.cpge@cpge.info>                            */
/* http://cpge.info                                                 */
/*::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::*/

#include "kmers.h"

const u64 P[5] = {4242424243, 4242424261, 4242424271, 4242424331, 4242424363};
const u64 B[5] = {257, 259, 263, 275, 289};
const u64 M = 10000000;

char* ex_seq = "ATGCCACAGCTAGATACATCCACCTGATTTATTATAATCTTTTCAATATTTCTCACCCTCTTCATCCTATTTCAACTAAAAATTTCAAATCACTACTACCCAGAAAACCCGATAACCAAATCTGCTAAAATTGCTGGTCAACATAATCCTTGAGAAAACAAATGAACGAAAATCTATTCGCTTCTTTCGCTGCCCCCTCAATAA";

u64 exp_mod(u64 x, u64 n, u64 p) {
  u64 res = 1;
  while (n > 0) {
    if (n % 2 == 1) res = (res * x) % p;
    x = (x * x) % p;
    n /= 2;
  }
  return res;
}

u64 hash(char *s, int k, u64 b, u64 p) {
  assert(s != NULL && k > 0 && b > 1 && p > 1);
  u64 res = 0;
  for (int i = 0; i < k; i++) {
    res = (((res * b) % p) + (u64)s[i]) % p;
  }
  return res;
}

/* int bk = exp_mod(b, k, p); à précalculer */
/* int64_t hash_suivant(int64_t prev, char deb, char fin, int bk, int b, int p) { */
/*   return (b * prev - deb * bk + fin + p) % p; */
/* } */

hashtbl* hashtbl_create(int m, u64 b, u64 p) {
  assert(m > 0 && b > 1 && p > 1 && p > (u64)m);
  hashtbl* h = malloc(sizeof(hashtbl));
  h->table = malloc(m * sizeof(cell*));
  for (int i = 0; i < m; i++) {
    h->table[i] = NULL;
  }
  h->m = m;
  h->b = b;
  h->p = p;
  return h;
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
  for (int i = 0; i < h->m; i++) {
    cell* c = h->table[i];
    while (c != NULL) {
      cell* tmp = c;
      c = c->next;
      free(tmp->kmer);
      free(tmp);
    }
  }
  free(h->table);
  free(h);
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

filter* filter_create(int m, int r) {
  filter* f = malloc(sizeof(filter));
  f->m = m;
  f->r = r;
  f->count = malloc(m * sizeof(int));
  for (int i = 0; i < m; i++) {
    f->count[i] = 0;
  }
  return f;
}

void filter_delete(filter* f) {
  free(f->count);
  free(f);
}

void filter_add_one(filter* f, char* kmer, int k) {
  for (int i = 0; i < f->r; i++) {
    f->count[hash(kmer, k, B[i], P[i]) % (u64)f->m]++;
  }
}

bool filter_mem(filter* f, char* kmer, int k, int c) {
  for (int i = 0; i < f->r; i++) {
    if (f->count[hash(kmer, k, B[i], P[i]) % (u64)f->m] < c) {
      return false;
    }
  }
  return true;
}

hashtbl* fast_build(char* file_name, int k, int c) {
  FILE* f = fopen(file_name, "r");
  if (f == NULL) {
    fprintf(stderr, "ERROR : could not open file %s\n", file_name);
    abort();
  }
  char line[20001]; // On admet qu'il n'y aura pas de dépassement
  hashtbl* h = hashtbl_create(M, B[0], P[0]);
  filter* y = filter_create(M, 3);
  while (fscanf(f, "%s", line) != EOF) {
    int len = strlen(line);
    for (int i = 0; i <= len - k; i++) {
      if (!filter_mem(y, &line[i], k, c - 1)) {
        filter_add_one(y, &line[i], k);
      } else {
        hashtbl_add_one(h, &line[i], k);
     }
    }
  }
  filter_delete(y);
  fclose(f);
  return h;
}

int main(void) {

  printf("* 2^1000 mod 131 = %llu\n", exp_mod(2, 1000, 131));
  printf("* B[0]^42 mod P[0] = %llu\n", exp_mod(B[0], 42, P[0]));
  printf("* hash(ex_seq, 100, 2, 131) = %llu\n", hash(ex_seq, 100, 2, 131));
  printf("* hash(ex_seq, 10, B[0], P[0]) = %llu\n", hash(ex_seq, 10, B[0], P[0]));

  hashtbl* h = hashtbl_create(M, B[0], P[0]);
  int ex_len = strlen(ex_seq);
  int k = 3;
  for (int i = 0; i <= ex_len - k; i++) {
    hashtbl_add_one(h, &ex_seq[i], k);
  }
  printf("* Nombre de 3-mers dans ex_seq : %d\n", hashtbl_size(h));
  hashtbl_delete(h);

  hashtbl* h_human = build("data/human.seq", 30);
  printf("* Nombre de 30-mers chez l'humain : %d\n", hashtbl_size(h_human));
  hashtbl_delete(h_human);

  hashtbl* h_dog_filtered = fast_build("data/dog.seq", 20, 4);
  printf("* Nombre approximatif de 20-mers chez le chien apparaissant au moins 4 fois : %d\n", hashtbl_size(h_dog_filtered));
  hashtbl_delete(h_dog_filtered);

}
