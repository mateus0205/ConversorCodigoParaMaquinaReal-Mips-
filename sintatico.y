/*+=============================================================
|   UNIFAL - Universidade Federal de Alfenas.
|       BACHARELADO EM CIENCIA DA COMPUTACAO.
| Trabalho.. : Geracao de codigo MIPS
| Disciplina : Compiladores
| Professor. : Luiz Eduardo da Silva
| Aluno..... : Mateus Henrique Martins
| Data...... : 11/12/2024
+=============================================================*/

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "lexico.c"

int contaVar = 0;
int tipo;
int rotulo = 0;
char literal[100][100]; 
int contaLiteral = 0;

int pilhaRotulos[100]; 
int topoRotulos = -1;  

void empilhaRotulo(int valor) {
    pilhaRotulos[++topoRotulos] = valor;
}

int desempilhaRotulo() {
    return pilhaRotulos[topoRotulos--];
}

char* identificadorAtual = NULL;

%}

%token T_PROGRAMA 
%token T_INICIO
%token T_FIMPROG
%token T_LEIA
%token T_ESCREVA
%token T_SE
%token T_ENTAO
%token T_SENAO
%token T_FIMSE
%token T_ENQUANTO
%token T_FACA
%token T_FIMQTO
%token T_STRING


%token T_MAIS
%token T_MENOS
%token T_VEZES
%token T_DIV


%token T_MAIOR
%token T_MENOR
%token T_IGUAL


%token T_E
%token T_OU
%token T_NAO


%token T_ATRIB
%token T_ABRE
%token T_FECHA


%token T_INTEIRO
%token T_LOGICO
%token T_V
%token T_F


%token T_IDENT
%token T_NUM

%start programa

%left T_MAIS T_MENOS
%left T_VEZES T_DIV
%left T_MAIOR T_MENOR T_IGUAL
%left T_E T_OU

%%
programa
    : cabecalho 
        { 
            fprintf(yyout, ".text\n\t.globl main\nmain:\tnop\n");
        }

      variaveis 
        { 
        }
      T_INICIO lista_comandos T_FIMPROG
    {
        fprintf(yyout, "fim:\tnop\n");
        fprintf(yyout, "\tli $v0, 10\n");  
        fprintf(yyout, "\tli $a0, 0\n");   
        fprintf(yyout, "\tsyscall\n");      

        fprintf(yyout, ".data\n");

        for (int i = 0; i < contaVar; i++) {
            if (tabSimb[i].tip == INT) {
                fprintf(yyout, "\t%s: .word 1\n", tabSimb[i].id);  
            } else if (tabSimb[i].tip == LOG) {
                fprintf(yyout, "\t%s: .word 1\n", tabSimb[i].id);  
            }
        }

        fprintf(yyout, "\t_esp: .asciiz \" \"\n");  
        fprintf(yyout, "\t_ent: .asciiz \"\\n\"\n"); 

        for (int i = 0; i < contaLiteral; i++) {
            fprintf(yyout, "\t_const%d: .asciiz \%s\n", i, literal[i]);
        }
    }
;
cabecalho
    : T_PROGRAMA T_IDENT
    ;
variaveis
    : 
    | declaracao_variaveis

declaracao_variaveis
    : tipo lista_variaveis declaracao_variaveis
    | tipo lista_variaveis 
    ;

tipo 
    : T_INTEIRO {tipo = INT; }
    | T_LOGICO  {tipo = LOG; }
    ;

lista_variaveis
    : lista_variaveis T_IDENT
        {
            strcpy (elemTab.id, atomo);
            elemTab.end = contaVar;
            elemTab.tip = tipo;
            insereSimbolo(elemTab);
            contaVar++;
        }
    | T_IDENT
        {
            strcpy (elemTab.id, atomo);
            elemTab.end = contaVar;
            elemTab.tip = tipo;
            insereSimbolo(elemTab);
            contaVar++;
        }
    ;
lista_comandos
    : lista_comandos comando
    | 
    ;

comando 
    : leitura
    | escrita
    | repeticao
    | selecao
    | atribuicao
    ;

leitura 
    : T_LEIA T_IDENT
        {
            fprintf(yyout, "\tli $v0, 5\n");
            fprintf(yyout, "\tsyscall\n");
            fprintf(yyout, "\tsw $v0, %s\n", atomo);
        }

    ;

escrita
    : T_ESCREVA expressao
        
        { 
            fprintf(yyout, "\tli $v0, 1\n");
            fprintf(yyout, "\tsyscall\n");

            fprintf(yyout, "\tla $a0 _ent\n");
            fprintf(yyout, "\tli $v0, 4\n");
            fprintf(yyout, "\tsyscall\n");      
        }

    | T_ESCREVA T_STRING
        { 
        strcpy(literal[contaLiteral], atomo);  
        fprintf(yyout,"\tla $a0 _const%d\n", contaLiteral++); 
        fprintf(yyout,"\tli $v0, 4\n");
        fprintf(yyout,"\tsyscall\n");}
    ;

