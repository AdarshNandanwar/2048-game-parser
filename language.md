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
## Grammer
### Current
```

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
																	$$ = val;
																}
		| identifier in_token COORDINATE						{throw_error("VALUE keyword expected."); $$ = -1;}
		| value_token identifier COORDINATE						{throw_error("IN keyword expected."); $$ = -1;}
		;
	
COORDINATE	: integer ',' integer								{
																	if($1 < 0 || $3 < 0){
																		if($1 < 0) throw_error("Row number can not be negative.");
																		if($3 < 0) throw_error("Column number can not be negative.");
																		$$ = make_coordinate(-1, -1);
																	} else {
																		$$ = make_coordinate($1, $3);
																	}
																}
			| float_token ',' integer							{$$ = make_coordinate(-1, -1); throw_error("Floating point numbers not allowed.");}
			| integer ',' float_token							{$$ = make_coordinate(-1, -1); throw_error("Floating point numbers not allowed.");}
			| float_token ',' float_token						{$$ = make_coordinate(-1, -1); throw_error("Floating point numbers not allowed.");}
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
### Removed
```
LINE	| identifier direction '.'								{throw_error("Invalid operation. Choose an operation among {\"ADD\", \"SUBTRACT\", \"MULTIPLY\", \"DIVIDE\"}.");}
		| identifier QUERY to_token COORDINATE '.'				{throw_error("\"ASSIGN\" keyword expected.");}
		| identifier identifier is_token COORDINATE '.'			{throw_error("\"VAR\" keyword expected.");}
		| identifier in_token COORDINATE '.'					{throw_error("\"VALUE\" keyword expected.");}
QUERY	| identifier in_token COORDINATE						{throw_error("\"VALUE\" keyword expected."); $$ = -1;}
```
## ToDo
## Doubts
- output format (spaces) for the variables if there are multiple present
- Do we print on stderr after a VALUE in command?	No
