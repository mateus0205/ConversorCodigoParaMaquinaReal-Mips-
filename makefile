#+=============================================================
#|   UNIFAL - Universidade Federal de Alfenas.
#|       BACHARELADO EM CIENCIA DA COMPUTACAO.
#| Trabalho.. : Geracao de codigo MIPS
#| Disciplina : Compiladores
#| Professor. : Luiz Eduardo da Silva
#| Aluno..... : Mateus Henrique Martins
#| Data...... : 11/12/2024
#+=============================================================

lexico: lexico.l sintatico.y utils.c;
	flex -t lexico.l > lexico.c;\
	bison -v -d sintatico.y -o sintatico.c;\
	gcc sintatico.c -o simples

limpa:; 
	rm -f lexico.c sintatico.c sintatico.output *~ sintatico.h simples\