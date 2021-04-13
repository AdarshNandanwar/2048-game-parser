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
```
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
- can you name an empty tile?
- output format (spaces) for the variables if there are multiple present
- make `\n` a part of the grammer?
- 1.1 part 2