---
hide_table_of_contents: true
hide_title: true
title: "TP 1 : révisions de MP2I"
---

Ce TP est à effectuer en C, sous Visual Code. Vous pouvez utiliser le [Codespace GitHub](./0_codespace.md) ou votre ordinateur personnel.

## Dichotomie

On rappelle que la recherche par dichotomie d'un élément `e` dans un tableau trié `t` consiste à considérer l'élément au milieu `t[m]` puis :
- Si `e == t[m]` : on renvoie `true`.
- Si `e < t[m]` : on regarde à gauche de `m`.
- Si `e > t[m]` : on regarde à droite de `m`.


:::info[Exercice]

Écrire une fonction `dichotomie` déterminant si un élément `e` appartient à un tableau `t`. On pourra utiliser soit une fonction récursive, soit une boucle `while`.

