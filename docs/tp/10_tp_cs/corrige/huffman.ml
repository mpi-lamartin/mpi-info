include Musique
include Arbre

let count_occ (part : partition) : (note * int) list =
  let rec maj_note note occ_liste acc =
    match occ_liste with
    | [] -> (note, 1)::acc
    | (n, occ)::tl when n = note -> (n, occ+1)::(acc@tl)
    | hd::tl -> maj_note note tl (hd::acc)
  in
  let rec parcours_notes cpt occ_liste =
    if cpt = Array.length part then
      occ_liste
    else
      let n = part.(cpt) in
      parcours_notes (cpt+1) (maj_note n occ_liste [])
  in
  (* permet d'avoir un encodage même si la note n'apparaît pas dans la partition analysee *)
  let init = [ (Do, 1); (Re, 1); (Mi, 1); (Fa, 1); (Sol, 1); (La, 1); (Si, 1) ] in
  parcours_notes 0 init

let algo_huffman part : arbre =
  let rec init file occ_liste =
    match occ_liste with
    | [] -> file
    | (note, occ)::tl ->
       let ab = creer_feuille note in
       init (FilePrio.add occ ab file) tl
  in
  let rec algo file =
    if FilePrio.est_singleton file then
      FilePrio.((recup_min file).ab)
    else
      let e1, e2, tl = FilePrio.extract_2_min file in
      let nv_arbre = fusion_arbres e1.FilePrio.ab e2.FilePrio.ab in
      let nv_prio = e1.FilePrio.prio + e2.FilePrio.prio in
      algo (FilePrio.add nv_prio nv_arbre tl)
  in
  let file = init (FilePrio.init ()) (count_occ part) in
  assert (not (FilePrio.est_vide file) && not (FilePrio.est_singleton file)) ;
  algo file

let dict_encodage part : (note, string) Hashtbl.t =
  let arb = algo_huffman part in
  let htbl = Hashtbl.create 7 in
  let rec parcours encod a =
    match a with
    | Leaf n -> Hashtbl.add htbl n encod
    | Node (a1, a2) ->
       parcours (encod^"0") a1 ;
       parcours (encod^"1") a2
  in
  parcours "" arb ;
  htbl

let encodage part dict_enc : string =
  let rec parcours cpt acc =
    if cpt = Array.length part then
      acc
    else
      let enc = Hashtbl.find dict_enc part.(cpt) in
      parcours (cpt+1) (acc^enc)
  in
  parcours 0 ""
