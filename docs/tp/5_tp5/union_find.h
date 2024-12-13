#ifndef UNION_FIND_H
#define UNION_FIND_H

typedef int element;

struct partition;

typedef struct partition partition_t;

partition_t *partition_new(int nb_elements);

void partition_free(partition_t *p);

element find(partition_t *p, element x);

void merge(partition_t *p, element x, element y);

int nb_sets(partition_t *p);

int nb_elements(partition_t *p);

#endif
