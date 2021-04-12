%{
#include "y.tab.h"
void yyerror (char *s);
int yylex();
%}
%%
"ADD"|"SUBTRACT"|"MULTIPLY"|"DIVIDE"    {printf("keyword "); yylval.id = yytext[0]; return operator;}
"UP"|"DOWN"|"LEFT"|"RIGHT"              {printf("keyword "); yylval.id = yytext[0]; return direction;}
"ASSIGN"                                {printf("keyword "); return assign_token;}
"TO"                                    {printf("keyword "); return to_token;}
"VAR"                                   {printf("keyword "); return var_token;}
"IS"                                    {printf("keyword "); return is_token;}
"VALUE"                                 {printf("keyword "); return value_token;}
"IN"                                    {printf("keyword "); return in_token;}
[0-9]+                                  {printf("integer "); yylval.num = atoi(yytext); return number;}
[a-zA-Z][a-zA-Z0-9]*                    {printf("identifier "); yylval.str = strdup(yytext); return identifier;}
,                                       {printf("comma "); return comma_token;}
\.                                      {printf("end\n"); return line_end;}
[ \t\n]                                 {;}
.                                       {yyerror("unexpected character");}

%%

int yywrap(void){
    return 1;
}