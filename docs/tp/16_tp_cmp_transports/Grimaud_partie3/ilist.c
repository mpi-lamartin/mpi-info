// Written by A. Grimaud
// March 2026

#include <stdio.h>
#include <stdlib.h>
#include "ilist.h"

/* create an empty list */
ilist create_iList(void){
  return NULL;
}

/* check if list is empty */
int isEmpty_iList(ilist L){
  return (L == NULL);
}

/* return value at head */
intervalle value_iList(ilist L){
  if (L == NULL){
    fprintf(stderr, "Error: empty list\n");
    exit(EXIT_FAILURE);
  }
  return L->value;
}

/* insert at beginning */
ilist insertBegin_iList(ilist L, intervalle c){
  ilist new_cell = malloc(sizeof(ilist_s));
  if (new_cell == NULL){
    fprintf(stderr, "Memory allocation error\n");
    exit(EXIT_FAILURE);
  }

  new_cell->value = c;
  new_cell->next = L;

  return new_cell;
}

/* delete first element */
ilist deleteBegin_iList(ilist L){
  if (L == NULL){
    fprintf(stderr, "Error: empty list\n");
    exit(EXIT_FAILURE);
  }

  ilist next = L->next;
  free(L);

  return next;
}
