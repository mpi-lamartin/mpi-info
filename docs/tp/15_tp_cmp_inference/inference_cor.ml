type ('a, 'b) dict =
  | Empty
  | Node of ('a, 'b) dict * 'a * 'b * ('a, 'b) dict


let creer_dictionnaire () = Empty


let rec trouver cle = function
  | Empty -> None
  | Node (gauche, cle_noeud, valeur, droite) ->
  if cle = cle_noeud then Some valeur
  else if cle < cle_noeud then trouver cle gauche
      else trouver cle droite


let rec inserer cle valeur = function
  | Empty -> Node (Empty, cle, valeur, Empty)
  | Node (gauche, cle_noeud, valeur_noeud, droite) ->
      if cle = cle_noeud then Node (gauche, cle, valeur, droite)
      else if cle < cle_noeud then
        Node (inserer cle valeur gauche, cle_noeud, valeur_noeud, droite)
      else Node (gauche, cle_noeud, valeur_noeud, inserer cle valeur droite)


let rec map_dict f = function
  | Empty -> Empty
  | Node (gauche, cle, valeur, droite) ->
      Node (map_dict f gauche, cle, f valeur, map_dict f droite)


let rec fold_dict f dictionnaire accumulateur =
  match dictionnaire with
  | Empty -> accumulateur
  | Node (gauche, cle, valeur, droite) ->
      let accumulateur = fold_dict f gauche accumulateur in
      let accumulateur = f accumulateur cle valeur in
      fold_dict f droite accumulateur


let valeur_associee nom dictionnaire =
  match trouver nom dictionnaire with
  | Some valeur -> valeur
  | None -> failwith ("identifiant inconnu : " ^ nom)


(* Inférence avec annotation de paramètre *)

type typ1 =
  | Int
  | Arrow of typ1 * typ1
  | Product of typ1 * typ1
;;

type expression1 =
  | Var of string
  | Const of int
  | Op of string
  | Fun of string * typ1 * expression1
  | App of expression1 * expression1
  | Couple of expression1 * expression1
  | Let of string * expression1 * expression1
;;


let parentheser condition texte =
  if condition then "(" ^ texte ^ ")" else texte


let string_of_typ1 typ =
  let rec aux priorite = function
    | Int -> "int"
    | Product (gauche, droite) ->
        parentheser (priorite > 1) (aux 1 gauche ^ " * " ^ aux 1 droite)
    | Arrow (gauche, droite) ->
        parentheser (priorite > 0) (aux 2 gauche ^ " -> " ^ aux 0 droite)
  in
  aux 0 typ


let print_typ1 typ = print_string (string_of_typ1 typ)


let string_of_expression1 expression =
  let rec aux priorite = function
    | Var nom -> nom
    | Const entier -> string_of_int entier
    | Op operateur -> operateur
    | Fun (nom, typ, corps) ->
        parentheser (priorite > 0)
          ("fun " ^ nom ^ " : " ^ string_of_typ1 typ ^ " -> " ^ aux 0 corps)
    | App (fonction, argument) ->
        parentheser (priorite > 1) (aux 1 fonction ^ " " ^ aux 2 argument)
    | Couple (gauche, droite) -> "(" ^ aux 0 gauche ^ ", " ^ aux 0 droite ^ ")"
    | Let (nom, valeur, corps) ->
        parentheser (priorite > 0)
          ("let " ^ nom ^ " = " ^ aux 0 valeur ^ " in " ^ aux 0 corps)
  in
  aux 0 expression


let print_expression1 expression = print_string (string_of_expression1 expression)


let typ_expr expression =
  let rec aux environnement = function
    | Var nom -> valeur_associee nom environnement
    | Const _ -> Int
    | Op _ -> Arrow (Product (Int, Int), Int)
    | Fun (nom, typ_argument, corps) ->
        let environnement = inserer nom typ_argument environnement in
        Arrow (typ_argument, aux environnement corps)
    | App (fonction, argument) ->
        let typ_fonction = aux environnement fonction in
        let typ_argument = aux environnement argument in
        begin
          match typ_fonction with
          | Arrow (attendu, resultat) when attendu = typ_argument -> resultat
          | Arrow _ -> failwith "argument de type incorrect"
          | _ -> failwith "application d'une expression non fonctionnelle"
        end
    | Couple (gauche, droite) -> Product (aux environnement gauche, aux environnement droite)
    | Let (nom, valeur, corps) ->
        let typ_valeur = aux environnement valeur in
        aux (inserer nom typ_valeur environnement) corps
  in
  aux (creer_dictionnaire ()) expression


(* Inférence sans annotation *)

