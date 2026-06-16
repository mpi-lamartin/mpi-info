#use "reines_cor.ml";;

let assert_equal_int label expected actual =
  if expected <> actual then
    failwith
      (Printf.sprintf "%s: attendu %d, obtenu %d" label expected actual)

let assert_equal_pair label (expected_a, expected_b) (actual_a, actual_b) =
  if expected_a <> actual_a || expected_b <> actual_b then
    failwith
      (Printf.sprintf "%s: attendu (%d, %d), obtenu (%d, %d)" label expected_a
         expected_b actual_a actual_b)

let assert_true label condition =
  if not condition then failwith (label ^ ": condition fausse")

let test_couverture () =
  let c = creer_couverture 4 in
  assert_equal_int "z initial" 16 c.z;
  assert_true "couverture initiale incomplète" (not (finale c));
  mise_a_jour c 1 1 1;
  assert_equal_int "z après ajout" 4 c.z;
  assert_equal_int "case reine" 1 c.m.(1).(1);
  assert_equal_int "case couverte ligne" 1 c.m.(1).(3);
  assert_equal_int "case couverte colonne" 1 c.m.(3).(1);
  assert_equal_int "case couverte diagonale" 1 c.m.(2).(2);
  mise_a_jour c 1 1 (-1);
  assert_equal_int "z après suppression" 16 c.z;
  assert_true "retour à la matrice vide" (c.m.(0).(0) = 0 && c.m.(3).(3) = 0)

let test_recherche_exacte () =
  assert_equal_int "minimum n=1" 1 (couverture_par_reines 1);
  assert_equal_int "minimum n=4" 3 (couverture_par_reines 4);
  assert_equal_int "minimum n=5" 3 (couverture_par_reines 5);
  assert_equal_int "minimum n=6" 4 (couverture_par_reines 6)

let test_positions () =
  let r, pos = couverture_par_reines_positions 5 in
  assert_equal_int "taille solution n=5" 3 r;
  assert_equal_int "nombre de positions n=5" 3 (List.length pos)

let test_comptage () =
  assert_equal_pair "n=4 minimum et nombre" (3, 16)
    (couverture_par_reines_nombre_solutions 4);
  assert_equal_pair "n=5 minimum et nombre" (3, 16)
    (couverture_par_reines_nombre_solutions 5)

let test_choix_position () =
  assert_equal_int "aucune case libre" (-1) (choix_position [| 1; 2; 3 |]);
  let j = choix_position [| 1; 0; 4; 0 |] in
  assert_true "indice aléatoire valide" (j = 1 || j = 3)

let () =
  Random.init 0;
  test_couverture ();
  test_recherche_exacte ();
  test_positions ();
  test_comptage ();
  test_choix_position ();
  print_endline "Tests reines OK"
