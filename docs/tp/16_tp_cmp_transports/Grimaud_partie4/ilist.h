// Written by A. Grimaud
// March 2026

#ifndef ILIST_H
#define ILIST_H

#include "graph.h"

typedef struct ilist_s {
  intervalle value;
  struct ilist_s *next;
} ilist_s;

typedef ilist_s* ilist;

ilist create_iList(void);
int isEmpty_iList(ilist L);
intervalle value_iList(ilist L);
ilist insertBegin_iList(ilist L, intervalle c);
ilist deleteBegin_iList(ilist L);

#endif
