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
int DEBUG = 0;
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
	double decimal;
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
%type <decimal> float_token

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
		| operator '.'											{throw_error("Direction not specified. Choose a direction among {\"LEFT\", \"RIGHT\", \"UP\", \"DOWN\"}.");}
		| direction '.'											{throw_error("Operation not specified. Choose an operation among {\"ADD\", \"SUBTRACT\", \"MULTIPLY\", \"DIVIDE\"}.");}
		
		| assign_token QUERY to_token COORDINATE '.'			{assign_value($2, $4.row-1, $4.col-1);}
		| assign_token to_token COORDINATE '.'					{throw_error("Value not specified. Please specify a non-negative integer value.");}
		| assign_token QUERY identifier COORDINATE '.'			{throw_error("Expected keyword \"TO\".");}

		| var_token identifier is_token COORDINATE '.'			{name_tile($2, $4.row-1, $4.col-1);}
		| var_token KEYWORD is_token COORDINATE '.'				{throw_error("Keyword can not be a variable name.");}
		| var_token KEYWORD COORDINATE '.'						{throw_error("Keyword can not be a variable name."); throw_error("Expected keyword \"IS\".");}
		| var_token identifier identifier COORDINATE '.'		{throw_error("Expected keyword \"IS\".");}

		| value_token in_token COORDINATE '.'					{
																	int val = get_value($3.row-1, $3.col-1);
																	if(val != -1) printf("2048> Value in <%d,%d> is %d\n", $3.row, $3.col, val);
																}
		| value_token identifier COORDINATE '.'					{throw_error("Expected keyword \"IN\".");}
		| value_token COORDINATE '.'							{throw_error("Expected keyword \"IN\".");}
		;

QUERY	: integer												{
																	if($1 < 0) throw_error("Tile value can only be a non-negative integer.");
																	$$ = $1;
																}
		| float_token											{throw_error("Tile value can only be a non-negative integer."); $$ = -1;}
		| value_token in_token COORDINATE						{
																	int val = get_value($3.row-1, $3.col-1);
																	$$ = val;
																}
		| value_token identifier COORDINATE						{throw_error("Expected keyword \"IN\"."); $$ = -1;}
		| value_token COORDINATE								{throw_error("Expected keyword \"IN\"."); $$ = -1;}
		;
	
COORDINATE	: integer ',' integer								{
																	if(check_negative($1, $3)){
																		$$ = make_coordinate($1, $3);
																	} else {
																		$$ = make_coordinate(-1, -1);
																	}
																}
			| float_token ',' integer							{$$ = make_coordinate(-1, -1); check_negative($1, $3); throw_error("Floating point numbers not allowed.");}
			| integer ',' float_token							{$$ = make_coordinate(-1, -1); check_negative($1, $3); throw_error("Floating point numbers not allowed.");}
			| float_token ',' float_token						{$$ = make_coordinate(-1, -1); check_negative($1, $3); throw_error("Floating point numbers not allowed.");}
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

void case_error_helper(){
	if(strcmp(yytext, "add") == 0) printf("Did you mean the keyword \"ADD\"?");
	if(strcmp(yytext, "subtract") == 0) printf("Did you mean the keyword \"SUBTRACT\"?");
	if(strcmp(yytext, "multiply") == 0) printf("Did you mean the keyword \"MULTIPLY\"?");
	if(strcmp(yytext, "divide") == 0) printf("Did you mean the keyword \"DIVIDE\"?");
	if(strcmp(yytext, "left") == 0) printf("Did you mean the keyword \"LEFT\"?");
	if(strcmp(yytext, "right") == 0) printf("Did you mean the keyword \"RIGHT\"?");
	if(strcmp(yytext, "up") == 0) printf("Did you mean the keyword \"UP\"?");
	if(strcmp(yytext, "down") == 0) printf("Did you mean the keyword \"DOWN\"?");
	if(strcmp(yytext, "assign") == 0) printf("Did you mean the keyword \"ASSIGN\"?");
	if(strcmp(yytext, "to") == 0) printf("Did you mean the keyword \"TO\"?");
	if(strcmp(yytext, "var") == 0) printf("Did you mean the keyword \"VAR\"?");
	if(strcmp(yytext, "is") == 0) printf("Did you mean the keyword \"IS\"?");
	if(strcmp(yytext, "value") == 0) printf("Did you mean the keyword \"VALUE\"?");
	if(strcmp(yytext, "in") == 0) printf("Did you mean the keyword \"IN\"?");
}

void yyerror(char * msg) {
	if(!strcmp(yytext, "\n")) return;
	if(IS_ERROR) printf("       Syntax error at token \"%s\". ", yytext);
	else printf("ERROR: Syntax error at token \"%s\". ", yytext);
	IS_ERROR = 1;
	case_error_helper();
	printf("\n");
} 

void throw_error(char * msg){
	if(IS_ERROR) printf("       %s\n", msg);
	else printf("ERROR: %s\n", msg);
	IS_ERROR = 1;
}

struct CoordinateStruct make_coordinate(int row, int col){
	struct CoordinateStruct node;
	node.row = row;
	node.col = col;
	return node;
}

int check_negative(double row, double col){
	// 0: invalid, 1: valid
	if(DEBUG) printf("\n%f %f\n", row, col);
	if(row < 0 || col < 0){
		if(row < 0) throw_error("Row number can not be negative.");
		if(col < 0) throw_error("Column number can not be negative.");
		return 0;
	}
	return 1;
}

int main (void) {
	srand(time(0));
	initialize_state(state);
	printf("#################################\n");
	printf("##       2048-game Engine      ##\n");
	printf("#################################\n\n");
	print_state();

	int status = 0, command_count = 0;
	while(!status){
		IS_ERROR = 0;
		printf("\n2048> Enter a command:\n");
		printf("----> ");
		status = yyparse();
		if(!status){
			// if not <<EOF>>
			command_count++;
			if(IS_ERROR){
				fprintf(stderr, "-1\n");
			} else{
				print_state();
				print_state_flat();
			}
			if(DEBUG) print_trie();
		}
		// printf("[break] status: %d\n", status);
	}
	printf("2048> Exiting. Total commands given: %d\n", command_count);
	return 0;
}