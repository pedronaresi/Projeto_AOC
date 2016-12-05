######################################################################
# 			     Tetris                                  #
######################################################################
#  Developed by: Pedro Naresi, Jaime Ossada, Bruno Ogata, Joao       #
# Mesquita							     #
######################################################################
#	This program requires the Keyboard and Display MMIO          #
#       and the Bitmap Display to be connected to MIPS.              #
#								     #
#       Bitmap Display Settings:                                     #
#	Unit Width: 8						     #
#	Unit Height: 8						     #
#	Display Width: 512					     #
#	Display Height: 512					     #
#	Base Address for Display: 0x10008000 ($gp)		     #
#	Nu						             #
######################################################################

.data
	corblocoI:		.word 0x0000ffff		#Cor do Bloco I: Azul claro
	corblocoJ:		.word 0x000000cd		#Cor do Bloco J: Azul escuro
	corblocoL:		.word 0x00ffa500		#Cor do Bloco L: Laranja
	corblocoO:		.word 0x00ffff00		#Cor do Bloco O: Amarelo
	corblocoS:		.word 0x0000ff00		#Cor do Bloco S: Verde
	corblocoT:		.word 0x009400d3		#Cor do Bloco T: Roxo
	corblocoZ:		.word 0x00ff0000		#Cor do Bloco Z: Vermelho
	corMargemJogo:		.word 0x00c0c0c0		#Cor da Margem Jogo: Silver
	corMargem:		.word 0x00ffffff		#Cor da Margem: Branco
	corFundo:		.word 0x00000000		#Cor do Fundo: Preto
	mode:			.word 0
	IDblocoI: 		.word 0				#ID para gerar o bloco I
	IDblocoJ: 		.word 1				#ID para gerar o bloco I
	IDblocoL: 		.word 2				#ID para gerar o bloco I
	IDblocoO: 		.word 3				#ID para gerar o bloco I
	IDblocoS: 		.word 4				#ID para gerar o bloco I
	IDblocoT: 		.word 5				#ID para gerar o bloco I
	IDblocoZ: 		.word 6				#ID para gerar o bloco I
	PieceArray:		.word 0:220			#Cria Matriz de Peças de 220 espaços com todos já inicializados com 0
	SpawnArray:		.word 0:8			#Matriz de Próxima Peça 
.text

.globl main


main:
	jal NewGame
	
	li $v0, 10
	syscall

######################################################
# Deixa a tela preta
######################################################

