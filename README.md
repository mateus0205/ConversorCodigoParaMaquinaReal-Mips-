
# Compilador para Geração de Código MIPS

Este projeto consiste em um compilador que traduz programas escritos em uma linguagem simples (`.simples`) para código de máquina MIPS. O compilador foi desenvolvido como parte da disciplina de Compiladores do Bacharelado em Ciência da Computação da Universidade Federal de Alfenas (UNIFAL-MG).

## Objetivo

O objetivo principal deste trabalho é gerar código MIPS a partir de programas escritos em uma linguagem simples, simulando uma máquina de pilha na arquitetura MIPS. O compilador também permite a escrita de valores literais e verifica a compatibilidade de tipos em comandos de atribuição, seleção e repetição.

## Funcionalidades

- Tradução de instruções da linguagem simples para instruções MIPS.
- Simulação de uma máquina de pilha usando registradores MIPS.
- Verificação de compatibilidade de tipos em comandos de atribuição, seleção e repetição.
- Geração de código MIPS para operações aritméticas, lógicas e de controle de fluxo.
- Suporte para escrita de literais e leitura de valores do usuário.

## Estrutura do Projeto

O projeto é composto pelos seguintes arquivos:

- **lexico.l**: Arquivo de definição do analisador léxico (Lex).
- **sintatico.y**: Arquivo de definição do analisador sintático (Bison).
- **utils.c**: Funções utilitárias para o compilador.
- **Makefile**: Script para compilar o projeto.
- **README.md**: Este arquivo, com informações sobre o projeto.

## Como Compilar e Executar

1. **Compilação do Compilador**:
   Para compilar o compilador, execute o seguinte comando no terminal:
   ```bash
   make
  Isso gerará o executável simples.

2. **Compilação de um programa .simples:**
   Para compilar um programa escrito na linguagem simples, use o seguinte comando:
   ```bash
    ./simples nome_do_arquivo[.simples]
  O compilador gerará um arquivo .asm com o código Mips correspondente. 

3. **Execução do Código MIPS:**
Para executar o código MIPS gerado, use o simulador MARS:
   ```bash
   java -jar Mars4_5.jar nome_do_arquivo.asm
