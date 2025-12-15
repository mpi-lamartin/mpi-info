type state = {
  grid : int array array;
  mutable i : int;
  mutable j : int;
  mutable h : int;
}

let s = { (* exemple de l'énoncé *)
    grid =
        [| [| 2; 3; 1; 6 |];
           [| 14; 5; 8; 4 |];
           [| 15; 12; 7; 9 |];
           [| 10; 13; 11; 0|] |];
    i = 2;
    j = 0;
    h = 38
}
let final = (* l'état dans lequel on doit aboutir *)
  let m = Array.make_matrix 4 4 0 in
  for i = 0 to 3 do
    for j = 0 to 3 do
      m.(i).(j) <- i * 4 + j
    done
  done;
  {grid = m; i = 3; j = 3; h = 0}

type direction = U | D | L | R

let possible_moves s =
  let l = ref [] in
  if s.i < 3 then l := [D];
  if s.i > 0 then l := U::!l;
  if s.j < 3 then l := R::!l;
  if s.j > 0 then l := L::!l;
  !l

let compute_h s =
  let h = ref 0 in
  for i = 0 to 3 do
      for j = 0 to 3 do
          let v = s.grid.(i).(j) in
          h := !h + (abs (i - v/4)) + (abs (j - v mod 4))
      done
  done;
  s.h <- !h;;
compute_h s;;


let delta_h s d = 
    let (di, dj) = match d with
        | U -> (-1, 0)
        | D -> (1, 0)
        | L -> (0, -1)
        | R -> (0, 1) in
    let i, j = s.i, s.j in
    let v = s.grid.(i + di).(j + dj) in
    (abs (i - v/4)) + (abs (j - v mod 4)) -
    (abs ((i+di) - v/4)) - (abs ((j+dj) - v mod 4))

delta_h s U;;

let apply s d =
    let (di, dj) = match d with
        | U -> (-1, 0)
        | D -> (1, 0)
        | L -> (0, -1)
        | R -> (0, 1) in
    let i, j = s.i, s.j in
    let x = s.grid.(i + di).(j + dj) in
    s.grid.(i + di).(j + dj) <- 15;
    s.grid.(i).(j) <- x;
    s.h <- s.h + delta_h s d;
    s.i <- i + di;
    s.j <- j + dj

apply s U; s;;

let copy s = {
    i = s.i;
    j = s.j;
    h = s.h;
    grid = Array.map (Array.copy) s.grid
}

let successors s =
    let rec aux = function
        | [] -> []
        | d::q -> 
            let s' = copy s in
            apply s' d;
            s'::aux q in
    aux (possible_moves s)

(* penser à réinitialiser s après l'utilisation de apply *)
successors s;;

type 'a abr = V | N of 'a * 'a abr * 'a abr

let rec add a p e = match a with
    | V -> N((p, e), V, V)
    | N(r, g, d) -> if p < fst r then N(r, add g p e, d)
        else  N(r, g, add d p e)
        
let rec extract_min = function
    | V -> failwith "vide"
    | N(r, V, d) -> r, d
    | N(r, g, d) -> 
        let x, g' = extract_min g in
        x, N(r, g', d)

let a_star s =
    let q = ref V in
    q := add !q s.h s;
    let d = Hashtbl.create 42 in
    while not (Hashtbl.mem d final) do
        let (p, e), q' = extract_min !q in
        q := q';
        if not (Hashtbl.mem d e) then (
            let de = p - e.h in
            Hashtbl.replace d e de;
            List.iter (fun s ->
                q := add !q (de + 1 + s.h) s
            ) (successors e)
        )
    done;
    Hashtbl.find d final

let random_state nb_moves =
  let state = copy final in
  for i = 0 to nb_moves - 1 do
    let moves = possible_moves state in
    let n = List.length moves in
    apply state (List.nth moves (Random.int n))
  done;
  state

let ten =
  let moves = [U; U; L; L; U; R; D; D; L; L] in
  let state = copy final in
  List.iter (apply state) moves;
  state

let rs = random_state 10;;
a_star rs;;