NewGame:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal TelaPreta
	TETRIS:
		li $a0, 2				# $a0 the x coordinate
		li $a1, 3				# $a1 the y starting coordinate
		lw $a2, corMargem			# $a2 the color
		li $a3, 61				# $a3 the x ending coordinate
		jal DrawHorizontalLine

		li $a1, 2
		jal DrawHorizontalLine

		li $a1, 4
		jal DrawHorizontalLine

		li $a1, 24
		jal DrawHorizontalLine

		li $a1, 25
		jal DrawHorizontalLine

		li $a1, 26
		jal DrawHorizontalLine

		#Desenha "T"
		li $a0, 2
		li $a1, 7
		lw $a2, corblocoZ
		li $a3, 10
		jal DrawHorizontalLine

		li $a1, 8
		jal DrawHorizontalLine

		li $a1, 9
		jal DrawHorizontalLine

		li $a0, 5
		li $a1, 10
		li $a3, 21
		jal DrawVerticalLine

		li $a0, 6
		jal DrawVerticalLine
		li $a0, 7
		jal DrawVerticalLine

		#Desenha "E"

		li $a0, 13
		li $a1, 7
		lw $a2, corblocoL
		jal DrawVerticalLine

		li $a0, 14
		jal DrawVerticalLine

		li $a0, 15
		jal DrawVerticalLine

		li $a0, 16
		li $a3 21
		jal DrawHorizontalLine

		li $a1, 8
		jal DrawHorizontalLine

		li $a1, 9
		jal DrawHorizontalLine

		li $a1, 21
		jal DrawHorizontalLine

		li $a1, 20
		jal DrawHorizontalLine

		li $a1, 19
		jal DrawHorizontalLine

		li $a1, 13
		li $a3, 19
		jal DrawHorizontalLine

		li $a1, 14
		jal DrawHorizontalLine

		li $a1, 15
		jal DrawHorizontalLine

		#Desenha "T"
		li $a0, 24
		li $a1, 7
		lw $a2, corblocoO
		li $a3, 32
		jal DrawHorizontalLine

		li $a1, 8
		jal DrawHorizontalLine

		li $a1, 9
		jal DrawHorizontalLine

		li $a0, 27
		li $a1, 10
		li $a3, 21
		jal DrawVerticalLine

		li $a0, 28
		jal DrawVerticalLine
		li $a0, 29
		jal DrawVerticalLine

		#Desenha "R"
		li $a0, 35
		li $a1, 7
		lw $a2, corblocoS
		li $a3, 21
		jal DrawVerticalLine

		li $a0, 36
		jal DrawVerticalLine

		li $a0, 37
		jal DrawVerticalLine

		li $a0, 38
		li $a3, 42
		jal DrawHorizontalLine

		li $a1, 8
		li $a3, 43
		jal DrawHorizontalLine

		li $a1, 9
		jal DrawHorizontalLine

		li $a0, 41
		li $a1, 10
		li $a3, 43
		jal DrawHorizontalLine

		li $a1, 11
		jal DrawHorizontalLine

		li $a1, 12
		jal DrawHorizontalLine

		li $a1, 13
		li $a0, 38
		jal DrawHorizontalLine

		li $a3, 42
		li $a1, 14
		jal DrawHorizontalLine

		li $a0, 38
		li $a3, 39
		li $a1, 15
		jal DrawHorizontalLine

		li $a1, 16
		li $a3, 40
		jal DrawHorizontalLine

		li $a0, 39
		li $a3, 41
		li $a1, 17
		jal DrawHorizontalLine

		li $a1, 18
		li $a0, 40
		li $a3, 42
		jal DrawHorizontalLine

		li $a0, 41
		li $a3, 43
		li $a1, 19
		jal DrawHorizontalLine

		li $a1, 20
		li $a0, 42
		li $a3, 43
		jal DrawHorizontalLine

		li $a1, 21
		jal DrawHorizontalLine

		#Desenha "I"

		li $a0, 46
		li $a1, 7
		lw $a2, corblocoI
		li $a3, 21
		jal DrawVerticalLine

		li $a0, 47
		jal DrawVerticalLine

		li $a0, 48
		jal DrawVerticalLine

		#Desenha "S"

		li $a0, 52
		li $a1, 7
		lw $a2, corblocoT
		li $a3, 61
		jal DrawHorizontalLine

		li $a0, 51
		li $a1, 8
		jal DrawHorizontalLine

		li $a1, 9
		jal DrawHorizontalLine

		li $a1, 10
		li $a3, 53
		jal DrawHorizontalLine

		li $a1, 11
		jal DrawHorizontalLine

		li $a1, 12
		jal DrawHorizontalLine

		li $a1, 13
		li $a3, 60
		jal DrawHorizontalLine

		li $a1, 14
		li $a3, 61
		jal DrawHorizontalLine

		li $a0, 52
		li $a1, 15
		jal DrawHorizontalLine

		li $a0, 59
		li $a1, 16
		jal DrawHorizontalLine

		li $a1, 17
		jal DrawHorizontalLine

		li $a1, 18
		jal DrawHorizontalLine

		li $a0, 51
		li $a1, 19
		jal DrawHorizontalLine

		li $a1, 20
		jal DrawHorizontalLine

		li $a1, 21
		li $a3, 60
		jal DrawHorizontalLine

	PressOne:
		#Desenha P

		li $a0, 18
		li $a1, 39
		lw $a2, corMargem
		li $a3, 20
		jal DrawHorizontalLine

		li $a0, 18
		li $a1, 40
		li $a3, 18
		jal DrawHorizontalLine

		li $a0, 21
		li $a3,21
		jal DrawHorizontalLine

		li $a0, 18
		li $a1, 41
		li $a3, 18
		jal DrawHorizontalLine

		li $a0, 21
		li $a3, 21
		jal DrawHorizontalLine

		li $a0, 18
		li $a1, 42
		li $a3, 20
		jal DrawHorizontalLine

		li $a0, 18
		li $a1, 43
		li $a3, 18
		jal DrawHorizontalLine

		li $a0, 18
		li $a1, 44
		li $a3, 18
		jal DrawHorizontalLine

		li $a0, 18
		li $a1, 45
		li $a3, 18
		jal DrawHorizontalLine

		#Desenha R
		li $a0, 24
		li $a1, 39
		li $a3, 26
		jal DrawHorizontalLine

		li $a0, 24
		li $a1, 40
		li $a3, 24
		jal DrawHorizontalLine

		li $a0, 27
		li $a1, 40
		li $a3, 27
		jal DrawHorizontalLine

		li $a0, 24
		li $a1, 41
		li $a3, 24
		jal DrawHorizontalLine

		li $a0, 27
		li $a1, 41
		li $a3, 27
		jal DrawHorizontalLine

		li $a0, 24
		li $a1, 42
		li $a3, 26
		jal DrawHorizontalLine

		li $a0, 24
		li $a1, 43
		li $a3, 24
		jal DrawHorizontalLine

		li $a0, 27
		li $a1, 43
		li $a3, 27
		jal DrawHorizontalLine

		li $a0, 24
		li $a1, 44
		li $a3, 24
		jal DrawHorizontalLine

		li $a0, 27
		li $a1, 44
		li $a3, 27
		jal DrawHorizontalLine

		li $a0, 24
		li $a1, 45
		li $a3, 24
		jal DrawHorizontalLine

		li $a0, 27
		li $a1, 45
		li $a3, 27
		jal DrawHorizontalLine

		#Desenha E
		li $a0, 30
		li $a1, 39
		li $a3, 33
		jal DrawHorizontalLine

		li $a0, 30
		li $a1, 40
		li $a3, 30
		jal DrawHorizontalLine

		li $a0, 30
		li $a1, 41
		li $a3, 30
		jal DrawHorizontalLine

		li $a0, 30
		li $a1, 42
		li $a3, 32
		jal DrawHorizontalLine

		li $a0, 30
		li $a1, 43
		li $a3, 30
		jal DrawHorizontalLine

		li $a0, 30
		li $a1, 44
		li $a3, 30
		jal DrawHorizontalLine

		li $a0, 30
		li $a1, 45
		li $a3, 33
		jal DrawHorizontalLine

		#Desenha S

		li $a0, 36
		li $a1, 39
		li $a3, 39
		jal DrawHorizontalLine

		li $a0, 36
		li $a1, 40
		li $a3, 36
		jal DrawHorizontalLine

		li $a0, 36
		li $a1, 41
		li $a3, 36
		jal DrawHorizontalLine

		li $a0, 36
		li $a1, 42
		li $a3, 39
		jal DrawHorizontalLine

		li $a0, 39
		li $a1, 43
		li $a3, 39
		jal DrawHorizontalLine

		li $a0, 39
		li $a1, 44
		li $a3, 39
		jal DrawHorizontalLine

		li $a0, 36
		li $a1, 45
		li $a3, 39
		jal DrawHorizontalLine

		#Desenha S

		li $a0, 42
		li $a1, 39
		li $a3, 45
		jal DrawHorizontalLine

		li $a0, 42
		li $a1, 40
		li $a3, 42
		jal DrawHorizontalLine

		li $a0, 42
		li $a1, 41
		li $a3, 42
		jal DrawHorizontalLine

		li $a0, 42
		li $a1, 42
		li $a3, 45
		jal DrawHorizontalLine

		li $a0, 45
		li $a1, 43
		li $a3, 45
		jal DrawHorizontalLine

		li $a0, 45
		li $a1, 44
		li $a3, 45
		jal DrawHorizontalLine

		li $a0, 42
		li $a1, 45
		li $a3, 45
		jal DrawHorizontalLine

		#Desenha 1

		li $a0, 31
		li $a1, 49
		li $a3, 32
		jal DrawHorizontalLine

		li $a0, 32
		li $a1, 50
		li $a3, 32
		jal DrawHorizontalLine

		li $a0, 32
		li $a1, 51
		li $a3, 32
		jal DrawHorizontalLine

		li $a0, 32
		li $a1, 52
		li $a3, 32
		jal DrawHorizontalLine

		li $a0, 32
		li $a1, 53
		li $a3, 32
		jal DrawHorizontalLine

		li $a0, 32
		li $a1, 54
		li $a3, 32
		jal DrawHorizontalLine

		li $a0, 31
		li $a1, 55
		li $a3, 33
		jal DrawHorizontalLine




	SelectMode:
		lw $t1, 0xFFFF0004		# check to see which key has been pressed
		beq $t1, 0x00000031, ComecaJogo # 1 pressed

		li $a0, 500	#
		li $v0, 32	# pause for 250 milisec
		syscall		#

		j SelectMode    # Jump back to the top of the wait loop

	ComecaJogo:
		jal ZeraBotoes
		jal TelaPreta
		jal TelaJogo
		
		#Testando funções, as chamadas abaixas serão retiradas
		lw $t0, corblocoZ
		la $t1, SpawnArray
		sw $t0, 0($t1)
		sw $t0, 4($t1)
		sw $t0, 8($t1)
		sw $t0, 12($t1)
		sw $t0, 16($t1)
		sw $t0, 20($t1)
		sw $t0, 24($t1)
		sw $t0, 28($t1)
		jal CopiaMemoriaProximaPeca
		jal Spawn
		jal CopiaMemoria
		#Fim de Testes
		
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		jr $ra
	


