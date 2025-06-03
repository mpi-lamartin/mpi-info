.PHONY: clean
.PRECIOUS: %.cmi %.cmo

main: main.ml musique.cmo
	ocamlc musique.cmo main.ml -o main

tests_rech: tests_rech.ml musique.cmo rech_naive.cmo
	ocamlc musique.cmo rech_naive.cmo $< -o $@

tests_plsc: tests_plsc.ml musique.cmo plsc.cmo
	ocamlc musique.cmo plsc.cmo tests_plsc.ml -o tests_plsc

tests_huffman: tests_huffman.ml musique.cmo arbre.cmo filePrio.cmo huffman.cmo
	ocamlc musique.cmo arbre.cmo filePrio.cmo huffman.cmo tests_huffman.ml -o tests_huffman

%.cmi : %.mli
	ocamlc -c $<

%.cmo : %.ml %.cmi
	ocamlc -c $<

clean:
	@rm -f *.cmi *.cmo main tests_rech tests_plsc tests_huffman
