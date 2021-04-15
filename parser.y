%{
/* C declarations used in actions */
void yyerror (char *s);
int yylex();
extern int yylineno;
extern char * yytext;
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <time.h>
#include <string.h>
#include "board.h"
#include "tile_name.h"
#include "common_header.h"
int DEBUG = 1;
int IS_ERROR = 0;
struct CoordinateStruct make_coordinate(int row, int col);
%}

/* Yacc definitions */
%locations
%code requires {
	struct CoordinateStruct{
		int row;
		int col;
	};
}
%union {
	int num;
	char id;
	char * str;
	struct CoordinateStruct coordinate;
}         
%start PROGRAM
%token <str> identifier
%token assign_token
%token to_token
%token var_token
%token is_token
%token value_token
%token in_token
%token float_token
%token end_of_file
%token <num> integer operator direction
%type <num> PROGRAM LINE QUERY KEYWORD
%type <coordinate> COORDINATE

%%

/* Grammer definitions */

PROGRAM	: PROGRAM LINE '\n'										{; yyerrok; YYACCEPT;}
		| PROGRAM error '.' '\n'								{throw_error("Invalid command."); yyerrok; YYACCEPT;}
		| PROGRAM error '\n'									{throw_error("Command must end with a full-stop."); yyerrok; YYACCEPT;}
		| end_of_file											{printf("EOF\n"); YYABORT;}
		| /* empty */											{;}
		;

LINE	: operator direction '.'								{make_move($1, $2);}
		| operator identifier '.'								{throw_error("Invalid direction. Choose a direction among {\"LEFT\", \"RIGHT\", \"UP\", \"DOWN\"}.");}
		| identifier direction '.'								{throw_error("Invalid operation. Choose an operation among {\"ADD\", \"SUBTRACT\", \"MULTIPLY\", \"DIVIDE\"}.");}
		| operator '.'											{throw_error("Direction not specified. Choose a direction among {\"LEFT\", \"RIGHT\", \"UP\", \"DOWN\"}.");}
		| direction '.'											{throw_error("Operation not specified. Choose an operation among {\"ADD\", \"SUBTRACT\", \"MULTIPLY\", \"DIVIDE\"}.");}
		
		| assign_token QUERY to_token COORDINATE '.'			{assign_value($2, $4.row-1, $4.col-1);}
		| assign_token QUERY identifier COORDINATE '.'			{throw_error("TO keyword expected.");}
		| identifier QUERY to_token COORDINATE '.'				{throw_error("ASSIGN keyword expected.");}

		| var_token identifier is_token COORDINATE '.'			{name_tile($2, $4.row-1, $4.col-1);}
		| var_token KEYWORD is_token COORDINATE '.'				{throw_error("Variable name can not be a keyword.");}
		| var_token identifier identifier COORDINATE '.'		{throw_error("IS keyword expected.");}
		| identifier identifier is_token COORDINATE '.'			{throw_error("VAR keyword expected.");}

		| value_token in_token COORDINATE '.'					{
																	int val = get_value($3.row-1, $3.col-1);
																	if(val != -1) printf("2048> Value in <%d,%d> is %d\n", $3.row, $3.col, val);
																}
		| identifier in_token COORDINATE '.'					{throw_error("VALUE keyword expected.");}
		| value_token identifier COORDINATE '.'					{throw_error("IN keyword expected.");}
		;

QUERY	: integer												{
																	if($1 < 0) throw_error("Tile value can only be a non-negative integer.");
																	$$ = $1;
																}
		| float_token											{throw_error("Tile value can only be a non-negative integer."); $$ = -1;}
		| value_token in_token COORDINATE						{
																	int val = get_value($3.row-1, $3.col-1); 
																	if(val != -1){
																		if(DEBUG) printf("2048> Value in <%d,%d> is %d\n", $3.row, $3.col, val);
																	}
																	$$ = val;
																}
		| identifier in_token COORDINATE						{throw_error("VALUE keyword expected."); $$ = -1;}
		| value_token identifier COORDINATE						{throw_error("IN keyword expected."); $$ = -1;}
		;
	
COORDINATE	: integer ',' integer								{
																	if($1 < 0 || $3 < 0){
																		if($1 < 0) printf("ERROR: Row number can not be negative.\n");
																		if($3 < 0) printf("ERROR: Column number can not be negative.\n");
																		$$ = make_coordinate(-1, -1);
																	} else {
																		$$ = make_coordinate($1, $3);
																	}
																}
			| float_token ',' integer							{$$ = make_coordinate(-1, -1); printf("ERROR: Floating point numbers not allowed.\n");}
			| integer ',' float_token							{$$ = make_coordinate(-1, -1); printf("ERROR: Floating point numbers not allowed.\n");}
			| float_token ',' float_token						{$$ = make_coordinate(-1, -1); printf("ERROR: Floating point numbers not allowed.\n");}
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
	printf("ERROR: Syntax error at token \"%s\".\n", (strcmp(yytext, "\n")?yytext:"\\n"));
} 

void throw_error(char * msg){
	printf("ERROR: %s\n", msg);
	fprintf(stderr, "-1\n");
}

struct CoordinateStruct make_coordinate(int row, int col){
	struct CoordinateStruct node;
	node.row = row;
	node.col = col;
	return node;
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