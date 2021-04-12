%{
/* C declarations used in actions */
void yyerror (char *s);
int yylex();
#include <stdio.h>     
#include <stdlib.h>
#include <ctype.h>
#include <time.h>
int state[4][4];
void initialize_state();
void insert_random_tile();
void make_move(char oper, char dir);
void assign_value(int val, int row, int col);
void name_tile(char * name, int row, int col);
void get_value(int row, int col);
void print_state();
%}

/* Yacc definitions */
%union {int num; char id; char * str;}         
%start LINE
%token <str> identifier
%token line_end
%token assign_token
%token comma_token
%token to_token
%token var_token
%token is_token
%token value_token
%token in_token
%token <num> number operator direction
%type <num> LINE

%%

/* Grammer definitions */

LINE	: operator direction line_end												{make_move($1, $2);}
		| assign_token number to_token number comma_token number line_end			{assign_value($2, $4-1, $6-1);}
		| var_token identifier is_token number comma_token number line_end			{name_tile($2, $4-1, $6-1);}
		| value_token in_token number comma_token number line_end					{get_value($3-1, $5-1);}
		| LINE operator direction line_end											{make_move($2, $3);}
		| LINE assign_token number to_token number comma_token number line_end		{assign_value($3, $5-1, $7-1);}
		| LINE var_token identifier is_token number comma_token number line_end		{name_tile($3, $5-1, $7-1);}
		| LINE value_token in_token number comma_token number line_end				{get_value($4-1, $6-1);}
		;

%%                     
/* C code */
int main (void) {
	srand(time(0));
	initialize_state();
	return yyparse( );
}

void make_move(char oper, char dir){
	printf("\nMoving %c using %c\n", dir, oper);
	print_state();
}

void initialize_state(){
	for(int i = 0; i<4; i++){
		for(int j = 0; j<4; j++){
			state[i][j] = -1;
		}
	}
	insert_random_tile();
	insert_random_tile();
	print_state();
}

void insert_random_tile(){
	int free_tiles = 0;
	for(int i = 0; i<4; i++){
		for(int j = 0; j<4; j++){
			if(state[i][j] == -1){
				free_tiles++;
			}
		}
	}
	if(free_tiles == 0){
		// game over
		return;
	}
	int pos = rand()%free_tiles;
	int val = rand()%2;
	int offset = -1;
	for(int i = 0; i<4; i++){
		for(int j = 0; j<4; j++){
			if(state[i][j] == -1){
				offset++;
			}
			if(offset == pos){
				state[i][j] = (val?2:4);
				return;
			}
		}
	}
}

void print_state(){
	printf("\n---------------------------------\n");
	for(int i = 0; i<4; i++){
		for(int j = 0; j<4; j++){
			if(state[i][j] == -1){
				printf("|\t");
			} else {
				printf("|%d\t", state[i][j]);
			}
		}
		printf("|\n---------------------------------\n");
	}
}

void assign_value(int val, int row, int col){
	if(0<=row && row<4 && 0<=col && col<4){
		state[row][col] = val;
		print_state();
	} else {
		fprintf(stderr, "There is no tile like that. The tile co-ordinates must be in the range 1,2,3,4.\n");
	}
}

void name_tile(char * name, int row, int col){
	if(0<=row && row<4 && 0<=col && col<4){
		print_state();
		printf("<%d, %d> is now named %s.\n", row, col, name);
	} else {
		fprintf(stderr, "There is no tile like that. The tile co-ordinates must be in the range 1,2,3,4.\n");
	}
}

void get_value(int row, int col){
	// remove this function. This is for testing only. this is supposed to be a non-terminal
	if(0<=row && row<4 && 0<=col && col<4){
		print_state();
		printf("%d\n", state[row][col]);
	} else {
		fprintf(stderr, "There is no tile like that. The tile co-ordinates must be in the range 1,2,3,4.\n");
	}
}

void yyerror(char *s) {
	fprintf(stderr, "%s\n", s);
} 