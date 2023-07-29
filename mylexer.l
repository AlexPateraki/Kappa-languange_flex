%{
#include <assert.h>
#include <stdio.h>
#include <string.h>
#include "cgen.h"
#include "myanalyzer.tab.h"

int line_num = 1;

%}

IDENTIFIER [a-zA-Z_][0-9a-zA-Z_]*
DIGIT   [0-9]
INTEGER [+-]?{DIGIT}{DIGIT}*
SCALAR {INTEGER}("."{DIGIT}+)?([eE][+-]?{INTEGER})?
MARK \"
ESCAPE_CH [\n\t\r\\\"]
SYMBOL [-+*/:_$%!#@&~,^()]
STRING  ({MARK}({ESCAPE_CH}|[^{MARK}])*(\\{ESCAPE_CH}|[^{MARK}])){MARK}

%x comment

%%
integer     {fprintf(stderr,"Token KEYWORD_INTEGER: \t\t%s\n",yytext);return KW_INTEGER;}
False       {fprintf(stderr,"Token KEYWORD_FALSE: \t\t%s\n",yytext);return KW_FALSE;}
for         {fprintf(stderr,"Token KEYWORD_FOR: \t\t%s\n",yytext);return KW_FOR;}
break       {fprintf(stderr,"Token KEYWORD_BREAK: \t\t%s\n",yytext);return KW_BREAK;}
def        {fprintf(stderr,"Token KEYWORD_DEF: \t\t%s\n",yytext);return KW_DEF;}
endcomp     {fprintf(stderr,"Token KEYWORD_FENDCOMP: \t\t%s\n",yytext);return KW_ENDCOMP;}
scalar      {fprintf(stderr,"Token KEYWORD_SCALAR: \t\t%s\n",yytext);return KW_SCALAR;}
const       {fprintf(stderr,"Token KEYWORD_CONST: \t\t%s\n",yytext);return KW_CONST;}
in          {fprintf(stderr,"Token KEYWORD_IN: \t\t%s\n",yytext); return KW_IN;}
continue    {fprintf(stderr,"Token KEYWORD_CONTINUE: \t\t%s\n",yytext);return KW_CONTINUE;}
enddef      {fprintf(stderr,"Token KEYWORD_ENDDEF: \t\t%s\n",yytext);return KW_ENDDEF;}
of          {fprintf(stderr,"Token KEYWORD_OF: \t\t%s\n",yytext);return KW_OF;}
str         {fprintf(stderr,"Token KEYWORD_STR: \t\t%s\n",yytext);return KW_STR;}
if          {fprintf(stderr,"Token KEYWORD_IF: \t\t%s\n",yytext);return KW_IF;}
endfor      {fprintf(stderr,"Token KEYWORD_ENDFOR: \t\t%s\n",yytext);return KW_ENDFOR;}
not         {fprintf(stderr,"Token KEYWORD_NOT: \t\t%s\n",yytext);return KW_NOT;}
main        {fprintf(stderr,"Token KEYWORD_MAIN: \t\t%s\n",yytext);return KW_MAIN;}
boolean     {fprintf(stderr,"Token KEYWORD_BOOLEAN: \t\t%s\n",yytext);return KW_BOOLEAN;}
else	    {fprintf(stderr,"Token KEYWORD_ELSE: \t\t%s\n",yytext);return KW_ELSE;}
while       {fprintf(stderr,"Token KEYWORD_WHILE: \t\t%s\n",yytext);return KW_WHILE; }
and         {fprintf(stderr,"Token KEYWORD_AND: \t\t%s\n",yytext);return KW_AND;}
return      {fprintf(stderr,"Token KEYWORD_RETURN: \t\t%s\n",yytext);return KW_RETURN;  }    
True        {fprintf(stderr,"Token KEYWORD_TRUE: \t\t%s\n",yytext);return KW_TRUE;}
endif       {fprintf(stderr,"Token KEYWORD_ENDIF: \t\t%s\n",yytext);return KW_ENDIF;}
endwhile    {fprintf(stderr,"Token KEYWORD_ENDWHILE: \t\t%s\n",yytext);return KW_ENDWHILE;}
or          {fprintf(stderr,"Token KEYWORD_OR: \t\t%s\n",yytext);return KW_OR;}
comp        {fprintf(stderr,"Token KEYWORD_COMP: \t\t%s\n",yytext);return KW_COMP;}


{IDENTIFIER} {fprintf(stderr,"Token IDENTIFIER: \t\t%s\n",yytext);yylval.str = strdup(yytext);
              return IDENTIFIER; }
{INTEGER}    {fprintf(stderr,"Token INTEGER: \t\t\t%s\n",yytext); yylval.str = strdup(yytext); 
              return INTEGER; }
{SCALAR}     {fprintf(stderr,"Token SCALAR: \t\t%s\n",yytext); yylval.str = strdup(yytext); 
              return SCALAR; }
{STRING}	{fprintf(stderr,"Token STRING: \t\t%s\n",yytext); yylval.str = strdup(yytext); 
              return STRING; }

"+"         {fprintf(stderr,"Token PLUS: \t\t\t%s\n",yytext);return PLUS;}
"-"         {fprintf(stderr,"Token MINUS: \t\t\t%s\n",yytext);return MINUS;}
"*"         {fprintf(stderr,"Token MULT: \t\t\t%s\n",yytext);return MULT;}
"/"         {fprintf(stderr,"Token DIV: \t\t\t%s\n",yytext);return DIV;}
"%"         {fprintf(stderr,"Token MOD: \t\t\t%s\n",yytext);return MOD;}
"**"        {fprintf(stderr,"Token DOUBLE_MULT: \t\t\t%s\n",yytext);return DOUBLE_MULT;}
"=="        {fprintf(stderr,"Token EQUAL: \t\t\t%s\n",yytext);return EQUAL;}
"!="        {fprintf(stderr,"Token NOT_EQUAL: \t\t\t%s\n",yytext);return NOT_EQUAL;}
"<"         {fprintf(stderr,"Token LESS: \t\t\t%s\n",yytext);return LESS;}
">"         {fprintf(stderr,"Token GREATER: \t\t\t%s\n",yytext);return GREATER;}
"<="        {fprintf(stderr,"Token LESS_EQUAL: \t\t\t%s\n",yytext);return LESS_EQUAL;}
">="        {fprintf(stderr,"Token GREATER_EQUAL: \t\t\t%s\n",yytext);return GREATER_EQUAL;}
"="         {fprintf(stderr,"Token ASSIGN: \t\t\t%s\n",yytext);return ASSIGN;}
"+="        {fprintf(stderr,"Token PLUS_EQUAL: \t\t\t%s\n",yytext);return PLUS_EQUAL;}
"-="        {fprintf(stderr,"Token MINUS_EQUAL: \t\t\t%s\n",yytext);return MINUS_EQUAL;}
"*="        {fprintf(stderr,"Token MULT_EQUAL: \t\t\t%s\n",yytext);return MULT_EQUAL;}
"/="        {fprintf(stderr,"Token DIV_EQUAL: \t\t\t%s\n",yytext);return DIV_EQUAL;}
"%="        {fprintf(stderr,"Token MOD_EQUAL: \t\t\t%s\n",yytext);return MOD_EQUAL;}
";"	    {fprintf(stderr,"Token SEMICOLON: \t\t%s\n",yytext);return SEMICOLON;}
"("         {fprintf(stderr,"Token PARENTHESIS_R: \t\t%s\n",yytext);return PARENTHESIS_R;}
")"	    {fprintf(stderr,"Token PARENTHESIS_L: \t\t%s\n",yytext);return PARENTHESIS_L;}
","         {fprintf(stderr,"Token COMMA: \t\t\t%s\n",yytext);return COMMA;}
"["         {fprintf(stderr,"Token BRACKET_R: \t\t\t%s\n",yytext);return BRACKET_R;}
"]"         {fprintf(stderr,"Token BRACKET_L: \t\t\t%s\n",yytext);return BRACKET_L;}
":"         {fprintf(stderr,"Token COLON: \t\t\t%s\n",yytext);return COLON;}
"."         {fprintf(stderr,"Token DOT: \t\t\t%s\n",yytext);return DOT;}
"->"	    {fprintf(stderr,"Token ARROW: \t\t\t%s\n",yytext);return ARROW;}
"#"	    {fprintf(stderr,"Token HASHTAG: \t\t\t%s\n",yytext);return HASHTAG;}

[ \r\t]+	/* eat whitespace */
"//"[^\n]*  	/* eat line comments */
"--"[^\n]*  	/* eat line comments */

"/*"	BEGIN(comment);
	
<comment>[^*\n]*        /* eat anything that's not a '*' */
<comment>"*"+[^*/\n]*   /* eat up '*'s not followed by ')'s */
<comment>\n             ++line_num;
<comment>"*"+"/"        BEGIN(INITIAL);


\n 	++line_num;
<<EOF>> return EOF;
.       {yyerror("lexical error: unrecognized literal '%s'\n", yytext); }

%%































































































































































































































































































































