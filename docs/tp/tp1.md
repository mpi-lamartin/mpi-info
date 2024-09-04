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

<details>
<summary>Indice</summary>

<Tabs>
<TabItem label="Version récursive">

```c
#include <stdbool.h>
#include <stdio.h>

bool dichotomie(int* t, int e, int i, int j) {
    // détermine si e apparait entre les indices i et j de t
    ...
}

int main() {
    int t[10] = {-4, -2, 0, 1, 3, 5, 7, 9, 11, 13};
    printf("%d\n", dichotomie(t, 1, 0, 10)); // 1 
    printf("%d\n", dichotomie(t, 4, 0, 10)); // 0
    printf("%d\n", dichotomie(t, 13, 0, 10)); // 1
    return 0;
}
```
</TabItem>
<TabItem label="Version itérative">

```c
#include <stdbool.h>
#include <stdio.h>

bool dichotomie(int* t, int e, int n){
    ...
}

int main() {
    int t[10] = {-4, -2, 0, 1, 3, 5, 7, 9, 11, 13};
    printf("%d\n", dichotomie(t, 1, 10)); // 1 
    printf("%d\n", dichotomie(t, 4, 10)); // 0
    printf("%d\n", dichotomie(t, 13, 10)); // 1
    return 0;
}
```
</TabItem>
</Tabs>
