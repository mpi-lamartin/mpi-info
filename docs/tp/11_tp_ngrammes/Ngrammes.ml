(* Un modèle est une table de hachage de tableaux d'occurrences. Les tableaux sont de taille
   129, car la dernière case permet de garder en mémoire le nombre total d'occurrences pour
   éviter de le recalculer à chaque fois (c'est la somme des 128 cases précédentes). On 
   suppose que le texte d'apprentissage est non vide, donc il y a des successeurs au
   0-gramme. *)

let read_file filename = 
    let lines = ref "" in
    let chan = open_in filename in
    try
      while true; do
        lines := input_line chan ^ !lines
      done; !lines
    with End_of_file ->
      close_in chan;
      !lines ;;

let _K = 128

type modele = (string, int array) Hashtbl.t

let _ = Random.self_init ()

let init_modele s _N : modele =
    let modele = Hashtbl.create 1 in
    for k = 0 to _N do
        (* Pour chaque taille de k-grammes *)
        for i = 0 to String.length s - 1 - k do
            (* Pour chaque indice de début d'un k-gramme, on détermine ce k-gramme,
               le code du caractère qui suit, on crée nouveau tableau de 0 dans la
               table de hachage s'il n'y en a pas déjà un, et on incrémente les deux
               bonnes cases. *)
            let kgramme = String.sub s i k in
            let code = Char.code s.[i + k] in
            if not (Hashtbl.mem modele kgramme) then 
               Hashtbl.add modele kgramme (Array.make (_K + 1) 0);
            let occ = Hashtbl.find modele kgramme in
            occ.(code) <- occ.(code) + 1;
            occ.(_K) <- occ.(_K) + 1
        done
    done;
    modele

let prediction modele ngramme =
    let k = ref (String.length ngramme) and
        kgramme = ref ngramme in
    while not (Hashtbl.mem modele !kgramme) do
        (* Tant qu'on n'a pas trouvé un k-gramme présent dans le modèle, on enlève
           la première lettre. On suppose qu'il existe au moins la chaîne vide. *)
        decr k;
        kgramme := String.sub !kgramme 1 !k
    done;
    let t = Hashtbl.find modele !kgramme in
    (* On tire ensuite un entier aléatoire, et on renvoie le caractère correspondant
       à ce numéro d'occurrence. *)
    let alea = Random.int t.(_K) in
    let nb_occ = ref 0 and i = ref (-1) in
    while !nb_occ <= alea do
        incr i;
        nb_occ := !nb_occ + t.(!i)
    done;
    Char.chr !i

let generation modele _N graine taille =
    let gen = ref graine in
    let len = ref (String.length graine) in
    while !len < taille do
        let m = min !len _N in
        let ngramme = String.sub !gen (!len - m) m in
        gen := !gen ^ (String.make 1 (prediction modele ngramme));
        incr len
    done;
    !gen

let cid = "O rage ! o desespoir ! o vieillesse ennemie ! N'ai-je donc tant vecu que pour cette infamie ? Et ne suis-je blanchi dans les travaux guerriers Que pour voir en un jour fletrir tant de lauriers ? Mon bras qu'avec respect tout l'Espagne admire, Mon bras, qui tant de fois a sauve cet empire, Tant de fois affermi le trone de son roi, Trahit donc ma querelle, et ne fait rien pour moi ? O cruel souvenir de ma gloire passee ! Oeuvre de tant de jours en un jour effacee ! Nouvelle dignite fatale a mon bonheur ! Precipice eleve d'ou tombe mon honneur ! Faut-il de votre eclat voir triompher Le Comte, Et mourir sans vengeance, ou vivre dans la honte ? Comte, sois de mon prince a present gouverneur ; Ce haut rang n'admet point un homme sans honneur ; Et ton jaloux orgueil par cet affront insigne Malgre le choix du roi, m'en a su rendre indigne. Et toi, de mes exploits glorieux instrument, Mais d'un corps tout de glace inutile ornement, Fer, jadis tant a craindre, et qui, dans cette offense, M'as servi de parade, et non pas de defense, Va, quitte desormais le derniers des humains, Passe, pour me venger, en de meilleurs mains."

(* let cid = read_file "cid.txt" *)

let test _N = 
    let modele = init_modele cid _N in
    let gen = generation modele _N "" 1000 in
    Printf.printf "%s\n" gen

let init_modele2 s _N nb_fils : modele =
    let modele = Hashtbl.create 1 and mutex = Mutex.create () in
    let len = String.length s in
    let init_fil (deb, fin) =
        (* Fonction qui prend en argument une tranche de texte et se charge
           de remplir le modèle. *)        
        for k = 0 to _N do
            (* Pour chaque taille de k-grammes *)
            for i = deb to min (len - 1 - k) (fin - 1) do
                (* Pour chaque indice de début de k-grammes (c'est-à-dire tel qu'on
                   ne dépassera pas la fin de la chaîne) *)
                let kgramme = String.sub s i k in
                let code = Char.code s.[i + k] in
                if not (Hashtbl.mem modele kgramme) then begin
                    Mutex.lock mutex;
                    (* On vérifie à nouveau que le k-gramme n'a pas été rajouté
                       le temps de verrouiller le mutex. *)
                    if not (Hashtbl.mem modele kgramme) then
                        Hashtbl.add modele kgramme (Array.make (_K + 1) 0, Mutex.create ());
                    Mutex.unlock mutex
                end;
                let (occ, mut) = Hashtbl.find modele kgramme in
                (* On verrouille le mutex avant la modification. *)
                Mutex.lock mut;
                occ.(code) <- occ.(code) + 1;
                occ.(_K) <- occ.(_K) + 1;
                Mutex.unlock mut
            done
        done
    in
    let indices i = ((i * len) / nb_fils, ((i + 1) * len) / nb_fils) in
    let fils = Array.init nb_fils (fun i -> Thread.create init_fil (indices i)) in
    Array.iter Thread.join fils;
    (* On recrée la table sans les mutex. *)
    let sans_mutex = Hashtbl.create 1 in
    Hashtbl.iter (fun kgramme (occ, mut) -> Hashtbl.add sans_mutex kgramme occ) modele;
    sans_mutex

let test2 _N = 
    let modele = init_modele2 cid _N 4 in
    let gen = generation modele _N "" 1000 in
    Printf.printf "%s\n" gen

let _ = test2 4