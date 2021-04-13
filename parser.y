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
void print_state();
void assign_value(int val, int row, int col);
void name_tile(char * name, int row, int col);
int get_value(int row, int col);
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
%type <num> LINE QUERY

%%

/* Grammer definitions */

LINE	: operator direction line_end												{make_move($1, $2);}
		| assign_token QUERY to_token number comma_token number line_end			{assign_value($2, $4-1, $6-1);}
		| var_token identifier is_token number comma_token number line_end			{name_tile($2, $4-1, $6-1);}
		| QUERY line_end																	{;}
		| LINE operator direction line_end											{make_move($2, $3);}
		| LINE assign_token QUERY to_token number comma_token number line_end		{assign_value($3, $5-1, $7-1);}
		| LINE var_token identifier is_token number comma_token number line_end		{name_tile($3, $5-1, $7-1);}
		| LINE QUERY line_end																{;}
		;

QUERY	: number																	{$$ = $1;}
		| value_token in_token number comma_token number							{int val = get_value($3-1, $5-1); printf("value in <%d, %d> is %d\n", $3, $5, val); $$ = val;}
		;

%%                     
/* C code */
int main (void) {
	srand(time(0));
	initialize_state(state);
	return yyparse();
}


void assign_value(int val, int row, int col){
	if(0<=row && row<4 && 0<=col && col<4){
		state[row][col] = val;
		print_state(state);
	} else {
		fprintf(stderr, "There is no tile like that. The tile co-ordinates must be in the range 1,2,3,4.\n");
	}
}

void name_tile(char * name, int row, int col){
	if(0<=row && row<4 && 0<=col && col<4){
		print_state(state);
		printf("<%d, %d> is now named %s.\n", row, col, name);
	} else {
		fprintf(stderr, "There is no tile like that. The tile co-ordinates must be in the range 1,2,3,4.\n");
	}
}

int get_value(int row, int col){
	// remove this function. This is for testing only. this is supposed to be a non-terminal
	if(0<=row && row<4 && 0<=col && col<4){
		return state[row][col];
	} else {
		fprintf(stderr, "There is no tile like that. The tile co-ordinates must be in the range 1,2,3,4.\n");
	}
}

void yyerror(char *s) {
	fprintf(stderr, "%s\n", s);
} 

// board operations

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

void shift_left(){
    for(int i = 0; i<4; i++){
        int left = 0;
        for(int j = 0; j<4; j++){
            if(state[i][j] != -1) state[i][left++] = state[i][j];
        }
        for(;left<4; left++){
            state[i][left] = -1;
        }
    }
}

void operate_left(char oper){
    for(int i = 0; i<4; i++){
        int left = -1;
        int left_value = -1;
        for(int j = 0; j<4; j++){
            if(state[i][j] != -1){
                if(left >= 0 && left_value >= 0 && state[i][j] == left_value){
                    switch(oper){
                        case 'A': state[i][left] += state[i][j]; break;
                        case 'S': state[i][left] -= state[i][j]; break;
                        case 'M': state[i][left] *= state[i][j]; break;
                        case 'D': state[i][left] /= state[i][j]; break;
                    }
					state[i][j] = -1; 
                }
                left = j;
                left_value = state[i][j];
            } 
        }
    }
}

void transpose(){
	for(int i = 0; i<4; i++){
		for(int j = 0; j<i; j++){
			int temp = state[i][j];
			state[i][j] = state[j][i];
			state[j][i] = temp;
		}
	}
}

void mirror(){
	for(int i = 0; i<4; i++){
		for(int j = 0; j<4/2; j++){
			int temp = state[i][j];
			state[i][j] = state[i][4-1-j];
			state[i][4-1-j] = temp;
		}
	}
}

void make_move(char oper, char dir){
	printf("\nMoving %c using %c\n", dir, oper);
	switch(dir){
		case 'L': {
			shift_left();
			operate_left(oper);
			shift_left();
			break;
		}
		case 'R': {
			mirror();
			shift_left();
			operate_left(oper);
			shift_left();
			mirror();
			break;
		}
		case 'U': {
			transpose();
			shift_left();
			operate_left(oper);
			shift_left();
			transpose();
			break;
		}
		case 'D': {
			transpose();
			mirror();
			shift_left();
			operate_left(oper);
			shift_left();
			mirror();
			transpose();
			break;
		}
	}
	insert_random_tile();
	print_state();
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