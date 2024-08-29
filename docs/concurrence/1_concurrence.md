---
hide_table_of_contents: true
hide_title: true
title: Concurrence et parallélisme
---

<div class="container4x3">
<iframe src={require('./concurrence.pdf#zoom=page-fit&pagemode=none').default + "#zoom=page-fit&pagemode=none"} class="responsive-iframe" allowFullScreen></iframe>
</div>

## Produit de matrice 

```c
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#define N 1000
#define NTHREADS 1000

long long timeInMilliseconds(void) {
    struct timeval tv;
    gettimeofday(&tv,NULL);
    return (((long long)tv.tv_sec)*1000)+(tv.tv_usec/1000);
}

int u[N][N], v[N][N], w[N][N];

void* sum(void* arg) {
    int a = *(int*)arg;
    for(int b = a; b < N*N; b += NTHREADS) {
        int i = b / N;
        int j = b % N;
        w[i][j] = 0;
        for(int k = 0; k < N; k++) {
            w[i][j] += u[i][k] * v[k][j];
        }
    }
    return NULL;
}

int main(void) {
    pthread_t threads[N*N];
    for(int i = 0; i < N; i++) {
        for(int j = 0; j < N; j++) {
            u[i][j] = i;
            v[i][j] = j;
        }
    }
    long long t = timeInMilliseconds();
    for(int i = 0; i < NTHREADS; i++) {
        int* arg = malloc(sizeof(int));
        *arg = i;
        pthread_create(&threads[i], NULL, sum, arg);
        free(arg);
    }
    for(int i = 0; i < NTHREADS; i++) {
        pthread_join(threads[i], NULL);
    }
    printf("En parallèle : %lld ms\n", timeInMilliseconds() - t);
    t = timeInMilliseconds();
    for(int i = 0; i < N; i++) {
        for(int j = 0; j < N; j++) {
            w[i][j] = 0;
            for(int k = 0; k < N; k++) {
                w[i][j] += u[i][k] * v[k][j];
            }
        }
    }
    printf("En séquentiel : %lld ms\n", timeInMilliseconds() - t);
    return 0;
}
```
