#include <stdio.h>
#include <pthread.h>
#include <stdlib.h>
#include "../boite_noire2.h"
#define NB_THREADS 3

pthread_mutex_t mon_mutex;                          // Mutex partagé
pthread_t tid_thread_1, tid_thread_2, tid_thread_3; // Identifiant des threads

int ordre[OBJECTIF];
int k = 0;
int cur = 0;
void topo(int* vus, int i) {
    if(vus[i]) return;
    vus[i] = 1;
    for(int j = 0; j < nb_de_prerequis(i); j++)
        topo(vus, prerequis_de(i, j));
    ordre[k++] = i;
}

int verifie_topo() {
    for(int i = 0; i < OBJECTIF; i++) {
        for(int j = i + 1; j < OBJECTIF; j++)
            for(int k = 0; k < nb_de_prerequis(ordre[i]); k++)
                if(prerequis_de(ordre[i], k) == ordre[j])
                    return 0;
    }
    return 1;
}

void *thread_main(void *data) {
    pthread_t tid_local = pthread_self(); // vaut tdi_thread_i quand on est le thread i
    // pthread_mutex_lock(&mon_mutex);
    // section critique
    // pthread_mutex_unlock(&mon_mutex);


    while(1) {
        pthread_mutex_init(&mon_mutex, NULL);
        pthread_mutex_lock(&mon_mutex);
        if(cur == OBJECTIF) {
            pthread_mutex_unlock(&mon_mutex);
            break;
        }
        int i = ordre[cur++];
        pthread_mutex_unlock(&mon_mutex);
        if(etat(i) != 0) {
            // printf("Tache %d déjà faite\n", i);
            continue;
        }
        int b = 0;
        while(!b) {
            b = 1;
            for(int j = 0; j < nb_de_prerequis(i); j++)
                if(etat(prerequis_de(i, j)) != 2) {
                    b = 0;
                    // printf("Prerequis manquant pour %d\n", i);
                    break;
                }
        }
        if(etat(i) != 2) boite_noire(i);
    }
    return NULL;
}
void *thread_main2_2(void *data)
{
    return NULL;
}

int main(void)
{
    demarre_boite();

    int* vus = (int*)malloc(OBJECTIF * sizeof(int));
    for(int i = 0; i < OBJECTIF; i++)
        vus[i] = 0;
    for(int i = 0; i < OBJECTIF; i++)
        topo(vus, i);
    // if(!verifie_topo()) {
    //     printf("Erreur dans le tri topologique\n");
    //     return 1;
    // }
    pthread_create(&tid_thread_1, NULL, thread_main, NULL);
    pthread_create(&tid_thread_2, NULL, thread_main, NULL);
    pthread_create(&tid_thread_3, NULL, thread_main, NULL);

    // un thread avec une autre fonction
    // pthread_create(&tid_thread_3, NULL, thread_main_2, NULL);

    // on attend maintenant que nos threads terminent
    pthread_join(tid_thread_1, NULL);
    pthread_join(tid_thread_2, NULL);
    pthread_join(tid_thread_3, NULL);
    eteint_boite(); 
    return 0;
}
