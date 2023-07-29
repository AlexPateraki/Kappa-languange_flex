%{
#include <stdlib.h>
#include <stdarg.h>
#include <stdio.h>
#include <string.h>	
#include "cgen.h"
#include "kappalib.h"


extern int yylex(void);
extern int line_num;


%}
%debug

%union{	
char*  str;
} 

%token <str> IDENTIFIER
%token <str> INTEGER
%token <str> SCALAR
%token <str> STRING


%token KW_INTEGER   
%token KW_FALSE 
%token KW_FOR 
%token KW_BREAK
%token KW_DEF
%token KW_ENDCOMP 
%token KW_SCALAR 
%token KW_CONST 
%token KW_IN 
%token KW_CONTINUE 
%token KW_ENDDEF
%token KW_OF 
%token KW_STR 
%token KW_IF 
%token KW_ENDFOR
%token KW_NOT
%token KW_MAIN 
%token KW_BOOLEAN 
%token KW_ELSE 
%token KW_WHILE 
%token KW_AND 
%token KW_RETURN 
%token KW_TRUE
%token KW_ENDIF 
%token KW_ENDWHILE 
%token KW_OR
%token KW_COMP
%token PLUS
%token MINUS
%token MULT
%token DIV
%token MOD
%token DOUBLE_MULT
%token EQUAL
%token NOT_EQUAL
%token LESS
%token GREATER
%token LESS_EQUAL
%token GREATER_EQUAL
%token ASSIGN
%token PLUS_EQUAL
%token MINUS_EQUAL
%token MULT_EQUAL
%token DIV_EQUAL
%token MOD_EQUAL
%token SEMICOLON
%token PARENTHESIS_R
%token PARENTHESIS_L
%token COMMA
%token BRACKET_R
%token BRACKET_L
%token COLON
%token DOT
%token ARROW
%token HASHTAG


%start program

//all statements
%type <str> program 
%type <str> structure_main
%type <str> declarations_variables 
%type <str> declarations_const
%type <str> declarations_functions 
%type <str> declarations_comp
%type <str> expressions
%type <str> return_type
%type <str> assign_op
%type <str> functions
%type <str> loop_comps
%type <str> sign
%type <str> expr 
%type <str> data_types
%type <str> member_variables
%type <str> loop_declare
%type <str> loop_variables
%type <str> standard_values
%type <str> declare
%type <str> stmts
%type <str> simple
%type <str> more
%type <str> loop
%type <str> while_stmts
%type <str> break_stmts
%type <str> continue_stmts
%type <str> if_stmts
%type <str> return_stmts
%type <str> for_stmts
%type <str> function_loop
%type <str> call_function
%type <str> loop_expressions
%type <str> arrays
%type <str> kw_operations
%type <str>  loop_assign
%type <str>  check_operations


//associations
%left DOT PARENTHESIS_R PARENTHESIS_L BRACKET_R BRACKET_L
%right DOUBLE_MULT 
%left MULT DIV MOD PLUS MINUS LESS GREATER LESS_EQUAL GREATER_EQUAL EQUAL NOT_EQUAL
%right KW_NOT 
%left  KW_AND KW_OR
%right ASSIGN PLUS_EQUAL MINUS_EQUAL MULT_EQUAL DIV_EQUAL MOD_EQUAL ":="

%%

//structure of program(2.2i)
program:  
loop_declare structure_main SEMICOLON{ 
  if (yyerror_count == 0) {
    // include the kappalib.h file
    puts(c_prologue); 
    printf("/* program */ \n\n");
    printf("%s\n\n", $1);
    printf("int main() {\n%s\n} \n", $2);
  }
}
;

//define main (2.2i)
structure_main:
KW_DEF KW_MAIN PARENTHESIS_R PARENTHESIS_L COLON loop_declare KW_ENDDEF {$$=template("\n%s\n",$6);}
;

//loop all the cases 
loop_declare:
declare
| loop_declare declare
;

