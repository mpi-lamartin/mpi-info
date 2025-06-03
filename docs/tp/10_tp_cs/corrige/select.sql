SELECT * FROM artistes WHERE debut > 2000;
-- 17|Orelsan|2002|
-- 21|Lana Del Rey|2005|
-- 23|Woodkid|2006|
-- 27|alt-J|2007|
-- 32|Arctic Monkeys|2002|

SELECT nom FROM artistes WHERE fin IS NOT NULL and (fin-debut+1) >= 15;
-- Pink Floyd
-- Daft Punk
-- Michael Jackson
-- David Bowie
-- Serge Gainsbourg
-- Miles Davis

SELECT albums.nom FROM albums JOIN artistes ON albums.id_artiste = artistes.id WHERE artistes.nom = 'Pink Floyd';
-- The Dark Side of the Moon
-- The Wall
-- Wish You Were Here
-- Animals

SELECT artistes.nom, albums.nom, note FROM albums JOIN artistes on artistes.id = albums.id_artiste WHERE annee = 2001 ORDER BY note;
-- Muse|Origin of Symmetry|7.3
-- System of a down|Toxicity|7.3
-- Gorillaz|Gorillaz|7.4
-- Yann Tiersen|Le Fabuleux Destin d Amélie Poulain|7.5
-- Daft Punk|Discovery|7.8

SELECT AVG(note) FROM albums where annee >= 1990 and annee <= 2000;
-- 7.71666666666667

SELECT annee, COUNT(*) FROM albums WHERE annee >= 2005 GROUP BY annee;
-- 2005|1
-- 2006|1
-- 2009|1
-- 2011|1
-- 2012|2
-- 2013|3
-- 2017|1
