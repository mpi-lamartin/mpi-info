open Dnat

let seq gamma phi = {gamma; phi}

(* Réponse Q1 *)
let rec string_of_formule = function
  | Var v -> v
  | Bot -> "F"
  | And (f1, f2) -> "(" ^ string_of_formule f1 ^ " & " ^ string_of_formule f2 ^ ")"
  | Or (f1, f2) -> "(" ^ string_of_formule f1 ^ " | " ^ string_of_formule f2 ^ ")"
  | Implies (f1, f2) -> "(" ^ string_of_formule f1 ^ " -> " ^ string_of_formule f2 ^ ")"
  | Not f -> "(! " ^ string_of_formule f ^ ")"


(* Réponse Q2 *)
let string_of_sequent s =
  let gamma_str = String.concat ", " (List.map string_of_formule s.gamma) in
  gamma_str ^ " |- " ^ string_of_formule s.phi

(* Réponse Q3 *)
let appliquer_regle r s =
  match r, s.phi with
  | Axiom, _ ->
      if List.mem s.phi s.gamma then Some [] else None
  | AndIntro, And (f1, f2) ->
      Some [seq s.gamma f1; seq s.gamma f2]
  | OrIntro1, Or (f1, _) ->
      Some [seq s.gamma f1]
  | OrIntro2, Or (_, f2) ->
      Some [seq s.gamma f2]
  | ImpliesIntro, Implies (f1, f2) ->
      Some [seq (f1 :: s.gamma) f2]
  | NotIntro, Not f ->
      Some [seq (f :: s.gamma) Bot]
  | ImpliesElim f1, _ ->
      Some [seq s.gamma (Implies (f1, s.phi)); seq s.gamma f1]
  | AndElim1 f2, _ ->
      Some [seq s.gamma (And (s.phi, f2))]
  | AndElim2 f1, _ ->
      Some [seq s.gamma (And (f1, s.phi))]
  | NotElim f, Bot ->
      Some [seq s.gamma (Not f); seq s.gamma f]
  | OrElim (f1, f2), _ ->
      (* Pour prouver phi par OrElim, il faut prouver qu'on a f1 \/ f2, puis que f1 implique phi, et f2 implique phi *)
      Some [
        seq s.gamma (Or (f1, f2));
        seq (f1 :: s.gamma) s.phi;
        seq (f2 :: s.gamma) s.phi
      ]
  | _, _ -> None

(* Fonction utilitaire : Extraire les sous-formules *)
(* Réponse Q4 *)
let rec sous_formules_f f =
  match f with
  | And (f1, f2) | Or (f1, f2) | Implies (f1, f2) ->
      f :: (sous_formules_f f1 @ sous_formules_f f2)
  | Not f1 -> f :: sous_formules_f f1
  | _ -> [f]

(* Réponse Q5 *)
let sous_formules_gamma gamma = List.map sous_formules_f gamma |> List.concat

(* Réponse Q6 *)
let regles_possibles s =
  let intros = match s.phi with
    | And _ -> [AndIntro]
    | Or _ -> [OrIntro1; OrIntro2]
    | Implies _ -> [ImpliesIntro]
    | Not _ -> [NotIntro]
    | _ -> []
  in
  let elims = 
    let sf = sous_formules_gamma s.gamma in
    let list_elims_classiques = List.concat (List.map (fun f -> [AndElim1 f; AndElim2 f; ImpliesElim f; NotElim f]) sf) in
    let list_or_elims = 
      List.filter_map (fun f -> 
        match f with
        | Or (f1, f2) -> Some (OrElim (f1, f2))
        | _ -> None
      ) sf
    in
    list_elims_classiques @ list_or_elims
  in
  (* On privilégie l'axiome, puis les intros, puis les éliminations limitées aux sous-formules *)
  Axiom :: (intros @ elims)

(* Réponse Q7 *)
let rec prouver depth s =
  if depth <= 0 then None
  else
    let rules = regles_possibles s in
    let rec try_rules = function
      | [] -> None
      | r :: rs ->
          match appliquer_regle r s with
          | None -> try_rules rs
          | Some premises ->
              let rec prove_all = function
                | [] -> Some []
                | p :: ps ->
                    match prouver (depth - 1) p with
                    | None -> None
                    | Some tree ->
                        match prove_all ps with
                        | None -> None
                        | Some trees -> Some (tree :: trees)
              in
              match prove_all premises with
              | None -> try_rules rs
              | Some trees -> Some (Noeud (r, s, trees))
          in try_rules rules

(* Réponse Q8 *)
let prouver_min max_depth s =
  let rec iter depth =
    if depth > max_depth then None
    else match prouver depth s with
      | Some arbre -> Some arbre
      | None -> iter (depth + 1)
  in iter 1

let tests = [
  "|- A -> A";
  "|- (A & B) -> (B & A)";
  "|- A -> (B -> A)";
  "|- ((A -> B) & A) -> B";
  "|- (A & (B | C)) -> ((A & B) | (A & C))";
  "|- (A & !A) -> F";
]

let run_test seq_str =
  let seq = parse seq_str in
  Printf.printf "\nTest : %s\n" (string_of_sequent seq);
  match prouver_min 8 seq with
  | None -> Printf.printf "  -> Echec de la preuve\n"
  | Some arbre ->
      Printf.printf "  -> Succes !\n";
      afficher_arbre_preuve arbre

let () =
  List.iter run_test tests