TelaJogo:
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		#Margem de cima
		li $a0, 0
		li $a1, 0
		lw $a2, corMargemJogo
		li $a3, 63
		jal DrawHorizontalLine

		li $a0, 0
		li $a1, 1
		li $a3, 63
		jal DrawHorizontalLine


		#Margem de baixo
		li $a0, 0
		li $a1, 63
		li $a3, 63
		jal DrawHorizontalLine

		li $a0, 0
		li $a1, 62
		li $a3, 63
		jal DrawHorizontalLine

		#Margem Lateral Esquerda
		li $a0, 0
		li $a1, 0
		li $a3, 63
		jal DrawVerticalLine

		li $a0, 1
		li $a1, 0
		li $a3, 63
		jal DrawVerticalLine


		#Margem Lateral Direita
		li $a0, 32
		li $a1, 0
		li $a3, 63
		jal DrawVerticalLine
		li $a0, 33
		li $a1, 0
		li $a3, 63
		jal DrawVerticalLine
		li $a0, 34
		li $a1, 0
		li $a3, 63
		jal DrawVerticalLine
		li $a0, 35
		li $a1, 0
		li $a3, 63
		jal DrawVerticalLine
		li $a0, 36
		li $a1, 0
		li $a3, 63
		jal DrawVerticalLine
		li $a0, 37
		li $a1, 0
		li $a3, 63
		jal DrawVerticalLine
		li $a0, 38
		li $a1, 0
		li $a3, 63
		jal DrawVerticalLine
		li $a0, 39
		li $a1, 0
		li $a3, 63
		jal DrawVerticalLine
		li $a0, 40
		li $a1, 0
		li $a3, 63
		jal DrawVerticalLine
		li $a0, 41
		li $a1, 0
		li $a3, 63
		jal DrawVerticalLine

		li $a0, 42
		li $a1, 0
		li $a3, 63
		jal DrawVerticalLine

		li $a0, 43
		li $a1, 0
		li $a3, 63
		jal DrawVerticalLine

		li $a0, 44
		li $a1, 0
		li $a3, 63
		jal DrawVerticalLine

		li $a0, 45
		li $a1, 0
		li $a3, 63
		jal DrawVerticalLine

		li $a0, 46
		li $a1, 0
		li $a3, 63
		jal DrawVerticalLine

		li $a0, 47
		li $a1, 0
		li $a3, 63
		jal DrawVerticalLine

		li $a0, 48
		li $a1, 0
		li $a3, 63
		jal DrawVerticalLine

		li $a0, 49
		li $a1, 0
		li $a3, 63
		jal DrawVerticalLine

		li $a0, 50
		li $a1, 0
		li $a3, 63
		jal DrawVerticalLine

		li $a0, 51
		li $a1, 0
		li $a3, 63
		jal DrawVerticalLine

		li $a0, 52
		li $a1, 0
		li $a3, 63
		jal DrawVerticalLine

		li $a0, 53
		li $a1, 0
		li $a3, 63
		jal DrawVerticalLine

		li $a0, 54
		li $a1, 0
		li $a3, 63
		jal DrawVerticalLine

		li $a0, 55
		li $a1, 0
		li $a3, 63
		jal DrawVerticalLine

		li $a0, 56
		li $a1, 0
		li $a3, 63
		jal DrawVerticalLine

		li $a0, 57
		li $a1, 0
		li $a3, 63
		jal DrawVerticalLine

		li $a0, 58
		li $a1, 0
		li $a3, 63
		jal DrawVerticalLine

		li $a0, 59
		li $a1, 0
		li $a3, 63
		jal DrawVerticalLine

		li $a0, 60
		li $a1, 0
		li $a3, 63
		jal DrawVerticalLine

		li $a0, 61
		li $a1, 0
		li $a3, 63
		jal DrawVerticalLine

		li $a0, 62
		li $a1, 0
		li $a3, 63
		jal DrawVerticalLine

		li $a0, 63
		li $a1, 0
		li $a3, 63
		jal DrawVerticalLine

		#Desenhando Espaço de Próxima Peça
		#X Absoluto Base: 45
		#Y Abosuluto Base: 10
		li $a0, 45
		li $a1 10
		lw $a2, corFundo
		li $a3, 55
		jal DrawHorizontalLine
		
		li $a0, 45
		li $a1 11
		lw $a2, corFundo
		li $a3, 55
		jal DrawHorizontalLine
		
		li $a0, 45
		li $a1 12
		lw $a2, corFundo
		li $a3, 55
		jal DrawHorizontalLine
		
		li $a0, 45
		li $a1 13
		lw $a2, corFundo
		li $a3, 55
		jal DrawHorizontalLine
		
		li $a0, 45
		li $a1 14
		lw $a2, corFundo
		li $a3, 55
		jal DrawHorizontalLine
		
		li $a0, 45
		li $a1 15
		lw $a2, corFundo
		li $a3, 55
		jal DrawHorizontalLine

		#Bloco Tetris
		
		lw $ra, 0($sp)
		addi $sp, $sp, 4

		jr $ra

