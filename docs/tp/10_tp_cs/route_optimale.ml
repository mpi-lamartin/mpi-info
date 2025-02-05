type temps = int
type noeud = {id : int ; clefs : ((int * temps) list) ; est_final : bool}

type verrou = int list
type mgraphe = (temps * verrou * noeud) list array

type inventaire = int option array

type etat = {noeud : noeud; temps : temps; inventaire : inventaire}


(* Construction du multi-graphe *)
let ajoute_transition g n1 n2 t clefs : unit =
  g.(n1.id) <- (t, clefs, n2):: g.(n1.id);
  g.(n2.id) <- (t, clefs, n1):: g.(n2.id)


(* Exemple du jeu numéro 1 *)
let n1_0 = {id = 0; clefs = []; est_final = false}
let n1_1 = {id = 1; clefs = []; est_final = false}
let n1_2 = {id = 2; clefs = [(1, 1)]; est_final = false}
let n1_3 = {id = 3; clefs = [(0, 5); (1, 70)]; est_final = false}
let n1_4 = {id = 4; clefs = [(2, 5); (0, 1)]; est_final = false}
let n1_5 = {id = 5; clefs = []; est_final = true}

let g1 = Array.make 6 []
let () = ajoute_transition g1 n1_0 n1_1 10 [0]
let () = ajoute_transition g1 n1_1 n1_2 2 [1]
let () = ajoute_transition g1 n1_1 n1_2 10 []
let () = ajoute_transition g1 n1_0 n1_3 10 []
let () = ajoute_transition g1 n1_1 n1_4 80 [1]
let () = ajoute_transition g1 n1_2 n1_5 5 [1; 2]
let () = ajoute_transition g1 n1_3 n1_4 10 [1]
let () = ajoute_transition g1 n1_4 n1_5 10 [0; 1]


(* Exemple du jeu numéro 2 *)

let n2_0 = {id = 0; clefs = []; est_final = true}
let n2_1 = {id = 1; clefs = [(2, 10)]; est_final = false}
let n2_2 = {id = 2; clefs = [(5, 10)]; est_final = false}

(* Noeud initial : n2_3*)
let n2_3 = {id = 3; clefs = [(0, 10); (1, 1)]; est_final = false}
let n2_4 = {id = 4; clefs = []; est_final = false}
let n2_5 = {id = 5; clefs = [(8, 5)]; est_final = false}
let n2_6 = {id = 6; clefs = [(14, 10)]; est_final = false}
let n2_7 = {id = 7; clefs = [(12, 10)]; est_final = false}
let n2_8 = {id = 8; clefs = [(6, 5)]; est_final = false}
let n2_9 = {id = 9; clefs = [(3, 5); (4, 10)]; est_final = false}
let n2_10 = {id = 10; clefs = [(13, 10)]; est_final = false}
let n2_11 = {id = 11; clefs = [(10, 10)]; est_final = false}
let n2_12 = {id = 12; clefs = [(11, 10); (9, 5)]; est_final = false}
let n2_13 = {id = 13; clefs = []; est_final = false}
let n2_14 = {id = 14; clefs = [(15, 10)]; est_final = false}
let n2_15 = {id = 15; clefs = [(7, 10)]; est_final = false}
let n2_16 = {id = 16; clefs = [(5, 5)]; est_final = false}
let n2_17 = {id = 17; clefs = [(16, 10)]; est_final = false}

let g2 = Array.make 18 []
let () = ajoute_transition g2 n2_0 n2_3 2 [11; 12; 13]
let () = ajoute_transition g2 n2_1 n2_4 14 [6; 7]
let () = ajoute_transition g2 n2_2 n2_3 9 [1]
let () = ajoute_transition g2 n2_3 n2_4 12 [3]
let () = ajoute_transition g2 n2_3 n2_4 5 [0]
let () = ajoute_transition g2 n2_4 n2_5 8 [0; 2]
let () = ajoute_transition g2 n2_2 n2_6 12 [5; 6]
let () = ajoute_transition g2 n2_2 n2_7 12 []
let () = ajoute_transition g2 n2_3 n2_7 7 [4]
let () = ajoute_transition g2 n2_3 n2_8 10 []
let () = ajoute_transition g2 n2_4 n2_11 10 []
let () = ajoute_transition g2 n2_5 n2_12 15 [3]
let () = ajoute_transition g2 n2_6 n2_7 17 [4; 5]
let () = ajoute_transition g2 n2_7 n2_8 12 [4]
let () = ajoute_transition g2 n2_8 n2_9 12 [6]
let () = ajoute_transition g2 n2_9 n2_10 22 [7]
let () = ajoute_transition g2 n2_10 n2_11 27 [4; 7]
let () = ajoute_transition g2 n2_7 n2_12 17 [0]
let () = ajoute_transition g2 n2_8 n2_12 22 [0; 6]
let () = ajoute_transition g2 n2_10 n2_13 12 []
let () = ajoute_transition g2 n2_12 n2_13 15 [0; 9]
let () = ajoute_transition g2 n2_13 n2_14 31 [7; 8]
let () = ajoute_transition g2 n2_13 n2_15 17 [2]
let () = ajoute_transition g2 n2_13 n2_16 17 [10]
let () = ajoute_transition g2 n2_16 n2_17 17 [15; 16]
