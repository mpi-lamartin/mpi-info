type elt = { prio : int ; ab : Arbre.arbre }

type file = elt list

val init : unit -> file

val add : int -> Arbre.arbre -> file -> file

val recup_min : file -> elt

val extract_2_min : file -> elt * elt * file

val est_vide : file -> bool
val est_singleton : file -> bool
