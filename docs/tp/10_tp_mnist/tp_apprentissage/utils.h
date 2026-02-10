#ifndef UTILS_H
#define UTILS_H

#define LEN (28 * 28)
#define NB_CLASSES 10

typedef struct data {
    int class;
    float pixels[LEN]; // pixels[i*28+j] est le pixel (i, j)
} data;

data* read_dataset(char *path, int nb_samples);

#endif
