SRC=stack_string.s
OBJ=$(SRC:.s=.o)
BIN=$(SRC:.s=)
ASFLAGS=-g
CFLAGS=-g -nostartfiles -no-pie

all:
	as $(ASFLAGS) -o $(OBJ) $(SRC)
	gcc $(CFLAGS) -o $(BIN) $(OBJ)

clean:
	rm -f $(OBJ) $(BIN)

run: all
	./$(BIN)

.PHONY: all clean run
