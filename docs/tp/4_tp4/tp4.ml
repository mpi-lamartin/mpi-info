type 'a regexp = 
    | Vide | Epsilon | L of 'a
    | Union of 'a regexp * 'a regexp
    | Concat of 'a regexp * 'a regexp
    | Etoile of 'a regexp;;

(* 1 *)
let rec fusion l1 l2 = match l1, l2 with
    | [], l2 -> l2
    | l1, [] -> l1
    | t1::q1, t2::q2 -> if t1 < t2 then t1::(fusion q1 l2)
                        else if t1 > t2 then t2::(fusion l1 q2)
                        else t1::(fusion q1 q2);;
fusion [1;3;5] [2;3;4;6];;

(* 2 *)
let rec est_vide e = match e with
    | Vide -> true
    | Epsilon -> false
    | L _ -> false
    | Union (e1, e2) -> (est_vide e1) && (est_vide e2)
    | Concat (e1, e2) -> (est_vide e1) || (est_vide e2)
    | Etoile _ -> false;;

(* 3 *)
let rec a_epsilon e = match e with
    | Vide -> false
    | Epsilon -> true
    | L _ -> false
    | Union (e1, e2) -> (a_epsilon e1) || (a_epsilon e2)
    | Concat (e1, e2) -> (a_epsilon e1) && (a_epsilon e2)
    | Etoile _ -> true;;

(* 6 *)
let rec p e = match e with
    | Vide -> []
    | Epsilon -> []
    | L a -> [a]
    | Union (e1, e2) -> fusion (p e1) (p e2)
    | Concat (e1, e2) -> 
        if est_vide e1 || est_vide e2 then []
        else if (a_epsilon e1) then fusion (p e1) (p e2)
        else p e1
    | Etoile e1 -> p e1;;
p (Union (Concat(L 1, L 3), L 2));;
p (Concat (L 1, Vide));;
p (Concat (Concat(L 1, L 3), L 2));;
p (Concat (Epsilon, L 2));;

(* 7 *)
let rec s e = match e with
    | Vide -> []
    | Epsilon -> []
    | L a -> [a]
    | Union (e1, e2) -> fusion (s e1) (s e2)
    | Concat (e1, e2) -> 
        if est_vide e1 || est_vide e2 then []
        else if a_epsilon e1 then fusion (s e1) (s e2)
        else s e2
    | Etoile e1 -> s e1;;
s (Concat(L 1, L 3));;

(* 8 *)
let rec produit l1 l2 = match l1, l2 with
    | [], _ -> []
    | _, [] -> []
    | t1::q1, t2::q2 -> (t1, t2)::(produit [t1] q2)@(produit q1 l2);;

(* 9 *)
let rec f e = match e with
    | Vide -> []
    | Epsilon -> []
    | L a -> []
    | Union (e1, e2) -> fusion (f e1) (f e2)
    | Concat (e1, e2) -> 
        if est_vide e1 || est_vide e2 then []
        else let l = fusion (f e1) (f e2) in
            fusion l (produit (s e1) (p e2))
    | Etoile e1 -> f e1;;
f (Concat (Concat(L 1, L 3), L 2));;

(* 10 *)
let rec n_lettres e = match e with
    | Vide -> 0
    | Epsilon -> 0
    | L _ -> 1
    | Union (e1, e2) -> n_lettres e1 + n_lettres e2
    | Concat (e1, e2) -> n_lettres e1 + n_lettres e2
    | Etoile e1 -> n_lettres e1;;

(* 11 *)
