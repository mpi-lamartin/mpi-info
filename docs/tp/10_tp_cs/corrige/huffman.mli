val count_occ : Musique.partition -> (Musique.note * int) list

val algo_huffman : Musique.partition -> Arbre.arbre

val dict_encodage : Musique.partition -> (Musique.note, string) Hashtbl.t

val encodage : Musique.partition -> (Musique.note, string) Hashtbl.t -> string
