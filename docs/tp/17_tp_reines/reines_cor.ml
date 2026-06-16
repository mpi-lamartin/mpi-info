(** Le champ `m` est une matrice représentant l'échiquier indiquant
   pour chaque case `(i, j)` le nombre de reines qui couvrent cette
   case. Le champ `z` sera utilisé plus tard. *)
type couverture = {m : int array array; mutable z : int}

let creer_couverture n = {m = Array.make_matrix n n 0; z = n * n}

let taille (c : couverture) = Array.length c.m

let modifie_case (c : couverture) (i : int) (j : int) (v : int) : unit =
  let avant = c.m.(i).(j) in
  let apres = avant + v in
  assert (apres >= 0);
  if avant = 0 && apres > 0 then c.z <- c.z - 1
  else if avant > 0 && apres = 0 then c.z <- c.z + 1;
  c.m.(i).(j) <- apres


(** Vérifie si une couverture est terminée, c'est-à-dire si toute case
   est couverte par au moins une reine. **)
let finale (c : couverture) : bool =
  c.z = 0


(** Mise à jour de la couverture `c` suite au placement/suppression
   d'une reine en position `(i, j)`. Si `v = 1` une nouvelle reine y
   est placée ; si `v = -1` la reine qui s'y trouve est enlevée *)
let mise_a_jour (c : couverture) (i : int) (j : int) (v : int) : unit =
  assert (c.m.(i).(j) = 0 && v = 1 || c.m.(i).(j) = 1 && v = -1);
  let n = taille c in
  for colonne = 0 to n - 1 do
    modifie_case c i colonne v
  done;
  for ligne = 0 to n - 1 do
    if ligne <> i then modifie_case c ligne j v
  done;
  let ligne = ref (i - 1) in
  let colonne = ref (j - 1) in
  while !ligne >= 0 && !colonne >= 0 do
    modifie_case c !ligne !colonne v;
    decr ligne;
    decr colonne
  done;
  let ligne = ref (i + 1) in
  let colonne = ref (j + 1) in
  while !ligne < n && !colonne < n do
    modifie_case c !ligne !colonne v;
    incr ligne;
    incr colonne
  done;
  let ligne = ref (i - 1) in
  let colonne = ref (j + 1) in
  while !ligne >= 0 && !colonne < n do
    modifie_case c !ligne !colonne v;
    decr ligne;
    incr colonne
  done;
  let ligne = ref (i + 1) in
  let colonne = ref (j - 1) in
  while !ligne < n && !colonne >= 0 do
    modifie_case c !ligne !colonne v;
    incr ligne;
    decr colonne
  done

(** Calcul du nombre minimal de reines sans prises nécessaires pour
   couvrir un échiquier $n \times n$. *)
let couverture_par_reines n =
  (* Nombre minimal de reines trouvées jusqu'ici *)
  let r_min = ref n in
  (* La couverture est une variable globale, dont les champs sont
     mutables, pour la fonction auxiliaire qui recherche la solution.
     Elle doit être à jour en tout temps. *)
  let c = creer_couverture n in
  (* Placement des reines à partir de la ligne `i` incluse, sachant
     que l'on a déjà placé `r` reines et que la couverture `c` est
     dans un état cohérent avec les placements effectués. *)
  let rec place i r =
    if r >= !r_min then ()
    (* Si on a tout couvert on met à jour suivant ce que l'on a trouvé *)
    else if finale c then begin
      r_min := r
    end
    (* Sinon, et à condition d'avoir encore des lignes à considérer *)
    else if i < n then begin
      (* On essaie sans reine sur cette ligne *)
      place (i + 1) r;
      (* On essaie tous les placements envisageables d'une reine sur cette ligne *)
      for j = 0 to n - 1 do
        if c.m.(i).(j) = 0 then begin
          (* On essaie avec une reine en position `(i, j)` *)
          mise_a_jour c i j 1;
          place (i + 1) (r + 1);
          (* Retour à l'état précédent pour tester la suite *)
          mise_a_jour c i j (-1)
        end
      done
    end
  in
  place 0 0;
  !r_min

let couverture_par_reines_positions n =
  let r_min = ref n in
  let meilleure_solution = ref [] in
  let c = creer_couverture n in
  let rec place i r positions =
    if r >= !r_min then ()
    else if finale c then begin
      r_min := r;
      meilleure_solution := List.rev positions
    end
    else if i < n then begin
      place (i + 1) r positions;
      for j = 0 to n - 1 do
        if c.m.(i).(j) = 0 then begin
          mise_a_jour c i j 1;
          place (i + 1) (r + 1) ((i, j) :: positions);
          mise_a_jour c i j (-1)
        end
      done
    end
  in
  place 0 0 [];
  (!r_min, !meilleure_solution)

let couverture_par_reines_nombre_solutions n =
  let r_min = ref n in
  let nb_solutions = ref 0 in
  let c = creer_couverture n in
  let rec place i r =
    if r > !r_min then ()
    else if finale c then begin
      if r < !r_min then begin
        r_min := r;
        nb_solutions := 1
      end
      else incr nb_solutions
    end
    else if i < n then begin
      place (i + 1) r;
      for j = 0 to n - 1 do
        if c.m.(i).(j) = 0 then begin
          mise_a_jour c i j 1;
          place (i + 1) (r + 1);
          mise_a_jour c i j (-1)
        end
      done
    end
  in
  place 0 0;
  (!r_min, !nb_solutions)

(** Affichage d'un échiquier `n` x `n` avec des reines placéees aux
    cordonnées de la liste `pos` *)
let affiche_reines n pos =
  let m = Array.make_matrix n n '.' in
  List.iter (fun (i, j) -> m.(i).(j) <- 'x') pos;
  print_newline ();
  for i = 0 to n - 1 do
    for j = 0 to n - 1 do
      print_char m.(i).(j);
      if j <> n - 1 then print_char ' '
    done;
    print_newline ();
  done;
  print_newline ()

(** Choix aléatoire uniforme d'un indice dans un tableau `a` parmi les
    indices donnant une valeur nulle pour `a`. La valeur `-1` est
    renvoyée si aucune valeur du tableau `a` n'est nulle. *)
let choix_position (a : int array) : int =
  let resultat = ref (-1) in
  let nb_zeros = ref 0 in
  Array.iteri
    (fun i valeur ->
      if valeur = 0 then begin
        incr nb_zeros;
        if Random.int !nb_zeros = 0 then resultat := i
      end)
    a;
  !resultat

(** Borne supérieure du nombre minimal de reines sans prises
    nécessaires pour couvrir un échiquier $n \times n$ en effectuant
    `nb_essais` d'une couverture aléatoire. *)
let couverture_par_reines_aleatoire n nb_essais =
  Random.self_init ();
  let meilleur = ref n in
  for _ = 1 to nb_essais do
    let c = creer_couverture n in
    let nb_reines = ref 0 in
    let abandon = ref false in
    for i = 0 to n - 1 do
      if not !abandon then begin
        if !nb_reines >= !meilleur then abandon := true
        else if Random.int n < n - 1 then begin
          let j = choix_position c.m.(i) in
          if j <> -1 then begin
            mise_a_jour c i j 1;
            incr nb_reines
          end
        end
      end
    done;
    if not !abandon && finale c && !nb_reines < !meilleur then
      meilleur := !nb_reines
  done;
  !meilleur
