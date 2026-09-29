type 'a regexp =
    | Vide | Epsilon | L of 'a
    | Union of 'a regexp * 'a regexp
    | Concat of 'a regexp * 'a regexp
    | Etoile of 'a regexp;;

(* solution:q1:start *)
let rec fusion l1 l2 = match l1, l2 with
    | [], l2 -> l2
    | l1, [] -> l1
    | t1::q1, t2::q2 -> if t1 < t2 then t1::(fusion q1 l2)
                        else if t1 > t2 then t2::(fusion l1 q2)
                        else t1::(fusion q1 q2);;
fusion [1;3;5] [2;3;4;6]
(* solution:q1:end *)

(* solution:q2:start *)
let rec est_vide e = match e with
    | Vide -> true
    | Epsilon -> false
    | L _ -> false
    | Union (e1, e2) -> (est_vide e1) && (est_vide e2)
    | Concat (e1, e2) -> (est_vide e1) || (est_vide e2)
    | Etoile _ -> false;;
est_vide (Concat(L 1, Vide));;
est_vide (Etoile Vide);;
(* solution:q2:end *)

(* solution:q3:start *)
let rec a_epsilon e = match e with
    | Vide -> false
    | Epsilon -> true
    | L _ -> false
    | Union (e1, e2) -> (a_epsilon e1) || (a_epsilon e2)
    | Concat (e1, e2) -> (a_epsilon e1) && (a_epsilon e2)
    | Etoile _ -> true;;
a_epsilon (Concat(L 1, Epsilon));;
a_epsilon (Etoile (L 1));;
(* solution:q3:end *)

(* solution:q6:start *)
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
(* solution:q6:end *)

(* solution:q7:start *)
let rec s e = match e with
    | Vide -> []
    | Epsilon -> []
    | L a -> [a]
    | Union (e1, e2) -> fusion (s e1) (s e2)
    | Concat (e1, e2) ->
        if est_vide e1 || est_vide e2 then []
        else if a_epsilon e2 then fusion (s e1) (s e2)
        else s e2
    | Etoile e1 -> s e1;;
s (Union (L 2, Concat(L 1, L 3)));;
s (Concat (Vide, L 1));;
s (Concat (Concat(L 1, L 3), L 2));;
s (Concat (L 2, Epsilon));;
(* solution:q7:end *)

(* solution:q8:start *)
let rec produit l1 l2 = match l1, l2 with
    | [], _ -> []
    | _, [] -> []
    | t1::q1, t2::q2 -> (t1, t2)::(produit [t1] q2)@(produit q1 l2);;
produit [1;2] [3;4];;
(* solution:q8:end *)

(* solution:q9:start *)
let rec f e = match e with
    | Vide -> []
    | Epsilon -> []
    | L a -> []
    | Union (e1, e2) -> fusion (f e1) (f e2)
    | Concat (e1, e2) ->
        if est_vide e1 || est_vide e2 then []
        else let l = fusion (f e1) (f e2) in
            fusion l (produit (s e1) (p e2))
    | Etoile e1 -> fusion (f e1) (produit (s e1) (p e1));;
f (Concat (Concat(L 1, L 3), L 2));;
(* solution:q9:end *)

(* solution:q10:start *)
let rec n_lettres e = match e with
    | Vide -> 0
    | Epsilon -> 0
    | L _ -> 1
    | Union (e1, e2) -> n_lettres e1 + n_lettres e2
    | Concat (e1, e2) -> n_lettres e1 + n_lettres e2
    | Etoile e1 -> n_lettres e1;;
(* solution:q10:end *)

(* solution:q11:start *)
let lineariser e =
    let r = ref 0 in
    let rec aux e = match e with
        | Vide -> Vide
        | Epsilon -> Epsilon
        | L a -> incr r; L (a, !r)
        | Union (e1, e2) -> let e1' = aux e1 in
                            let e2' = aux e2 in
                            Union (e1', e2')
        | Concat (e1, e2) -> let e1' = aux e1 in
                             let e2' = aux e2 in
                             Concat (e1', e2')
        | Etoile e1 -> Etoile (aux e1) in
    aux e;;
lineariser (Union (Concat (L 'a', L 'b'), Etoile (L 'a')));;
(* solution:q11:end *)

(* solution:q12:start *)
type 'a automate = {
    delta : 'a list array array;
    finaux : bool array;
}
let glushkov e =
    let e' = lineariser e in
    let n = n_lettres e' in

    let delta = Array.make_matrix (n + 1) (n + 1) [] in
    (* ajoute une transition de i vers j *)
    let add i j k = delta.(i).(j) <- k::delta.(i).(j) in
    List.iter (fun (a, i) -> add 0 i a) (p e');
    List.iter (fun ((a, i), (b, j)) -> add i j b) (f e');

    let finaux = Array.make (n + 1) false in
    List.iter (fun (a, i) -> finaux.(i) <- true) (s e');
    finaux.(0) <- a_epsilon e';
    { delta = delta; finaux = finaux };;
(* solution:q12:end *)

(* solution:q13:start *)
let e = Etoile (Union(L 'b', Concat(L 'a', Concat(Etoile (L 'b'), L 'a'))));;
glushkov e
(* solution:q13:end *)
