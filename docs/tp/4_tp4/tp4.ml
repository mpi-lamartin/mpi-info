type grammaire = {
    n_variables : int;
    regles1 : (int * char) list;
    regles2 : (int * int * int) list;
    epsilon : bool
}

(* 6 *)
let g0 = { 
    n_variables = 5;
    regles1 = [(0, 'b'); (1, 'a'); (2, 'b'); (4, 'a')];
    regles2 = [(0, 1, 2); (0, 2, 1); (0, 3, 1); (1, 1, 4); (3, 1, 2)];
    epsilon = false
}

(* 7 *)
let cyk g u =
    let n = String.length u in
    let k = g.n_variables in
    let t = Array.make (n+1) [||] in
    for i = 0 to n do
        t.(i) <- Array.make_matrix n k false
    done;
    if g.epsilon then t.(0).(0).(0) <- true;

    let rec aux = function
        | [] -> ()
        | (i, a)::q ->
            for d = 0 to n - 1 do
                if u.[d] = a then t.(1).(d).(i) <- true
            done;
            aux q
    in
    aux g.regles1;

    for l = 2 to n do
        for d = 0 to n - l do
            let rec aux = function
                | [] -> ()
                | (i, j, k)::q ->
                    for p = 1 to l - 1 do
                        if d + p < n && t.(p).(d).(j) && t.(l-p).(d+p).(k) 
                        then t.(l).(d).(i) <- true
                    done;
                    aux q
            in
            aux g.regles2
        done
    done;
    t.(n).(0).(0);;

(* 8 *)
cyk g0 "aab";;
cyk g0 "aabb";;
cyk g0 "abaa";;
cyk g0 "aababa";;

(* 9 *)
type arbre = Vide | Un of int * char | Deux of int * arbre * arbre

let arbre_derivation g u : arbre option =
    let n = String.length u in
    let k = g.n_variables in
    let t = Array.make (n+1) [||] in
    for i = 0 to n do
        t.(i) <- Array.make_matrix n k None
    done;
    if g.epsilon then t.(0).(0).(0) <- Some Vide;
    let rec aux = function
        | [] -> ()
        | (i, a)::q ->
            for d = 0 to n - 1 do
                if u.[d] = a then t.(1).(d).(i) <- Some (Un (i, a))
            done;
            aux q
    in
    aux g.regles1;

    for l = 2 to n do
        for d = 0 to n - l do
            let rec aux = function
                | [] -> ()
                | (i, j, k)::q ->
                    for p = 1 to l - 1 do
                        if d + p < n
                        then match t.(p).(d).(j), t.(l-p).(d+p).(k) with
                        | Some a1, Some a2 -> t.(l).(d).(i) <- Some (Deux (i, a1, a2))
                        | _ -> ()
                    done;
                    aux q
            in
            aux g.regles2
        done
    done;
    t.(n).(0).(0);;

(* 10 *)

arbre_derivation g0 "aab";;