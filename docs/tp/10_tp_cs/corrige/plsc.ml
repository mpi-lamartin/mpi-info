let tabPLSC part1 part2 : int array array =
  let n1 = Array.length part1 in
  let n2 = Array.length part2 in
  let tab = Array.make_matrix (n1+1) (n2+1) 0 in
  let rec rempliTab i j =
    if i = (n1+1) then ()
    else if j = (n2+1) then rempliTab (i+1) 1
    else
      if part1.(i-1) = part2.(j-1) then
        (tab.(i).(j) <- tab.(i-1).(j-1) + 1 ;
         rempliTab i (j+1))
      else
        (tab.(i).(j) <- max tab.(i).(j-1) tab.(i-1).(j) ;
         rempliTab i (j+1))
  in
  rempliTab 1 1 ;
  tab

let pp_tab tab =
  Array.iter (fun a -> Array.iter print_int a ; print_newline ()) tab

let lgPLSC part1 part2 : int =
  let tab = tabPLSC part1 part2 in
  tab.(Array.length part1).(Array.length part2)

let trouvePLSC part1 part2 : Musique.note list =
  let tab = tabPLSC part1 part2 in
  let rec parcoursTab i j ss =
    if i = 0 || j = 0 then ss
    else
      if part1.(i-1) = part2.(j-1) then
        parcoursTab (i-1) (j-1) ((part1.(i-1))::ss)
      else
        if tab.(i).(j-1) > tab.(i-1).(j) then
          parcoursTab i (j-1) ss
        else
          parcoursTab (i-1) j ss
  in
  parcoursTab (Array.length part1) (Array.length part2) []
