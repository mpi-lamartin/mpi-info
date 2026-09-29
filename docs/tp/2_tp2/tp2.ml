(* solution:q1:start *)
type afdc = {
    initial : int;
    finaux : int list;
    delta : int array array
}
let a1 = {
    initial = 0;
    finaux = [1];
    delta = [|[|1; 0|]; [|0; 1|]|]
}
let a2 = {
    initial = 0;
    finaux = [2];
    delta = [|[|0; 1|]; [|1; 2|]; [|2; 0|]|]
}
(* solution:q1:end *)

(* solution:q2:start *)
let rec delta_etoile a q u = match u with
    | [] -> q
    | t::q2 -> delta_etoile a (a.delta.(q).(t)) q2;;

delta_etoile a1 a1.initial [0; 1];;
(* solution:q2:end *)

(* solution:q3:start *)
let accepte a u =
  List.mem (delta_etoile a a.initial u) a.finaux;;

accepte a1 [0; 1];;
accepte a1 [1; 0; 0];;
(* solution:q3:end *)

(* solution:q4:start *)
let complementaire a =
  let rec aux n =
    if n = -1 then []
    else if List.mem n a.finaux then aux (n - 1)
    else n::aux (n - 1) in
  {initial = a.initial; finaux = aux (Array.length a.delta - 1); delta = a.delta};;
complementaire a1;;
(* solution:q4:end *)

(* solution:q5:start *)
let accessibles a =
  let vus = Array.make (Array.length a.delta) false in
  let rec aux q = 
    vus.(q) <- true;
    for i = 0 to Array.length a.delta.(q) - 1 do
      if not vus.(a.delta.(q).(i)) then aux a.delta.(q).(i)
    done in
  aux a.initial;
  let rec aux2 n =
    if n = -1 then []
    else if vus.(n) then n::aux2 (n - 1)
    else aux2 (n - 1) in
  aux2 (Array.length a.delta - 1);;
accessibles a1;;

let a3 = {
    initial = 0;
    finaux = [2];
    delta = [|[|1; 0; 0|]; [|0; 1; 0|]; [|1; 0; 2|]|]
};;
accessibles a3;; (* l'état 2 n'est pas accessible *)
(* solution:q5:end *)

(* solution:q6:start *)
let vide a =
  not (List.exists (fun q -> List.mem q a.finaux) (accessibles a));;
(* solution:q6:end *)

(* solution:q7:start *)
let inter a b =
  let n = Array.length a.delta in
  let p = Array.length b.delta in
  let s = Array.length a.delta.(0) in
  let d = Array.make_matrix (n*p) s (-1) in
  for i = 0 to n - 1 do
    for j = 0 to p - 1 do
      for k = 0 to s - 1 do
        d.(i*p + j).(k) <- a.delta.(i).(k)*p + b.delta.(j).(k)
      done
    done
  done;
  let rec finaux l1 l2 = match l1, l2 with
    | [], _ -> []
    | _, [] -> []
    | i::q, j::q' -> (i*p + j)::(finaux q l2)@(finaux [i] q') in
  {initial = a.initial*p + b.initial; finaux = finaux a.finaux b.finaux; delta = d};;

let a3 = inter a1 a2;;
accepte a3 [0; 1; 0; 0; 1];;
accepte a3 [0; 1; 1; 0; 0; 1];;
accepte a3 [1; 0; 0; 1];;
(* solution:q7:end *)

(* solution:q8:start *)
(* A est inclus dans B ssi A inter (complémentaire de B) est vide *)
let inclus a b =
  vide (inter a (complementaire b));;
(* solution:q8:end *)

(* solution:q9:start *)
let equivalent a b =
  inclus a b && inclus b a;;
(* solution:q9:end *)
