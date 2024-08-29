---
hide_table_of_contents: false
hide_title: true
title: Code
---

# Exemples avec threads 

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';

<Tabs>
<TabItem value="c" label="C">

```c
#include <pthread.h> // threads POSIX (standard Linux)
#include <stdio.h>

void *f(void *x) {
    int *n = (int *)x; // Conversion du type
    for(int i = 0; i < 100000; i++) {
        if(i % 20000 == 0)
            printf("%d %d\n", *n, i);
    }
}

int main() {
    pthread_t t1, t2;
    int n1 = 1, n2 = 2;
    pthread_create(&t1, NULL, f, (void *)&n1);
    pthread_create(&t2, NULL, f, (void *)&n2);
    pthread_join(t1, NULL); // Attendre la fin de t1
    pthread_join(t2, NULL); // Attendre la fin de t2
}
```
Compilation : `gcc -pthread exemple.c`

</TabItem>
<TabItem value="OCaml" label="OCaml">

```ocaml
let counter = ref 0

let increment n =
  for i = 0 to n - 1 do
    counter := !counter + 1;
  done

let main () =
  let n = 1_000_000 in
  let t0 = Thread.create increment n in
  let t1 = Thread.create increment n in
  Thread.join t0;
  Thread.join t1;
  Printf.printf "counter = %d\n" !counter

let () = main ()
```

Compilation : `ocamlopt -I +unix -I +threads unix.cmxa threads.cmxa exemple.ml`

</TabItem>
</Tabs>

## Incrémentation d'un compteur

<Tabs>
<TabItem value="c" label="C">

```c
#include <stdio.h>
#include <pthread.h>

int counter;

void *increment(void *arg){
    for (int i = 1; i <= 1000000; i++) {
        counter++;
    }
    return NULL;
}

int main(void){
    counter = 0;
    pthread_t t1, t2;
    pthread_create(&t1, NULL, increment, NULL);
    pthread_create(&t2, NULL, increment, NULL);
    pthread_join(t1, NULL);
    pthread_join(t2, NULL);
    printf("Counter = %d\n", counter);
    return 0;
}
```

</TabItem>
<TabItem value="OCaml" label="OCaml">

```ocaml
let counter = ref 0

let increment n =
  for i = 0 to n - 1 do
    counter := !counter + 1;
  done

let main () =
  let n = 1_000_000 in
  let t0 = Thread.create increment n in
  let t1 = Thread.create increment n in
  Thread.join t0;
  Thread.join t1;
  Printf.printf "counter = %d\n" !counter

let () = main ()
```

</TabItem>
</Tabs>





```c title="Produit de matrice"
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
