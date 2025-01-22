#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <time.h>
#include "utils.h"

data* compute_centers(data* X, int n, int* classes, int k) {
    data* centers = malloc(k * sizeof(data));
    int* counts = malloc(k * sizeof(int));
    for(int i = 0; i < k; i++) {
        counts[i] = 0;
        for(int j = 0; j < LEN; j++) {
            centers[i].pixels[j] = 0.;
        }
    }
    for(int i = 0; i < k; i++) {
        int c = classes[i];
        counts[c]++;
        for(int j = 0; j < LEN; j++) {
            centers[c].pixels[j] += X[i].pixels[j];
        }
    }
    for(int i = 0; i < k; i++) {
        for(int j = 0; j < LEN; j++) {
            centers[i].pixels[j] /= counts[i];
        }
    }
    free(counts);
    return centers;
}

int* compute_classes(data* X, int n, data* centers, int k, bool* has_changed) {
    *has_changed = false;
    int* classes = malloc(n * sizeof(int));
    for(int i = 0; i < n; i++) {
        bool* T = malloc(k * sizeof(bool));
        for(int j = 0; j < k; j++) {
            T[j] = true;
        }
        int min_index = nearest(X[i], centers, T, k);
        classes[i] = min_index;
        if(min_index != classes[i]) {
            *has_changed = true;
        }
    }
    return classes;
}

data* init_centers(data* X, int n, int k) {
    data* centers = malloc(k * sizeof(data));
    bool* taken = malloc(n * sizeof(bool));
    for(int i = 0; i < n; i++) {
        taken[i] = false;
    }
    for(int i = 0; i < k; i++) {
        int j = rand() % n;
        while(taken[j]) {
            j = rand() % n;
        }
        taken[j] = true;
        centers[i] = X[j];
    }
    free(taken);
    return centers;
}

int* kmeans(data* X, int n, int k) {
    bool has_changed = true;
    data* centers = init_centers(X, n, k);
    while(true) {
        int* classes = compute_classes(X, n, centers, k, &has_changed);
        free(centers);
        if(!has_changed) {
            return classes;
        }
        centers = compute_centers(X, n, classes, k);
        free(classes);
    }
}

float precision(data* test, int n_test, data* train, int n_train, int k) {
    int correct = 0;
    int* classes = kmeans(train, n_train, k);
    for(int i = 0; i < n_test; i++) {
        bool* T = malloc(k * sizeof(bool));
        for(int j = 0; j < k; j++)
            T[j] = true;
        int c = nearest(test[i], train, T, k);
        if(classes[c] == test[i].class)
            correct++;
    }
    return (float) correct / n_test;
}

int main() {
    srand(time(NULL));
    int n = 10000;
    int k = 10;
    data* X = read_dataset("data/digit-train.txt", n);
    printf("Read %d samples\n", n);
    float p = precision(X, n, X, n, k);
    printf("Precision: %f\n", p);
    return 0;
}
