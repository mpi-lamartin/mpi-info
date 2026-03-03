---
sidebar_position: 12
title: "TP Déduction naturelle"
description: Algorithme de recherche de preuve
---

# TP : Déduction Naturelle en OCaml

Dans ce TP, nous allons implémenter un prouveur de théorèmes pour la logique propositionnelle en déduction naturelle.
Nous allons construire des arbres de preuve en appliquant les règles d'introduction et d'élimination des connecteurs logiques. L'algorithme principal sera une recherche avec retour sur trace (backtracking).

## 1. Représentation des formules et des séquents

Nous allons utiliser la représentation suivante pour les formules de la logique propositionnelle :

```ocaml
type var = string

type formule =
  | Var of var
  | Top
  | Bot
  | And of formule * formule
  | Or of formule * formule
  | Implies of formule * formule
  | Not of formule
```

Un séquent $\Gamma \vdash \varphi$ représente le fait que la formule $\varphi$ est déductible à partir de l'ensemble de formules (ou hypothèses) $\Gamma$.

```ocaml
type ensemble_formules = formule list

type sequent = {
  gamma : ensemble_formules;
  phi : formule;
}
```

### Exercice 1 : Utilitaires

1. Écrire une fonction `mem : formule -> ensemble_formules -> bool` qui teste si une formule appartient au contexte $\Gamma$.
2. Écrire une fonction `string_of_formule : formule -> string` qui renvoie la représentation sous forme de chaîne de caractères d'une formule.
3. Écrire une fonction `string_of_sequent : sequent -> string` pour afficher un séquent.

## 2. Arbre de preuve et règles de déduction

Une preuve en déduction naturelle est un arbre dont les feuilles sont des axiomes et les nœuds internes correspondent aux applications des règles de déduction.

```ocaml
type regle =
  | Axiom
  | TopIntro
  | BotElim
  | AndIntro
  | AndElim1 of formule (* On mémorise la formule ignorée de la conjonction *)
  | AndElim2 of formule
  | OrIntro1
  | OrIntro2
  | OrElim of formule * formule (* On mémorise les deux formules du Ou *)
  | ImpliesIntro
  | ImpliesElim of formule (* On mémorise l'antécédent *)
  | NotIntro
  | NotElim of formule

type arbre_preuve =
  | Noeud of regle * sequent * arbre_preuve list
```

### Exercice 2 : Application d'une règle

Pour construire l'arbre de preuve, il faut savoir quelles sous-preuves (quels "sous-séquents") sont nécessaires pour prouver un séquent donné en fonction de la règle appliquée.

Écrire une fonction `appliquer_regle : regle -> sequent -> sequent list option` qui, étant donné une règle et un séquent à prouver, renvoie la liste des prémisses (les sous-séquents) nécessaires. Si la règle n'est pas applicable (par exemple, si on essaie d'appliquer `AndIntro` alors que le but n'est pas une conjonction), la fonction renverra `None`.

_Exemple :_

- `appliquer_regle AndIntro { gamma; phi = And (f1, f2) }` doit renvoyer `Some [{ gamma; phi = f1 }; { gamma; phi = f2 }]`.
- `appliquer_regle Axiom { gamma; phi }` doit renvoyer `Some []` si `mem phi gamma = true`, sinon `None`.

## 3. Algorithme de recherche (Backtracking)

Nous allons implémenter un algorithme de recherche en profondeur. L'idée est d'essayer d'appliquer les règles de déduction possibles, et pour chacune d'elles, de chercher récursivement une preuve pour toutes les prémisses engendrées. Si on échoue, on revient en arrière (backtracking) et on essaie la règle suivante.

### Exercice 3 : Prouver un séquent

Écrire une fonction récursive `prouver : int -> sequent -> arbre_preuve option` où `int` représente la profondeur maximale de recherche (pour éviter de boucler indéfiniment).

L'algorithme doit suivre ces étapes :

1. Si la profondeur maximale est atteinte (`<= 0`), on renvoie `None`.
2. Sinon, on liste toutes les règles que l'on souhaite essayer. _Indice : essayez d'abord les règles d'introduction et `Axiom`, puis les règles d'élimination._ Les règles d'élimination demandent souvent de deviner une formule (par exemple la formule intermédiaire dans la règle du Modus Ponens/`ImpliesElim`). Pour restreindre la recherche, vous pouvez vous limiter aux sous-formules des hypothèses.
3. Pour chaque règle de la liste :
   - On appelle `appliquer_regle` sur le séquent.
   - Si ça réussit, on obtient une liste de prémisses. On essaie de `prouver` chacune de ces prémisses récursivement (avec une profondeur décrémentée).
   - Si toutes les prémisses sont prouvées, on renvoie le nœud de l'arbre de preuve correspondant.
4. Si aucune règle n'aboutit à une preuve complète, renvoyer `None`.

### Exercice 4 : Un peu d'aide (stratégique) pour la recherche

L'étape 2 de l'exercice 3 demande une liste de règles à tester.
Écrire une fonction `regles_possibles : sequent -> regle list` qui retourne la liste des règles judicieuses à essayer en fonction du séquent (en observant la forme du but et les formules présentes dans $\Gamma$).

Intégrer cette fonction dans votre algorithme `prouver`.

### Exercice 5 : Preuve la plus courte (Recherche itérative)

Notre algorithme effectue une recherche en profondeur (DFS). S'il trouve une solution avec une limite de profondeur élevée, cette preuve risque d'être inutilement complexe avec des détours inutiles.
Pour garantir de trouver la preuve ayant le moins grand nombre de pas (hauteur de l'arbre), on utilise la technique de l'approfondissement itératif (_Iterative Deepening_).

Écrire une fonction `prouver_min : int -> sequent -> arbre_preuve option` qui appelle `prouver` avec une profondeur de 1, puis 2, etc., jusqu'à trouver une solution ou atteindre la profondeur maximale donnée en argument.

## 4. Tests et extensions

### Exercice 6 : Validation

Testez votre prouveur sur quelques tautologies classiques :

1. $\varphi \to \varphi$
2. $\varphi \land \psi \to \psi \land \varphi$
3. $\varphi \to (\psi \to \varphi)$
4. $(\varphi \to (\psi \to \chi)) \to ((\varphi \to \psi) \to (\varphi \to \chi))$

L'implication $(\neg \psi \to \neg \varphi) \to (\varphi \to \psi)$ serait-elle prouvable avec ces seules règles ? (Indice : non, elle nécessite une règle de Raisonnement par l'Absurde propre à la logique classique).

---

_Remarque : ce prouveur naïf est limité par l'explosion combinatoire. Des techniques comme l'unification et la résolution permettent des implémentations beaucoup plus efficaces._
