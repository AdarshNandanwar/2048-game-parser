%{
#include "parser.tab.h"
#include "common_header.h"
void yyerror (char *s);
int yylex();
extern int DEBUG;
%}
%option noyywrap
%option yylineno
%%
"ADD"|"SUBTRACT"|"MULTIPLY"|"DIVIDE"    {if(DEBUG) printf("keyword "); yylval.id = yytext[0]; return operator;}
"UP"|"DOWN"|"LEFT"|"RIGHT"              {if(DEBUG) printf("keyword "); yylval.id = yytext[0]; return direction;}
"ASSIGN"                                {if(DEBUG) printf("keyword "); return assign_token;}
"TO"                                    {if(DEBUG) printf("keyword "); return to_token;}
"VAR"                                   {if(DEBUG) printf("keyword "); return var_token;}
"IS"                                    {if(DEBUG) printf("keyword "); return is_token;}
"VALUE"                                 {if(DEBUG) printf("keyword "); return value_token;}
"IN"                                    {if(DEBUG) printf("keyword "); return in_token;}
[-+]?[0-9]+\.[0-9]+                     {if(DEBUG) printf("float "); yylval.decimal = atof(yytext); return float_token;}
[-+]?[0-9]+                             {if(DEBUG) printf("integer "); yylval.num = atoi(yytext); return integer;}
[a-zA-Z_][a-zA-Z0-9_]*                  {if(DEBUG) printf("identifier "); yylval.str = strdup(yytext); return identifier;}
[,.]                                    {if(DEBUG) printf("%c ", yytext[0]); return yytext[0];}
[\n]                                    {if(DEBUG) printf("\\n\n"); return yytext[0];}
[ \t]                                   { /* ignore */}
.                                       {
                                            if(DEBUG) printf("unexpected_character "); 
                                            char * msg = (char *) malloc(32*sizeof(char));
                                            sprintf(msg, "Unexpected character '%c'.", yytext[0]);
                                            throw_error(msg);
                                        }
<<EOF>>                                 {return end_of_file;}
%%