//all declarations
declare:
declarations_comp
|declarations_comp SEMICOLON
|declarations_const SEMICOLON//constants
|declarations_const
|declarations_variables SEMICOLON
|declarations_variables
|declarations_functions SEMICOLON
|declarations_functions
|stmts SEMICOLON
|stmts
;


//define data types(2.2ii)
data_types:
KW_INTEGER { $$ = "int"; }
| KW_SCALAR { $$ = "double"; }
| KW_STR { $$ = "char*"; }
| KW_BOOLEAN { $$ = "int"; }
;

//handle arrays
arrays:
 IDENTIFIER BRACKET_R INTEGER BRACKET_L COLON KW_INTEGER {$$=template("int %s[%s];",$1,$3);}
| IDENTIFIER BRACKET_R INTEGER BRACKET_L COLON KW_SCALAR {$$=template("double %s[%s];",$1,$3);}
| IDENTIFIER BRACKET_R INTEGER BRACKET_L COLON KW_STR {$$=template("char* %s[%s];",$1,$3);}
| IDENTIFIER BRACKET_R INTEGER BRACKET_L COLON KW_BOOLEAN {$$=template("int %s[%s];",$1,$3);}
| IDENTIFIER BRACKET_R INTEGER BRACKET_L COLON KW_COMP {$$=template("comp %s[%s];",$1,$3);}
| IDENTIFIER BRACKET_R BRACKET_L COLON KW_INTEGER {$$=template("int %s[];",$1);}
| IDENTIFIER BRACKET_R BRACKET_L COLON KW_SCALAR {$$=template("double %s[];",$1);}
| IDENTIFIER BRACKET_R BRACKET_L COLON KW_STR {$$=template("char* %s[];",$1);}
| IDENTIFIER BRACKET_R BRACKET_L COLON KW_BOOLEAN {$$=template("int %s[];",$1);}
| IDENTIFIER BRACKET_R BRACKET_L COLON KW_COMP {$$=template("comp %s[];",$1);}
; 

//DECLARE variables(2.2iii)
declarations_variables:
expressions COLON data_types {$$=template("%s %s; ",$3, $1);}
|expressions COMMA loop_variables COLON data_types {$$=template("%s %s, %s; ",$5, $1, $3);}
|expressions COLON data_types COMMA loop_variables {$$=template("%s %s , %s; ",$3, $1, $5);}
|arrays { $$ = $1; }
;

//for all types recursively(2.2iii)
loop_variables:
expressions  {$$=template("%s",$1);}
|loop_variables COMMA expressions {$$=template("%s, %s",$1, $3);}
|loop_variables COLON data_types {$$=template("%s %s",$3, $1);}
;

//declare functions
declarations_functions:
KW_DEF IDENTIFIER PARENTHESIS_R declarations_variables PARENTHESIS_L ARROW data_types COLON loop_declare KW_ENDDEF SEMICOLON{$$=template("%s %s(%s){%s}",$7, $2, $4,$9 );}
|KW_DEF IDENTIFIER PARENTHESIS_R declarations_variables PARENTHESIS_L COLON loop_declare KW_ENDDEF SEMICOLON{$$=template("%s %s(%s){%s}",$7, $2, $4,$7 );}
|KW_DEF IDENTIFIER PARENTHESIS_R PARENTHESIS_L COLON loop_declare KW_ENDDEF SEMICOLON{$$=template(" %s(){%s}",$2,$6 );}
;

//declare the constants (2.2iv)
declarations_const:
KW_CONST expressions ASSIGN expressions COLON data_types {$$=template("const %s %s=%s;",$6, $2, $4);}
//missing the case of arrays
;

//returning types used in fuctions(2.2v)
return_type:
SEMICOLON { $$ = ";";}
|expressions { $$ = $1; }
|expr { $$ = $1; }
|expressions kw_operations loop_expressions { $$ = template("%s %s %s ", $1,$2,$3); }
|sign { $$ = $1; }
;

