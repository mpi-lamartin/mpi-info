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
let rec mem f = function
  | [] -> false
  | x::xs -> if x = f then true else mem f xs

let rec string_of_formule = function
  | Var v -> v
  | Top -> "T"
  | Bot -> "F"
  | And (f1, f2) -> "(" ^ string_of_formule f1 ^ " /\\ " ^ string_of_formule f2 ^ ")"
  | Or (f1, f2) -> "(" ^ string_of_formule f1 ^ " \\/ " ^ string_of_formule f2 ^ ")"
  | Implies (f1, f2) -> "(" ^ string_of_formule f1 ^ " -> " ^ string_of_formule f2 ^ ")"
  | Not f -> "(~ " ^ string_of_formule f ^ ")"

let string_of_sequent s =
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

let string_of_regle = function
  | Axiom -> "Axiom"
  | TopIntro -> "TopIntro"
  | BotElim -> "BotElim"
  | AndIntro -> "AndIntro"
  | AndElim1 f -> "AndElim1(" ^ string_of_formule f ^ ")"
  | AndElim2 f -> "AndElim2(" ^ string_of_formule f ^ ")"
  | OrIntro1 -> "OrIntro1"
  | OrIntro2 -> "OrIntro2"
  | OrElim (f1, f2) -> "OrElim(" ^ string_of_formule f1 ^ ", " ^ string_of_formule f2 ^ ")"
  | ImpliesIntro -> "ImpliesIntro"
  | ImpliesElim f -> "ImpliesElim(" ^ string_of_formule f ^ ")"
  | NotIntro -> "NotIntro"
  | NotElim f -> "NotElim(" ^ string_of_formule f ^ ")"

let rec afficher_arbre_preuve depth (Noeud (r, s, premises)) =
  let indent = String.make (depth * 2) ' ' in
  Printf.printf "%s[%s] %s\n" indent (string_of_regle r) (string_of_sequent s);
  List.iter (afficher_arbre_preuve (depth + 1)) premises

let appliquer_regle r s =
  match r, s.phi with
  | Axiom, _ ->
      if mem s.phi s.gamma then Some [] else None
  | TopIntro, Top -> Some []
  | AndIntro, And (f1, f2) ->
      Some [{gamma = s.gamma; phi = f1}; {gamma = s.gamma; phi = f2}]
  | OrIntro1, Or (f1, _) ->
      Some [{gamma = s.gamma; phi = f1}]
  | OrIntro2, Or (_, f2) ->
      Some [{gamma = s.gamma; phi = f2}]
  | ImpliesIntro, Implies (f1, f2) ->
      Some [{gamma = f1 :: s.gamma; phi = f2}]
  | NotIntro, Not f ->
      Some [{gamma = f :: s.gamma; phi = Bot}]
  | ImpliesElim f1, _ ->
      Some [{gamma = s.gamma; phi = Implies (f1, s.phi)}; {gamma = s.gamma; phi = f1}]
  | AndElim1 f2, _ ->
      Some [{gamma = s.gamma; phi = And (s.phi, f2)}]
  | AndElim2 f1, _ ->
      Some [{gamma = s.gamma; phi = And (f1, s.phi)}]
  | OrElim (f1, f2), _ ->
      (* Pour prouver phi par OrElim, il faut prouver qu'on a f1 \/ f2, puis que f1 implique phi, et f2 implique phi *)
      Some [
        {gamma = s.gamma; phi = Or (f1, f2)};
        {gamma = f1 :: s.gamma; phi = s.phi};
        {gamma = f2 :: s.gamma; phi = s.phi}
      ]
  | _, _ -> None

(* Fonction utilitaire : Extraire les sous-formules *)
let rec sous_formules_f f =
  match f with
  | And (f1, f2) | Or (f1, f2) | Implies (f1, f2) ->
      f :: (sous_formules_f f1 @ sous_formules_f f2)
  | Not f1 -> f :: sous_formules_f f1
  | _ -> [f]

let sous_formules_gamma gamma =
  List.sort_uniq compare (List.concat (List.map sous_formules_f gamma))

(* Exercice 4 *)
let regles_possibles s =
  let intros = match s.phi with
    | Top -> [TopIntro]
    | And _ -> [AndIntro]
    | Or _ -> [OrIntro1; OrIntro2]
    | Implies _ -> [ImpliesIntro]
    | Not _ -> [NotIntro]
    | _ -> []
  in
  let elims = 
    let sf = sous_formules_gamma s.gamma in
    let list_elims_classiques = List.concat (List.map (fun f -> [AndElim1 f; AndElim2 f; ImpliesElim f]) sf) in
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

(* Exercice 3 *)
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

(* Exercice 5 : Iterative Deepening (Preuve la plus courte) *)
let prouver_min max_depth s =
  let rec iter depth =
    if depth > max_depth then None
    else match prouver depth s with
      | Some arbre -> Some arbre
      | None -> iter (depth + 1)
  in iter 1

(* Exercice 6 - Tests *)
let test () =
  let f1 = Var "A" in
  let f2 = Var "B" in
  let f3 = Var "C" in
  
  (* 1. A -> A *)
  let seq1 = { gamma = []; phi = Implies (f1, f1) } in
  
  (* 2. A /\ B -> B /\ A *)
  let seq2 = { gamma = []; phi = Implies (And (f1, f2), And (f2, f1)) } in
  
  (* 3. A -> (B -> A) *)
  let seq3 = { gamma = []; phi = Implies (f1, Implies (f2, f1)) } in

  (* 4. (A -> B) /\ A -> B (Finalement marche grâce aux sous-formules) *)
  let seq4 = { gamma = []; phi = Implies (And (Implies (f1, f2), f1), f2) } in

  (* 5. F -> A (Impossible car on n'a pas inclus BotElim dans regles_possibles) *)
  let seq5 = { gamma = []; phi = Implies (Bot, f1) } in

  (* 6. A /\ (B \/ C) -> (A /\ B) \/ (A /\ C) (Logique minimale, échoue sans OrElim) *)
  let seq6 = { gamma = []; phi = Implies (And (f1, Or (f2, f3)), Or (And (f1, f2), And (f1, f3))) } in

  let run_test name seq =
    Printf.printf "\nTest %s : %s\n" name (string_of_sequent seq);
    match prouver_min 8 seq with
    | None -> Printf.printf "  -> Echec de la preuve\n"
    | Some arbre -> 
        Printf.printf "  -> Succès !\n";
        afficher_arbre_preuve 1 arbre
  in

  run_test "1" seq1;
  run_test "2 (partiel, necessite elim)" seq2;
  run_test "3" seq3;
  run_test "4" seq4;
  run_test "5 (F -> A, échoue sans BotElim)" seq5;
  run_test "6 (A/\\(B\\/C) -> ..., marche avec OrElim)" seq6

let () = test ()
