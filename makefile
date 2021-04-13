2048: lex.yy.c y.tab.c board.o tile_name.o
	gcc -g lex.yy.c y.tab.c board.o tile_name.o -o 2048

lex.yy.c: y.tab.c lexer.l
	lex lexer.l

y.tab.c: parser.y
	yacc -d parser.y

board.o: board.c
	gcc -c board.c -o board.o

tile_name.o: tile_name.c
	gcc -c tile_name.c -o tile_name.o

clean: 
	rm -rf tile_name.o board.o lex.yy.c y.tab.c y.tab.h 2048

run:
	./2048