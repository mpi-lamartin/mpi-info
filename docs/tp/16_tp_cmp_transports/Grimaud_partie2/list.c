// Modified by A. Grimaud
// March 2026

#include "list.h"

//fonction d'erreur pour factoriser du code
void error(char errMsg[]){
  fprintf(stderr,"%s\n",errMsg);
  exit(EXIT_FAILURE);
}

list createList(){
  return NULL;
}

bool isEmpty(list L){
  return L==NULL;
}

arc value(list L){
  if(isEmpty(L)) error("Vous lisez une valeur dans une liste vide");
  return L->value;
}

list next(list L){
  if(isEmpty(L)) error("Vous avancez dans une liste vide");
  return L->next;
}

list insertBegin(list L, arc x){
  list newL = (list)malloc(sizeof(struct list));
  newL->value = x;
  newL->next = L;
  return newL;
}

list deleteBegin(list L){
  if(isEmpty(L)) error("Vous essayez de retirer un element dans une liste vide");
  list newList = L->next;
  free(L);
  return newList;
}

void insertAfter(list cursor, arc x){
  if(isEmpty(cursor)) error("Vous inserez apres une position NULL");
  cursor->next = insertBegin(cursor->next,x);
}

void deleteAfter(list cursor){
  if(isEmpty(cursor) || isEmpty(cursor->next)) error("Vous supprimez apres une position NULL");
  list newList = cursor->next->next;
  free(cursor->next);
  cursor->next = newList;
}
