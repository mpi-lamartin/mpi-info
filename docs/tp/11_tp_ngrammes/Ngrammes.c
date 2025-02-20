#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#define K 128 //nombre de codes

int plus_frequent_successeur(char c, char* chaine){
    int occ[K] = {0}; // garde en mémoire le nombre d'occurrences de chaque successeur
    int n = strlen(chaine);
    int b_max = 0;
    for (int i=0; i<n; i++){
        if (chaine[i] == c){
            int b = (int) chaine[i+1];
            occ[b]++;
            if (occ[b] > occ[b_max]){
                b_max = b;
            }
        }
    }
    return b_max;
}

int* init_modele(char* chaine){
    int* M = malloc(K * sizeof(int));
    for (int a=0; a<K; a++){
        M[a] = plus_frequent_successeur((char) a, chaine);
    }
    return M;
}

int** matrice_confusion(int* M, char* test){
    // Initialisation d'une matrice de 0
    int** mat = malloc(K * sizeof(int*));
    for (int a=0; a<K; a++){
        mat[a] = malloc(K * sizeof(int));
        for (int b=0; b<K; b++){
            mat[a][b] = 0;
        }
    }
    // On modifie les coefficients de la matrice de confusion
    int n = strlen(test);
    for (int i=0; i<n; i++){
        int a = (int) test[i + 1];
        int b = M[(int) test[i]];
        mat[a][b]++;
    }
    return mat;
}

double taux_erreur(int** mat){
    int occ = 0, erreurs = 0;
    for (int a=0; a<K; a++){
        for (int b=0; b<K; b++){
            occ += mat[a][b];
            if (a != b){
                erreurs += mat[a][b];
            }
        }
    }
    return 1.0 * erreurs / occ;
}

void liberer_mat(int** mat){
    for (int a=0; a<K; a++){
        free(mat[a]);
    }
    free(mat);
}

int main(void){
    char chaine[] = "Bonjour, comment allez-vous ? Ca va, ca va aller bien mieux.";
    char test[] = "Bonjour, ca va bien ? Oui ! Bien mieux, et vous, ca va ?";
    int* M = init_modele(chaine);
    int** mat = matrice_confusion(M, test);
    printf("Taux erreurs : %lf\n", taux_erreur(mat));
    free(M);
    liberer_mat(mat);
    return 0;
}