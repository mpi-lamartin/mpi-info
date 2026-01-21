(** TP Arbres de décision ID3 - Correction
    
    Ce fichier implémente l'algorithme ID3 pour construire des arbres de décision
    sur le jeu de données du Titanic.
    
    Compilation :
    ocamlfind ocamlopt -package str -linkpkg csv_loader.ml decision_tree_cor.ml -o decision_tree
*)

(* ============================================================
   PARTIE 1 : Chargement des données
   ============================================================ *)

open Csv_loader

(** Question 1 : Charger les données d'entraînement *)
let load_train () = load_train_data "data/train.csv"

(** Question 1 : Charger les données de test *)
let load_test () = load_test_data "data/test.csv"

(** Question 3 : Afficher les statistiques des données *)
let stats data =
  let survived = List.filter (fun p -> p.survived = Some 1) data |> List.length in
  let died = List.filter (fun p -> p.survived = Some 0) data |> List.length in
  Printf.printf "Survivants: %d, Décédés: %d\n" survived died

(* ============================================================
   PARTIE 2 : Attributs catégoriels
   ============================================================ *)

(** Question 4 : Type représentant les attributs utilisables *)
type attribute =
  | Sex        (* "male" ou "female" *)
  | Pclass     (* "1", "2" ou "3" *)
  | AgeGroup   (* "child", "adult", "senior", "unknown" *)
  | FamilySize (* "alone", "small", "large" *)
  | Embarked   (* "S", "C", "Q", "unknown" *)
  | FareGroup  (* "low", "medium", "high", "unknown" *)

(** Question 5 : Extraire la valeur d'un attribut pour un passager *)
let get_attribute_value attr p =
  match attr with
  | Sex -> p.sex
  | Pclass -> string_of_int p.pclass
  | AgeGroup ->
    (* Conversion de l'âge en catégorie *)
    (match p.age with
     | None -> "unknown"
     | Some a when a < 18.0 -> "child"
     | Some a when a <= 60.0 -> "adult"
     | Some _ -> "senior")
  | FamilySize ->
    (* Taille de la famille = sibsp + parch *)
    let size = p.sibsp + p.parch in
    if size = 0 then "alone"
    else if size <= 3 then "small"
    else "large"
  | Embarked ->
    (match p.embarked with
     | None -> "unknown"
     | Some e -> e)
  | FareGroup ->
    (* Conversion du prix en catégorie *)
    (match p.fare with
     | None -> "unknown"
     | Some f when f < 10.0 -> "low"
     | Some f when f <= 50.0 -> "medium"
     | Some _ -> "high")

(** Question 4 : Liste des valeurs possibles pour chaque attribut *)
let attribute_values attr =
  match attr with
  | Sex -> ["male"; "female"]
  | Pclass -> ["1"; "2"; "3"]
  | AgeGroup -> ["child"; "adult"; "senior"; "unknown"]
  | FamilySize -> ["alone"; "small"; "large"]
  | Embarked -> ["S"; "C"; "Q"; "unknown"]
  | FareGroup -> ["low"; "medium"; "high"; "unknown"]

(** Nom de l'attribut pour l'affichage *)
let attribute_name attr =
  match attr with
  | Sex -> "Sex"
  | Pclass -> "Pclass"
  | AgeGroup -> "AgeGroup"
  | FamilySize -> "FamilySize"
  | Embarked -> "Embarked"
  | FareGroup -> "FareGroup"

(* ============================================================
   PARTIE 3 : Entropie et gain d'information
   ============================================================ *)

(** Calcule log2(x), avec la convention que log2(0) = 0 *)
let log2 x = 
  if x <= 0.0 then 0.0 
  else log x /. log 2.0

(** Question 6 : Calcul de l'entropie d'un ensemble de passagers
    
    H(S) = -sum_{c in {0,1}} p_c * log2(p_c)
    
    où p_c est la proportion de passagers de classe c dans S.
*)
let entropy data =
  let total = float_of_int (List.length data) in
  if total = 0.0 then 0.0
  else
    (* Compter les survivants et décédés *)
    let survived = List.filter (fun p -> p.survived = Some 1) data 
                   |> List.length 
                   |> float_of_int in
    let died = total -. survived in
    (* Calculer les proportions *)
    let p_survived = survived /. total in
    let p_died = died /. total in
    (* Calculer l'entropie *)
    -. (if p_survived > 0.0 then p_survived *. log2 p_survived else 0.0)
    -. (if p_died > 0.0 then p_died *. log2 p_died else 0.0)

(** Question 7 : Calcul du gain d'information
    
    IG(S, A) = H(S) - sum_{v in valeurs(A)} (|S_v| / |S|) * H(S_v)
    
    où S_v est le sous-ensemble des passagers ayant la valeur v pour l'attribut A.
*)
let information_gain data attr =
  let total_entropy = entropy data in
  let total = float_of_int (List.length data) in
  if total = 0.0 then 0.0
  else
    let values = attribute_values attr in
    (* Calculer l'entropie pondérée *)
    let weighted_entropy =
      List.fold_left (fun acc value ->
        (* Filtrer les passagers ayant cette valeur *)
        let subset = List.filter (fun p -> 
          get_attribute_value attr p = value
        ) data in
        let weight = float_of_int (List.length subset) /. total in
        acc +. weight *. entropy subset
      ) 0.0 values
    in
    total_entropy -. weighted_entropy

(** Question 8 : Trouver l'attribut avec le meilleur gain d'information *)
let best_attribute data attributes =
  match attributes with
  | [] -> None
  | attrs ->
    (* Calculer le gain pour chaque attribut *)
    let gains = List.map (fun attr -> 
      (attr, information_gain data attr)
    ) attrs in
    (* Trier par gain décroissant *)
    let sorted = List.sort (fun (_, g1) (_, g2) -> compare g2 g1) gains in
    match sorted with
    | (attr, gain) :: _ when gain > 0.0 -> Some attr
    | _ -> None

(* ============================================================
   PARTIE 4 : Construction de l'arbre
   ============================================================ *)

(** Question 9 : Type pour l'arbre de décision *)
type decision_tree =
  | Leaf of int                                        (* Prédiction : 0 ou 1 *)
  | Node of attribute * (string * decision_tree) list  (* Attribut et branches *)

(** Question 10 : Classe majoritaire dans un ensemble de passagers *)
let majority_class data =
  let survived = List.filter (fun p -> p.survived = Some 1) data |> List.length in
  let died = List.filter (fun p -> p.survived = Some 0) data |> List.length in
  if survived >= died then 1 else 0

(** Question 11 : Construction de l'arbre avec l'algorithme ID3
    
    Algorithme :
    1. Si la liste est vide, retourner Leaf 0
    2. Si tous ont la même classe, retourner Leaf (cette classe)
    3. Si plus d'attributs, retourner Leaf (classe majoritaire)
    4. Sinon :
       - Trouver le meilleur attribut A
       - Pour chaque valeur v de A, construire un sous-arbre sur {x | A(x) = v}
       - Retourner Node (A, branches)
*)
let rec build_tree data attributes =
  (* Cas 1 : pas de données *)
  if List.length data = 0 then 
    Leaf 0
  (* Cas 2a : tous les passagers ont survécu *)
  else if List.for_all (fun p -> p.survived = Some 1) data then 
    Leaf 1
  (* Cas 2b : tous les passagers sont décédés *)
  else if List.for_all (fun p -> p.survived = Some 0) data then 
    Leaf 0
  (* Cas 3 : plus d'attributs disponibles *)
  else if List.length attributes = 0 then 
    Leaf (majority_class data)
  else
    (* Cas 4 : chercher le meilleur attribut *)
    match best_attribute data attributes with
    | None -> 
      (* Aucun attribut n'améliore la classification *)
      Leaf (majority_class data)
    | Some attr ->
      (* Retirer cet attribut de la liste *)
      let remaining_attrs = List.filter (fun a -> a <> attr) attributes in
      let values = attribute_values attr in
      (* Construire les branches pour chaque valeur *)
      let branches = List.map (fun value ->
        let subset = List.filter (fun p -> 
          get_attribute_value attr p = value
        ) data in
        let subtree =
          if List.length subset = 0 then 
            (* Pas de données pour cette valeur : prédire la classe majoritaire *)
            Leaf (majority_class data)
          else 
            build_tree subset remaining_attrs
        in
        (value, subtree)
      ) values in
      Node (attr, branches)

(** Affichage de l'arbre de décision (fourni) *)
let rec print_tree tree indent =
  let spaces = String.make (indent * 2) ' ' in
  match tree with
  | Leaf pred -> 
    Printf.printf "%s└── Prédiction: %s\n" spaces 
      (if pred = 1 then "Survit" else "Décède")
  | Node (attr, branches) ->
    Printf.printf "%s[%s]\n" spaces (attribute_name attr);
    List.iter (fun (value, subtree) ->
      Printf.printf "%s  ├─ %s :\n" spaces value;
      print_tree subtree (indent + 2)
    ) branches

(* ============================================================
   PARTIE 5 : Prédiction et évaluation
   ============================================================ *)

(** Question 12 : Prédire la survie d'un passager *)
let rec predict tree p =
  match tree with
  | Leaf prediction -> prediction
  | Node (attr, branches) ->
    let value = get_attribute_value attr p in
    match List.assoc_opt value branches with
    | Some subtree -> predict subtree p
    | None -> 0  (* Valeur inconnue : prédire 0 par défaut *)

(** Question 13 : Calculer la précision sur un ensemble de données *)
let accuracy tree data =
  let correct = List.filter (fun p ->
    match p.survived with
    | Some s -> s = predict tree p
    | None -> false
  ) data in
  float_of_int (List.length correct) /. float_of_int (List.length data)

(* ============================================================
   PARTIE 6 : Génération de soumission
   ============================================================ *)

(** Question 15 : Générer un fichier de soumission au format Kaggle *)
let generate_submission tree data filename =
  let oc = open_out filename in
  Printf.fprintf oc "PassengerId,Survived\n";
  List.iter (fun p ->
    Printf.fprintf oc "%d,%d\n" p.passenger_id (predict tree p)
  ) data;
  close_out oc;
  Printf.printf "Fichier de soumission généré : %s\n" filename

(* ============================================================
   BONUS : Validation croisée et améliorations
   ============================================================ *)

(** Question 16 : Validation croisée k-fold *)
let cross_validation data k build_fn =
  let n = List.length data in
  let fold_size = n / k in
  (* Mélanger les données *)
  let shuffled = 
    let arr = Array.of_list data in
    for i = Array.length arr - 1 downto 1 do
      let j = Random.int (i + 1) in
      let tmp = arr.(i) in
      arr.(i) <- arr.(j);
      arr.(j) <- tmp
    done;
    Array.to_list arr
  in
  (* Calculer les scores pour chaque fold *)
  let scores = List.init k (fun i ->
    let start_idx = i * fold_size in
    let end_idx = if i = k - 1 then n else (i + 1) * fold_size in
    (* Séparer train et validation *)
    let _, train_val = List.fold_left (fun (idx, (train, valid)) p ->
      if idx >= start_idx && idx < end_idx then
        (idx + 1, (train, p :: valid))
      else
        (idx + 1, (p :: train, valid))
    ) (0, ([], [])) shuffled in
    let train_set = fst train_val in
    let valid_set = snd train_val in
    (* Construire et évaluer *)
    let tree = build_fn train_set in
    accuracy tree valid_set
  ) in
  (* Calculer moyenne et écart-type *)
  let mean = List.fold_left (+.) 0.0 scores /. float_of_int k in
  let variance = List.fold_left (fun acc s -> 
    acc +. (s -. mean) ** 2.0
  ) 0.0 scores /. float_of_int k in
  let std = sqrt variance in
  (mean, std, scores)

(** Question 17 : C4.5 - Ratio de gain d'information 
    
    GR(S, A) = IG(S, A) / IV(A)
    où IV(A) = -sum_v (|S_v|/|S|) * log2(|S_v|/|S|)
*)
let intrinsic_value data attr =
  let total = float_of_int (List.length data) in
  if total = 0.0 then 0.0
  else
    let values = attribute_values attr in
    List.fold_left (fun acc value ->
      let subset = List.filter (fun p -> 
        get_attribute_value attr p = value
      ) data in
      let ratio = float_of_int (List.length subset) /. total in
      if ratio > 0.0 then acc -. ratio *. log2 ratio
      else acc
    ) 0.0 values

let gain_ratio data attr =
  let ig = information_gain data attr in
  let iv = intrinsic_value data attr in
  if iv = 0.0 then 0.0 else ig /. iv

let best_attribute_c45 data attributes =
  match attributes with
  | [] -> None
  | attrs ->
    let ratios = List.map (fun attr -> 
      (attr, gain_ratio data attr)
    ) attrs in
    let sorted = List.sort (fun (_, r1) (_, r2) -> compare r2 r1) ratios in
    match sorted with
    | (attr, ratio) :: _ when ratio > 0.0 -> Some attr
    | _ -> None

(** Construction de l'arbre avec l'algorithme C4.5 (utilise gain_ratio) *)
let rec build_tree_c45 data attributes =
  (* Cas 1 : pas de données *)
  if List.length data = 0 then 
    Leaf 0
  (* Cas 2a : tous les passagers ont survécu *)
  else if List.for_all (fun p -> p.survived = Some 1) data then 
    Leaf 1
  (* Cas 2b : tous les passagers sont décédés *)
  else if List.for_all (fun p -> p.survived = Some 0) data then 
    Leaf 0
  (* Cas 3 : plus d'attributs disponibles *)
  else if List.length attributes = 0 then 
    Leaf (majority_class data)
  else
    (* Cas 4 : chercher le meilleur attribut avec C4.5 *)
    match best_attribute_c45 data attributes with
    | None -> 
      Leaf (majority_class data)
    | Some attr ->
      let remaining_attrs = List.filter (fun a -> a <> attr) attributes in
      let values = attribute_values attr in
      let branches = List.map (fun value ->
        let subset = List.filter (fun p -> 
          get_attribute_value attr p = value
        ) data in
        let subtree =
          if List.length subset = 0 then 
            Leaf (majority_class data)
          else 
            build_tree_c45 subset remaining_attrs
        in
        (value, subtree)
      ) values in
      Node (attr, branches)

(** Question 18 : Forêt aléatoire (Random Forest)
    
    Principe :
    1. Créer n_trees arbres de décision
    2. Pour chaque arbre :
       - Échantillonner les données avec remplacement (bootstrap)
       - Sélectionner aléatoirement max_features attributs
       - Construire l'arbre
    3. Prédiction par vote majoritaire
*)

(** Échantillonnage bootstrap : tire n éléments avec remplacement *)
let bootstrap_sample data =
  let n = List.length data in
  let arr = Array.of_list data in
  List.init n (fun _ -> arr.(Random.int n))

(** Sélectionne aléatoirement k éléments d'une liste *)
let random_subset lst k =
  let arr = Array.of_list lst in
  let n = Array.length arr in
  (* Fisher-Yates shuffle partiel *)
  for i = 0 to min (k - 1) (n - 1) do
    let j = i + Random.int (n - i) in
    let tmp = arr.(i) in
    arr.(i) <- arr.(j);
    arr.(j) <- tmp
  done;
  Array.to_list (Array.sub arr 0 (min k n))

(** Type pour la forêt aléatoire *)
type random_forest = decision_tree list

(** Construction d'un arbre avec profondeur maximale *)
let rec build_tree_with_depth data attributes max_depth current_depth =
  (* Cas 1 : pas de données *)
  if List.length data = 0 then 
    Leaf 0
  (* Cas 2a : tous les passagers ont survécu *)
  else if List.for_all (fun p -> p.survived = Some 1) data then 
    Leaf 1
  (* Cas 2b : tous les passagers sont décédés *)
  else if List.for_all (fun p -> p.survived = Some 0) data then 
    Leaf 0
  (* Cas 3 : profondeur maximale atteinte *)
  else if current_depth >= max_depth then
    Leaf (majority_class data)
  (* Cas 4 : plus d'attributs disponibles *)
  else if List.length attributes = 0 then 
    Leaf (majority_class data)
  else
    (* Cas 5 : chercher le meilleur attribut *)
    match best_attribute data attributes with
    | None -> 
      Leaf (majority_class data)
    | Some attr ->
      let remaining_attrs = List.filter (fun a -> a <> attr) attributes in
      let values = attribute_values attr in
      let branches = List.map (fun value ->
        let subset = List.filter (fun p -> 
          get_attribute_value attr p = value
        ) data in
        let subtree =
          if List.length subset = 0 then 
            Leaf (majority_class data)
          else 
            build_tree_with_depth subset remaining_attrs max_depth (current_depth + 1)
        in
        (value, subtree)
      ) values in
      Node (attr, branches)

(** Construit une forêt aléatoire améliorée
    @param data données d'entraînement
    @param all_attributes liste de tous les attributs disponibles
    @param n_trees nombre d'arbres à construire
    @param max_features nombre d'attributs par arbre (None = n-1 attributs)
    @param max_depth profondeur maximale des arbres (None = pas de limite)
    @param sample_ratio proportion des données à échantillonner (défaut 1.0)
*)
let build_forest_improved data all_attributes n_trees max_features max_depth sample_ratio =
  let n_attrs = List.length all_attributes in
  let max_f = match max_features with
    | Some k -> k
    | None -> max 1 (n_attrs - 1)  (* Par défaut : n-1 attributs au lieu de sqrt(n) *)
  in
  let max_d = match max_depth with
    | Some d -> d
    | None -> 10  (* Profondeur par défaut *)
  in
  let n_samples = int_of_float (float_of_int (List.length data) *. sample_ratio) in
  List.init n_trees (fun _ ->
    (* Échantillonnage bootstrap *)
    let arr = Array.of_list data in
    let sample = List.init n_samples (fun _ -> arr.(Random.int (Array.length arr))) in
    (* Sélection aléatoire des attributs *)
    let attrs = random_subset all_attributes max_f in
    (* Construction de l'arbre avec profondeur limitée *)
    build_tree_with_depth sample attrs max_d 0
  )

(** Ancienne fonction pour compatibilité *)
let build_forest data all_attributes n_trees max_features =
  build_forest_improved data all_attributes n_trees max_features (Some 8) 1.0

(** Prédiction par vote majoritaire de la forêt *)
let predict_forest forest passenger =
  let votes = List.map (fun tree -> predict tree passenger) forest in
  let count_ones = List.filter (fun v -> v = 1) votes |> List.length in
  let count_zeros = List.length votes - count_ones in
  if count_ones > count_zeros then 1 else 0

(** Calcule la précision de la forêt sur un ensemble de données *)
let accuracy_forest forest data =
  let correct = List.filter (fun p ->
    match p.survived with
    | Some s -> s = predict_forest forest p
    | None -> false
  ) data in
  float_of_int (List.length correct) /. float_of_int (List.length data)

(** Génère un fichier de soumission avec la forêt aléatoire *)
let generate_submission_forest forest data filename =
  let oc = open_out filename in
  Printf.fprintf oc "PassengerId,Survived\n";
  List.iter (fun p ->
    Printf.fprintf oc "%d,%d\n" p.passenger_id (predict_forest forest p)
  ) data;
  close_out oc;
  Printf.printf "Fichier de soumission généré : %s\n" filename

(* ============================================================
   TESTS UNITAIRES - Exemples pour vérifier les réponses
   ============================================================ *)

(** Affiche un test avec son résultat *)
let test_print name expected actual =
  let status = if expected = actual then "✓" else "✗" in
  Printf.printf "  %s %s: attendu %s, obtenu %s\n" status name expected actual

let test_float name expected actual tolerance =
  let status = if abs_float (expected -. actual) < tolerance then "✓" else "✗" in
  Printf.printf "  %s %s: attendu %.4f, obtenu %.4f\n" status name expected actual

let run_tests () =
  Printf.printf "\n=== TESTS UNITAIRES ===\n\n";
  
  let train = load_train () in
  let p1 = List.hd train in  (* Premier passager : Braund, Mr. Owen Harris *)
  
  (* Question 3 : stats *)
  Printf.printf "Question 3 - stats:\n";
  Printf.printf "  Attendu: Survivants: 342, Décédés: 549\n";
  Printf.printf "  Obtenu:  ";
  stats train;
  Printf.printf "\n";
  
  (* Question 4 : attribute_values *)
  Printf.printf "Question 4 - attribute_values:\n";
  let format_list l = "[\"" ^ String.concat "\"; \"" l ^ "\"]" in
  test_print "Sex" "[\"male\"; \"female\"]" (format_list (attribute_values Sex));
  test_print "Pclass" "[\"1\"; \"2\"; \"3\"]" (format_list (attribute_values Pclass));
  Printf.printf "\n";
  
  (* Question 5 : get_attribute_value *)
  Printf.printf "Question 5 - get_attribute_value (passager n°1: homme, 22 ans, classe 3, sibsp=1, fare=7.25):\n";
  test_print "Sex" "male" (get_attribute_value Sex p1);
  test_print "Pclass" "3" (get_attribute_value Pclass p1);
  test_print "AgeGroup" "adult" (get_attribute_value AgeGroup p1);
  test_print "FamilySize" "small" (get_attribute_value FamilySize p1);
  test_print "FareGroup" "low" (get_attribute_value FareGroup p1);
  test_print "Embarked" "S" (get_attribute_value Embarked p1);
  Printf.printf "\n";
  
  (* Question 6 : entropy *)
  Printf.printf "Question 6 - entropy:\n";
  test_float "entropy(train)" 0.9607 (entropy train) 0.001;
  Printf.printf "\n";
  
  (* Question 7 : information_gain *)
  Printf.printf "Question 7 - information_gain:\n";
  test_float "IG(Sex)" 0.2177 (information_gain train Sex) 0.001;
  test_float "IG(Pclass)" 0.0838 (information_gain train Pclass) 0.001;
  test_float "IG(AgeGroup)" 0.0162 (information_gain train AgeGroup) 0.001;
  test_float "IG(FamilySize)" 0.0608 (information_gain train FamilySize) 0.001;
  test_float "IG(Embarked)" 0.0240 (information_gain train Embarked) 0.001;
  test_float "IG(FareGroup)" 0.0916 (information_gain train FareGroup) 0.001;
  Printf.printf "\n";
  
  (* Question 8 : best_attribute *)
  Printf.printf "Question 8 - best_attribute:\n";
  let all_attrs = [Sex; Pclass; AgeGroup; FamilySize; Embarked; FareGroup] in
  let best = best_attribute train all_attrs in
  let best_name = match best with Some a -> attribute_name a | None -> "None" in
  test_print "best_attribute" "Sex" best_name;
  Printf.printf "\n";
  
  (* Question 10 : majority_class *)
  Printf.printf "Question 10 - majority_class:\n";
  test_print "majority_class(train)" "0" (string_of_int (majority_class train));
  let femmes_1ere = List.filter (fun p -> p.sex = "female" && p.pclass = 1) train in
  test_print "majority_class(femmes 1ère classe)" "1" (string_of_int (majority_class femmes_1ere));
  Printf.printf "\n";
  
  (* Question 13 : accuracy *)
  Printf.printf "Question 13 - accuracy:\n";
  let tree = build_tree train all_attrs in
  test_float "accuracy(tree, train)" 0.8530 (accuracy tree train) 0.001;
  Printf.printf "\n";
  
  (* Question 17 : gain_ratio (C4.5) *)
  Printf.printf "Question 17 - gain_ratio (C4.5):\n";
  test_float "GR(Sex)" 0.2325 (gain_ratio train Sex) 0.001;
  test_float "GR(FareGroup)" 0.0612 (gain_ratio train FareGroup) 0.001;
  test_float "GR(Pclass)" 0.0582 (gain_ratio train Pclass) 0.001;
  Printf.printf "\n"

(* ============================================================
   PROGRAMME PRINCIPAL
   ============================================================ *)

let () =
  Random.init 42;
  
  Printf.printf "=== TP Arbres de décision ID3 ===\n\n";
  
  (* Question 1-2 : Chargement et statistiques *)
  Printf.printf "--- Partie 1 : Chargement des données ---\n";
  let train = load_train () in
  let test = load_test () in
  Printf.printf "Données d'entraînement : %d passagers\n" (List.length train);
  Printf.printf "Données de test : %d passagers\n" (List.length test);
  stats train;
  Printf.printf "\n";
  
  (* Question 5-7 : Entropie et gain d'information *)
  Printf.printf "--- Partie 3 : Entropie et gain d'information ---\n";
  Printf.printf "Entropie totale : %.4f\n" (entropy train);
  Printf.printf "\nGains d'information :\n";
  let all_attrs = [Sex; Pclass; AgeGroup; FamilySize; Embarked; FareGroup] in
  List.iter (fun attr ->
    Printf.printf "  %s : %.4f\n" (attribute_name attr) (information_gain train attr)
  ) all_attrs;
  Printf.printf "\n";
  
  (* Question 10 : Construction de l'arbre *)
  Printf.printf "--- Partie 4 : Construction de l'arbre ---\n";
  let tree = build_tree train all_attrs in
  Printf.printf "Arbre construit :\n";
  print_tree tree 0;
  Printf.printf "\n";
  
  (* Question 11-12 : Évaluation *)
  Printf.printf "--- Partie 5 : Évaluation ---\n";
  Printf.printf "Précision sur données d'entraînement : %.2f%%\n" 
    (accuracy tree train *. 100.0);
  Printf.printf "\n";
  
  (* Question 14 : Génération de soumission *)
  Printf.printf "--- Partie 6 : Génération de soumission ---\n";
  generate_submission tree test "submission_id3_correction.csv";
  Printf.printf "\n";
  
  (* Question 15 : Validation croisée *)
  Printf.printf "--- Question 15 : Validation croisée (5-fold) ---\n";
  let (mean, std, scores) = cross_validation train 5 (fun data ->
    build_tree data all_attrs
  ) in
  Printf.printf "Scores par fold : ";
  List.iter (Printf.printf "%.2f%% ") (List.map (fun s -> s *. 100.0) scores);
  Printf.printf "\n";
  Printf.printf "Moyenne : %.2f%% (+/- %.2f%%)\n\n" (mean *. 100.0) (std *. 200.0);
  
  (* Question 17 : C4.5 *)
  Printf.printf "--- Question 17 : Comparaison ID3 vs C4.5 ---\n";
  Printf.printf "Ratio de gain (C4.5) :\n";
  List.iter (fun attr ->
    Printf.printf "  %s : %.4f\n" (attribute_name attr) (gain_ratio train attr)
  ) all_attrs;
  
  let tree_c45 = build_tree_c45 train all_attrs in
  Printf.printf "\nPrécision C4.5 sur entraînement : %.2f%%\n" (accuracy tree_c45 train *. 100.0);
  
  (* Validation croisée C4.5 *)
  let (mean_c45, std_c45, scores_c45) = cross_validation train 5 (fun data ->
    build_tree_c45 data all_attrs
  ) in
  Printf.printf "Validation croisée C4.5 (5-fold) :\n";
  Printf.printf "Scores par fold : ";
  List.iter (Printf.printf "%.2f%% ") (List.map (fun s -> s *. 100.0) scores_c45);
  Printf.printf "\n";
  Printf.printf "Moyenne : %.2f%% (+/- %.2f%%)\n\n" (mean_c45 *. 100.0) (std_c45 *. 200.0);
  
  (* Question 18 : Forêt aléatoire améliorée *)
  Printf.printf "--- Question 18 : Forêt aléatoire ---\n";
  
  (* Test avec différentes configurations *)
  Printf.printf "\nComparaison des configurations :\n";
  
  (* Configuration 1 : paramètres originaux (sqrt attributs) *)
  let forest1 = build_forest_improved train all_attrs 100 (Some 2) (Some 10) 1.0 in
  Printf.printf "  sqrt(n) attrs, depth=10 : %.2f%%\n" (accuracy_forest forest1 train *. 100.0);
  
  (* Configuration 2 : plus d'attributs *)
  let forest2 = build_forest_improved train all_attrs 100 (Some 4) (Some 10) 1.0 in
  Printf.printf "  4 attrs, depth=10       : %.2f%%\n" (accuracy_forest forest2 train *. 100.0);
  
  (* Configuration 3 : tous les attributs sauf 1 *)
  let forest3 = build_forest_improved train all_attrs 100 (Some 5) (Some 8) 1.0 in
  Printf.printf "  5 attrs, depth=8        : %.2f%%\n" (accuracy_forest forest3 train *. 100.0);
  
  (* Configuration 4 : configuration optimisée *)
  let n_trees = 200 in
  let forest = build_forest_improved train all_attrs n_trees (Some 4) (Some 6) 1.0 in
  Printf.printf "\nConfiguration retenue : 200 arbres, 4 attrs, depth=6\n";
  Printf.printf "Précision forêt (entraînement) : %.2f%%\n" (accuracy_forest forest train *. 100.0);
  
  (* Validation croisée sur la forêt optimisée *)
  Printf.printf "\nValidation croisée forêt (5-fold) :\n";
  let forest_cv_scores = 
    let n = List.length train in
    let fold_size = n / 5 in
    let shuffled = 
      let arr = Array.of_list train in
      for i = Array.length arr - 1 downto 1 do
        let j = Random.int (i + 1) in
        let tmp = arr.(i) in
        arr.(i) <- arr.(j);
        arr.(j) <- tmp
      done;
      Array.to_list arr
    in
    List.init 5 (fun i ->
      let start_idx = i * fold_size in
      let end_idx = if i = 4 then n else (i + 1) * fold_size in
      let _, (train_set, valid_set) = List.fold_left (fun (idx, (tr, va)) p ->
        if idx >= start_idx && idx < end_idx then
          (idx + 1, (tr, p :: va))
        else
          (idx + 1, (p :: tr, va))
      ) (0, ([], [])) shuffled in
      let f = build_forest_improved train_set all_attrs 100 (Some 4) (Some 6) 1.0 in
      accuracy_forest f valid_set
    )
  in
  Printf.printf "Scores par fold : ";
  List.iter (Printf.printf "%.2f%% ") (List.map (fun s -> s *. 100.0) forest_cv_scores);
  let mean_forest = List.fold_left (+.) 0.0 forest_cv_scores /. 5.0 in
  let var_forest = List.fold_left (fun acc s -> acc +. (s -. mean_forest) ** 2.0) 0.0 forest_cv_scores /. 5.0 in
  Printf.printf "\nMoyenne : %.2f%% (+/- %.2f%%)\n\n" (mean_forest *. 100.0) (sqrt var_forest *. 200.0);
  
  (* Génération soumission forêt *)
  generate_submission_forest forest test "submission_random_forest.csv";
  Printf.printf "\n";
  
  (* Comparaison finale *)
  Printf.printf "=== Résumé ===\n";
  let baseline_acc = 
    let correct = List.filter (fun p -> 
      p.survived = Some (if p.sex = "female" then 1 else 0)
    ) train in
    float_of_int (List.length correct) /. float_of_int (List.length train)
  in
  Printf.printf "Baseline (femmes survivent)      : %.2f%%\n" (baseline_acc *. 100.0);
  Printf.printf "Arbre de décision ID3            : %.2f%%\n" (accuracy tree train *. 100.0);
  Printf.printf "Validation croisée ID3           : %.2f%% (+/- %.2f%%)\n" (mean *. 100.0) (std *. 200.0);
  Printf.printf "Arbre de décision C4.5           : %.2f%%\n" (accuracy tree_c45 train *. 100.0);
  Printf.printf "Validation croisée C4.5          : %.2f%% (+/- %.2f%%)\n" (mean_c45 *. 100.0) (std_c45 *. 200.0);
  Printf.printf "Forêt aléatoire (200 arbres)     : %.2f%%\n" (accuracy_forest forest train *. 100.0);
  Printf.printf "Validation croisée forêt         : %.2f%% (+/- %.2f%%)\n" (mean_forest *. 100.0) (sqrt var_forest *. 200.0);
  
  (* Exécuter les tests unitaires *)
  run_tests ()