TelaPreta:
		lw $t0, corFundo
		li $t1, 16384 # O Numero de pixels do Display
	StartCLoop:
		subi $t1, $t1, 4
		addu $t2, $t1, $gp
		sw $t0, ($t2)
		beqz $t1, EndCLoop
		j StartCLoop
	EndCLoop:
		jr $ra

ZeraBotoes:
		sw $zero, 0xFFFF0000		# clear the button pushed bit
		jr $ra



#Spawna a nova peça
Spawn:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	la $t0, PieceArray
	addi $t0, $t0, 12
	la $t1, SpawnArray
	
	li $t2, 0
	SpawnPieceILoop:
		li $t3, 0
		SpawnPieceJLoop:
			lw $a0, 0($t1)
			addi $t1, $t1, 4
			sw $a0, 0($t0)
			addi $t0, $t0, 4
			addi $t3, $t3, 1
			bne $t3, 4, SpawnPieceJLoop
		
		addi $t2, $t2, 1
		addi $t0, $t0, 24
		bne $t2, 2, SpawnPieceILoop
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
		

#Copia PieceArray para a Memória da Tela
CopiaMemoria:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	
	la $t0, PieceArray
	addi $t0, $t0, 80 #Pula os 20 primeiros espaços do Array, pois as duas primeiras linhas não aparecem na tela
	li $t2, 0
	CopyILoop:
		li $t1, 0
		CopyJLoop:
			move $a0, $t1
			move $a1, $t2
			lw $a2, 0($t0)	
			addi $sp, $sp, -4
			sw $t0, 0($sp)
			addi $sp, $sp, -4
			sw $t1, 0($sp)
			addi $sp, $sp, -4
			sw $t2, 0($sp)
			jal DesenhaBloco
			lw $t2, 0($sp)
			addi $sp, $sp, 4
			lw $t1, 0($sp)
			addi $sp, $sp, 4
			lw $t0, 0($sp)
			addi $sp, $sp, 4
			addi $t1, $t1, 1
			addi $t0, $t0, 4
			bne $t1, 10, CopyJLoop
		addi $t2, $t2, 1
		bne $t2, 20, CopyILoop
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
	

	# $a0 the x starting coordinate
	# $a1 the y coordinate
	# $a2 the color
