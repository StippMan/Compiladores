%{
#include <string.h>
#include "util.h"
#include "tokens.h"
#include "errormsg.h"

#define STR_MAX_SIZE 16384
#define YY_NO_UNPUT

int depth = 0;
int curr_line = 1;
int curr_col = 0;
int char_pos = 1;

char str_buffer[STR_MAX_SIZE];
char* buffer_ptr;

void adjust(void);

// extern YYLTYPE yylloc;

%}

%x IN_COMMENT 
%x IN_STRING


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
"."	 		{adjust(); return DOT;}

 /*Arithmetic*/
"+"	 		{adjust(); return PLUS;}
"-"	 		{adjust(); return MINUS;}
"*"	 		{adjust(); return TIMES;}
"/"	 		{adjust(); return DIVIDE;}

 /*Comparison*/
"="	 		{adjust(); return EQ;}
"<"	 		{adjust(); return LT;}
">"	 		{adjust(); return GT;}
"<="			{adjust(); return LTEQ;}
">="			{adjust(); return GTEQ;}
"<>"			{adjust(); return NEQ;}

 /*Boolean Operators*/
"&"	 		{adjust(); return AND;}
"|"	 		{adjust(); return OR;}

 /*Reserved Words*/
"if"  	 			{adjust(); return IF;}
"then"  	 		{adjust(); return THEN;}
"else"  	 		{adjust(); return ELSE;}
"while"  	 	    {adjust(); return WHILE;}
"do"  	 			{adjust(); return DO;}
"for"  	 			{adjust(); return FOR;}
"to"  	 			{adjust(); return TO;}
"break"  	 	    {adjust(); return BREAK;}
"let"  	 			{adjust(); return LET;}
"nil"      			{adjust(); return NIL;}
"type"     			{adjust(); return TYPE;}
"array"    			{adjust(); return ARRAY;}
"of"    			{adjust(); return OF;}
"var"    		    {adjust(); return VAR;}
"funtion"    	    {adjust(); return FUNCTION;}
"end"    		    {adjust(); return END;}

"goto"    			{adjust(); return GOTO;}

[0-9]+	 					{adjust(); yylval.ival=atoi(yytext); return INT;}
[a-zA-Z][a-zA-Z0-9_]*	 	{adjust(); yylval.sval=yytext; return ID;}

 /*string*/
\"			{adjust(); BEGIN(IN_STRING); buffer_ptr = str_buffer;}

<IN_STRING>{
	\"			{
					adjust(); 
					BEGIN(INITIAL); 
					
					*buffer_ptr = '\0';
					char *p;
					p = malloc((strlen(str_buffer)+1)*sizeof(char));			// essa parte peguei do professor...
					strcpy(p, str_buffer);
					yylval.sval = p; 						// nao sei se o sval é o correto aqui

					return STRLIT;
				}
				
	\n	 		{adjust(); EM_error(EM_tokPos,"unterminated string constant");;}
	<<EOF>>	 	{adjust(); EM_error(EM_tokPos,"unterminated string constant");;}
	\\n	 		{*buffer_ptr++ = '\n';}
	\\t	 		{*buffer_ptr++ = '\t';}
	\\^[a-z]	{
					if(strchr("abcdefghijklmnopqrstuvwxyz", yytext[2])){
						*buffer_ptr++ = yytext[2] - 'a' + 1;
					} else {
						EM_error(EM_tokPos,"illegal escape sequence");
					}
				}
	\\\"			{*buffer_ptr++ = '"';}			
	\\\\	 		{*buffer_ptr++ = '\\';}
	\\[0-9]{3}		{*buffer_ptr++ = (char)atoi(&yytext[1]);}
	\\[\n\t ]+\\    {/*nothing*/}				
	\\.				{adjust(); EM_error(EM_tokPos,"illegal escape sequence");}
	[^\\\n\"]+		{
						char *p = yytext;
						while (*p)
							*buffer_ptr++ = *p++;
					}
}

 /*comentario*/
"/*"	 	{adjust(); BEGIN(IN_COMMENT); depth = 1;}

<IN_COMMENT>{
	"/*"	 	{adjust(); depth++;}
	"*/"	 	{adjust(); if (--depth == 0) BEGIN(INITIAL);}
	\n	 		{adjust();}
	<<EOF>>     {adjust(); EM_error(EM_tokPos,"unterminated comment");}
	.	 		{adjust();}
}


 /*Illegal Token*/
.	 		{adjust(); EM_error(EM_tokPos,"illegal token");}

%%

int yywrap(void) {
 char_pos=1;
 return 1;
}

void adjust(void) {
  EM_tokPos=char_pos;
  char_pos+=yyleng;
 }
