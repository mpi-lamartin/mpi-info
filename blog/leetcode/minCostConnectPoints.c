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

arete a(int u, int v, int poids) {
    arete e;
    e.u = u;
    e.v = v;
    e.poids = poids;
    return e;
}

typedef struct {
  int n; // nombre d'élements
  int* t; // t[i] = père de i
} uf;

uf* create(int n) {
    uf* u = malloc(sizeof(uf));
    u->n = n;
    u->t = malloc(n * sizeof(int));
    for (int i = 0; i < n; i++) {
        u->t[i] = -1;
    }
    return u;
}

int find(uf* u, int x) {
    if (u->t[x] < 0) {
        return x;
    } else {
        int r = find(u, u->t[x]);
        u->t[x] = r;
        return r;
    }
}

void merge(uf* u, int x, int y) {
    int rx = find(u, x);
    int ry = find(u, y);
    if (rx < ry) u->t[ry] = rx;
    else if (rx > ry) u->t[rx] = ry;
    else {
        u->t[ry] = rx;
        u->t[rx]--;
    }
}

void fusion(arete* t, int n, arete* t1, int n1, arete* t2, int n2) {
    int i = 0;
    int j = 0;
    int k = 0;
    while (i < n1 && j < n2) {
        if (t1[i].poids < t2[j].poids) {
            t[k] = t1[i];
            i++;
        } else {
            t[k] = t2[j];
            j++;
        }
        k++;
    }
    while (i < n1) {
        t[k] = t1[i];
        i++;
        k++;
    }
    while (j < n2) {
        t[k] = t2[j];
        j++;
        k++;
    }
}

void tri_fusion(arete* t, int n, int debut, int fin) {
    if (fin - debut <= 1) {
        return;
    }
    int milieu = (debut + fin) / 2;
    tri_fusion(t, n, debut, milieu);
    tri_fusion(t, n, milieu, fin);
    arete* temp = malloc((fin - debut) * sizeof(arete));
    fusion(temp, fin - debut, &t[debut], milieu - debut, &t[milieu], fin - milieu);
    for (int i = debut; i < fin; i++) {
        t[i] = temp[i - debut];
    }
    free(temp);
}

int minCostConnectPoints(int** points, int pointsSize, int* pointsColSize) {
    arete* t = malloc(pointsSize * (pointsSize - 1) / 2 * sizeof(arete));
    int k = 0;
    for (int i = 0; i < pointsSize; i++) {
        for (int j = i + 1; j < pointsSize; j++) {
            t[k] = a(i, j, abs(points[i][0] - points[j][0]) + abs(points[i][1] - points[j][1]));
            k++;
        }
    }
    tri_fusion(t, pointsSize * (pointsSize - 1) / 2, 0, pointsSize * (pointsSize - 1) / 2);
    uf* u = create(pointsSize);
    int res = 0;
    for (int i = 0; i < pointsSize * (pointsSize - 1) / 2; i++) {
        if (find(u, t[i].u) != find(u, t[i].v)) {
            res += t[i].poids;
            merge(u, t[i].u, t[i].v);
        }
    }
    free(u->t);
    free(u);
    free(t);
    return res;
}
