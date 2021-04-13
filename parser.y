%{
/* C declarations used in actions */
void yyerror (char *s);
int yylex();
extern int yylineno;
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <time.h>
#include "board.h"
#include "tile_name.h"
int DEBUG = 0;
%}

/* Yacc definitions */
%union {int num; char id; char * str;}         
%start PROGRAM
%token <str> identifier
%token assign_token
%token to_token
%token var_token
%token is_token
%token value_token
%token in_token
%token <num> number operator direction
%type <num> PROGRAM LINE QUERY

%%

/* Grammer definitions */

PROGRAM	: PROGRAM LINE '\n'										{;}
		| PROGRAM error '.' '\n'								{printf("Syntax error.\n"); yyerrok; fprintf(stderr, "-1\n");}
		| PROGRAM error	'\n'									{printf("You need to end the command with a full-stop.\n"); fprintf(stderr, "-1\n");}
		| /* empty */											{;}
		;

LINE	: operator direction '.'								{make_move($1, $2);}
		| assign_token QUERY to_token number ',' number '.'		{assign_value($2, $4-1, $6-1);}
		| var_token identifier is_token number ',' number '.'	{name_tile($2, $4-1, $6-1);}
		| value_token in_token number ',' number '.'			{
																	int val = get_value($3-1, $5-1);
																	if(val != -1){
																		printf("Value in <%d,%d> is %d\n", $3, $5, val);
																	} else {
																		printf("There is no tile like that. The tile co-ordinates must be in the range 1,2,3,4.\n");
																		fprintf(stderr, "-1\n");
																	}
																}
		;

QUERY	: number												{$$ = $1;}
		| value_token in_token number ',' number				{
																	int val = get_value($3-1, $5-1); 
																	if(val != -1){
																		if(DEBUG) printf("Value in <%d,%d> is %d\n", $3, $5, val);
																	} else {
																		printf("There is no tile like that. The tile co-ordinates must be in the range 1,2,3,4.\n");
																		fprintf(stderr, "-1\n");
																	}
																	$$ = val;
																}
		;

%%                     
/* C code */

void yyerror(char *s) {
	// printf("[line %d] error: %s\n", yylineno, s);
	printf("Sorry, I don’t understand that.\n");
} 

int main (void) {
	srand(time(0));
	initialize_state(state);
	printf("Hi, I am the 2048-game Engine.\n");
	print_state();
	return yyparse();
}