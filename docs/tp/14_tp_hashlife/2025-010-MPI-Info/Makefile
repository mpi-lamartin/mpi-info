OPTIONS = -Wall -Wextra -pedantic -g -fsanitize=address
OPTIONS_FAST = -Wall -Wextra -pedantic -g -O3

all: safe

safe: quadtree.c hashlife.c
	gcc $(OPTIONS) hashlife.c quadtree.c -o life

fast: quadtree.c hashlife.c
	gcc $(OPTIONS_FAST) hashlife.c quadtree.c -o life

clean:
	rm -rf *.o
