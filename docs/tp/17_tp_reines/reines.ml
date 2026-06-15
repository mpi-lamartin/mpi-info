(** Le champ `m` est une matrice représentant l'échiquier indiquant
   pour chaque case `(i, j)` le nombre de reines qui couvrent cette
   case. Le champ `z` sera utilisé plus tard. *)
type couverture = {m : int array array; mutable z : int}


(** Vérifie si une couverture est terminée, c'est-à-dire si toute case
   est couverte par au moins une reine. **)
let finale (c : couverture) : bool =
  (* ... À compléter ... *)
  false


(** Mise à jour de la couverture `c` suite au placement/suppression
   d'une reine en position `(i, j)`. Si `v = 1` une nouvelle reine y
   est placée ; si `v = -1` la reine qui s'y trouve est enlevée *)
let mise_a_jour (c : couverture) (i : int) (j : int) (v : int) : unit =
  assert (c.m.(i).(j) = 0 && v = 1 || c.m.(i).(j) = 1 && v = -1);
  (* ... À compléter ... *)
  ()

(** Calcul du nombre minimal de reines sans prises nécessaires pour
   couvrir un échiquier $n \times n$. *)
(*
let couverture_par_reines n =
  (* Nombre minimal de reines trouvées jusqu'ici *)
  let r_min = n + 1 in
  (* La couverture est une variable globale, dont les champs sont
     mutables, pour la fonction auxiliaire qui recherche la solution.
     Elle doit être à jour en tout temps. *)
  let c := {m = Array.make_matrix n n 0; z = -1} in
  (* Placement des reines à partir de la ligne `i` incluse, sachant
     que l'on a déjà placé `r` reines et que la couverture `c` est
     dans un état cohérent avec les placements effectués. *)
  let rec place i r =
    (* Si on a tout couvert on met à jour suivant ce que l'on a trouvé *)
    if finale c then begin
      r_min := min r !r_min
    end
    (* Sinon, et à condition d'avoir encore des lignes à considérer *)
    else if i < n begin
      (* On essaie sans reine sur cette ligne *)
      place (i + 1) r;
      (* On essaie tous les placements envisageables d'une reine sur cette ligne *)
      for j = 0 to n - 1
        if c.m.(i).(j) = 0 then begin
          (* On essaie avec une reine en position `(i, j)` *)
          mise_a_jour c i j 1
          place (i + 1) (r + 1)
          (* Retour à l'état précédent pour tester la suite *)
          mise_a_jour c i j (-1)
        end
      done
    end
  in
  let () = place 0 0;
  !r_min
*)

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
  -1

(** Borne supérieure du nombre minimal de reines sans prises
    nécessaires pour couvrir un échiquier $n \times n$ en effectuant
    `nb_essais` d'une couverture aléatoire. *)
let couverture_par_reines_aleatoire n nb_essais =
  -1