DesenhaBloco:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	#Transforma Coordenada x relativa do Grid em Absoluta da tela
	#AbsX = 2 + (RelX * 3)
	li $t0, 3
	mul $a0, $a0, $t0
	addi $a0, $a0, 2
	
	#Transforma Coordenada 5 relativa do Grid em Absoluta da tela
	#AbsY = 2 + (RelY * 3)
	li $t0, 3
	mul $a1, $a1, $t0
	addi $a1, $a1, 2
	
	#Desenha o Bloco 3x3
	li $t0, 0
	move $t4, $a0
	move $t5, $a1
	BlockDrawILoop:
		li $t1, 0
		BlockDrawJLoop:
			addi $sp, $sp, -4
			sw $t0, 0($sp)
			addi $sp, $sp, -4
			sw $t1, 0($sp)
			add $a0, $t4, $t0
			add $a1, $t5, $t1
			jal DrawPoint
			lw $t1, 0($sp)
			addi $sp, $sp, 4
			lw $t0, 0($sp)
			addi $sp, $sp, 4
			addi $t1, $t1, 1
			bne $t1, 3, BlockDrawJLoop
		addi $t0, $t0, 1
		bne $t0, 3, BlockDrawILoop
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

	# $a0 the x starting coordinate
	# $a1 the y coordinate
	# $a2 the color
	# $a3 the x ending coordinate

