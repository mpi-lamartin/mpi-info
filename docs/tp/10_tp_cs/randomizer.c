
#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>

#include <assert.h>


// Structure pour une proposition
struct prop_ {
    bool N; // Booléen indiquant si c'est une proposition N_i ou O_i
    int i; // Indice i associé à la proposition
};
typedef struct prop_ prop;

// Structure pour une règle reliée aux règles suivantes.
struct regle_ {
    struct regle_* suivant;
    prop* premisse;
    int taille_premisse;
    prop conclusion;
};
typedef struct regle_ regle;


//////////////////////////////////////////////////////////////////////
// Définition du jeu.

// Libération des règles restantes.
void libere_regles(regle *r) {
    // Attention à bien libérer la premisse.
    if (r != NULL) {
        libere_regles(r->suivant);
        free(r->premisse);
        free(r);
    }
}


//////////////////////////////////////////////////////////////////////
// Generation d'une permutation
void init_i(int* tableau, int k) {
    for (int i = 0; i < k; i++) {
        tableau[i] = i;
    }
}

void pp_permutation(int* permutation, int k) {
    for (int i = 0; i < k; i++) {
        printf("%d ", permutation[i]);
    }
    printf("\n");
}

void melange(int* tableau, int k) {
    for (int i = 0; i < k; i++) {
        int j = rand() % k;
        int tmp = tableau[i];
        tableau[i] = tableau[j];
        tableau[j] = tmp;
    }
}

//////////////////////////////////////////////////////////////////////
// Règles de déduction
regle* ajoute_regles_clefs(regle* r, int n1, int* clefs, int nb_clefs) {
    for (int i = 0; i < nb_clefs; i++) {
        regle* new = malloc(sizeof(regle));
        prop* p = malloc(sizeof(prop));
        p[0].N = true;
        p[0].i = n1;
        new->premisse = p;
        new->taille_premisse = 1;
        new->conclusion.N = false;
        new->conclusion.i = clefs[i];
        new->suivant = r;
        r = new;
    }
    return r;
}

// ajoute une règle provenant d'une arête, seulement dans une direction
regle* ajoute_regle_arete(regle* r, int n1, int n2, int* verr, int nb_verr) {
    prop* p = malloc((nb_verr + 1) * sizeof(prop));
    p[0].N = true;
    p[0].i = n1;
    for(int i = 0; i < nb_verr; i++) {
        p[i + 1].N = false;
        p[i + 1].i = verr[i];
    }
    regle *new = malloc(sizeof(regle));
    new->premisse = p;
    new->taille_premisse = nb_verr + 1;
    new->conclusion.N = true;
    new->conclusion.i = n2;
    new->suivant = r;
    return new;
}

// dans les deux directions
regle* ajoute_regles_arete(regle* r, int n1, int n2, int* verr, int nb_verr) {
    r = ajoute_regle_arete(r, n1, n2, verr, nb_verr);
    r = ajoute_regle_arete(r, n2, n1, verr, nb_verr);
    return r;
}

void print_jeu(regle* r) {
    while (r != NULL) {
        for (int i = 0; i < r->taille_premisse; i++) {
            if (r->premisse[i].N) {
                printf("N_%d ", r->premisse[i].i);
            } else {
                printf("O_%d ", r->premisse[i].i);
            }
        }
        if (r->conclusion.N) {
            printf("=> N_%d\n", r->conclusion.i);
        } else {
            printf("=> O_%d\n", r->conclusion.i);
        }
        r = r->suivant;
    }
}

void init_faux(bool* tableau, int taille_tableau) {
    for (int i = 0; i < taille_tableau; i++) {
        tableau[i] = false;
    }
}

bool verifie_premisse(regle r, bool* noeuds, bool* clefs) {
    for (int i = 0; i < r.taille_premisse; i++) {
        if (r.premisse[i].N) {
            if (!noeuds[r.premisse[i].i]) {
                return false;
            }
        } else {
            if (!clefs[r.premisse[i].i]) {
                return false;
            }
        }
    }
    return true;
}