repeticao
    : T_ENQUANTO
        { 
            fprintf(yyout, "L%d:\tnop\n", ++rotulo); 
            empilhaRotulo(rotulo); 
        }
     expressao T_FACA 
        {
            int tipo = desempilha();
            if(tipo != LOG)
                yyerror("Incompatibilidade de tipo na repetição"); 
            fprintf(yyout, "\tbeqz $a0, L%d\n", ++rotulo); 
            empilhaRotulo(rotulo);
        }
     lista_comandos 
     T_FIMQTO 
        { 
            int fimrepeticao = desempilhaRotulo();  
            int desvioSempre = desempilhaRotulo();  
            fprintf(yyout, "\tj L%d\nL%d:\tnop\n", desvioSempre, fimrepeticao);  
        }
;

selecao
    : T_SE expressao 
      T_ENTAO 
        { 
            int tipo = desempilha();
            if(tipo != LOG)
                yyerror("Incompatibilidade de tipo na seleção");
            fprintf(yyout, "\tbeqz $a0, L%d\n", ++rotulo);
            empilhaRotulo(rotulo);
        }
      lista_comandos 
      T_SENAO
        {
            int falso = desempilhaRotulo();
            fprintf(yyout, "\tj L%d\n", ++rotulo);
            empilhaRotulo(rotulo);
            fprintf(yyout, "L%d:\tnop\n", falso);
        }
      lista_comandos 
      T_FIMSE
        {
            int fimselecao = desempilhaRotulo();
            fprintf(yyout, "L%d:\tnop\n", fimselecao);
        }
;

atribuicao
    : T_IDENT 
        {
            int pos = buscaSimbolo(atomo);
            empilha(pos);
            identificadorAtual = strdup(tabSimb[pos].id); 
        }
      T_ATRIB expressao
      {
        int tipo = desempilha();
        int pos = desempilha();
        if (tipo != tabSimb[pos].tip)
            yyerror("Incompatibilidade de Tipos!");
        fprintf(yyout, "\tsw $a0, %s\n", identificadorAtual);
      }
    ;

expressao: 
    expressao T_MAIS
        {
            fprintf(yyout,"\tsw $a0 0($sp)\n");
            fprintf(yyout,"\taddiu $sp $sp -4\n");
        }
        expressao
        {
            fprintf(yyout,"\tlw $t1 4($sp)\n");
            fprintf(yyout,"\taddiu $sp $sp 4\n");
            fprintf(yyout,"\tadd $a0, $t1, $a0\n");
            
        }
    |  expressao T_MENOS   
        {
            fprintf(yyout,"\tsw $a0 0($sp)\n");
            fprintf(yyout,"\taddiu $sp $sp -4\n");
        }
        expressao
        {
            fprintf(yyout,"\tlw $t1 4($sp)\n");
            fprintf(yyout,"\taddiu $sp $sp 4\n");
            fprintf(yyout,"\tsub $a0, $t1, $a0\n");
            

        }
    | expressao T_VEZES 
        {
            fprintf(yyout,"\tsw $a0 0($sp)\n");
            fprintf(yyout,"\taddiu $sp $sp -4\n");
        }
        expressao
        {
            fprintf(yyout,"\tlw $t1 4($sp)\n");
            fprintf(yyout,"\taddiu $sp $sp 4\n");
            fprintf(yyout,"\tmult $t1, $a0\n");
            fprintf(yyout,"\tmflo $a0\n");
           
        }
     
    | expressao T_DIV 
    {
        fprintf(yyout,"\tsw $a0 0($sp)\n");
        fprintf(yyout,"\taddiu $sp $sp -4\n");
    }
    expressao
    {
        fprintf(yyout,"\tlw $t1 4($sp)\n");
        fprintf(yyout,"\taddiu $sp $sp 4\n");
        fprintf(yyout,"\tdiv $t1, $a0\n");
        fprintf(yyout,"\tmflo $a0\n");
        
    } 
    |expressao T_MAIOR
    {
        fprintf(yyout,"\tsw $a0 0($sp)\n");
        fprintf(yyout,"\taddiu $sp $sp -4\n");
    }
    expressao
    {
        fprintf(yyout,"\tlw $t1 4($sp)\n");
        fprintf(yyout,"\taddiu $sp $sp 4\n");
        fprintf(yyout,"\tslt $a0, $a0, $t1\n");
        empilha(LOG); 
    }
    |  expressao T_MENOR
    {
        fprintf(yyout,"\tsw $a0 0($sp)\n");
        fprintf(yyout,"\taddiu $sp $sp -4\n");
    }
    expressao
    {
        fprintf(yyout,"\tlw $t1 4($sp)\n");
        fprintf(yyout,"\taddiu $sp $sp 4\n");
        fprintf(yyout,"\tslt $a0, $t1, $a0\n");
        empilha(LOG); 
    }
    | expressao T_IGUAL
        {
            fprintf(yyout, "\tsw $a0 0($sp)\n");
            fprintf(yyout, "\taddiu $sp $sp -4\n");
        }
        expressao
        {
            fprintf(yyout, "\tlw $t1 4($sp)\n");
            fprintf(yyout, "\taddiu $sp $sp 4\n");

            int rotuloCondicao = ++rotulo;  
            int rotuloFim = ++rotulo; 
            empilhaRotulo(rotuloCondicao);  
            empilhaRotulo(rotuloFim);  

            fprintf(yyout, "\tbeq $a0, $t1, L%d\n", rotuloCondicao);  
            fprintf(yyout, "\tli $a0, 0\n");              
            fprintf(yyout, "\tj L%d\n", rotuloFim);             

            fprintf(yyout, "L%d:\tli $a0, 1\n", rotuloCondicao);  
            fprintf(yyout, "L%d:\tnop\n", rotuloFim);        

            desempilhaRotulo(); 
            desempilhaRotulo();  

            empilha(LOG); 
        }

    | expressao T_E
        {
            fprintf(yyout, "\tsw $a0 0($sp)\n");
            fprintf(yyout, "\taddiu $sp $sp -4\n");
        }
        expressao
        {
            fprintf(yyout, "\tlw $t1 4($sp)\n");
            fprintf(yyout, "\taddiu $sp $sp 4\n");

            int rotuloCondicao = ++rotulo;
            int rotuloFim = ++rotulo;

            empilhaRotulo(rotuloCondicao);
            empilhaRotulo(rotuloFim);

            fprintf(yyout, "\tbeqz $a0, L%d\n", rotuloCondicao);
            fprintf(yyout, "\tbeqz $t1, L%d\n", rotuloCondicao);
            fprintf(yyout, "\tli $a0, 1\n");
            fprintf(yyout, "\tj L%d\n", rotuloFim);
            fprintf(yyout, "L%d:\tli $a0, 0\n", rotuloCondicao);
            fprintf(yyout, "L%d:\tnop\n", rotuloFim);

            desempilhaRotulo();
            desempilhaRotulo();
            empilha(LOG); 
    }

    | expressao T_OU
        {
            fprintf(yyout, "\tsw $a0 0($sp)\n");
            fprintf(yyout, "\taddiu $sp $sp -4\n");
        }
    expressao
        {
            fprintf(yyout, "\tlw $t1 4($sp)\n");
            fprintf(yyout, "\taddiu $sp $sp 4\n");

            int rotuloCondicao = ++rotulo;
            int rotuloFim = ++rotulo;

            fprintf(yyout, "\tbnez $a0, L%d\n", rotuloCondicao);
            fprintf(yyout, "\tbnez $t1, L%d\n", rotuloCondicao); 
            fprintf(yyout, "\tli $a0, 0\n");
            fprintf(yyout, "\tj L%d\n", rotuloFim); 
            fprintf(yyout, "L%d:\tli $a0, 1\n", rotuloCondicao);
            fprintf(yyout, "L%d:\tnop\n", rotuloFim);

            desempilhaRotulo();
            desempilhaRotulo();
            empilha(LOG); 
        }

    | termo
        ;