//loop for equations
loop_expressions:
expr { $$ = $1; }
|loop_expressions kw_operations expr{ $$ = template("%s %s %s", $1, $2,$3); }
;


//declarations_comp(2.2vi)
declarations_comp:
KW_COMP IDENTIFIER COLON loop_comps functions KW_ENDCOMP SEMICOLON{$$=template("comp %s: %s\n %s;\nendcomp;",$2,$4,$5);}
|HASHTAG IDENTIFIER ASSIGN IDENTIFIER SEMICOLON{$$=template("#%s= %s\n;",$2,$4);}
;

//for lots of lines of members(2.2vi)
loop_comps:
member_variables{ $$ = $1; }
|loop_comps member_variables{ $$ = template("%s \n %s", $1, $2); }
;

//for comp type recursively(2.2iii)
member_variables:
  HASHTAG IDENTIFIER COLON data_types SEMICOLON{$$=template("#%s: %s",$2,$4);}
|member_variables COMMA HASHTAG IDENTIFIER  {$$=template("%s, #%s",$1, $4);}
|  HASHTAG IDENTIFIER {$$=template("#%s",$2);};
;

//for lots of functions in a compined type(2.2vi)
functions:
declarations_functions{ $$ = $1; }
|functions declarations_functions{ $$ = template("%s \n %s", $1, $2); }
;

//basic expressions(2.2 vii)
expressions:
 IDENTIFIER { $$ = template("%s ", $1); }
| INTEGER  { $$ = template("%s ", $1); }
| SCALAR  { $$ = template("%s ", $1); }
| STRING { $$ = template("%s ", $1); }
| standard_values { $$ = template("%s ", $1); }
;

//manage operations
kw_operations:
MULT{ $$ = template("*"); }
|DIV{ $$ = template("/"); }
|PLUS{ $$ = template("+"); }
|MINUS{ $$ = template("-"); }
;

//expression to check two numbers
check_operations:
DOUBLE_MULT{ $$ = template("^"); }
|EQUAL { $$ = template("=="); }
|ASSIGN{ $$ = template("="); }
|MOD_EQUAL{ $$ = template("%="); }
|DIV_EQUAL{ $$ = template("/="); }
|PLUS_EQUAL{ $$ = template("+="); }
|MINUS_EQUAL{ $$ = template("-="); }
|MULT_EQUAL{ $$ = template("*="); }
|NOT_EQUAL{ $$ = template("!="); }
|LESS{ $$ = template("<"); }
|GREATER{ $$ = template(">"); }
|LESS_EQUAL{ $$ = template("<="); }
|GREATER_EQUAL{ $$ = template(">="); }
|MOD{ $$ = template("%"); }
;

//cases of signs
sign:
MINUS expressions { $$ = template("-%s",$2); }
|PLUS expressions  { $$ = template("+%s", $2); }
;

//all expressions(2.2 vii)
expr:
expressions kw_operations expressions  { $$ = template("%s %s %s", $1,$2,$3); }
| KW_NOT expressions { $$ = template("! %s", $2); }
| PARENTHESIS_R expr PARENTHESIS_L { $$ = template("(%s)", $2); }
| BRACKET_R expressions BRACKET_L { $$ = template("[%s]", $2); }
| expressions check_operations expressions { $$ = template("%s %s%s)", $1,$2, $3); }
| expressions ":=" expressions { $$ = template("%s := %s", $1,$3); }
| expressions DOT expressions { $$ = template("%s.%s", $1,$3); }
|expressions KW_AND expressions{ $$ = template("%s&&%s", $1,$3); }
|expressions KW_OR expressions{ $$ = template("%s||%s", $1,$3); }
;

//boolean expressions and assign(2.2vii, 2.3.1)
standard_values:
 KW_TRUE SEMICOLON{ $$ = template("1"); }
| KW_FALSE SEMICOLON{ $$ = template("0"); }
;