#Desenha a Proxima Peca no espaco indicado copiando da memoria SpawnArray
#Coordenada X Base : 45
#Coordenada Y Base : 10
CopiaMemoriaProximaPeca:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	la $t0, SpawnArray
	
	li $t2, 0
	SpawnILoop:
		li $t1, 0
		SpawnJLoop:
			#RelX = 45 + (t1 * 3)
			#RelY = 10 + (t2 * 3)
			mul $t3, $t1, 3
			add $t3, $t3, 45
			mul $t4, $t2, 3
			add $t4, $t4, 10
			lw $t5, 0($t0)
			addi $t0, $t0, 4
			
		
			
			li $t6, 0
			InsideSpawnILoop:
				addi $sp, $sp, -4
				sw $t0, 0($sp)
				addi $sp, $sp, -4
				sw $t1, 0($sp)
				addi $sp, $sp, -4
				sw $t2, 0($sp)
				addi $sp, $sp, -4
				sw $t3, 0($sp)
				addi $sp, $sp, -4
				sw $t4, 0($sp)
				addi $sp, $sp, -4
				sw $t5, 0($sp)
				addi $sp, $sp, -4
				sw $t6, 0($sp)
				
				move $a0, $t3
				add $a1, $t4, $t6
				move $a2, $t5
				addi $a3, $a0, 3
				jal DrawHorizontalLine
				
				lw $t6, 0($sp)
				addi $sp, $sp, 4
				lw $t5, 0($sp)
				addi $sp, $sp, 4
				lw $t4, 0($sp)
				addi $sp, $sp, 4
				lw $t3, 0($sp)
				addi $sp, $sp, 4
				lw $t2, 0($sp)
				addi $sp, $sp, 4
				lw $t1, 0($sp)
				addi $sp, $sp, 4
				lw $t0, 0($sp)
				addi $sp, $sp, 4
				
				addi $t6, $t6, 1
				bne $t6, 3, InsideSpawnILoop
				
			addi $t1, $t1, 1
			bne $t1, 4, SpawnJLoop
		addi $t2, $t2, 1
		bne $t2, 2, SpawnILoop
	
	
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

DrawHorizontalLine:

		addi $sp, $sp, -4
   		sw $ra, 0($sp)

		sub $t9, $a3, $a0
		move $t1, $a0

	HorizontalLoop:

		add $a0, $t1, $t9
		jal DrawPoint
		addi $t9, $t9, -1
		
		bge $t9, 0, HorizontalLoop

		lw $ra, 0($sp)		# put return back
   		addi $sp, $sp, 4

		jr $ra

# $a0 the x coordinate
# $a1 the y starting coordinate
# $a2 the color
# $a3 the y ending coordinate

DrawVerticalLine:

		addi $sp, $sp, -4
   		sw $ra, 0($sp)

		sub $t9, $a3, $a1
		move $t1, $a1

	VerticalLoop:

		add $a1, $t1, $t9
		jal DrawPoint
		addi $t9, $t9, -1

		bge $t9, 0, VerticalLoop

		lw $ra, 0($sp)		# put return back
   		addi $sp, $sp, 4

		jr $ra

# $a0 contains x position, $a1 contains y position, $a2 contains the color
DrawPoint:
		sll $t0, $a1, 6   # multiply y-coordinate by 64 (length of the field)
		addu $v0, $a0, $t0
		sll $v0, $v0, 2
		addu $v0, $v0, $gp
		sw $a2, ($v0)		# draw the color to the location

		jr $ra


# $a0 the x starting coordinate
# $a1 the y coordinate
# $a2 the color
# $a3 the x ending coordinate

