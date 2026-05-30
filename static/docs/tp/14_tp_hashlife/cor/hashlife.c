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


// Question 18
quadtree* evolution(quadtree* t) 
{

  assert(t->hash >= 0);
  assert(t->hash < HASH_MAX);

  if (t->hauteur == 2) 
  {
    quadtree* s = evolution_4x4(t);
    return s;
  }

  quadtree* hg = t->no;
  quadtree* hm = assemble_quadtree(t->no->ne, t->ne->no, t->no->se, t->ne->so);
  quadtree* hd = t->ne;
  quadtree* mg = assemble_quadtree(t->no->so, t->no->se, t->so->no, t->so->ne);
  quadtree* mm = centre(t);
  quadtree* md = assemble_quadtree(t->ne->so, t->ne->se, t->se->no, t->se->ne);
  quadtree* bg = t->so;
  quadtree* bm = assemble_quadtree(t->so->ne, t->se->no, t->so->se, t->se->so);
  quadtree* bd = t->se;

  quadtree* a = centre(hg);
  quadtree* b = centre(hm);
  quadtree* c = centre(hd);
  quadtree* d = centre(mg);
  quadtree* e = centre(mm);
  quadtree* f = centre(md);
  quadtree* g = centre(bg);
  quadtree* h = centre(bm);
  quadtree* i = centre(bd);

  quadtree* bloc_no = assemble_quadtree(a, b, d, e);
  quadtree* bloc_ne = assemble_quadtree(b, c, e, f);
  quadtree* bloc_so = assemble_quadtree(d, e, g, h);
  quadtree* bloc_se = assemble_quadtree(e, f, h, i);

  quadtree* resultat = assemble_quadtree(evolution(bloc_no), evolution(bloc_ne), evolution(bloc_so), evolution(bloc_se));

  return resultat;
}

// Question 19
void simulation(quadtree* t, int nb_etapes, char* nom_dossier) 
{

  assert(t != NULL);
  assert(nb_etapes > 0);

  // Chaîne de charactère correspondant au chemin et nom du fichier du fichier .pbm  qui sera créé.
  char chemin_vers_fichier[100];

  int numero_image = 0;

  // Permet de mettre à jour la chaine chemin_vers_fichier pour qu'elle soit de la forme "nom_dossier/i.pbm".
  // Il n'est pas demandé de comprendre cette ligne.
  while(numero_image < nb_etapes)
  {
    snprintf(chemin_vers_fichier, sizeof(chemin_vers_fichier), "%s/%d.pbm", nom_dossier, numero_image);
    t = evolution(entoure(t));
    exporte_quadtree(t, chemin_vers_fichier);
    numero_image++;
  }
}

int main() {

  extern table_hachage* ht; // À décommenter pour la partie III
  ht = nouvelle_table(HASH_MAX); // À décommenter pour la partie III

  // Attention, tout ceci ne fonctionne plus après implémentation de la question 15 puisque la libération n'est plus gérée pareil
  // // Test question 4 / 5 puis 8 puis 10
  // char* source = "data/space_filler.rle";
  // printf("Ouverture du fichier %s\n", source);
  // quadtree* t = importe_quadtree_rle(source);
  // printf("Hash du quadtree importé : %d\n", t->hash);
  // quadtree* c = centre(t);
  // printf("Hash du centre de la grille D : %d\n", c->hash);
  // // Commenté le temps de libérer correctement la mémoire
  // quadtree* e = entoure(t);
  // printf("Hash de D entourée : %d\n", e->hash);
  // free_quadtree(t);
  // free(c); // Attention, t et c partagent de la mémoire.

  // // Test question 7
  // char* petit_vaisseau = "data/petit_vaisseau.rle";
  // quadtree* pv = importe_quadtree_rle(petit_vaisseau);
  // exporte_quadtree(pv, "petit_vaisseau.pbm");
  // free_quadtree(pv);

  // char* galaxie = "data/galaxie.rle";
  // quadtree* g = importe_quadtree_rle(galaxie);
  // exporte_quadtree(g, "galaxie.pbm");
  // free_quadtree(g);

  // char* usine = "data/usine.rle";
  // quadtree* u = importe_quadtree_rle(usine);
  // exporte_quadtree(u, "usine.pbm");
  // free_quadtree(u);

  // // Test question 9
  // quadtree* b = blanc(10);
  // printf("Hash d'un quadtree blanc de hauteur 10 : %d\n", b->hash);
  // free_quadtree(b);

  // Test question 15 : on vérifie qu'on retrouve le bon hash
  char* source = "data/space_filler.rle";
  printf("Ouverture du fichier %s\n", source);
  quadtree* t = importe_quadtree_rle(source);
  printf("Hash du quadtree D : %d\n", t->hash);
  free_table_hachage(ht); 

  // Test question 16
  ht = nouvelle_table(HASH_MAX);
  quadtree* b = blanc(10);
  printf("Hash d'un quadtree blanc de hauteur 10 : %d\n", b->hash);
  printf("Nombre de noeuds quadtree blanc : %d\n", ht->nb_elems);
  free_table_hachage(ht); 

  // Question 17
  ht = nouvelle_table(HASH_MAX);
  char* course = "data/course.rle";
  quadtree* c = importe_quadtree_rle(course);
  printf("Hash du quadtree E : %d\n", c->hash);
  printf("Nombre de noeuds fichier E : %d\n", ht->nb_elems);
  free_table_hachage(ht);

  ht = nouvelle_table(HASH_MAX);
  char* fumeurs = "data/fumeurs.rle";
  quadtree* f = importe_quadtree_rle(fumeurs);
  printf("Hash du quadtree F : %d\n", f->hash);
  printf("Nombre de noeuds fichier F : %d\n", ht->nb_elems);
  free_table_hachage(ht);

  // Question 18
  ht = nouvelle_table(HASH_MAX);
  char* space = "data/space_filler.rle";
  quadtree* s = importe_quadtree_rle(space);
  quadtree* s_evo = evolution(s);
  quadtree* s_evo_centre = centre(s_evo);
  printf("Hash du centre de D évolué une fois : %d\n", s_evo_centre->hash);
  free_table_hachage(ht);

  // Question 20
  ht = nouvelle_table(HASH_MAX);
  char* course_again = "data/course.rle";
  quadtree* cc = importe_quadtree_rle(course_again);
  simulation(cc, 350, "images");
  free_table_hachage(ht);
  return 0;
}
