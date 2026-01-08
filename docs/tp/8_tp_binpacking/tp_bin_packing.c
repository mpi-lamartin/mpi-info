#include <stdio.h>
#include <stdlib.h>
#include <time.h>

typedef struct instance {
    int n; // nombre d'objets
    int *w; // poids des objets
    int c; // capacité
} instance;

instance* random_instance(int n, int c) {
    instance* inst = malloc(sizeof(instance));
    inst->n = n;
    inst->w = malloc(n * sizeof(int));
    inst->c = c;
    for (int i = 0; i < n; i++)
        inst->w[i] = rand() % c + 1;
    return inst;
}

int next_fit(instance *inst) {
    int nb_bins = 0;
    int *bins = malloc(inst->n * sizeof(int));
    for(int i = 0; i < inst->n; i++) {
        if (bins[nb_bins] + inst->w[i] > inst->c)
            nb_bins++;
        bins[nb_bins] += inst->w[i];
    }
    free(bins);
    return nb_bins + 1;
}

int first_fit(instance *inst) {
    int nb_bins = 0;
    int *bins = malloc(inst->n * sizeof(int));
    for (int i = 0; i < inst->n; i++) {
        int j = 0;
        while (j < nb_bins && bins[j] + inst->w[i] > inst->c)
            j++;
        if (j == nb_bins)
            nb_bins++;
        bins[j] += inst->w[i];
    }
    free(bins);
    return nb_bins;
}

void sort(instance *inst) {
    for (int i = 0; i < inst->n; i++) {
        for (int j = i + 1; j < inst->n; j++) {
            if (inst->w[i] < inst->w[j]) {
                int tmp = inst->w[i];
                inst->w[i] = inst->w[j];
                inst->w[j] = tmp;
            }
        }
    }
}

int first_fit_decr(instance *inst) {
    sort(inst);
    return first_fit(inst);
}

int branch_and_bound(instance *inst, int i, int *bins, int nb_bins, int best) {
    if (nb_bins >= best)
        return best;
    if (i == inst->n) 
        return nb_bins;
    for (int j = 0; j < nb_bins; j++) {
        if (bins[j] + inst->w[i] <= inst->c) {
            bins[j] += inst->w[i];
            int res = branch_and_bound(inst, i + 1, bins, nb_bins, best);
            if (res < best)
                best = res;
            bins[j] -= inst->w[i];
        }
    }
    bins[nb_bins] = inst->w[i];
    int res = branch_and_bound(inst, i + 1, bins, nb_bins + 1, best);
    if (res < best)
        best = res;
    return best;
}
    
void print_instance(instance *inst) {
    printf("instance inst = {\n");
    printf("    .n = %d,\n", inst->n);
    printf("    .w = {");
    for (int i = 0; i < inst->n; i++)
        printf("%d, ", inst->w[i]);
    printf("},\n");
    printf("    .c = %d\n", inst->c);
    printf("};\n");
}

int main() {
    srand(time(NULL));
    instance q1 = {
        .n = 7,
        .w = (int[]){2, 5, 4, 7, 1, 3, 8},
        .c = 10
    };
    printf("next_fit: %d\n", next_fit(&q1));
    printf("first_fit: %d\n", first_fit(&q1));
    printf("first_fit_decr: %d\n", first_fit_decr(&q1));
    printf("branch_and_bound: %d\n", branch_and_bound(&q1, 0, malloc(q1.n * sizeof(int)), 0, q1.n));
    int n = 30;
    int c = 100;
    instance* inst = random_instance(n, c);
    print_instance(inst);
    int t = clock();
    printf("next_fit: %d (%f s)\n", next_fit(inst), (double)(clock() - t)/CLOCKS_PER_SEC);
    t = clock();
    printf("first_fit: %d (%f s)\n", first_fit(inst), (double)(clock() - t)/CLOCKS_PER_SEC);
    t = clock();
    printf("first_fit_decr: %d (%f s)\n", first_fit_decr(inst), (double)(clock() - t)/CLOCKS_PER_SEC);
    t = clock();
    printf("branch_and_bound: %d (%f s)\n", branch_and_bound(inst, 0, malloc(inst->n * sizeof(int)), 0, first_fit_decr(inst)), (double)(clock() - t)/CLOCKS_PER_SEC);
    free(inst->w);
    free(inst);
    return 0;
}


