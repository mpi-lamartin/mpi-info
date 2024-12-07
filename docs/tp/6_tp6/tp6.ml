type bipartite = {
  n1 : int;
  adj : int list array
}

type matching = int option array

type path = int list

(* 1 *)
let is_augmenting m path =
  let rec aux = function
  | x::y::xs -> m.(x) = Some y && aux xs
  | [x] -> m.(x) = None
  | [] -> false in
  match path with
  | x::xs -> m.(x) = None && aux xs
  | _ -> false

(* 2 *)
let rec delta m path =
  match path with
  | x::y::tl ->
    m.(x) <- Some y;
    m.(y) <- Some x;
    delta m tl
  | [] | [_] -> ()

(* 3 *)
let orient g m =
  let n = Array.length g.adj in
  let g' = Array.make n [] in
  for i = 0 to g.n1 - 1 do
    let f j =
      if m.(i) = Some j then g'.(j) <- i::g'.(j)
      else g'.(i) <- j::g'.(i) in
    List.iter f g.adj.(i)
  done;
  g'

(* 4 *)
let find_augmenting_path g m =
  let n = 2 * g.n1 in
  let dfs r =
    let vus = Array.make n false in
    let rec aux u = (* renvoie Some p si un chemin augmentant p est trouvé depuis u *)
      if m.(u) = None && u <> r then Some [u]
      else if vus.(u) then None
      else (
        vus.(u) <- true;
        let rec voisins = function
          | [] -> None
          | v::q -> match aux v with
            | None -> voisins vs
            | Some p -> Some (u::p) in
        voisins g.adj.(u)
      ) in
    aux r in
  let rec start_dfs u =
    if u = g.n1 then None
    else match dfs u with
      | None -> start_dfs (u+1)
      | Some p -> Some p in
  start_dfs 0
      
(* 5 *)
let get_maximum_matching g =
  let n = 2 * g.n1 in
  let m = Array.make n None in
  let rec loop () =
    match find_augmenting_path g m with
    | None -> m
    | Some p -> delta m p; loop () in
  loop ()
