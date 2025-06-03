
(* Incrémente de un la valeur associée à la clé `x` dans la table de
   hachage `h`. Une clé non présente a pour valeur associée `0`. *)
let add_one h x =
  (* À modifier *)
  ()

(* Applique la fonction `f` sur chaque ligne du ficher de nom
   `file_name`. *)
let file_iter f file_name =
  (* À modifier *)
  ()

(* Met à jour la table de hachage `h` avec toutes les occurrences des
   `k`-mers présent dans la chaîne de caractères `seq`. *)
let build_seq k h seq =
  (* À modifier *)
  ()

(* Construit une table de hachage qui dénombre le nombre d'occurrences
   de chaque `k`-mer dans un fichier de séquences. *)
let build file_name k =
  let h = Hashtbl.create 1 in
  file_iter (build_seq k h) file_name;
  h

(* Supprime de la table de hachage `h` toutes les liaisons ayant pour
   valeur `v` *)
let delete_all h v =
  (* À modifier *)
  ()

let main () =
  if Array.length Sys.argv <> 3 then begin
    Printf.eprintf "usage: %s file.seq k\n" Sys.argv.(0);
    exit 1
  end;
  let file_name = Sys.argv.(1) in
  let k = int_of_string Sys.argv.(2) in
  let h = build file_name k in
  let l0 = Hashtbl.length h in
  Printf.printf "** %8d\n" l0;
  for i = 1 to 9 do
    delete_all h i;
    let li = Hashtbl.length h in
    Printf.printf ">%d %8d (%.2f %%)\n" i li (100. *. float li /. float l0)
  done

let () = main ()
