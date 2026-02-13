---
hide_table_of_contents: false
hide_title: true
title: Code
---

## Mutex

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';

<Tabs>
<TabItem value="c" label="C">

```c
#include <stdio.h>
#include <pthread.h>

int counter;
pthread_mutex_t mutex;

void *increment(void *arg){
    for (int i = 1; i <= 1000000; i++) {
        pthread_mutex_lock(&mutex);
        counter++;
        pthread_mutex_unlock(&mutex);
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

Compilation : `gcc -pthread exemple.c`

</TabItem>
<TabItem value="OCaml" label="OCaml">

```ocaml
let counter = ref 0
let lock = Mutex.create ()

let multiple_increment n =
  for i = 0 to n - 1 do
    Mutex.lock lock;
    counter := !counter + 1;
    Mutex.unlock lock
  done

let main () =
  let n = 1_000_000 in
  let t0 = Thread.create multiple_increment n in
  let t1 = Thread.create multiple_increment n in
  Thread.join t0;
  Thread.join t1;
  Printf.printf "counter = %d\n" !counter

let () = main ()
```

Compilation : `ocamlopt -I +unix -I +threads unix.cmxa threads.cmxa exemple.ml`

</TabItem>
</Tabs>
