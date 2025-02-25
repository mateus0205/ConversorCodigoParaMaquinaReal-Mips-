/*+=============================================================
|   UNIFAL - Universidade Federal de Alfenas.
|       BACHARELADO EM CIENCIA DA COMPUTACAO.
| Trabalho.. : Geracao de codigo MIPS
| Disciplina : Compiladores
| Professor. : Luiz Eduardo da Silva
| Aluno..... : Mateus Henrique Martins
| Data...... : 11/12/2024
+============================================================= */

%{
#include "sintatico.h"    
#include "utils.c"
char atomo[100];    
int numlinha = 1;
int yyerror(char *);
%}

identificador   [a-zA-Z]([a-zA-z0-9])*
numero          [0-9]*
espaco          [ \t\r]*
novalinha       [\n]
literal         \"[^\"]*\" 






%%
programa            {return T_PROGRAMA;}
inicio               {return T_INICIO;}
fimprograma         {return T_FIMPROG;}
leia                {return T_LEIA;}
escreva             {return T_ESCREVA;}
se                  {return T_SE;}
entao               {return T_ENTAO;}
senao               {return T_SENAO;}
fimse               {return T_FIMSE;}
enquanto            {return T_ENQUANTO;}
faca                {return T_FACA;}
fimenquanto         {return T_FIMQTO;}


"+"                 {return T_MAIS;}
"-"                 {return T_MENOS;}
"*"                 {return T_VEZES;}
div                 {return T_DIV;}

">"                 {return T_MAIOR;}
"<"                 {return T_MENOR;}
"="                 {return T_IGUAL;}   

e                   {return T_E;}
ou                  {return T_OU;}
nao                 {return T_NAO;}

"<-"                {return T_ATRIB;}
"("                 {return T_ABRE;}
")"                 {return T_FECHA;}

inteiro             {return T_INTEIRO;}
logico              {return T_LOGICO;}
V                   {return T_V;}
F                   {return T_F;}

{identificador}     {strcpy(atomo, yytext); return T_IDENT;}
{numero}            {strcpy(atomo, yytext); return T_NUM;}
{espaco}            /*nada*/
{novalinha}         numlinha++;
{literal}           {strcpy(atomo, yytext); return T_STRING;}
.                   yyerror("lexico - símbolo desconhecido!");
%%

int yywrap () { return 1; }

int yyerror(char *s){
    printf("Erro na linha %d: %s\n", numlinha,s);
    exit(100);
}