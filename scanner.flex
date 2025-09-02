%{
#include "token.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>


char* last_identifier = nullptr;
char* prev_identifier = nullptr;
int let_context = 0;
char* let_var_stack[100];
int let_var_top = 0;
%}

SPACE      [ \t\n]
DIGIT      [0-9]
LETTER     [A-Za-z] 
INT     ({DIGIT}+)
REAL ({DIGIT}+([.|,]{DIGIT}+))
IDENTIFIER ({LETTER})({DIGIT}|{LETTER}|_)*
TEXT       (\"({DIGIT}|{LETTER}|{SPACE})*\")
COMMENTL (@@({DIGIT}|{LETTER}|{TEXT}|{SPACE})*)
COMMENTML   (\@({DIGIT}|{LETTER}|{TEXT}|{SPACE})*\@)

COMMENT ({COMMENTL}|{COMMENTML})
%%
{SPACE} { }
"#" { return TOKEN_CONCAT; }
"rtos" { return TOKEN_RTOS; }
"itos"  { return TOKEN_ETOS; }
"itor"  { return TOKEN_ETOR; }
"rtoi"  { return TOKEN_RTOE; }
"(" { return TOKEN_LPAREN; }
")" { return TOKEN_RPAREN; }
"if" { return TOKEN_IF; }
"else" { return TOKEN_ELSE; }
"=" { 
    if (let_context == 1) {
        let_context = 2;
    }
    return TOKEN_ASIG; 
}
{REAL} { return TOKEN_REAL; }
{INT} { return TOKEN_INT; }
"+" { return TOKEN_ADD; }
"-" { return TOKEN_SUBSTRACT; }
"*" { return TOKEN_MULTIPLY; }
"/" { return TOKEN_DIVIDE; }
"%" { return TOKEN_MOD; }
"and" { return TOKEN_AND; }
"or" { return TOKEN_OR; }
"not" { return TOKEN_NOT; }
"xor" { return TOKEN_XOR; }

"let" { 
    let_context = 1; 
    return TOKEN_LET; 
}
"true" { return TOKEN_TRUE; }
"false" { return TOKEN_FALSE; }
"in" { 
    if (let_context == 2) {
        let_context = 0;
        return TOKEN_IN_LET;
    }
    return TOKEN_IN; 
}
"fun" { return TOKEN_FUN; }
"print" { return TOKEN_PRINT; }
"pair" { return TOKEN_PAIR; }
"fst" { return TOKEN_FST; }
"snd" { return TOKEN_SND; }
"<" { return TOKEN_LESS; }
">" { return TOKEN_GREAT; }
"<=" { return TOKEN_LESSEQL; }
">=" { return TOKEN_GREATEQL; }
"!=" { return TOKEN_NOTEQUAL; }
"==" { return TOKEN_EQUAL; }
"," { return TOKEN_COMMA; }
{COMMENT} { }

{IDENTIFIER} {
    if (let_context == 1) {
        if (let_var_top < 100) {
            let_var_stack[let_var_top++] = strdup(yytext);
        }
    }
    if (prev_identifier != nullptr) {
        free(prev_identifier);
    }
    prev_identifier = last_identifier;
    last_identifier = strdup(yytext);
    return TOKEN_IDENTIFIER;
}
{TEXT}       { return TOKEN_STRING; }

. {
    printf("caracter no reconocido %s", yytext);
    return TOKEN_UNKNOWN;
}

%%


int yywrap() { return 1; }

void cleanup_lexer(){
    if(last_identifier){
        free(last_identifier);
        last_identifier = nullptr;
    }
    if(prev_identifier){
        free(prev_identifier);
        prev_identifier = nullptr;
    }
    for(int i = 0; i < let_var_top; i++) {
        if(let_var_stack[i]) {
            free(let_var_stack[i]);
            let_var_stack[i] = nullptr;
        }
    }
    let_var_top = 0;
    let_context = 0;
}