type typ2 =
  | Int
  | Arrow of typ2 * typ2
  | Product of typ2 * typ2
  | Tvar of int
;;


type expression2 =
  | Var of string
  | Const of int
  | Op of string
  | Fun of string * expression2
  | App of expression2 * expression2
  | Couple of expression2 * expression2
  | Let of string * expression2 * expression2
;;


let string_of_typ2 typ =
  let rec aux priorite = function
    | Int -> "int"
    | Tvar numero -> string_of_int numero
    | Product (gauche, droite) ->
        parentheser (priorite > 1) (aux 1 gauche ^ " * " ^ aux 1 droite)
    | Arrow (gauche, droite) ->
        parentheser (priorite > 0) (aux 2 gauche ^ " -> " ^ aux 0 droite)
  in
  aux 0 typ


let print_typ2 typ = print_string (string_of_typ2 typ)


let string_of_expression2 expression =
  let rec aux priorite = function
    | Var nom -> nom
    | Const entier -> string_of_int entier
    | Op operateur -> operateur
    | Fun (nom, corps) -> parentheser (priorite > 0) ("fun " ^ nom ^ " -> " ^ aux 0 corps)
    | App (fonction, argument) ->
        parentheser (priorite > 1) (aux 1 fonction ^ " " ^ aux 2 argument)
    | Couple (gauche, droite) -> "(" ^ aux 0 gauche ^ ", " ^ aux 0 droite ^ ")"
    | Let (nom, valeur, corps) ->
        parentheser (priorite > 0)
          ("let " ^ nom ^ " = " ^ aux 0 valeur ^ " in " ^ aux 0 corps)
  in
  aux 0 expression


let print_expression2 expression = print_string (string_of_expression2 expression)


let compteur_types = ref 0


let reset_compteur_types () = compteur_types := 0


let nouvelle_variable_type () =
  let resultat = !compteur_types in
  incr compteur_types;
  resultat


let rec remplacer_variable variable remplacement = function
  | Int -> Int
  | Tvar numero when numero = variable -> remplacement
  | Tvar numero -> Tvar numero
  | Arrow (gauche, droite) ->
      Arrow (remplacer_variable variable remplacement gauche, remplacer_variable variable remplacement droite)
  | Product (gauche, droite) ->
      Product (remplacer_variable variable remplacement gauche, remplacer_variable variable remplacement droite)


let rec appliquer substitution = function
  | Int -> Int
  | Tvar numero ->
      begin
        match trouver numero substitution with
        | None -> Tvar numero
        | Some typ -> appliquer substitution typ
      end
  | Arrow (gauche, droite) -> Arrow (appliquer substitution gauche, appliquer substitution droite)
  | Product (gauche, droite) ->
      Product (appliquer substitution gauche, appliquer substitution droite)


let rec variable_libre_dans variable typ =
  match typ with
  | Int -> false
  | Tvar numero -> numero = variable
  | Arrow (gauche, droite) | Product (gauche, droite) ->
      variable_libre_dans variable gauche || variable_libre_dans variable droite


let ajouter_substitution substitution variable typ =
  let typ = appliquer substitution typ in
  let substitution = map_dict (remplacer_variable variable typ) substitution in
  inserer variable typ substitution


let rec unification substitution typ_gauche typ_droite =
  let typ_gauche = appliquer substitution typ_gauche in
  let typ_droite = appliquer substitution typ_droite in
  if typ_gauche = typ_droite then substitution
  else
    match (typ_gauche, typ_droite) with
    | Arrow (g1, d1), Arrow (g2, d2) ->
        let substitution = unification substitution g1 g2 in
        unification substitution d1 d2
    | Product (g1, d1), Product (g2, d2) ->
        let substitution = unification substitution g1 g2 in
        unification substitution d1 d2
    | Tvar variable, typ | typ, Tvar variable ->
        if variable_libre_dans variable typ then failwith "types non unifiables"
        else ajouter_substitution substitution variable typ
    | _ -> failwith "types non unifiables"


