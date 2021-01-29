%{
#include <string.h>
#include "util.h"
#include "tokens.h"
#include "errormsg.h"

int charPos=1;

int yywrap(void)
{
 charPos=1;
 return 1;
}


void adjust(void)
{
 EM_tokPos=charPos;
 charPos+=yyleng;
}

%}


%%

/*Ignore these*/
" "	 		{adjust(); continue;}
\t	 			{adjust(); continue;}
\r	 			{adjust(); continue;}
\n	 			{adjust(); EM_newline(); continue;}

/*Symbols*/
":"      		{adjust(); return COLON;}
";"      		{adjust(); return SEMICOLON;}
"("      		{adjust(); return LPAREN;}
")"      		{adjust(); return RPAREN;}
"["      		{adjust(); return LBRACK;}
"]"      		{adjust(); return RBRACK;}
"{"      		{adjust(); return LBRACE;}
"}"      		{adjust(); return RBRACE;}
":="			{adjust(); return ASSIGN;}
","	 		{adjust(); return COMMA;}
"."	 		{adjust(); return PERIOD;}

/*Arithmetic*/
"+"	 		{adjust(); return PLUS;}
"-"	 		{adjust(); return MINUS;}
"*"	 		{adjust(); return TIMES;}
"/"	 		{adjust(); return DIVIDE;}

/*Comparison*/
"="	 		{adjust(); return EQ;}
"<"	 		{adjust(); return LT;}
">"	 		{adjust(); return GT;}
"<="			{adjust(); return LEQ;}
">="			{adjust(); return GEQ;}
"<>"			{adjust(); return NEQ;}

/*Boolean Operators*/
"&"	 		{adjust(); return AND;}
"|"	 		{adjust(); return OR;}

/*Reserved Words*/
if  	 		{adjust(); return IF;}
then  	 		{adjust(); return THEN;}
else  	 		{adjust(); return ELSE;}
while  	 	{adjust(); return WHILE;}
do  	 		{adjust(); return DO;}
for  	 		{adjust(); return FOR;}
to  	 		{adjust(); return TO;}
break  	 	{adjust(); return BREAK;}
let  	 		{adjust(); return LET;}
nil      		{adjust(); return NIL;}
type     		{adjust(); return TYPE;}
array    		{adjust(); return ARRAY;}
of    			{adjust(); return OF;}
var    		{adjust(); return VAR;}
funtion    	{adjust(); return FUNCTION;}
end    		{adjust(); return END;}



[0-9]+	 					{adjust(); yylval.ival=atoi(yytext); return INT;}
[a-zA-Z][a-zA-Z0-9_]+	 	{adjust(); yylval.ival=atoi(yytext); return ID;}

/*Illegal Token*/
.	 		{adjust(); EM_error(EM_tokPos,"illegal token");}


//falta string e estados