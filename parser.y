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

PROGRAM	: PROGRAM LINE '.' '\n'									{;}
		| PROGRAM error '.' '\n'								{printf("[line %d] invalid command\n", yylineno-1); yyerrok;}
		| PROGRAM error	'\n'									{printf("[line %d] You need to end the command with a full-stop.\n", yylineno-1);}
		| /* empty */											{;}
		;

LINE	: operator direction									{make_move($1, $2);}
		| assign_token QUERY to_token number ',' number			{assign_value($2, $4-1, $6-1);}
		| var_token identifier is_token number ',' number		{name_tile($2, $4-1, $6-1);}
		| value_token in_token number ',' number				{printf("value in <%d,%d> is %d\n", $3, $5, get_value($3-1, $5-1));}
		;

QUERY	: number												{$$ = $1;}
		| value_token in_token number ',' number				{int val = get_value($3-1, $5-1); if(DEBUG) printf("value in <%d,%d> is %d\n", $3, $5, val); $$ = val;}
		;

%%                     
/* C code */

void yyerror(char *s) {
	printf("[line %d] error: %s\n", yylineno, s);
} 

int main (void) {
	srand(time(0));
	initialize_state(state);
	return yyparse();
}