#include <stdlib.h>
#include <stdio.h>
#include <assert.h>
#include <stdbool.h>

extern int HASH_MAX;

typedef struct _quadtree {

    int nb_vivantes;
    int hauteur;
    int hash;

    struct _quadtree* no;
    struct _quadtree* ne;
    struct _quadtree* so;
    struct _quadtree* se;

} quadtree;


// Partie III
typedef struct _noeud {
    struct _noeud* suivant;
    quadtree* t;
} noeud;

typedef struct _table_hachage {
    int taille;
    int nb_elems;

    quadtree* blanc;
    quadtree* noir;

    noeud** alveoles;
} table_hachage;

// table_hachage* nouvelle_table(int taille);
// void free_table_hachage(table_hachage* ht);


quadtree* allocation_feuille(int couleur);
quadtree* feuille(int couleur);
quadtree* assemble_quadtree(quadtree* no, quadtree* ne, quadtree* so, quadtree* se);

quadtree* blanc(int hauteur);
quadtree* entoure(quadtree* t);

void free_noeud(quadtree* t);
void free_quadtree(quadtree* t);

quadtree* centre(quadtree* t);

quadtree* importe_quadtree(char* nom_de_fichier);
quadtree* importe_quadtree_rle(char* nom_de_fichier);
void exporte_quadtree(quadtree* t, char* nom);
