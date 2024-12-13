#include <stdlib.h>
#include <stdint.h>


struct partition {
    int nb_sets;
    int nb_elements;
    int *arr;
};

typedef struct partition partition_t;

partition_t *partition_new(int nb_elements){
    partition_t *p = malloc(sizeof(partition_t));
    p->arr = malloc(nb_elements * sizeof(int));
    p->nb_elements = nb_elements;
    p->nb_sets = nb_elements;
    for (int i = 0; i < nb_elements; i++) {
        p->arr[i] = -1;
    }
    return p;
}

void partition_free(partition_t *p){
    free(p->arr);
    free(p);
}

int find(partition_t *p, int x){
    if (p->arr[x] < 0) return x;
    int root = find(p, p->arr[x]);
    p->arr[x] = root;
    return root;
}

void merge(partition_t *p, int x, int y){
    int rx = find(p, x);
    int ry = find(p, y);

    if (rx == ry) return;

    int sizex = - p->arr[rx];
    int sizey = - p->arr[ry];
    if (sizex <= sizey) {
        p->arr[ry] += p->arr[rx];
        p->arr[rx] = ry;
    } else {
        p->arr[rx] += p->arr[ry];
        p->arr[ry] = rx;
    }
    p->nb_sets--;
}

int nb_sets(partition_t *p){
    return p->nb_sets;
}

int nb_elements(partition_t *p){
    return p->nb_elements;
}
