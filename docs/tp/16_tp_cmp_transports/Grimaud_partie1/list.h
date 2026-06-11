// Modified by A. Grimaud
// March 2026

#ifndef LIST_H
#define LIST_H

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h> 

// Q1
typedef struct {
  int heure;
  int minute;
} temps;

// Q3
typedef struct {
  int u;
  int v;
  temps td;
  temps ta;
} arc;

struct list{
  arc value;
  struct list * next;
};
typedef struct list *list; // list est un pointeur sur struct list

//creer une liste vide
list createList();

//renvoie si la liste L est vide
bool isEmpty(list L);

//renvoie la valeur contenu dans la premiere case de L
arc value(list L);

//renvoie l'adresse de la case suivante
list next(list L);

//insere x au debut de la liste L et renvoie l'adresse de la nouvelle premiere case
list insertBegin(list L, arc x);

//supprime le premier element de la liste L et renvoie l'adresse de la case suivante
list deleteBegin(list L);

//insert x dans une liste apres la case pointee par cursor
void insertAfter(list cursor, arc x);

//supprime la case d'une liste apres celle pointee par cursor
void deleteAfter(list cursor);

#endif
