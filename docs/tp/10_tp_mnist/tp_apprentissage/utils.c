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