open Alphabet
open Gaddag

(** Représentation d'une case du plateau.
    Quand une case est recouverte par une lettre, l'information de score
    présente initialement disparait. *)
type case =
  | Lettre of lettre
  | Centrale
  | Vide
  | LettreDouble
  | LettreTriple
  | MotDouble
  | MotTriple

(** Indique si une case est recouverte d'une lettre. *)
let case_est_vide case =
  match case with
  | Lettre(_) -> false
  | _ -> true

(** Type représentant les plateaux. On les suppose toujours carrés et on
    suppose que pour un plateau vide, il existe une unique case "Centrale". *)
type plateau = case array array

(** Création d'un plateau vide, sans aucun mot. *)
let nouveau_plateau () =
  let plateau = Array.make_matrix 15 15 Vide in
  (* diagonales en mot compte double, à réaliser en premier
     car pour les cases de milieu on écrasera par d'autres valeurs ensuite (pour
     avoir un code de génération du plateau un peu plus régulier) *)
  for i = 1 to Array.length plateau - 2 do
    plateau.(i).(i) <- MotDouble;
    plateau.(i).(Array.length plateau - 1 - i) <- MotDouble
  done;
  (* lignes de lettres triples *)
  for i = 0 to 3 do
    plateau.(5).(4*i+1) <- LettreTriple;
    plateau.(9).(4*i+1) <- LettreTriple;
    plateau.(4*i+1).(5) <- LettreTriple;
    plateau.(4*i+1).(9) <- LettreTriple;
  done;
  (* Lettres doubles un peu en vrac *)
  List.iter (fun (i,j) ->
      plateau.(i).(j) <- LettreDouble;
      plateau.(Array.length plateau - i - 1).(j) <- LettreDouble;
      plateau.(i).(Array.length plateau.(i) - j - 1) <- LettreDouble;
      plateau.(Array.length plateau - i - 1).(Array.length plateau.(i) - j - 1) <- LettreDouble;
      let (i,j) = (j,i) in
      plateau.(i).(j) <- LettreDouble;
      plateau.(Array.length plateau - i - 1).(j) <- LettreDouble;
      plateau.(i).(Array.length plateau.(i) - j - 1) <- LettreDouble;
      plateau.(Array.length plateau - i - 1).(Array.length plateau.(i) - j - 1) <- LettreDouble;
    ) [(3,0);(6,2);(7,3);(6,6)];
  (* Bords en mot triple *)
  for i = 0 to 2 do
    for j = 0 to 2 do
      plateau.(7*i).(7*j) <- MotTriple
    done
  done;
  plateau.(7).(7) <- Centrale;
  plateau

(** Affichage à l'écran d'un plateau sous une forme concise. *)
let affiche_plateau plateau =
  for i = 0 to Array.length plateau - 1 do
    for j = 0 to Array.length plateau.(i) - 1 do
      print_char (match plateau.(i).(j) with
	  | Lettre(x) -> x
	  | Centrale -> '*'
	  | Vide -> '_'
	  | LettreDouble -> 'd'
	  | LettreTriple -> 't'
	  | MotDouble -> '@'
	  | MotTriple -> '$'
	)
    done;
    print_newline ()
  done

(* Ajout d'un mot sur un plateau, la première lettre étant en coordonnée (i,j).
   Le sens du placement du mot (horizontal ou vertical) est indiqué par le
   booléen [est_vertical]. Cette fonction n'effectue absolument aucune
   vérification sur le caractère correct ou non du placement demandé. *)
let place_mot plateau (i,j) est_vertical mot =
  for offset = 0 to String.length mot - 1 do
    let (i', j') =
      if est_vertical
      then (i + offset, j)
      else (i, j + offset)
    in
    plateau.(i').(j') <- Lettre(mot.[offset])
  done

(* Plateau correspondant à la figure donnée en exemple *)
let plateau_figure =
  let plateau = nouveau_plateau () in
  List.iter (fun (coord, horiz, mot) -> place_mot plateau coord horiz mot)
    [
      ((6,8), false, "JOCISTE");
      ((7,3), false, "PARADERAS");
      ((11,3), false, "LEK");
      ((11,9), false, "BIQUET");
      ((12,0), false, "FRAISAGE");
      ((13,7), false, "ENGOUERA");
      ((14,0), false, "REELUTES");
      ((14,10), false, "UNS");
      ((0,14), true, "ENNOYIEZ");
      ((3,1), true, "TAXI");
      ((3,11), true, "HIAIS");
      ((4,10), true, "NUCAL");
      ((5,9), true, "MORIO");
      ((6,0), true, "ACCOT");
      ((6,4), true, "PAWNEES");
      ((7,7), true, "DECODEES");
      ((8,12), true, "FLEUVES");
      ((9,1), true, "HEURTE");
      ((9,14), true, "MITRAL");
    ]; plateau


(** Un tirage correspond à l'ensemble des lettres qu'un joueur peut utiliser
    pour composer le mot suivant. *)
type tirage = lettre list

(** Q2 *)
let lettres_necessaires_horizontal plateau mot (i, j) =
  let rec aux k acc =
    if k = String.length mot then
      List.rev acc
    else
      let case =
        try plateau.(i).(j + k)
        with Invalid_argument _ -> failwith "Position hors plateau"
      in
      match case with
      | Lettre(c) ->
        if c <> mot.[k] then
          failwith "Conflit avec une lettre déjà posée"
        else
          aux (k + 1) acc
      | Vide | LettreDouble | LettreTriple | MotDouble | MotTriple | Centrale ->
        aux (k + 1) (mot.[k] :: acc)
  in
  aux 0 []

(** Q3 *)
let lettres_necessaires plateau mot (i, j) est_vertical =
  let rec aux k acc =
    if k = String.length mot then
      List.rev acc
    else
      let i', j' = if est_vertical then (i + k, j) else (i, j + k) in
      let case =
        try plateau.(i').(j')
        with Invalid_argument _ -> failwith "Position hors plateau"
      in
      match case with
      | Lettre(c) ->
          if c <> mot.[k] then
            failwith "Conflit avec une lettre déjà posée"
          else
            aux (k + 1) acc
      | Vide | LettreDouble | LettreTriple | MotDouble | MotTriple | Centrale ->
          aux (k + 1) (mot.[k] :: acc)
  in
  aux 0 []

(** Q4 *)
let somme_lettres mot =
  let rec aux k acc =
    if k = String.length mot then acc
    else aux (k + 1) (acc + points mot.[k])
  in
  aux 0 0

(** Q5 *)
let valeur_mot_seul plateau mot (i, j) est_vertical =
  let rec aux k acc mot_mul =
    if k = String.length mot then acc * mot_mul
    else
      let i', j' = if est_vertical then (i + k, j) else (i, j + k) in
      let case = plateau.(i').(j') in
      match case with
      | Lettre(c) ->
          let v = points c in
          aux (k + 1) (acc + v) mot_mul
      | Vide | Centrale ->
          let v = points mot.[k] in
          let mot_mul' = if case = Centrale then max mot_mul 2 else mot_mul in
          aux (k + 1) (acc + v) mot_mul'
      | LettreDouble ->
          let v = 2 * points mot.[k] in
          aux (k + 1) (acc + v) mot_mul
      | LettreTriple ->
          let v = 3 * points mot.[k] in
          aux (k + 1) (acc + v) mot_mul
      | MotDouble ->
          let v = points mot.[k] in
          aux (k + 1) (acc + v) (max mot_mul 2)
      | MotTriple ->
          let v = points mot.[k] in
          aux (k + 1) (acc + v) (max mot_mul 3)
  in
  aux 0 0 1

(** Q8 *)
let valeur_mot plateau mot (i, j) est_vertical =
  let score_principal = valeur_mot_seul plateau mot (i, j) est_vertical in
  let score_perpendiculaires =
    let rec collect k acc =
      if k = String.length mot then acc
      else
        let (i', j') = if est_vertical then (i + k, j) else (i, j + k) in
        match plateau.(i').(j') with
        | Lettre(_) -> collect (k + 1) acc  (* Lettre déjà posée *)
        | _ -> 
          let rec remonte (i, j) =
            let (i', j') = if est_vertical then (i, j - 1) else (i - 1, j) in
            match plateau.(i').(j') with
            | Lettre(_) -> remonte (i', j')
            | _ -> (i, j)
          in 
          let rec descend (i, j) acc =
            if (i, j) = (i', j') then
              (* Case où on va poser une lettre *)
              let next = if est_vertical then (i, j + 1) else (i + 1, j) in
              descend next (acc ^ String.make 1 mot.[k])
            else
              match plateau.(i).(j) with
              | Lettre(c) ->
                let next = if est_vertical then (i, j + 1) else (i + 1, j) in
                descend next (acc ^ String.make 1 c)
              | _ -> acc             
          in
          let start = remonte (i', j') in
          let mot_perp = descend start "" in
          if String.length mot_perp > 1 then
            let score = valeur_mot_seul plateau mot_perp start (not est_vertical) in
            collect (k + 1) (acc + score)
          else
            collect (k + 1) acc
    in
    collect 0 0
  in
  score_principal + score_perpendiculaires

(** Q9 *)
let ancres_plateau plateau =
  let n = Array.length plateau in
  let est_lettre i j =
    match plateau.(i).(j) with
    | Lettre(_) -> true
    | _ -> false
  in
  let est_ancre i j =
    match plateau.(i).(j) with
    | Lettre(_) -> false
    | _ ->
      plateau.(i).(j) = Centrale ||
      let voisins = [ (i-1, j); (i+1, j); (i, j-1); (i, j+1) ] in
      List.exists (fun (x, y) ->
        x >= 0 && x < n && y >= 0 && y < n && est_lettre x y
      ) voisins
  in
  let rec parcours i j acc =
    if i = n then acc
    else if j = n then parcours (i + 1) 0 acc
    else
      let acc' = if est_ancre i j then (i, j) :: acc else acc in
      parcours i (j + 1) acc'
  in
  List.rev (parcours 0 0 [])

(** Q13 *)
let trouver_coup plateau tirage gaddag (anc_i, anc_j) est_vertical =
  let dans_plateau (i, j) =
    i >= 0 && i < Array.length plateau && j >= 0 && j < Array.length plateau.(i)
  in
  let verifie_lettre l (i, j) dir =
    let step = if dir then (0, 1) else (1, 0) in
    let rec remonte (x, y) acc =
      let x', y' = (x - fst step, y - snd step) in
      if dans_plateau (x', y') then
        match plateau.(x').(y') with
        | Lettre c -> remonte (x', y') (String.make 1 c ^ acc)
        | _ -> acc
      else acc
    in
    let rec descend (x, y) acc =
      let x', y' = (x + fst step, y + snd step) in
      if dans_plateau (x', y') then
        match plateau.(x').(y') with
        | Lettre c -> descend (x', y') (acc ^ String.make 1 c)
        | _ -> acc
      else acc
    in
    let mot = (remonte (i, j) "") ^ (String.make 1 l) ^ (descend (i, j) "") in
    let res = String.length mot <= 1 || appartient gaddag mot in
    (*Printf.printf "check word %s (%d,%d) %B \n" mot i j res ;*)
    res
  in
  let avance (i, j) =
    let i', j' = if est_vertical then (i + 1, j) else (i, j + 1) in
    if dans_plateau (i', j') then Some (i', j') else None
  in
  let recule (i, j) =
    let i', j' = if est_vertical then (i - 1, j) else (i, j - 1) in
    if dans_plateau (i', j') then Some (i', j') else None
  in
  let retirer_premier l lst =
    let rec aux acc = function
      | [] -> List.rev acc
      | x :: xs -> if x = l then List.rev acc @ xs else aux (x :: acc) xs
    in
    aux [] lst
  in
 
  let rec avance_depuis g (i, j) mot reste =
    let suivant g c = g.transitions.(int_of_lettre c) in
    let continuer_avec_lettre acc l =
      match (suivant g l, verifie_lettre l (i, j) est_vertical) with
      | (Some g', true) ->
        let reste' = retirer_premier l reste in
        (match avance (i, j) with
         | Some pos' -> avance_depuis g' pos' (mot @ [l]) reste' @ acc
         | None -> if g'.final then (mot @ [l]) :: acc else acc)
      | _ -> acc
    in
    match plateau.(i).(j) with
    | Lettre c -> (
      match (suivant g c, avance (i, j)) with
      | (Some g',Some pos') -> avance_depuis g' pos' (mot @ [c]) reste
      | (_, _) -> []
    )
    | _ ->
      let mots_depuis_tirage = List.fold_left continuer_avec_lettre [] reste in
      if g.final then mot :: mots_depuis_tirage else mots_depuis_tirage
  in

  let rec recule_depuis g (i, j) mot reste =
    let suivant g c = g.transitions.(int_of_lettre c) in
    let explorer_depuis g' mot' reste' =
      match avance (anc_i, anc_j) with
      | Some (i,j) -> avance_depuis g' (i,j) mot' reste'
      | None -> []
    in
    let essayer_lettre acc l =
      match suivant g l, verifie_lettre l (i,j) est_vertical with
      | Some g', true -> (
        let reste' = retirer_premier l reste in
        match recule (i,j) with
        | Some (i', j') ->
          recule_depuis g' (i', j') (l :: mot) reste' @ acc
        | None ->
          let suite = match suivant g' '!' with
            | Some g'' -> explorer_depuis g'' (l :: mot) reste'
            | None -> []
          in
          if g'.final then
            (l :: mot) :: suite @ acc
          else
            suite @ acc
        )
      | _,_ -> acc
    in
    match plateau.(i).(j) with
    | Lettre c -> (
      match (suivant g c, recule (i,j)) with
      | (Some g', Some (i,j)) -> recule_depuis g' (i, j) (c :: mot) reste
      | (_, _) -> []
    )
    | _ ->
      let mots_initiaux =
        match suivant g '!' with
        | Some g_av -> explorer_depuis g_av mot reste
        | None -> []
      in
      let mots_complets = List.fold_left essayer_lettre [] reste in
      mots_initiaux @ mots_complets
  in 
  let mots = 
    recule_depuis gaddag (anc_i,anc_j) [] tirage   
  in
  let string_of_char_list l =
    let buf = Bytes.create (List.length l) in
    List.iteri (Bytes.set buf) l;
    Bytes.to_string buf
  in
  List.map string_of_char_list mots

(** Q15 *)
let meilleur_coup plateau tirage gaddag : ((int * int) * string * bool * int) =
  let ancres_total = ancres_plateau plateau in
  let rec explore (meilleur_pos, meilleur_mot, meilleur_dir, meilleur_score) ancres =
    match ancres with
    | [] -> (meilleur_pos, meilleur_mot, meilleur_dir, meilleur_score)
    | ancre :: rest -> 
      let try_direction acc dir =
        let mots = trouver_coup plateau tirage gaddag ancre dir in
        List.fold_left (fun acc mot ->
            let score = valeur_mot plateau mot ancre dir in
            let (_, _, _, best_score) = acc in
            if score > best_score then
              (ancre, mot, dir, score)
            else
              acc
          ) acc mots
      in
        let best_after_vertical = try_direction (meilleur_pos, meilleur_mot, meilleur_dir, meilleur_score) false in
        let best_after_horizontal = try_direction best_after_vertical false in
        explore best_after_horizontal rest
  in
  explore ((-1, -1), "", false, -1) ancres_total

(* Expression principale pour les tests *)
let () =
  (** Q1 *)
  print_endline "Plateau vide :";
  let plateau_initial = nouveau_plateau () in
  affiche_plateau plateau_initial;
  print_newline ();
  print_endline "Plateau de la figure 1c :";
  affiche_plateau plateau_figure;

  Printf.printf "Test lettres_necessaires_horizontal\n";
  let plateau = nouveau_plateau () in
  place_mot plateau (7, 7) true "PARIS";
  let lettres = lettres_necessaires_horizontal plateau "PAPIER" (7, 7) in
  List.iter (fun c -> Printf.printf "%c " c) lettres;
  print_newline ();

  Printf.printf "Test lettres_necessaires\n";
  begin
    try
      (* Horizontal *)
      let lettres_h = lettres_necessaires plateau "PAPIER" (7, 7) false in
      List.iter (fun c -> Printf.printf "%c " c) lettres_h;
      print_newline ();
      (* Vertical *)
      let lettres_v = lettres_necessaires plateau "PAPIER" (7, 7) true in
      List.iter (fun c -> Printf.printf "%c " c) lettres_v;
      print_newline ();
    with
    | Failure m -> Printf.printf "Erreur : %s\n" m
  end;
  
  Printf.printf "somme_lettres\n";
  let mot = "JOCISTE" in
  Printf.printf "Score brut de %s = %d\n" mot (somme_lettres mot);

  Printf.printf "valeur_mot_seul\n";
  let plateau = nouveau_plateau () in
  let score = valeur_mot_seul plateau "JOCISTE" (6, 8) false in
  Printf.printf "Score de JOCISTE seul : %d\n" score;

  (** Q6 *)
  Printf.printf "Plateau 1b\n";
  let plateau = nouveau_plateau () in
  List.iter (fun (coord, est_vertical, mot) ->
      place_mot plateau coord est_vertical mot)
    [
      ((7,3), false, "PARADERAS");
      ((5,9), true, "MORIO");
      ((3,11), true, "HIAIS");
      ((6,8), false, "JOCISTE")
    ]; 
  affiche_plateau plateau;
  print_newline ();
  let score = valeur_mot_seul plateau "NUCAL" (4, 10) true in
  Printf.printf "Score de NUCAL seul : %d\n" score;

  let score = valeur_mot plateau "NUCAL" (4, 10) true in
  Printf.printf "Score de NUCAL complet : %d\n" score;
  let score = valeur_mot plateau "RAI" (8, 7) false in
  Printf.printf "Score de RAI complet : %d\n" score;

  Printf.printf "ancres_plateau\n";
  let ancres = ancres_plateau plateau_figure in
  Printf.printf "%d ancres détectées :\n" (List.length ancres);
  List.iter (fun (i,j) -> Printf.printf "(%d,%d) " i j) ancres;
  print_newline ();

  let lexique = "lexique.txt" in
  let gaddag = (construit_gaddag lexique) in

  (*
  Printf.printf "Plateau 1 : \n";
  let plateau = nouveau_plateau () in
  List.iter (fun (coord, est_vertical, mot) ->
      place_mot plateau coord est_vertical mot)
    [
      ((7,5), false, "SOLEI")
    ]; 
  affiche_plateau plateau;
  print_newline ();
  let tirage = ['C'; 'L'; 'K'] in
  begin
    let mots = trouver_coup plateau tirage gaddag (7, 10) false in
    Printf.printf "\n Solutions : \n";
    List.iter (fun mot -> Printf.printf "%s\n" mot) mots
  end;
  *)
  (* 
  Printf.printf "Plateau 2 : \n";
  let plateau = nouveau_plateau () in
  List.iter (fun (coord, est_vertical, mot) ->
      place_mot plateau coord est_vertical mot)
    [
      ((7,5), false, "SOLE")
    ]; 
  affiche_plateau plateau;
  print_newline ();
  let tirage = ['I'; 'L'; 'N'] in
  begin
    let mots = trouver_coup plateau tirage gaddag (7, 10) false in
    Printf.printf "\n Solutions : \n";
    List.iter (fun mot -> Printf.printf "%s\n" mot) mots
  end;
  *)
  (*
  Printf.printf "Plateau 3 : \n";
  let plateau = nouveau_plateau () in
  List.iter (fun (coord, est_vertical, mot) ->
      place_mot plateau coord est_vertical mot)
    [
      ((7,5), false, "SOLEI")
    ]; 
  affiche_plateau plateau;
  print_newline ();
  let tirage = ['C'; 'L'; 'S'; 'X'; 'O'; 'E'; 'U'; 'L'] in
  begin
    let mots = trouver_coup plateau tirage gaddag (7, 10) false in
    Printf.printf "\n Solutions : \n";
    List.iter (fun mot -> Printf.printf "%s\n" mot) mots
  end;
  *)
  (*
  Printf.printf "Plateau 4 : \n";
  let plateau = nouveau_plateau () in
  List.iter (fun (coord, est_vertical, mot) ->
      place_mot plateau coord est_vertical mot)
    [
      ((7,1), false, "OLEIL")
    ]; 
  affiche_plateau plateau;
  print_newline ();
  let tirage = ['C'; 'L'; 'S'; 'X'; 'E'; 'I'; 'U'; 'S'] in
  begin
    let mots = trouver_coup plateau tirage gaddag (7, 0) false in
    Printf.printf "\n Solutions : \n";
    List.iter (fun mot -> Printf.printf "%s\n" mot) mots
  end;
   *)
  (*
  Printf.printf "Plateau 5 : \n";
  let plateau = nouveau_plateau () in
  List.iter (fun (coord, est_vertical, mot) ->
      place_mot plateau coord est_vertical mot)
    [
      ((9,3), false, "SO");
      ((9,6), false, "EIL")
    ]; 
  affiche_plateau plateau;
  print_newline ();
  let tirage = ['C'; 'L'; 'S'] in
  begin
    let mots = trouver_coup plateau tirage gaddag (9, 5) false in
    Printf.printf "\n Solutions : \n";
    List.iter (fun mot -> Printf.printf "%s\n" mot) mots
  end;
  *)
  (*
  Printf.printf "Plateau 6 : \n";
  let plateau = nouveau_plateau () in
  List.iter (fun (coord, est_vertical, mot) ->
      place_mot plateau coord est_vertical mot)
    [
      ((5,7), true, "SOL");
      ((10,7), true, "L")
    ]; 
  affiche_plateau plateau;
  print_newline ();
  let tirage = ['C'; 'I'; 'S'; 'E'] in
  begin
    let mots = trouver_coup plateau tirage gaddag (8, 7) true in
    Printf.printf "\n Solutions : \n";
    List.iter (fun mot -> Printf.printf "%s\n" mot) mots
  end;
  *)
  
  Printf.printf "Plateau 7 : \n";
  let plateau = nouveau_plateau () in
  List.iter (fun (coord, est_vertical, mot) ->
      place_mot plateau coord est_vertical mot)
    [
      ((5,7), true, "SOL");
      ((10,7), true, "L")
    ]; 
  affiche_plateau plateau;
  print_newline ();
  let tirage = ['C'; 'I'; 'S'; 'E'] in
  begin
    let mots = trouver_coup plateau tirage gaddag (4, 7) false in
    Printf.printf "\n Solutions : \n";
    List.iter (fun mot -> Printf.printf "%s\n" mot) mots
  end;

  (** Q15 *)
  let ((i, j), mot, est_vertical, score) =
    meilleur_coup plateau tirage gaddag in
  Printf.printf "Meilleur coup : %s sur l'ancre (%d, %d) en %s, score = %d\n"
    mot i j (if est_vertical then "vertical" else "horizontal") score
  
