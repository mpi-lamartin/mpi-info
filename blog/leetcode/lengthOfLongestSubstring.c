// 1ere solution : O(n^3) en regardant, pour chaque sous-chaîne, si elle contient un doublon
int lengthOfLongestSubstring(char* s) {
    int max = 0;
    for(int i = 0; i < strlen(s); i++) {
        int j = i + 1;
        int b = 0;
        while(j < strlen(s)) {
            for(int k = i; k < j; k++) {
                if(s[k] == s[j])
                    b = 1;
            }
            if(b) break;
            j++;
        }
        if(j - i > max)
            max = j - i;
    }
    return max;
}

// 2eme solution : O(n^2) en conservant un tableau count pour savoir si un caractère est déjà présent dans la sous-chaîne
// on utilise un tableau de 256 éléments pour les caractères ASCII
int lengthOfLongestSubstring(char* s) {
    int max = 0;
    int n = strlen(s);
    for(int i = 0; i < n; i++) {
        int j = i;
        int count[256] = {0};
        while(j < n && count[s[j]] == 0) {
            count[s[j]] = 1;
            j++;
        }
        if(j - i > max)
            max = j - i;
    }
    return max;
}