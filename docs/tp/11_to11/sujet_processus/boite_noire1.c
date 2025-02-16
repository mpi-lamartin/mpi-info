#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/time.h>
#include <pthread.h>
#include "boite_noire1.h"

pthread_mutex_t    mutex_cache; // Mutex partagé
int actif ;
double elapsedTime;
struct timeval t1, t2;
int nbAppels ;

void boite_noire() {
  if (actif != 1) {
    printf("Boite noire non démarrée !");
    exit(1);
  }
  int duree ;
  pthread_mutex_lock(&mutex_cache);
  duree = rand() % 1000000 ;
  if (nbAppels < 3)
    duree += 5000000;
  nbAppels++;
  pthread_mutex_unlock(&mutex_cache);
  usleep(duree);
}

void demarre_boite() {
  if(actif != 0) {
    fprintf(stderr,"Boite noire déjà démarée !\n");
    exit(1);
  }
  actif = 1;
  pthread_mutex_init(&mutex_cache, NULL);
  srandom(time(NULL));  
  gettimeofday(&t1, NULL);
}

void eteint_boite() {
  if(actif != 1) {
    fprintf(stderr,"Boite noire non démarée !\n");
    exit(1);
  }
  pthread_mutex_lock(&mutex_cache);
  actif=2;
  if(nbAppels != OBJECTIF) {
    fprintf(stderr,"Boite noire arrêtée sans que l'objectif ne soit atteint (%d/%d) !\n",nbAppels,OBJECTIF);
    exit(1);
  }
  gettimeofday(&t2, NULL);
  elapsedTime = (t2.tv_sec - t1.tv_sec) * 1000.0;      // sec to ms
  elapsedTime += (t2.tv_usec - t1.tv_usec) / 1000.0;   // us to ms
  printf("Temps total %lf\n",elapsedTime);
}
  
