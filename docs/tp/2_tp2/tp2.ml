(* type automate = { 
    initiaux : int list;
    finaux : int list;
    transitions : (int * char * int) list
}

(* 2 *)
let a1 = {
    initiaux = [0];
    finaux = [1];
    transitions = [(0, 'b', 0); (0, 'a', 1); (1, 'a', 0); (1, 'b', 1)]
}
let a2 = {
    initiaux = [0];
    finaux = [2];
    transitions = [(0, 'a', 0); (0, 'b', 1); (1, 'a', 0); (1, 'a', 2); (2, 'b', 2)]
}

(* 3 *)
let miroir a =
  let rec aux = function
      | [] -> []
      | (e, l, e2)::q -> (e2, l, e)::aux q
  in {initiaux = a.finaux; finaux = a.initiaux; transitions = aux a.transitions};;

miroir a1

(* 4 *)
let est_deterministe a =
  let rec aux = function
      | [] -> true
      | (q1, a, q2)::t -> 
          let rec aux2 = function
              | [] -> aux q
              | (q1', a', q2')::t' -> if q1 = q1' && a = a' then false else aux2 t'
          in aux2 q
  in List.length a.initiaux = 1 && aux a.transitions;;

est_deterministe a1;;
est_deterministe a2;; *)

(* 1 *)
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

(* 2 *)
let rec delta_etoile a q u = match u with
    | [] -> q
    | t::q2 -> delta_etoile a (a.delta.(q).(t)) q2;;

delta_etoile a1 a1.initial [0; 1];;

(* 3 *)
let accepte a u =
  List.mem (delta_etoile a a.initial u) a.finaux;;

accepte a1 [0; 1];;
accepte a1 [1; 0; 0];;

(* 4 *)
let complementaire a =
  let rec aux n = 
    if n = -1 then []
    else if List.mem n a.finaux then aux (n - 1)
    else n::aux (n - 1) in
  {initial = a.initial; finaux = aux (Array.length a.delta - 1); delta = a.delta};;
complementaire a1;;

(* 5 *)
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
accessibles a3;; (* 3 n'est pas accessible *)

(* 6 *)
let vide a =
  List.exists (fun q -> List.mem q a.finaux) (accessibles a);;

(* 7 *)
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

(* 8 *)
(* A est inclus dans B ssi A inter (complémentaire de B) est vide *)
let inclus a b =
  vide (inter a (complementaire b));;

(* 9 *)
let equivalent a b =
  inclus a b && inclus b a;;
