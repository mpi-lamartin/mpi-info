# Written by A. Grimaud
# March 2026

CC := gcc
CFLAGS := -Wall -MMD -MP

EXE := transports

SRC := main.c distance.c list.c graph.c ilist.c
OBJ := $(SRC:.c=.o)
DEP := $(SRC:.c=.d)

all: $(EXE)

$(EXE): $(OBJ)
	$(CC) $(OBJ) -o $@

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

-include $(DEP)

clean:
	rm -f $(OBJ) $(DEP) $(EXE) *~	
