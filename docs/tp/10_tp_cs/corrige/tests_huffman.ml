include Huffman

let test_count () =
  let res = count_occ Musique.mus4 in
  List.iter
    (fun (note, occ) -> Printf.printf "%s -> %i\n" (Musique.note_vers_chaine note) occ)
    res

let test_huffman () =
  let _ = algo_huffman Musique.mus4 in
  ()

let test_dict_encodage () =
  let res = dict_encodage Musique.mus4 in
  Hashtbl.iter
    (fun note enc -> Printf.printf "%s -> %s\n" (Musique.note_vers_chaine note) enc)
    res

let test_encodage () =
  let dict = dict_encodage Musique.mus3 in
  Hashtbl.iter
    (fun note enc -> Printf.printf "%s -> %s\n" (Musique.note_vers_chaine note) enc)
    dict ;
  Musique.(afficher_partition mus4) ;
  print_newline () ;
  print_endline (encodage Musique.mus4 dict)

let () =
  test_count () ;
  test_huffman () ;
  Printf.printf "-- Question 16\n";
  test_dict_encodage () ;
  Printf.printf "-- Question 18\n";
  test_encodage () ;
  ()