let w_sans_polymorphisme expression =
  let rec inferer environnement substitution = function
    | Var nom -> (substitution, appliquer substitution (valeur_associee nom environnement))
    | Const _ -> (substitution, Int)
    | Op _ -> (substitution, Arrow (Product (Int, Int), Int))
    | Fun (nom, corps) ->
        let variable = Tvar (nouvelle_variable_type ()) in
        let environnement = inserer nom variable environnement in
        let substitution, typ_corps = inferer environnement substitution corps in
        (substitution, Arrow (appliquer substitution variable, typ_corps))
    | App (fonction, argument) ->
        let substitution, typ_fonction = inferer environnement substitution fonction in
        let substitution, typ_argument = inferer environnement substitution argument in
        let resultat = Tvar (nouvelle_variable_type ()) in
        let substitution = unification substitution typ_fonction (Arrow (typ_argument, resultat)) in
        (substitution, appliquer substitution resultat)
    | Couple (gauche, droite) ->
        let substitution, typ_gauche = inferer environnement substitution gauche in
        let substitution, typ_droite = inferer environnement substitution droite in
        (substitution, Product (appliquer substitution typ_gauche, appliquer substitution typ_droite))
    | Let _ -> failwith "les expressions Let ne sont pas traitées dans cette version"
  in
  reset_compteur_types ();
  let _, typ = inferer (creer_dictionnaire ()) (creer_dictionnaire ()) expression in
  typ


(* Inférence avec polymorphisme *)

type schema = Schema of int list * typ2


let ajouter_unique element liste =
  if List.mem element liste then liste else element :: liste


let union liste1 liste2 = List.fold_left (fun acc element -> ajouter_unique element acc) liste2 liste1


let difference liste1 liste2 = List.filter (fun element -> not (List.mem element liste2)) liste1


let rec variables_libres_type = function
  | Int -> []
  | Tvar numero -> [ numero ]
  | Arrow (gauche, droite) | Product (gauche, droite) ->
      union (variables_libres_type gauche) (variables_libres_type droite)


let variables_libres_schema (Schema (variables_quantifiees, typ)) =
  difference (variables_libres_type typ) variables_quantifiees


let variables_libres_env environnement =
  fold_dict
    (fun acc _ schema -> union acc (variables_libres_schema schema))
    environnement []


let rec appliquer_bloquees bloquees substitution = function
  | Int -> Int
  | Tvar numero when List.mem numero bloquees -> Tvar numero
  | Tvar numero ->
      begin
        match trouver numero substitution with
        | None -> Tvar numero
        | Some typ -> appliquer_bloquees bloquees substitution typ
      end
  | Arrow (gauche, droite) ->
      Arrow (appliquer_bloquees bloquees substitution gauche, appliquer_bloquees bloquees substitution droite)
  | Product (gauche, droite) ->
      Product (appliquer_bloquees bloquees substitution gauche, appliquer_bloquees bloquees substitution droite)


let appliquer_schema substitution (Schema (variables_quantifiees, typ)) =
  Schema (variables_quantifiees, appliquer_bloquees variables_quantifiees substitution typ)


let appliquer_env substitution environnement = map_dict (appliquer_schema substitution) environnement


let generaliser environnement typ =
  let variables = difference (variables_libres_type typ) (variables_libres_env environnement) in
  Schema (variables, typ)


let instancier (Schema (variables, typ)) =
  let substitution =
    List.fold_left
      (fun acc variable -> inserer variable (Tvar (nouvelle_variable_type ())) acc)
      (creer_dictionnaire ()) variables
  in
  appliquer substitution typ


let w expression =
  let rec inferer environnement substitution = function
    | Var nom ->
        let schema = valeur_associee nom environnement in
        (substitution, instancier (appliquer_schema substitution schema))
    | Const _ -> (substitution, Int)
    | Op _ -> (substitution, Arrow (Product (Int, Int), Int))
    | Fun (nom, corps) ->
        let variable = Tvar (nouvelle_variable_type ()) in
        let environnement = inserer nom (Schema ([], variable)) environnement in
        let substitution, typ_corps = inferer environnement substitution corps in
        (substitution, Arrow (appliquer substitution variable, typ_corps))
    | App (fonction, argument) ->
        let substitution, typ_fonction = inferer environnement substitution fonction in
        let environnement = appliquer_env substitution environnement in
        let substitution, typ_argument = inferer environnement substitution argument in
        let resultat = Tvar (nouvelle_variable_type ()) in
        let substitution = unification substitution typ_fonction (Arrow (typ_argument, resultat)) in
        (substitution, appliquer substitution resultat)
    | Couple (gauche, droite) ->
        let substitution, typ_gauche = inferer environnement substitution gauche in
        let environnement = appliquer_env substitution environnement in
        let substitution, typ_droite = inferer environnement substitution droite in
        (substitution, Product (appliquer substitution typ_gauche, appliquer substitution typ_droite))
    | Let (nom, valeur, corps) ->
        let substitution, typ_valeur = inferer environnement substitution valeur in
        let environnement = appliquer_env substitution environnement in
        let schema = generaliser environnement (appliquer substitution typ_valeur) in
        inferer (inserer nom schema environnement) substitution corps
  in
  reset_compteur_types ();
  let _, typ = inferer (creer_dictionnaire ()) (creer_dictionnaire ()) expression in
  typ