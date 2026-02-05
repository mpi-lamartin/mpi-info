#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

#include "utils.h"

data* read_dataset(char* path, int nb_samples){
    FILE* fp = fopen(path, "r");
    int total_samples;
    fscanf(fp, "%d\n", &total_samples);
    data* X = malloc(nb_samples * sizeof(data));
    for (int i = 0; i < nb_samples; i++) {
        fscanf(fp, "%d", &(X[i].class));
        for (int j = 0; j < LEN; j++) {
            int pixel = 0;
            fscanf(fp, ",%d", &pixel);
            X[i].pixels[j] = pixel / 255.0;
        }
    }
    fclose(fp);
    return X;
}

float d(data x1, data x2) {
    float s = 0.;
    for (int i = 0; i < LEN; i++) {
        float delta = x1.pixels[i] - x2.pixels[i];
        s += delta * delta;
    }
    return s;
}

int nearest(data x, data* X, bool* T, int n) {
    float min_d = 1e100;
    int min_index = -1;
    for (int i = 0; i < n; i++) {
        if (T[i]) {
            float d_ = d(x, X[i]);
            if (d_ < min_d) {
                min_d = d_;
                min_index = i;
            }
        }
    }
    return min_index;
}

int majority(int* T, int n, int p) {
    int* counts = calloc(p, sizeof(int));
    for (int i = 0; i < n; i++) {
        counts[T[i]]++;
    }
    int max_count = 0;
    int max_index = -1;
    for (int i = 0; i < p; i++) {
        if (counts[i] > max_count) {
            max_count = counts[i];
            max_index = i;
        }
    }
    free(counts);
    return max_index;
}