regle* parcours_regles(regle* r, bool* noeuds, bool* clefs, bool* progres) {
    regle* debut = r;
    while (r != NULL) {
        printf("Vérification de la règle : ");
        for (int i = 0; i < r->taille_premisse; i++) {
            if (r->premisse[i].N) {
                printf("N_%d ", r->premisse[i].i);
            } else {
                printf("O_%d ", r->premisse[i].i);
            }
        }
        if (r->conclusion.N) {
            printf("=> N_%d\n", r->conclusion.i);
        } else {
            printf("=> O_%d\n", r->conclusion.i);
        }
        if (verifie_premisse(*r, noeuds, clefs)) {
            if (r->conclusion.N && !noeuds[r->conclusion.i]) {
                noeuds[r->conclusion.i] = true;
                printf("Noeud %d débloqué\n", r->conclusion.i);
                *progres = true;
            }
            if (!r->conclusion.N && !clefs[r->conclusion.i]) {
                clefs[r->conclusion.i] = true;
                printf("Clef %d débloquée\n", r->conclusion.i);
                *progres = true;
            }
        }
        r = r->suivant;
    }
    return debut;
}

bool est_sat(regle* r, int nb_noeuds, int nb_clefs, int D, int F) {
    bool* noeuds = malloc(nb_noeuds * sizeof(bool));
    bool* clefs = malloc(nb_clefs * sizeof(bool));
    init_faux(noeuds, nb_noeuds);
    init_faux(clefs, nb_clefs);
    noeuds[D] = true;
    bool progres = true;
    while (progres) {
        progres = false;
        r = parcours_regles(r, noeuds, clefs, &progres);
    }
    bool res = noeuds[F];
    free(noeuds);
    free(clefs);
    return res;
}


//////////////////////////////////////////////////////////////////////
// Tests

regle* genere_jeu_1() {

    regle* r = NULL;
    // Définition des règles représentant le jeu 1 donné en exemple.

    r = ajoute_regles_clefs(r, 2, (int []){1}, 1);
    r = ajoute_regles_clefs(r, 3, (int []){0}, 1);
    r = ajoute_regles_clefs(r, 4, (int []){0, 2}, 2);

    r = ajoute_regles_arete(r, 0, 1, (int []){0}, 1);
    r = ajoute_regles_arete(r, 1, 2, (int []){1}, 1);
    r = ajoute_regles_arete(r, 1, 2, (int []){}, 0);
    r = ajoute_regles_arete(r, 0, 3, (int []){}, 0);
    r = ajoute_regles_arete(r, 1, 4, (int []){1}, 1);
    r = ajoute_regles_arete(r, 2, 5, (int []){1, 2}, 2);
    r = ajoute_regles_arete(r, 3, 4, (int []){1}, 1);
    r = ajoute_regles_arete(r, 4, 5, (int []){0, 1}, 2);


    // Noeud initial d'indice 0, et noeud final d'indice 5
    // Ce jeu comprend 6 noeuds et 3 clefs différentes

    return r;
}

