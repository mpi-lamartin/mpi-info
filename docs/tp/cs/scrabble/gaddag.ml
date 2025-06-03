open Alphabet

(**
 * Représentation des GADDAG.
 * Un GADDAG est donné par son état initial. Le champ "transitions" est un tableau qui à chaque numéro de lettre associe les états suivants. Le champ "final" indique si l'état est acceptant.
*)
type gaddag =
  {
    mutable transitions : gaddag option array;
    mutable final : bool;
  }

(** Création d'un GADDAG qui ne reconnait aucun mot *)
let vide () =
  {
    transitions = Array.make (nb_lettres + 1) None;
    final = false;
  }

(** Test d'appartenance d'un mot au GADDAG *)
(** Version du sujet *)
(* 
let appartient gaddag mot =
  let rec loop gaddag i =
    if i < String.length mot
    then
      match gaddag.transitions.(int_of_lettre mot.[i]) with
      | None -> false
      | Some(gaddag) -> loop gaddag (i+1)
    else gaddag.final
  in loop gaddag 0
*)

(** Test d'appartenance d'un mot au GADDAG *)
(** Version Grimaud *)
let appartient gaddag mot =
  let rec loop gaddag i =
    let sg = if i=1 then gaddag.transitions.(int_of_lettre '!') else Some gaddag in
    match sg with | None -> false | Some g ->
    if i < String.length mot then
      match g.transitions.(int_of_lettre mot.[i]) with
      | None -> false
      | Some(g') -> loop g' (i+1)
    else g.final
  in loop gaddag 0

(** Création d'un GADDAG qui accepte uniquement le mot donné en paramètre *)
let filaire mot =
  let rec loop i =
    if i < String.length mot
    then {
      transitions = Array.init (nb_lettres+1) (fun j -> if j = int_of_lettre mot.[i] then Some (loop (i+1)) else None);
      final = false
    }
    else {
      transitions = Array.make (nb_lettres+1) None;
      final = true
    }
  in loop 0

(** Ajout d'un mot au GADDAG *)
let ajoute gaddag mot =
  let rec loop gaddag i =
    if i < String.length mot
    then
      match gaddag.transitions.(int_of_lettre mot.[i]) with
      | None -> gaddag.transitions.(int_of_lettre mot.[i]) <- Some(filaire (String.sub mot (i+1) (String.length mot - i - 1)))
      | Some(gaddag) -> loop gaddag (i+1)
    else gaddag.final <- true
  in loop gaddag 0

(** Ajout de tous les ancrés d'un mot *)
let ancre_mot i mot =
  String.init (String.length mot + 1) (fun k ->
      if k = i
      then '!'
      else if k < i
      then mot.[i-1-k]
      else mot.[k-1])

let ajoute_conjugues gaddag mot =
  (*for i = 1 to String.length mot - 1 do*)
  for i = 1 to String.length mot do
    ajoute gaddag (ancre_mot i mot)
  done

(** Transformation d'un GADDAG en la liste de ses mots *)
let liste_mots gaddag =
  let rec parcours gaddag prefixe =
    let res = ref [] in
    if gaddag.final then res := [prefixe];
    for i = 0 to Array.length gaddag.transitions - 1 do
      match gaddag.transitions.(i) with
      | None -> ()
      | Some(gaddag) -> res := parcours gaddag (prefixe ^ (String.make 1 (lettre_of_int i))) @ !res
    done;
    !res
  in parcours gaddag ""

(** À partir d'un état du GADDAG, liste les transitions possibles *)
let transitions_possibles gaddag =
  let res = ref [] in
  for i = 0 to Array.length gaddag.transitions do
    match gaddag.transitions.(i) with
    | None -> ()
    | Some(_) -> res := Alphabet.lettre_of_int i :: !res
  done;
  !res

let rec nombre_etats gaddag =
  Array.fold_left (fun acc gopt ->
      acc +
      match gopt with
      | None -> 0
      | Some(g) -> nombre_etats g) 1 gaddag.transitions

(** Lecture du lexique depuis un fichier.
 * L'appel à lire_lexique renvoie une fonction
 * mot_suivant : unit -> string
 * qui à chaque appel renvoie le mot suivant dans le fichier.
 * Elle lève l'exception Lexique_fini quand il n'y a plus de mot à lire.
*)
exception Lexique_fini
let lire_lexique nom_fichier =
  let f = open_in nom_fichier in
  let mot_suivant () =
    try
      input_line f
    with End_of_file -> close_in f; raise Lexique_fini
  in mot_suivant

let construit_gaddag nom_fichier =
  let g = vide () in
  let mot_suivant = lire_lexique nom_fichier in
  try
    while true do
      let mot = mot_suivant () in
      if String.length mot > 0 then
        ajoute_conjugues g mot
    done;
    g  (* jamais atteint *)
  with Lexique_fini -> g
