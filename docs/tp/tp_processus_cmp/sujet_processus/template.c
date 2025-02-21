#include <stdio.h>
#include <pthread.h>

#define NB_THREADS 3

pthread_mutex_t    mon_mutex; // Mutex partagé
pthread_t tid_thread_1, tid_thread_2, tid_thread_3;	// Identifiant des threads

void *thread_main(void *data)
{
  pthread_t tid_local = pthread_self(); // vaut tdi_thread_i quand on est le thread i
  pthread_mutex_lock(&mon_mutex);
  //section critique
  pthread_mutex_unlock(&mon_global);
    
  return NULL; 
}
void *thread_main2_2(void *data)
{
  return NULL; 
}

int main(void)
{
  demarre_boite();
  pthread_mutex_init(&mon_global, NULL);
  pthread_mutex_lock(&mon_global);
  pthread_create(&tid_thread_1, NULL, thread_main, NULL);
  pthread_create(&tid_thread_2, NULL, thread_main, NULL);

  // un thread avec une autre fonction
  pthread_create(&tid_thread_3, NULL, thread_main_2, NULL);

  // on attend maintenant que nos threads terminent
  pthread_join(tid_thread_1, NULL);
  pthread_join(tid_thread_2, NULL);
  pthread_join(tid_thread_3, NULL);
  return 0;
}
