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
void throw_error(char * msg);
%}

/* Yacc definitions */
%locations
%union {int num; char id; char * str;}         
%start PROGRAM
%token <str> identifier
%token assign_token
%token to_token
%token var_token
%token is_token
%token value_token
%token in_token
%token end_of_file
%token <num> number operator direction
%type <num> PROGRAM LINE QUERY KEYWORD

%%

/* Grammer definitions */

PROGRAM	: PROGRAM LINE '\n'										{; yyerrok; YYACCEPT;}
		| PROGRAM error '.' '\n'								{printf("ERROR: Invalid command\n"); yyerrok; fprintf(stderr, "-1\n"); YYACCEPT;}
		| PROGRAM error '\n'									{printf("ERROR: Command must end with a full-stop.\n"); yyerrok; fprintf(stderr, "-1\n"); YYACCEPT;}
		| end_of_file											{printf("EOF\n"); YYABORT;}
		| /* empty */											{;}
		;

LINE	: operator direction '.'									{make_move($1, $2);}
		| operator identifier '.'									{throw_error("Invalid direction. Choose a direction among {\"LEFT\", \"RIGHT\", \"UP\", \"DOWN\"}.");}
		| identifier direction '.'									{throw_error("Invalid operation. Choose an operation among {\"ADD\", \"SUBTRACT\", \"MULTIPLY\", \"DIVIDE\"}.");}
		| operator '.'												{throw_error("Direction not specified.");}
		| direction '.'												{throw_error("Operation not specified.");}
		
		| assign_token QUERY to_token number ',' number '.'			{assign_value($2, $4-1, $6-1);}

		| var_token identifier is_token number ',' number '.'		{name_tile($2, $4-1, $6-1);}
		| var_token KEYWORD is_token number ',' number '.'			{printf("ERROR: Variable name can not be a keyword\n"); fprintf(stderr, "-1\n");}

		| value_token in_token number ',' number '.'				{
																		int val = get_value($3-1, $5-1);
																		if(val != -1){
																			printf("2048> Value in <%d,%d> is %d\n", $3, $5, val);
																		} else {
																			printf("ERROR: Tile co-ordinates out of bounds. The tile co-ordinates must be in the range {1,2,3,4}.\n");
																			fprintf(stderr, "-1\n");
																		}
																	}
		;

QUERY	: number												{$$ = $1;}
		| value_token in_token number ',' number				{
																	int val = get_value($3-1, $5-1); 
																	if(val != -1){
																		if(DEBUG) printf("2048> Value in <%d,%d> is %d\n", $3, $5, val);
																	} else {
																		printf("ERROR: Tile co-ordinates out of bounds. The tile co-ordinates must be in the range {1,2,3,4}.\n");
																		fprintf(stderr, "-1\n");
																	}
																	$$ = val;
																}
		;

KEYWORD	: operator												{;}
		| direction												{;}
		| assign_token											{;}
		| to_token												{;}
		| var_token												{;}
		| is_token												{;}
		| value_token											{;}
		| in_token												{;}
		;

%%                     
/* C code */

void yyerror(char *s) {
	printf("ERROR: %s\n", s);
} 

void throw_error(char * msg){
	printf("ERROR: %s\n", msg);
	fprintf(stderr, "-1\n");
}

int main (void) {
	srand(time(0));
	initialize_state(state);
	printf("#################################\n");
	printf("##       2048-game Engine      ##\n");
	printf("#################################\n\n");
	print_state();

	int status = 0;
	while(!status){
		printf("\n2048> Enter a command:\n----> ");
		status = yyparse();
		printf("[break] status: %d\n", status);
	}
	return 0;
}