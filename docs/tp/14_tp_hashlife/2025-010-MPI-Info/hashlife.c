#include "hashlife.h"


table_hachage* ht;


int nouvelle_couleur(int nb_voisins_vivantes, int est_vivant) {
    // Règles du jeu de la vie, qui décide si une cellule sera vivante
    // en fonction du nombre de cellules voisines vivantes et de son état

    if (nb_voisins_vivantes == 3) {
        return 1;
    }
    if (nb_voisins_vivantes == 2 && est_vivant == 1) {
        return 1;
    }
    return 0;
}

quadtree* evolution_4x4(quadtree* t) {
    // Renvoie un quadtree de hauteur 1 (2x2) correspondant au centre
    // du quadtree t après avoir évolué d'une génération

    assert(t->hauteur == 2);

    int nb_voisins_no = t->no->so->nb_vivantes + t->no->no->nb_vivantes + t->no->ne->nb_vivantes + t->ne->no->nb_vivantes + t->ne->so->nb_vivantes + t->se->no->nb_vivantes + t->so->ne->nb_vivantes + t->so->no->nb_vivantes;
    int nb_voisins_ne = t->no->se->nb_vivantes + t->no->ne->nb_vivantes + t->ne->no->nb_vivantes + t->ne->ne->nb_vivantes + t->ne->se->nb_vivantes + t->se->ne->nb_vivantes + t->se->no->nb_vivantes + t->so->ne->nb_vivantes;
    int nb_voisins_so = t->no->so->nb_vivantes + t->no->se->nb_vivantes + t->ne->so->nb_vivantes + t->se->no->nb_vivantes + t->se->so->nb_vivantes + t->so->se->nb_vivantes + t->so->so->nb_vivantes + t->so->no->nb_vivantes;
    int nb_voisins_se = t->no->se->nb_vivantes + t->ne->so->nb_vivantes + t->ne->se->nb_vivantes + t->se->ne->nb_vivantes + t->se->se->nb_vivantes + t->se->so->nb_vivantes + t->so->se->nb_vivantes + t->so->ne->nb_vivantes;

    int nouveau_no = nouvelle_couleur(nb_voisins_no, t->no->se->nb_vivantes);
    int nouveau_ne = nouvelle_couleur(nb_voisins_ne, t->ne->so->nb_vivantes);
    int nouveau_so = nouvelle_couleur(nb_voisins_so, t->so->ne->nb_vivantes);
    int nouveau_se = nouvelle_couleur(nb_voisins_se, t->se->no->nb_vivantes);

    return assemble_quadtree(feuille(nouveau_no), feuille(nouveau_ne), feuille(nouveau_so), feuille(nouveau_se));
}



quadtree* evolution(quadtree* t) {

    // Algorithme récursif d'évolution pour quadtree de hauteur au moins 2

    // Cas de base
    if (t->hauteur == 2) {
        quadtree* s = evolution_4x4(t);
        return s;
    }

    // Cas récursif
    /*
    quadtree* a =
    quadtree* b =
    quadtree* c =
    quadtree* d =
    quadtree* e =
    quadtree* f =
    quadtree* g =
    quadtree* h =
    quadtree* i =
    */

    return NULL;
}

void simulation(quadtree* t, int nb_etapes, char* nom_dossier) {

    assert(t != NULL);
    assert(nb_etapes > 0);

    // Chaîne de charactère correspondant au chemin et nom du fichier du fichier .pbm  qui sera créé.
    char chemin_vers_fichier[100];

    int numero_image = 0;

    // Permet de mettre à jour la chaine chemin_vers_fichier pour qu'elle soit de la forme "nom_dossier/i.pbm".
    // Il n'est pas demandé de comprendre cette ligne.
    snprintf(chemin_vers_fichier, sizeof(chemin_vers_fichier), "%s/%d.pbm", nom_dossier, numero_image);

    // TODO;

}

int main() {

    // extern table_hachage* ht; // À décommenter pour la partie III
    // ht = nouvelle_table(HASH_MAX); // À décommenter pour la partie III

    char* source = "data/petit_vaisseau.rle";

    printf("Ouverture du fichier %s\n", source);

    quadtree* t = importe_quadtree_rle(source);

    printf("Hash du quadtree importé : %d\n", t->hash);

    free_quadtree(t);

    return 0;
}
