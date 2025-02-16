#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/time.h>
#include <pthread.h>
#include <limits.h>
#include "boite_noire2.h"

int nb_taches ;
int ** prerequis ;
int * duree ;
int * nb_prerequis ;

pthread_mutex_t    mutex_cache; // Mutex partagé
int actif ;
double elapsedTime;
struct timeval t1, t2;
int * fait ;

int strict = 0 ;

int temps_estime(int tache) {
  return duree[tache];
}

int etat(int i) {
  if(i<0 || i > OBJECTIF)
    return ERROR;
  pthread_mutex_lock(&mutex_cache);
  int r = fait[i];
  pthread_mutex_unlock(&mutex_cache);
  return r;
}

int nb_de_prerequis(int i) {
  if(i<0 || i > OBJECTIF)
    return ERROR;
  return nb_prerequis[i];
  pthread_mutex_lock(&mutex_cache);
  int r=0;
  for(int j = 0 ; j < nb_prerequis[i] ; j++ )
    if(fait[prerequis[i][j]] != 2)
      r++;
  pthread_mutex_unlock(&mutex_cache);
  return r;
}

int prerequis_de(int i,int k) {
  if(i<0 || i > OBJECTIF || k<0 || k > nb_prerequis[i])
    return ERROR;
  return prerequis[i][k];
  pthread_mutex_lock(&mutex_cache);
  for(int j = 0 ; j < nb_prerequis[i] ; j++ ) {
    if(fait[prerequis[i][j]] != 2)
      k--;
    if(k==0) {
      pthread_mutex_unlock(&mutex_cache);
      return prerequis[i][j];
    }
  }
  printf("Accès hors des bornes !\n");
  return -1;
}


int boite_noire(int tache) {
  if (actif != 1) {
    printf("Boite noire non démarrée !");
    exit(1);
  }
  pthread_mutex_lock(&mutex_cache);
  for(int i = 0 ; i < nb_prerequis[tache] ; i++) {
    if(fait[prerequis[tache][i]] != 2) {
      if(strict) { 
        printf("Prerequis non satisfait !\n");
        exit(1);
      }
      pthread_mutex_unlock(&mutex_cache);
      return PREREQUIS_MANQUANT;
    }
  }
  if(strict && fait[tache] != 0) {
    printf("Tâche déjà faite !\n");
    exit(1);
  }
  if(fait[tache] == 1) {
    pthread_mutex_unlock(&mutex_cache);
    return EN_COURS ;
  }
  if(fait[tache] == 2) {
    pthread_mutex_unlock(&mutex_cache);
    return DEJA_FAIT;
  }
  fait[tache] = 1;
  pthread_mutex_unlock(&mutex_cache);
  // DEBUT TACHE
  usleep(duree[tache]);
  // FIN TACHE
  pthread_mutex_lock(&mutex_cache);
  //  printf("Fin tâche %d\n",tache);
  fait[tache] = 2;
  pthread_mutex_unlock(&mutex_cache);
  return OK;
}
 
void demarre_boite() {
  srand(42);
  if(actif != 0) {
    fprintf(stderr,"Boite noire déjà démarée !\n");
    exit(1);
  }
  actif = 1;
  nb_taches = OBJECTIF ;
  int * perm = (int*) malloc(nb_taches * sizeof(int)) ;
  duree = (int*) malloc(nb_taches * sizeof(int)) ;
  for(int tache = 0 ; tache < nb_taches ; tache++) {
    int cible = rand()%(tache+1) ;
    perm[tache] = perm[cible] ;
    perm[cible] = tache ;
    
  }
  nb_prerequis = (int*) malloc(nb_taches * sizeof(int)) ;
  fait = (int*) malloc(nb_taches * sizeof(int)) ;
  prerequis = (int**) malloc(nb_taches * sizeof(int*)) ;
  for(int id = 0 ; id < nb_taches ; id++) {
    prerequis[id] = (int*) malloc(2 * sizeof(int)) ; // alloue 2 prerequis
    nb_prerequis[id] = 0;
  }
  
  for(int id = 0 ; id < nb_taches ; id+=4) {
    fait[id] = 0 ;
    fait[id+1] = 0 ;
    fait[id+2] = 0 ;
    fait[id+3] = 0 ;
    double f = 50000 ; //* ((double)rand())/INT_MAX ;
    double a = ((double)rand())/INT_MAX ;
    double b = ((double)rand())/INT_MAX ;
    duree[perm[id]] = f*a ;
    duree[perm[id+1]] = f*b ;
    duree[perm[id+2]] = f*(1-a) ;
    duree[perm[id+3]] = f*(1-b) ;
    if(id>0) {
      nb_prerequis[perm[id]]=2;
      prerequis[perm[id]][0]=perm[id-1];
      prerequis[perm[id]][1]=perm[id-2];
    }
    nb_prerequis[perm[id+2]]=1;
    nb_prerequis[perm[id+3]]=1;
    prerequis[perm[id+2]][0]=perm[id];
    prerequis[perm[id+3]][0]=perm[id+1];    
  }
  pthread_mutex_init(&mutex_cache, NULL);
  srandom(time(NULL));  
  gettimeofday(&t1, NULL);
}

void print_etat() {
  const char * trad_etat[] = {"à faire","en cours", "finie"};
  for(int i = 0 ; i < nb_taches ; i++) {
    printf("Tache %i, état %s\n",i,trad_etat[fait[i]]);
    for(int j = 0 ; j < nb_de_prerequis(i) ; j++ ) {
      printf("Prerequis %d\n",prerequis_de(i,j));
    }
    printf("Tache %i, état %s\n",i,trad_etat[fait[i]]);
  }
}

void eteint_boite() {
  pthread_mutex_lock(&mutex_cache);
  if(actif != 1) {
    fprintf(stderr,"Boite noire non démarée !\n");
    exit(1);
  }
  actif=2;
  for(int i = 0 ; i < nb_taches ; i++) {
    if(fait[i] != 2) {
        printf("Tache non finie !\n");
        print_etat();        
        exit(1);
    }
  }
  gettimeofday(&t2, NULL);
  elapsedTime = (t2.tv_sec - t1.tv_sec) * 1000.0;      // sec to ms
  elapsedTime += (t2.tv_usec - t1.tv_usec) / 1000.0;   // us to ms
  printf("Temps total %lf\n",elapsedTime);
}
  
