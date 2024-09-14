#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>

bool doublon1(int* t, int n) {
    bool* t2 = calloc(n, sizeof(bool)); // t2[j] = true si j est déjà apparu dans t
    // on peut aussi utiliser malloc à condition de mettre des 0
    for (int i = 0; i < n; i++) {
        int j = t[i];
        if (t2[j]) {
            free(t2);
            return true;
        }
        t2[j] = true;
    }
    free(t2);
    return false;
}

bool doublon2(int* t, int n) {
    for (int i = 0; i < n; i++) {
        int j = t[i] % n;
        if (t[j] >= n) {
            return true;
        }
        t[j] += n;
    }
    return false;
}

typedef struct cell {
    int elem;
    struct cell *next;
} cell;

bool cycle1(cell* l) {
    cell* p = l;
    while (l != NULL) {
        if (l->next == p) {
            return true;
        }
        l = l->next;
    }
    return false;
}

// si l contient un cycle alors, dans le référentiel de la tortue, le lièvre avance de 1 case à chaque itération donc arrivera sur la même case que la tortue
// l'intérêt par rapport à Q3 est d'avoir une complexité O(1) en mémoire
bool cycle2(cell* l) {
    cell* lievre = l, *tortue = l;
    while (lievre != NULL && lievre->next != NULL) {
        lievre = lievre->next->next;
        tortue = tortue->next;
        if (lievre == tortue) {
            return true;
        }
    }
    return false;
}

int main() {
    int t1[] = {0, 2, 5, 2, 1, 3};
    printf("%d\n", doublon1(t1, 6)); // Affiche 1
    printf("%d\n", doublon2(t1, 6)); // Affiche 1
    int t2[] = {0, 2, 5, 3, 1, 4};
    printf("%d\n", doublon1(t2, 6)); // Affiche 0
    printf("%d\n", doublon2(t2, 6)); // Affiche 0

    cell l1 = {.elem = 0, .next = NULL};
    cell l2 = {.elem = 1, .next = &l1};
    cell l3 = {.elem = 2, .next = &l2};
    printf("%d\n", cycle1(&l3)); // Affiche 0
    printf("%d\n", cycle2(&l3)); // Affiche 0
    l1.next = &l3;
    printf("%d\n", cycle1(&l3)); // Affiche 1
    printf("%d\n", cycle2(&l3)); // Affiche 1
    return 0; 
}