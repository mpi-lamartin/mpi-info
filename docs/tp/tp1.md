---
hide_table_of_contents: true
hide_title: true
title: "TP 1 : révisions de MP2I"
---

Ce TP est à effectuer en C, sous Visual Code. Vous pouvez utiliser le Codespace ou votre ordinateur personnel.

## Dichotomie

On rappelle que la recherche par dichotomie d'un élément `e` dans un tableau trié `t` consiste à considérer l'élément au milieu `t[m]` puis :
- Si `e == t[m]` : on renvoie `true`.
- Si `e < t[m]` : on regarde à gauche de `m`.
- Si `e > t[m]` : on regarde à droite de `m`.


:::info[Exercice]

Écrire une fonction `bool dichotomie(int* t, int n, int e)` déterminant si `e` appartient au tableau `t` de taille `n`.

