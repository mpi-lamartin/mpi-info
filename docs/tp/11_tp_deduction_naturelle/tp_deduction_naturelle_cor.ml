type formule =
  | Var of string
  | Bot
  | And of formule * formule
  | Or of formule * formule
  | Implies of formule * formule
  | Not of formule
;;

type sequent = {
  gamma : formule list;
  phi : formule;
};;

(* Réponse Q2 *)
let rec string_of_formule = function
  | Var v -> v
  | Bot -> "F"
  | And (f1, f2) -> "(" ^ string_of_formule f1 ^ " & " ^ string_of_formule f2 ^ ")"
  | Or (f1, f2) -> "(" ^ string_of_formule f1 ^ " | " ^ string_of_formule f2 ^ ")"
  | Implies (f1, f2) -> "(" ^ string_of_formule f1 ^ " -> " ^ string_of_formule f2 ^ ")"
  | Not f -> "(! " ^ string_of_formule f ^ ")";;

(* Réponse Q3 *)
let string_of_sequent s =
  let gamma_str = String.concat ", " (List.map string_of_formule s.gamma) in
  gamma_str ^ " |- " ^ string_of_formule s.phi

type regle =
  | Axiom
  | ImpliesIntro | ImpliesElim of formule (* A *)
  | AndIntro | AndElim1 of formule (* B *) | AndElim2 of formule (* A *)
  | OrIntro1 | OrIntro2 | OrElim of formule * formule (* A, B *)
  | NotElim of formule (* A *) | NotIntro;;

#use "docs/tp/11_tp_deduction_naturelle/parser.ml";;

type arbre_preuve = Noeud of regle * sequent * arbre_preuve list;;

let string_of_regle = function
  | Axiom -> "Axiom"
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
  List.iter (afficher_arbre_preuve (depth + 1)) premises;;

(* Réponse Q4 *)
let appliquer_regle r s =
  match r, s.phi with
  | Axiom, _ ->
      if List.mem s.phi s.gamma then Some [] else None
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
  | NotElim f, Bot ->
      Some [{gamma = s.gamma; phi = Not f}; {gamma = s.gamma; phi = f}]
  | OrElim (f1, f2), _ ->
      (* Pour prouver phi par OrElim, il faut prouver qu'on a f1 \/ f2, puis que f1 implique phi, et f2 implique phi *)
      Some [
        {gamma = s.gamma; phi = Or (f1, f2)};
        {gamma = f1 :: s.gamma; phi = s.phi};
        {gamma = f2 :: s.gamma; phi = s.phi}
      ]
  | _, _ -> None;;

appliquer_regle Axiom (parse "A |- A");;
appliquer_regle Axiom (parse "A |- B");; 
appliquer_regle AndIntro (parse "A |- (A & B)");;
appliquer_regle (NotElim ((parse "A | B").phi)) (parse "B, !A |- F");;
appliquer_regle (OrElim (Var "A", Var "B")) (parse "|- C");; 

(* Fonction utilitaire : Extraire les sous-formules *)
let rec sous_formules_f f =
  match f with
  | And (f1, f2) | Or (f1, f2) | Implies (f1, f2) ->
      f :: (sous_formules_f f1 @ sous_formules_f f2)
  | Not f1 -> f :: sous_formules_f f1
  | _ -> [f]

sous_formules_f (parse "A & (B | C)").phi;;

let sous_formules_gamma gamma =
  List.map sous_formules_f gamma |> List.concat (* |> List.sort_uniq compare) *)

sous_formules_gamma (parse "(A & B), (C | D) |- A").gamma;;

(* Réponse Q5 *)
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

regles_possibles (parse "(A & B) |- A");;
(* Réponse Q6 *)
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

prouver 2 (parse "(A & B) |- A") |> Option.iter (afficher_arbre_preuve 1);;
prouver 4 (parse "|- (A & B) -> (B & A)") |> Option.iter (afficher_arbre_preuve 1);;
prouver 6 (parse "|- (A & (B | C)) -> ((A & B) | (A & C))") |> Option.iter (afficher_arbre_preuve 1);;

(* Réponse Q7 *)
let prouver_min max_depth s =
  let rec iter depth =
    if depth > max_depth then None
    else match prouver depth s with
      | Some arbre -> Some arbre
      | None -> iter (depth + 1)
  in iter 1
