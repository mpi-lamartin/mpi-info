(* ============================================= *)
(* Utilitaires de Parsing (Formules et Séquents) *)
(* ============================================= *)

(* Remarque : ce fichier suppose que les types `formule` et `sequent` 
   sont déjà définis dans l'environnement *)

type token = TVar of string | TAnd | TOr | TImpl | TNot | TTop | TBot | TLPar | TRPar | TComma | TTurnstile

let lexer s =
  let len = String.length s in
  let rec lex i acc =
    if i >= len then List.rev acc
    else match s.[i] with
      | ' ' | '\t' | '\n' | '\r' -> lex (i+1) acc
      | '(' -> lex (i+1) (TLPar::acc)
      | ')' -> lex (i+1) (TRPar::acc)
      | ',' -> lex (i+1) (TComma::acc)
      | '!' -> lex (i+1) (TNot::acc)
      | 'T' -> lex (i+1) (TTop::acc)
      | 'F' -> lex (i+1) (TBot::acc)
      | '&' -> lex (i+1) (TAnd::acc)
      | '|' when i+1 < len && s.[i+1] = '-' -> lex (i+2) (TTurnstile::acc)
      | '|' -> lex (i+1) (TOr::acc)
      | '-' when i+1 < len && s.[i+1] = '>' -> lex (i+2) (TImpl::acc)
      | c when (c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z') ->
          let start = i in
          let rec find_end j =
            if j < len && ((s.[j] >= 'A' && s.[j] <= 'Z') || (s.[j] >= 'a' && s.[j] <= 'z') || (s.[j] >= '0' && s.[j] <= '9'))
            then find_end (j+1) else j
          in
          let j = find_end i in
          lex j (TVar (String.sub s start (j - start)) :: acc)
      | _ -> failwith ("Erreur lexicale: " ^ String.make 1 s.[i])
  in lex 0 []

let rec parse_expr tokens =
  let e1, rest = parse_or tokens in
  match rest with
  | TImpl :: rest' -> let e2, rest'' = parse_expr rest' in (Implies (e1, e2), rest'')
  | _ -> e1, rest
and parse_or tokens =
  let e1, rest = parse_and tokens in
  let rec loop acc t =
    match t with
    | TOr :: rest' -> let e2, rest'' = parse_and rest' in loop (Or (acc, e2)) rest''
    | _ -> acc, t
  in loop e1 rest
and parse_and tokens =
  let e1, rest = parse_not tokens in
  let rec loop acc t =
    match t with
    | TAnd :: rest' -> let e2, rest'' = parse_not rest' in loop (And (acc, e2)) rest''
    | _ -> acc, t
  in loop e1 rest
and parse_not tokens =
  match tokens with
  | TNot :: rest -> let e, rest' = parse_not rest in (Not e, rest')
  | _ -> parse_atom tokens
and parse_atom tokens =
  match tokens with
  | TVar v :: rest -> (Var v, rest)
  | TBot :: rest -> (Bot, rest)
  | TLPar :: rest ->
      let e, rest' = parse_expr rest in
      (match rest' with
       | TRPar :: rest'' -> (e, rest'')
       | _ -> failwith "Parenthèse fermée manquante")
  | _ -> failwith "Erreur de syntaxe"

let parse str =
  let tks = lexer str in
  let rec parse_g tk acc =
    match tk with
    | TTurnstile :: rest -> List.rev acc, rest
    | _ ->
        let e, rest = parse_expr tk in
        (match rest with
         | TComma :: rest' -> parse_g rest' (e::acc)
         | TTurnstile :: rest' -> List.rev (e::acc), rest'
         | _ -> failwith "Erreur syntaxe Gamma")
  in
  if not (List.mem TTurnstile tks) then
    let p, rest = parse_expr tks in
    if rest <> [] then failwith "Jetons restants" else { gamma = []; phi = p }
  else
    let g, rest = parse_g tks [] in
    let p, rest' = parse_expr rest in
    if rest' <> [] then failwith "Jetons après phi" else { gamma = g; phi = p }

let rec aux depth (Noeud (r, s, premises)) =
  let indent = String.make (depth * 2) ' ' in
  Printf.printf "%s[%s] %s\n" indent (string_of_regle r) (string_of_sequent s);
  List.iter (aux (depth + 1)) premises

let afficher_arbre_preuve = aux 1 