//statements choose one ore more lines(2.2viii)
stmts:
  simple { $$ = $1; }
| more { $$ = $1; }
;

//manage statements (2.2viii) 
simple:
 for_stmts         { $$ = template(" %s", $1); }
| while_stmts       { $$ = template(" %s", $1); }
| break_stmts      { $$ = template(" %s", $1); }
| continue_stmts    { $$ = template(" %s", $1); }
| return_stmts      { $$ = template(" %s", $1); }
| if_stmts          { $$ = template(" %s", $1); }
| call_function   { $$ = template(" %s", $1); }
| assign_op   { $$ = template(" %s", $1); }
;

//manages the case of check_operations
assign_op:
expressions check_operations loop_assign SEMICOLON{ $$ = template("%s %s %s;", $1,$2 ,$3); }
|expressions check_operations expressions{ $$ = template("%s =%s;", $1,$3); }
;

//handle equation
loop_assign:
expr loop_assign{ $$ = template("%s %s",$1,$2); }
|kw_operations call_function{ $$ = template("%s %s",$1,$2); }
|call_function { $$ = template("%s", $1); }
;


//multiple statements (2.2viii)
more:
  '{' loop '}' SEMICOLON { $$ = template("{%s}", $2); }
;

//looping for specific statements(2.2viii)
loop:
  simple { $$ = $1; }
| loop simple{ $$ = template("%s \n %s", $1, $2); }
;


//if statement (2.2viii)
if_stmts:
  KW_IF PARENTHESIS_R assign_op PARENTHESIS_L COLON stmts KW_ELSE COLON stmts KW_ENDIF SEMICOLON
  { $$ = template("if (%s): %s \nelse: %s endif;", $3, $6, $9); }
;
  
//while statement (2.2viii)
while_stmts:
  KW_WHILE PARENTHESIS_R expr PARENTHESIS_L COLON stmts KW_ENDWHILE{ $$ = template("while (%s): \n%s endwhile;", $3, $6); }
   ;

//break statement (2.2viii)
break_stmts:
  KW_BREAK { $$ = template("break;"); }
;


//continue statement (2.2viii)
continue_stmts:
  KW_CONTINUE { $$ = template("continue;"); }
;

 
//return statement (2.2viii)
return_stmts:
  KW_RETURN return_type{ $$ = template("return %s;", $2); }
;


//for statement statement (2.2viii)
for_stmts:
KW_FOR INTEGER KW_IN BRACKET_R INTEGER COLON INTEGER COLON INTEGER BRACKET_L COLON stmts KW_ENDFOR SEMICOLON{ $$  = template("for %s in [%s:%s:%s]: %s endfor;", $2, $5, $7, $9, $12) ;}
|KW_FOR INTEGER KW_IN BRACKET_R INTEGER COLON INTEGER BRACKET_L COLON stmts KW_ENDFOR SEMICOLON{ $$  = template("for %s in [%s:%s]: %s endfor;", $2, $5, $7, $10) ;}
; 

//recursion rule for function(2.2viii)
function_loop:
expr   { $$ = template(" %s", $1); }
|expressions    { $$ = template(" %s", $1); }
|sign { $$ = template(" %s", $1); }
|member_variables  { $$ = template(" %s", $1); }
;
 
 //call function (2.2viii)
call_function:
 IDENTIFIER PARENTHESIS_R function_loop PARENTHESIS_L { $$ = template("%s (%s);", $1, $3); }
 | IDENTIFIER PARENTHESIS_R expressions COMMA function_loop PARENTHESIS_L { $$ = template("%s (%s, %s);", $1, $3,$5); }
| IDENTIFIER PARENTHESIS_R PARENTHESIS_L { $$ = template("%s()", $1); }
;

%%
int main ()
{
   if ( yyparse() == 0 )
		printf("Your program is syntactically correct!\n");
	else
		printf("Rejected!\n");
}
