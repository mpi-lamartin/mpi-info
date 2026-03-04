type var = string

type formule =
  | Var of var
  | Top
  | Bot
  | And of formule * formule
  | Or of formule * formule
  | Implies of formule * formule
  | Not of formule

type ensemble_formules = formule list

type sequent = {
  gamma : ensemble_formules;
  phi : formule;
}

(* Exercice 1 *)
let rec mem (_f : formule) (_gamma : ensemble_formules) : bool =
  failwith "TODO: mem"

let rec string_of_formule (_f : formule) : string =
  failwith "TODO: string_of_formule"

let string_of_sequent (s : sequent) : string =
  let gamma_str = String.concat ", " (List.map string_of_formule s.gamma) in
  gamma_str ^ " |- " ^ string_of_formule s.phi

(* Exercice 2 *)
type regle =
  | Axiom
  | TopIntro
  | BotElim
  | AndIntro
  | AndElim1 of formule
  | AndElim2 of formule
  | OrIntro1
  | OrIntro2
  | OrElim of formule * formule
  | ImpliesIntro
  | ImpliesElim of formule
  | NotIntro
  | NotElim of formule

type arbre_preuve =
  | Noeud of regle * sequent * arbre_preuve list

let string_of_regle (_r : regle) : string =
  failwith "TODO: string_of_regle"

let rec afficher_arbre_preuve (_depth : int) (_a : arbre_preuve) : unit =
  failwith "TODO: afficher_arbre_preuve"

let appliquer_regle (_r : regle) (_s : sequent) : sequent list option =
  failwith "TODO: appliquer_regle"

(* Exercice 4 : aide stratégique *)
let rec sous_formules_f (_f : formule) : formule list =
  failwith "TODO: sous_formules_f"

let sous_formules_gamma (_gamma : ensemble_formules) : formule list =
  failwith "TODO: sous_formules_gamma"

let regles_possibles (_s : sequent) : regle list =
  failwith "TODO: regles_possibles"

(* Exercice 3 + 5 *)
let rec prouver (_depth : int) (_s : sequent) : arbre_preuve option =
  failwith "TODO: prouver"
and prouver_min (_max_depth : int) (_s : sequent) : arbre_preuve option =
  failwith "TODO: prouver_min"
;;

(* Parsing séparé *)
#use "parser.ml"
;;

(* Exercice 6 : tests via chaînes de séquents *)
let tests = [
  "|- A -> A";
  "|- (A & B) -> (B & A)";
  "|- A -> (B -> A)";
  "|- ((A -> B) & A) -> B";
  "|- F -> A";
  "|- (A & (B | C)) -> ((A & B) | (A & C))";
  "|- (A & !A) -> F";
]

let run_test (seq_str : string) : unit =
  let seq = parse_sequent seq_str in
  Printf.printf "\nTest : %s\n" (string_of_sequent seq);
  match prouver_min 8 seq with
  | None -> Printf.printf "  -> Echec de la preuve\n"
  | Some arbre ->
      Printf.printf "  -> Succès !\n";
      afficher_arbre_preuve 1 arbre

let test () =
  List.iter run_test tests

let () =
  Printf.printf "Template chargé. Compléter les TODO avant exécution complète.\n"
