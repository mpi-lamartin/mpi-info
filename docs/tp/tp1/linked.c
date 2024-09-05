#include <stdio.h>
#include <stdlib.h>

struct list {
    int elem;
    struct list *next;
} typedef list;

list *add(list *l, int e) { 
    list *new = malloc(sizeof(list));
    new->elem = e;
    new->next = l;
    return new;
}

void print(list *l) {
    while (l != NULL) {
        printf("%d\n", l->elem);
        l = l->next;
    }
}

list *del(list *l) {
    list *tmp = l->next;
    free(l);
    return tmp;
}
// on a implémenté une structure de pile

int main() {
    list *l = NULL;
    l = add(l, 1);
    l = add(l, 2);
    l = add(l, 3);
    print(l);
    l = del(l);
    print(l);
    return 0;
}
