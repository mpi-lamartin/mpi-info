#include "quadtree.h"

int HASH_MAX = 100000;


int hash(int no, int ne, int so, int se) {

    int a = 12421;
    int b = 6421;
    int c = 1231;
    int d = 4241;
    int e = 3499;

    return (a * no + b * ne + c * so + d * se + e) % HASH_MAX;
}


quadtree* allocation_feuille(int couleur) {

    // Alloue et initialise une feuille d'un quadtree
    // représentant une cellule de couleur donnée

    quadtree* t = malloc(sizeof(quadtree));

    t->nb_vivantes = couleur; // 0 ou 1
    t->hauteur = 0;
    t->hash = couleur;

    t->no = NULL;
    t->ne = NULL;
    t->so = NULL;
    t->se = NULL;

    return t;
}


quadtree* feuille(int couleur) {
    return allocation_feuille(couleur);
}


quadtree* assemble_quadtree(quadtree* no, quadtree* ne, quadtree* so, quadtree* se) {
    // Alloue et initialise un noeud qui sera le père de quatre quadtrees canonisés
    // non vides de même taille donnés en argument

    quadtree* nouvel_arbre = malloc(sizeof(quadtree));

    nouvel_arbre->nb_vivantes = 0; // TODO
    nouvel_arbre->hash = 0; // TODO
    nouvel_arbre->hauteur = 0; // TODO

    nouvel_arbre->no = no;
    nouvel_arbre->ne = ne;
    nouvel_arbre->so = so;
    nouvel_arbre->se = se;

    return nouvel_arbre;
}


void free_noeud(quadtree* t) {
    free(t);
}


void free_quadtree(quadtree* t) {
    if (t->no != NULL) {
        free_quadtree(t->no);
        free_quadtree(t->ne);
        free_quadtree(t->so);
        free_quadtree(t->se);
    }
    free_noeud(t);
}


int couleur_cellule(int x, int y, quadtree* t) {

    assert(0 <= x);
    assert(0 <= y);

    // Cas de base : feuille
    if (t->hauteur == 0) {
        // TODO
        return 0;
    }

    // Descente récursive dans l'arbre
    //int milieu = 1 << (t->hauteur - 1); // 2^(h-1), correspondant à la moitié de la largeur (et hauteur)

    // ...

    return 0;
}


void exporte_quadtree(quadtree* t, char* nom) {

    assert(t != NULL);
    assert(nom != NULL);

    //int largeur_image = 1 << t->hauteur; // un entier valant 2^h

    // TODO
}


///////////////////////////////////////////////////////////////////////////////

quadtree* construit_quadtree(int x, int y, int taille, int** im) {

    if (taille == 1) {
        return feuille(im[x][y]);
    }
    int decalage = taille / 2;
    quadtree* no = construit_quadtree(x, y, decalage, im);
    quadtree* ne = construit_quadtree(x + decalage, y, decalage, im);
    quadtree* so = construit_quadtree(x, y + decalage, decalage, im);
    quadtree* se = construit_quadtree(x + decalage, y + decalage, decalage, im);

    return assemble_quadtree(no, ne, so, se);
}

quadtree* importe_quadtree(char* nom_de_fichier) {

    // Ouverture du fichier cible
    FILE* fd = fopen(nom_de_fichier, "r");
    int largeur_image;
    int hauteur_image;

    // Lecture de l'en-tête
    (void)! fscanf(fd, "P1\n%d %d\n", &largeur_image, &hauteur_image);
    assert(largeur_image == hauteur_image);

    // Allocation d'une matrice pour stocker temporairement l'image
    int** im = malloc(largeur_image * sizeof(int*));
    for (int i=0; i < largeur_image; i++) {
        im[i] = malloc(largeur_image * sizeof(int));
    }

    char couleur;
    for (int i=0; i < largeur_image; i++) {
        for (int j=0; j < largeur_image; j++) {
            (void)! fscanf(fd, "%c", &couleur);
            im[i][j] = couleur - '0';
        }
        (void)! fscanf(fd, "\n");
    }

    fclose(fd);

    // Construction du quadtree
    quadtree* t = construit_quadtree(0, 0, largeur_image, im);

    // Libération de la matrice
    for (int i=0; i < largeur_image; i++) {
        free(im[i]);
    }
    free(im);

    return t;
}

quadtree* importe_quadtree_rle(char* nom_de_fichier) {

    FILE* fd = fopen(nom_de_fichier, "r");
    if (fd == NULL) {
        perror("Erreur : fichier introuvable.");
    }

    char commentaire[1000];
    while (fscanf(fd, "#%[^\n]\n", commentaire) > 0) {;}

    int taille_x;
    int taille_y;

    (void)! fscanf(fd, "x = %d, y = %d%*[^\n]\n", &taille_x, &taille_y);
    assert(taille_x == taille_y);
    printf("Image de taille %d x %d\n", taille_x, taille_y);

    int** im = malloc(taille_x * sizeof(int*));
    for (int i=0; i < taille_x; i++) {
        im[i] = calloc(taille_x, sizeof(int));
    }

    char c;
    int nb = 0;

    int i = 0;
    int j = 0;

    do {
        for (int k=0; k<nb; k++) {
            if (c == 'o') {im[i][j] = 1; j++;}
            if (c == 'b') {im[i][j] = 0; j++;}
            if (c == '$') {i++; j=0;}
        }

        nb = 1;
        (void)! fscanf(fd, "%d", &nb); // Peut échouer, auquel cas nb vaut 1
        (void)! fscanf(fd, "%c", &c);
        (void)! fscanf(fd, "\n"); // Peut échouer
    } while (c != '!');

    fclose(fd);

    // Construction du quadtree
    quadtree* t = construit_quadtree(0, 0, taille_x, im);

    // Libération de la matrice
    for (int i=0; i < taille_x; i++) {
        free(im[i]);
    }
    free(im);

    return t;
}
