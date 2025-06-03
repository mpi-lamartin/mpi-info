include Plsc
include Musique

let test_tab () =
  let tab = tabPLSC mus1 mus3 in
  pp_tab tab

let test_lg () =
  Printf.printf "Longueur: %i\n" (lgPLSC mus1 mus3)

let test_plsc () =
  let ss = trouvePLSC mus1 mus3 in
  List.iter (fun n -> print_string (note_vers_chaine n)) ss ;
  print_newline ()

let test_lg () =
  Printf.printf "Longueur: %i\n" (lgPLSC mus5 mus6) ;
  let ss = trouvePLSC mus5 mus6 in
  List.iter (fun n -> print_string (note_vers_chaine n)) ss ;
  print_newline ()

let () =
  (* test_tab () ; *)
  (* test_lg () ; *)
  (* test_plsc () ; *)
  test_lg () ;
  ()
