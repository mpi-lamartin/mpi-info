let tests_naif () =
  assert (Rech_naive.recherche [|Do; Mi|] Musique.mus1 = 0) ;
  assert (Rech_naive.recherche [|Mi; Fa|] Musique.mus1 = 1) ;
  assert (Rech_naive.recherche [| |] Musique.mus2 = 0) ;
  assert (Rech_naive.recherche [|Fa; Sol|] Musique.mus1 = -1) ;
  assert (Rech_naive.recherche [|Do; Re; Mi; Fa; Sol|] Musique.mus1 = -1) ;
  ()

let () =
  tests_naif ()
