.text
	.globl main
main:	nop
	la $a0 _const0
	li $v0, 4
	syscall
	li $v0, 5
	syscall
	sw $v0, n
	li $a0 1
	sw $a0, fat
L1:	nop
	lw $a0 n
	sw $a0 0($sp)
	addiu $sp $sp -4
	li $a0 0
	lw $t1 4($sp)
	addiu $sp $sp 4
	slt $a0, $a0, $t1
	beqz $a0, L2
	lw $a0 fat
	sw $a0 0($sp)
	addiu $sp $sp -4
	lw $a0 n
	lw $t1 4($sp)
	addiu $sp $sp 4
	mult $t1, $a0
	mflo $a0
	sw $a0, fat
	lw $a0 n
	sw $a0 0($sp)
	addiu $sp $sp -4
	li $a0 1
	lw $t1 4($sp)
	addiu $sp $sp 4
	sub $a0, $t1, $a0
	sw $a0, n
	j L1
L2:	nop
	la $a0 _const1
	li $v0, 4
	syscall
	lw $a0 fat
	li $v0, 1
	syscall
	la $a0 _ent
	li $v0, 4
	syscall
fim:	nop
	li $v0, 10
	li $a0, 0
	syscall
.data
	n: .word 1
	fat: .word 1
	_esp: .asciiz " "
	_ent: .asciiz "\n"
	_const0: .asciiz "Digite o valor de n: "
	_const1: .asciiz "fatorial = "
