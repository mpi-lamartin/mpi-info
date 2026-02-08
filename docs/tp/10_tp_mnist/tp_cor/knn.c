#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include "utils.h"

int* k_nearest(data x, data* X, int n, int k) {
    int* ans = malloc(k * sizeof(int));
    bool* T = malloc(n * sizeof(bool));
    for(int i = 0; i < n; i++) {
        T[i] = true;
    }
    for(int i = 0; i < k; i++) {
        int min_index = nearest(x, X, T, n);
        T[min_index] = false;
        ans[i] = min_index;
    }
    free(T);
    return ans;
}

int knn(data x, data* X, int n, int k) {
    int* indices = k_nearest(x, X, n, k);
    int* classes = malloc(k * sizeof(int));
    for(int i = 0; i < k; i++) {
        classes[i] = X[indices[i]].class;
    }
    return majority(classes, k, NB_CLASSES);
}

float precision(data* test, int n_test, data* train, int n_train, int k) {
    int correct = 0;
    for(int i = 0; i < n_test; i++) {
        int c = knn(test[i], train, n_train, k);
        if(c == test[i].class) {
            correct++;
        }
    }
    return (float) correct / n_test;
}

int main() {
    int n_train = 10000;
    int n_test = 200;
    int k = 3;
    data *train = read_dataset("data/digit-train.txt", n_train);
    printf("Read %d training data\n", n_train);
    data *test = read_dataset("data/digit-test.txt", n_test);
    printf("Read %d testing data\n", n_test);
    int c = knn(test[0], train, n_train, k);
    printf("Predicted class: %d (class is %d)\n", c, test[0].class); // doit afficher 7
    float p = precision(test, n_test, train, n_train, k);
    printf("Precision: %f\n", p);
    free(train);
    free(test);
    return 0;
}