#define OBJECTIF 1000

void demarre_boite(); // à appeler au début du programme
void eteint_boite(); // à appeler à la fin du programme 

int boite_noire(int); // à appeler avec l'id de la tâche à faire, renvoi une des valeurs suivantes :

#define PREREQUIS_MANQUANT -1
#define DEJA_FAIT -2
#define EN_COURS -3
#define OK 0

// La valeur ERROR ne devrait être renvoyée qu'en cas de paramètre absurde
#define ERROR 42

int temps_estime(int); // renvoi le temps (approximatif) que prend la tâche

int nb_de_prerequis(int); // renvoi le nb de prérequis d'une tâche

int prerequis_de(int,int); // prerequis_de(tache,j) renvoi l'id du j-ième prérequis de la tache
// on suppose que 0 <= j < nb_prerequis(tache)


int etat(int); // fonction qui prend un id de tache et renvoie
               // 0 si pas commencée, 1 si en cours, 2 si finie
void print_etat(); // pas thread safe

int * fait ;