regle* genere_jeu_2() {

    regle* r = NULL;
    // Définition des règles représentant le jeu 2 donné en annexe.

    r = ajoute_regles_clefs(r, 1, (int []){2}, 1);
    r = ajoute_regles_clefs(r, 2, (int []){5}, 1);
    r = ajoute_regles_clefs(r, 3, (int []){0, 1}, 2);
    r = ajoute_regles_clefs(r, 5, (int []){8}, 1);
    r = ajoute_regles_clefs(r, 6, (int []){14}, 1);
    r = ajoute_regles_clefs(r, 7, (int []){12}, 1);
    r = ajoute_regles_clefs(r, 8, (int []){6}, 1);
    r = ajoute_regles_clefs(r, 9, (int []){3, 4}, 2);
    r = ajoute_regles_clefs(r, 10, (int []){13}, 1);
    r = ajoute_regles_clefs(r, 11, (int []){10}, 1);
    r = ajoute_regles_clefs(r, 12, (int []){11, 9}, 2);
    r = ajoute_regles_clefs(r, 14, (int []){15}, 1);
    r = ajoute_regles_clefs(r, 15, (int []){7}, 1);
    r = ajoute_regles_clefs(r, 16, (int []){5}, 1);
    r = ajoute_regles_clefs(r, 17, (int []){16}, 1);

    r = ajoute_regles_arete(r, 0, 3, (int []){11, 12, 13}, 3);
    r = ajoute_regles_arete(r, 1, 4, (int []){6, 7}, 2);
    r = ajoute_regles_arete(r, 2, 3, (int []){1}, 1);
    r = ajoute_regles_arete(r, 3, 4, (int []){3}, 1);
    r = ajoute_regles_arete(r, 3, 4, (int []){0}, 1);
    r = ajoute_regles_arete(r, 4, 5, (int []){0, 2}, 2);
    r = ajoute_regles_arete(r, 2, 6, (int []){5, 6}, 2);
    r = ajoute_regles_arete(r, 2, 7, (int []){}, 0);
    r = ajoute_regles_arete(r, 3, 7, (int []){4}, 1);
    r = ajoute_regles_arete(r, 3, 8, (int []){}, 0);
    r = ajoute_regles_arete(r, 4, 11, (int []){}, 0);
    r = ajoute_regles_arete(r, 5, 12, (int []){3}, 1);
    r = ajoute_regles_arete(r, 6, 7, (int []){4, 5}, 2);
    r = ajoute_regles_arete(r, 7, 8, (int []){4}, 1);
    r = ajoute_regles_arete(r, 8, 9, (int []){6}, 1);
    r = ajoute_regles_arete(r, 9, 10, (int []){7}, 1);
    r = ajoute_regles_arete(r, 10, 11, (int []){4, 7}, 2);
    r = ajoute_regles_arete(r, 7, 12, (int []){0}, 1);
    r = ajoute_regles_arete(r, 8, 12, (int []){0, 6}, 2);
    r = ajoute_regles_arete(r, 10, 13, (int []){}, 0);
    r = ajoute_regles_arete(r, 12, 13, (int []){0, 9}, 2);
    r = ajoute_regles_arete(r, 13, 14, (int []){7, 8}, 2);
    r = ajoute_regles_arete(r, 13, 15, (int []){2}, 1);
    r = ajoute_regles_arete(r, 13, 16, (int []){10}, 1);
    r = ajoute_regles_arete(r, 16, 17, (int []){15, 16}, 2);

    // Noeud initial d'indice 3, et noeud final d'indice 0
    // Ce jeu comprend 18 noeuds et 17 clefs différentes

    return r;
}


int main() {
    srand(1); // seed à changer pour modifier l'aléatoire généré.

    printf("Jeu 1\n");
    regle* r = genere_jeu_1();
    print_jeu(r);
    printf("Est satisfiable ? %d\n", est_sat(r, 6, 3, 0, 5));
    libere_regles(r);
    //int p0[] = {8, 10, 14, 12, 5, 13, 4, 16, 11, 15, 9, 3, 7, 0, 1, 2, 6};
    //int p1[] = {0, 16, 5, 14, 1, 15, 3, 12, 8, 7, 11, 9, 13, 6, 4, 10, 2};
    //int p2[] = {0, 5, 10, 4, 15, 2, 9, 11, 16, 12, 6, 8, 13, 3, 1, 14, 7};
    //int p3[] = {3, 8, 7, 16, 2, 0, 4, 1, 5, 12, 9, 6, 10, 13, 11, 14, 15};
    //int p4[] = {2, 10, 14, 13, 0, 6, 15, 11, 16, 12, 9, 4, 1, 5, 7, 8, 3};

    return 0;
}
