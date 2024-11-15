#include <stdio.h>
#include <stdlib.h>

typedef struct {
    int u;
    int v;
    int poids;
} arete;

typedef struct {
    int n; // nombre de sommets
    int *degres; // degres[i] = nombre de voisins du sommet i
    arete **aretes; // aretes[i] = tableau des aretes incidentes au sommet i
} graphe;

//1 
arete a(int u, int v, int poids) {
    arete e;
    e.u = u;
    e.v = v;
    e.poids = poids;
    return e;
}

// 3
int n_aretes(graphe g) {
    int n = 0;
    for (int i = 0; i < g.n; i++) {
        n += g.degres[i];
    }
    return n / 2;
}

// 4
arete* aretes(graphe g) {
    arete* t = malloc(n_aretes(g) * sizeof(arete));
    int k = 0;
    for (int i = 0; i < g.n; i++) {
        for (int j = 0; j < g.degres[i]; j++) {
            if (i < g.aretes[i][j].v) {
                t[k] = g.aretes[i][j];
                k++;
            }
        }
    }
    return t;
}


// 5
void tri_insertion(arete* t, int n) {
    for (int i = 1; i < n; i++) {
        arete e = t[i];
        int j = i - 1;
        while (j >= 0 && t[j].poids > e.poids) {
            t[j + 1] = t[j];
            j = j - 1;
        }
        t[j + 1] = e;
    }
}


// 6
typedef struct {
  int n; // nombre d'élements
  int* t; // t[i] = père de i
} uf;
uf* create(int n) {
    uf* u = malloc(sizeof(uf));
    u->n = n;
    u->t = malloc(n * sizeof(int));
    for (int i = 0; i < n; i++) {
        u->t[i] = i;
    }
    return u;
}

// 7
int find(uf* u, int x) {
    if (u->t[x] == x) {
        return x;
    } else {
        return find(u, u->t[x]);
    }
}

// 8
void merge(uf* u, int x, int y) {
    u->t[find(u, x)] = find(u, y);
}

// 9
int n_cc(uf* u) {
    int n = 0;
    for (int i = 0; i < u->n; i++) {
        if (u->t[i] == i) {
            n++;
        }
    }
    return n;
}

// 10
arete* kruskal(graphe g) {
    arete* t = aretes(g);
    tri_insertion(t, n_aretes(g));
    uf* u = create(g.n);
    arete* mst = malloc((g.n - 1) * sizeof(arete));
    int k = 0;
    for (int i = 0; i < n_aretes(g); i++) {
        if (find(u, t[i].u) != find(u, t[i].v)) {
            mst[k] = t[i];
            k++;
            merge(u, t[i].u, t[i].v);
        }
    }
    free(u->t);
    free(u);
    free(t);
    return mst;
}

int main() {
    // 2
    int degres[] = {3, 3, 4, 3, 2, 3, 2};
    arete a0[] = {a(0, 1, 1), a(0, 2, 5), a(0, 6, 5)};
    arete a1[] = {a(0, 1, 1), a(1, 3, 2), a(1, 6, 3)};
    arete a2[] = {a(0, 2, 5), a(2, 3, 3), a(2, 5, 5), a(2, 4, 2)};
    arete a3[] = {a(1, 3, 2), a(2, 3, 3), a(3, 5, 1)};
    arete a4[] = {a(2, 4, 2), a(4, 5, 5)};
    arete a5[] = {a(4, 5, 5), a(2, 5, 5), a(3, 5, 1)};
    arete a6[] = {a(0, 6, 5), a(0, 6, 5)};
    arete* g_aretes[] = {a0, a1, a2, a3, a4, a5, a6};
    graphe g = {
        .n = 7,
        .degres = degres,
        .aretes = g_aretes};

    printf("Nombre d'aretes : %d\n", n_aretes(g));
    arete* t = aretes(g);
    for (int i = 0; i < n_aretes(g); i++) {
        printf("Arete %d : %d %d %d\n", i, t[i].u, t[i].v, t[i].poids);
    }
    arete* mst = kruskal(g);
    for (int i = 0; i < 6; i++) {
        printf("Arete %d : %d %d %d\n", i, mst[i].u, mst[i].v, mst[i].poids);
    }
    // free_graphe(g);
    free(t);
    free(mst);
}
