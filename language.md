# language
## Commands
```
ADD LEFT.
ADD RIGHT.
ADD UP.
ADD DOWN.
SUBTRACT LEFT.
SUBTRACT RIGHT.
SUBTRACT UP.
SUBTRACT DOWN.
MULTIPLY LEFT.
MULTIPLY RIGHT.
MULTIPLY UP.
MULTIPLY DOWN.
DIVIDE LEFT.
DIVIDE RIGHT.
DIVIDE UP.
DIVIDE DOWN.

ASSIGN <value> TO <x>,<y>.
VAR <varname> IS <x>,<y>.
VALUE IN <x>,<y>.
```
## Pattern
```
operation direction.
ASSIGN QUERY TO number,number.
VAR identifier IS number,number.
VALUE IN number,number.
```
## Grammer
### Old (PROGRAM version)
```

PROGRAM	: PROGRAM LINE '\n'										{; yyerrok; YYACCEPT;}
		| PROGRAM error '.' '\n'								{printf("[line %d] error: Invalid command\n", yylineno); yyerrok; fprintf(stderr, "-1\n"); YYACCEPT;}
		| PROGRAM error	'\n'									{printf("[line %d] error: Command must end with a full-stop.\n", yylineno); yyerrok; fprintf(stderr, "-1\n"); YYACCEPT;}
		| end_of_file											{printf("EOF\n"); YYABORT;}
		| /* empty */											{printf("empty_used\n");}
		;

LINE	: operator direction '.'								{make_move($1, $2);}
		| operator error '.'									{printf("[line %d] error: Invalid direction.\n", yylineno); fprintf(stderr, "-1\n");}
		| error direction '.'									{printf("[line %d] error: Invalid operator.\n", yylineno); fprintf(stderr, "-1\n");}

		| assign_token QUERY to_token number ',' number '.'		{assign_value($2, $4-1, $6-1);}
		| assign_token error to_token number ',' number '.'		{printf("[line %d] error: Invalid value. Please type an integer or a VALUE query.\n", yylineno); fprintf(stderr, "-1\n");}
		| assign_token QUERY to_token error '.'					{printf("[line %d] error: Invalid tile co-ordinates. Please type co-ordinates in the format \"<row>,<col>\".\n", yylineno); fprintf(stderr, "-1\n");}

		| var_token identifier is_token number ',' number '.'	{name_tile($2, $4-1, $6-1);}
		| var_token KEYWORD is_token number ',' number '.'		{printf("[line %d] error: Variable name can not be a keyword\n", yylineno); fprintf(stderr, "-1\n");}
		| var_token error is_token number ',' number '.'		{printf("[line %d] error: Illegal variable name. The variable name is a single word containing only alphanumeric characters and underscores\n", yylineno); fprintf(stderr, "-1\n");}
		| var_token identifier is_token error '.'				{printf("[line %d] error: Invalid tile co-ordinates. Please type co-ordinates in the format \"<row>,<col>\".\n", yylineno); fprintf(stderr, "-1\n");}

		| value_token in_token number ',' number '.'			{
																	int val = get_value($3-1, $5-1);
																	if(val != -1){
																		printf("2048> Value in <%d,%d> is %d\n", $3, $5, val);
																	} else {
																		printf("[line %d] error: Tile co-ordinates out of bounds. The tile co-ordinates must be in the range {1,2,3,4}.\n", yylineno);
																		fprintf(stderr, "-1\n");
																	}
																}
		| value_token in_token error '.'						{printf("[line %d] error: Invalid tile co-ordinates. Please type co-ordinates in the format \"<row>,<col>\".\n", yylineno); fprintf(stderr, "-1\n");}
		;

QUERY	: number												{$$ = $1;}
		| value_token in_token number ',' number				{
																	int val = get_value($3-1, $5-1); 
																	if(val != -1){
																		if(DEBUG) printf("2048> Value in <%d,%d> is %d\n", $3, $5, val);
																	} else {
																		printf("[line %d] error: Tile co-ordinates out of bounds. The tile co-ordinates must be in the range {1,2,3,4}.\n", yylineno);
																		fprintf(stderr, "-1\n");
																	}
																	$$ = val;
																}
		| value_token in_token error							{printf("[line %d] error: Invalid tile co-ordinates. Please type co-ordinates in the format \"<row>,<col>\".\n", yylineno); fprintf(stderr, "-1\n");}
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

```

## ToDo
- fix writing only integers
- code the variables logic
- show verbose errors
- default syntax errors
- seperate the modules completely by passing **
## Doubts
- should variable names be unique?
- variable names consists of what all ASCII codes (for trie)?
- **How can you name an empty tile?**
- output format (spaces) for the variables if there are multiple present
- make `\n` a part of the grammer?
- 1.1 part 2
- is variable to value mapping required?
- 
yynowrap -> lexer
yyaccept -> parser
- `printf("[line %d %d %d %d]", @$.first_line, @$.last_line, @$.first_column, @$.last_column); `
## Doubt class
- `Do we print on stderr after a VALUE in command??	No`
- focus on the syntax directed translation scheme and not on the interpretation.
- You can name mepty tile. It will get merged in the next non-empty tile in the direction of the move
- You can give custom errors
- All interpretations will be given marks
- one line will not contain more than 1 command.
- 2 0 0 2 ADD LEFT. -> 4 0 0 0
	- if tile 2 has name "a" and tile 4 has name "b", then after move, tile 1 will have both "a" and "b".
- OR zero tiles will have no names and this is handled in the interpretation part.
## Line by line parse
yynowrap -> lexer
yyaccept -> parser
###
- `<<EOF>>                                 {return end_of_file;}`
- add `%option noyywrap ` in .lex
- comment `yywrap()` defination.
- add `YYACCEPT` in first 3 productions of `PROGRAM`
- add `YYABORT` in eof production of `PROGRAM`