termo 
    : T_NUM         
    {
        fprintf (yyout, "\tli $a0 %s\n",atomo);
        empilha(INT);
    }
    | T_IDENT       
        {
            int pos = buscaSimbolo(atomo);
            fprintf(yyout, "\tlw $a0 %s\n",atomo);
            empilha(tabSimb[pos].tip); 
        
        }
    | T_V           
        {
            fprintf(yyout, "\tli $a0\t10\n");
            empilha(LOG); 
        }
    | T_F          
     {
        fprintf(yyout, "\tli $a0\t10\n");
        empilha(LOG);    
    }
    |T_NAO termo
{
    int tipo = desempilha();  
    if (tipo != LOG) {  
        yyerror("Incompatibilidade de tipos");
    }

    int rotuloCondicao = ++rotulo; 
    int rotuloFim = ++rotulo;  

    empilhaRotulo(rotuloCondicao);  
    empilhaRotulo(rotuloFim);  

    fprintf(yyout, "\tbeqz $a0, L%d\n", rotuloCondicao);  
    fprintf(yyout, "\tli $a0, 0\n");          
    fprintf(yyout, "\tj L%d\n", rotuloFim);          
    fprintf(yyout, "L%d:\tli $a0, 1\n", rotuloCondicao);  
    fprintf(yyout, "L%d:\tnop\n", rotuloFim);        

    desempilhaRotulo();  
    desempilhaRotulo();  

    empilha(LOG); 
}
    ;
    | T_ABRE expressao T_FECHA 
    ;

%%

int main(int argc, char *argv[]){

    char nameIn[30], nameOut[30], *p;

    if (argc < 2){
        printf("Uso: \n\t%s <nomefonte>[.simples]\n\n",argv[0]);
        return 10;
    }

    p = strstr(argv[1],".simples");

    if (p) *p = 0;

    strcpy(nameIn,argv[1]);
    strcat(nameIn,".simples");
    strcpy(nameOut,argv[1]);
    strcat(nameOut,".asm");
    
    yyin = fopen(nameIn, "rt");
    yyout = fopen(nameOut,"wt");

    yyparse();
    puts("Programa ok!");
    fclose(yyin);
    fclose(yyout);
    return 0;
}