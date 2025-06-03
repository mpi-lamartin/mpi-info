type elt = { prio : int ; ab : Arbre.arbre }

type file = elt list

let init () =
  []

let add prio ab f =
  let e = { prio ; ab } in
  let rec aux = function
    | [] -> [e]
    | hd::tl when hd.prio > e.prio ->
       e::hd::tl
    | hd::tl ->
       hd::(aux tl)
  in
  aux f

let recup_min f =
  match f with
  | hd::tl -> hd
  | [] -> failwith "file vide"

let extract_2_min f =
  match f with
  | hd::hd2::tl -> hd, hd2, tl
  | _ -> failwith "file vide"

let est_vide f =
  match f with
  | [] -> true
  | _ -> false

let est_singleton f =
  match f with
  | [_] -> true
  | _ -> false
