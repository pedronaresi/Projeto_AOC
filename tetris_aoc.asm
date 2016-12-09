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
	FixedArray:		.word 0:220			#Cria Matriz de Peças já fixadas. Mesmo tamanho de PieceArray
	SpawnArray:		.word 0:8			#Matriz de Próxima Peça
	RandomBag:		.word -1:7			#Bag de Spawn
	BagLength:		.word 0				#Tamanho da Bag
	CurrentPiece:		.word 0				#ID da Peça Atual
	NextPiece:		.word 0				#ID da Próxima Peça
	XRotation:		.word 0				#Coordenada X do Centro de Rotação da peça Atual
	YRotation:		.word 0				#Coordenada Y do Centro de Rotação da peça Atual
	Score:			.word -1				#Armazena a pontuacao
	Tick:			.word 0				#Tick Atual	
	ResetNumber:		.word 0				#Armazena o numero de resets no player(toda vez que a pontuacao chegar a 999 ele reseta)
	AuxModulus:		.word 0				#Data auxiliar para calcular modulo
	AuxModulus2:		.word 0				#Data auxiliar para calcular modulo
	TickSpeed:		.word 50000			#TickRate do Jogo
	PieceState:		.word 0				#Aux para a Rotação da peça I
	TempFixedArray:		.word 0:16			#Matriz Local de Blocos fixos
	TempPieceArray:		.word 0:16			#Matriz Local de Blocos Móveis
	TempRotateArray:	.word 0:16			#Matriz Local de Blocos Rotacionados
.text

.globl main


main:
	jal ZeraBotoes
	jal NewGame
	jal GameLoop
		
	li $v0, 10
	syscall


###########################################################
# 		Funções de Lógica de Jogo 		  #
###########################################################
#			Controles			  #
# 1 - Mover para Esquerda	#49#		  	  #
# 2 - Mover para Direita	#50#		  	  #
# 3 - Rotacionar Peça   	#51#		  	  #
# 4 - Drop			#52#		  	  #
# 5 - Restart Game		#53#		  	  #
###########################################################

GameLoop:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	LoopStart:
		#Ler botão e fazer ação se houver
		lw $t1, 0xFFFF0004
		beq $t1, 49, ButtonSwitch1
		beq $t1, 50, ButtonSwitch2
		beq $t1, 51, ButtonSwitch3
		beq $t1, 52, ButtonSwitch4
		beq $t1, 53, ButtonSwitch5
		j ButtonSwitchExit
		ButtonSwitch1:
			jal CheckLeftBoundary
			bnez $a0, DoAfter
			jal LeftMove
			jal CopiaMemoria
			jal CopiaMemoriaFixa
			lw $t0, XRotation
			addi $t0, $t0, -1
			sw $t0, XRotation
			j DoAfter
		ButtonSwitch2:
			jal CheckRightBoundary
			bnez $a0, DoAfter
			jal RightMove
			jal CopiaMemoria
			jal CopiaMemoriaFixa
			lw $t0, XRotation
			addi $t0, $t0, 1
			sw $t0, XRotation
			j DoAfter
		ButtonSwitch3:
			jal HardDrop
			jal CopiaMemoria
			jal CopiaMemoriaFixa
			j DoAfter
		ButtonSwitch4:
			lw $t0, CurrentPiece
			beqz $t0, DoAfter
			jal Rotate
			jal CopiaMemoria
			jal CopiaMemoriaFixa
			j DoAfter
		ButtonSwitch5:
			addi $sp, $sp, 4
			j main
		
		DoAfter:
		jal ZeraBotoes
		
		ButtonSwitchExit:
		
		#Atualiza Jogo
		la $t0, Tick
		lw $t1, 0($t0)
		addi $t1, $t1, 1
		sw $t1, 0($t0)
		lw $t5, TickSpeed
		move $t2, $t5
		slt $t3, $t1, $t2
		beq $t3, 1, LoopStart
		li $t1, 0
		sw $t1, ($t0)
		
		jal FixPieceCondition
		bne $a0, 1, Dropped
		jal CopyPieceToFixed
		jal LoseCondition
		bnez $a0, ExitGame
		jal ResetPieceArray
		jal SpawnNewPiece
		jal AllLineClear
		j NotDropped
		Dropped:
		jal DropPiece
		lw $t0, YRotation
		addi $t0, $t0, 1
		sw $t0, YRotation
		NotDropped:
		jal CopiaMemoria
		jal CopiaMemoriaFixa
		j LoopStart
		
		
	ExitGame:
		
	li $a0, 0
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

#Rotaciona a Peça
Rotate:
	addi $sp, $sp, -4 
	sw $ra, 0($sp)
	jal GetRotationArrayRegion
	jal GetFixedArrayRegion
	jal CreateRotatedArray
	jal CheckRotationOverlap
	bnez $a0, IgnoreRotation
	jal CommitRotation
	IgnoreRotation:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

#Copia a Região temporária rotacionada para a Piece Array
CommitRotation:
	addi $sp, $sp, -4 
	sw $ra, 0($sp)
	la $t0, TempRotateArray
	lw $t1, XRotation
	lw $t2, YRotation
	addi $t1, $t1, -2
	addi $t2, $t2, -1
	li $t3, 0
	CommitILoop:
		li $t4, 0
		CommitJLoop:
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
			
			add $a0, $t1, $t4
			add $a1, $t2, $t3
			lw $a2, 0($t0)
			jal SetValueToPieceArray
					
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
			
			addi $t0, $t0, 4
			addi $t4, $t4, 1
			bne $t4, 4, CommitJLoop
	addi $t3, $t3, 1
	bne $t3, 4, CommitILoop
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra


#Checa se há conflito de Peças
#Devolve em $a0: 1 se Sim, 0 se Não
CheckRotationOverlap: 
	addi $sp, $sp, -4 
	sw $ra, 0($sp)
	lw $t0, CurrentPiece
	la $t1, TempFixedArray
	la $t2, TempRotateArray
	li $t3, 0
	li $a0, 0
	RotationOverlapILoop:
		lw $t4, 0($t1)
		lw $t5, 0($t2)
		beqz $t4, NoOverlap
		beqz $t5, NoOverlap
		li $a0, 1
		j ExitOverlapFunction
		NoOverlap:
		addi $t1, $t1, 4
		addi $t2, $t2, 4
		addi $t3, $t3, 1
		bne $t3, 16, RotationOverlapILoop
	
	ExitOverlapFunction:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
	
#Gera a Matriz Rotacionada a partir da Matriz de rotação Móvel
CreateRotatedArray:
	addi $sp, $sp, -4 
	sw $ra, 0($sp)
	lw $t0, CurrentPiece
	bne $t0, 1, GenericPiece
	jal ExceptionPiece
	j ExitRotateArrayFunction
	
	
	
	GenericPiece:
	sw $ra, 0($sp)
	la $t0, TempRotateArray
	la $t1, TempPieceArray
	
	sw $zero 0($t0)
	
	lw $t2, 36($t1)
	sw $t2, 4($t0)
	
	lw $t2, 20($t1)
	sw $t2, 8($t0)
	
	lw $t2, 4($t1)
	sw $t2, 12($t0)
	
	sw $zero, 16($t0)
	
	lw $t2, 40($t1)
	sw $t2, 20($t0)
	
	lw $t2, 24($t1)
	sw $t2, 24($t0)
	
	lw $t2, 8($t1)
	sw $t2, 28($t0)
	
	sw $zero, 32($t0)
	
	lw $t2, 44($t1)
	sw $t2, 36($t0)
	
	lw $t2, 28($t1)
	sw $t2, 40($t0)
	
	lw $t2, 12($t1)
	sw $t2, 44($t0)
	
	sw $zero, 48($t0)
	sw $zero, 52($t0)
	sw $zero, 56($t0)
	sw $zero, 60($t0)
	
	ExitRotateArrayFunction:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
#Faz a Exceção da peça I
ExceptionPiece:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	la $t0, TempRotateArray
	la $t1, TempPieceArray
	lw $t2, 24($t1)
	lw $t3, PieceState
	
	bnez $t3, Estado2
	sw $zero, 0($t0)
	sw $zero, 4($t0)
	sw $t2, 8($t0)
	sw $zero, 12($t0)
	sw $zero, 16($t0)
	sw $zero, 20($t0)
	sw $t2, 24($t0)
	sw $zero, 28($t0)
	sw $zero, 32($t0)
	sw $zero, 36($t0)
	sw $t2, 40($t0)
	sw $zero, 44($t0)
	sw $zero, 48($t0)
	sw $zero, 52($t0)
	sw $t2, 56($t0)
	sw $zero, 60($t0)
	
	li $t1, 1
	sw $t1, PieceState
	
	j ExitExceptionPiece
	Estado2:
	sw $zero, 0($t0)
	sw $zero, 4($t0)
	sw $zero, 8($t0)
	sw $zero, 12($t0)
	sw $t2, 16($t0)
	sw $t2, 20($t0)
	sw $t2, 24($t0)
	sw $t2, 28($t0)
	sw $zero, 32($t0)
	sw $zero, 36($t0)
	sw $zero, 40($t0)
	sw $zero, 44($t0)
	sw $zero, 48($t0)
	sw $zero, 52($t0)
	sw $zero, 56($t0)
	sw $zero, 60($t0)
	sw $zero, PieceState
	
	ExitExceptionPiece:
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
#Pega a Região de rotação móvel a partir do par (x,y) na memória
GetRotationArrayRegion:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	la $t5, TempPieceArray
	lw $t1, XRotation
	lw $t2, YRotation
	addi $t2, $t2, -1
	addi $t1, $t1 -2
	li $t3, 0
	RotArrayReILoop:
		li $t4, 0
		RotArrayReJLoop:
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
			
			add $a0, $t4, $t1
			add $a1, $t3, $t2
			jal GetPieceArrayElement
			
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
			
			sw $a0, 0($t5)
			addi $t5, $t5, 4
			
			addi $t4, $t4, 1
			bne $t4, 4, RotArrayReJLoop
		
		addi $t3, $t3, 1
		bne $t3, 4, RotArrayReILoop
		
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
#Pega a Região de rotação Fixa a partir do par (x,y) na memória
GetFixedArrayRegion:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	la $t5, TempFixedArray
	lw $t1, XRotation
	lw $t2, YRotation
	addi $t2, $t2, -1
	addi $t1, $t1 -2
	li $t3, 0
	RotFixedReILoop:
		li $t4, 0
		RotFixedReJLoop:

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
			
			add $a0, $t4, $t1
			add $a1, $t3, $t2
			jal GetFixedArrayElement
			

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
			
			sw $a0, 0($t5)
			addi $t5, $t5, 4
			
			addi $t4, $t4, 1
			bne $t4, 4, RotFixedReJLoop
		
		addi $t3, $t3, 1
		bne $t3, 4, RotFixedReILoop
		
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
#Checa quais Linhas devem ser limpas e as limpa se necessário
AllLineClear:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	li $t0, 2
	AllLineClearILoop:
		addi $sp, $sp, -4
		sw $t0, 0($sp)
		move $a0, $t0
		jal LineClear
		lw $t0, 0($sp)
		addi, $sp, $sp 4
		addi $t0, $t0, 1
		bne $t0, 22, AllLineClearILoop
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

#Dado um y, checa se a linha deve ser limpa e limpa se necessário
#$a0: Linha que deve ser limpa
LineClear:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	la $t0, FixedArray
	move $t1, $a0
	mul $t1, $t1, 10
	mul $t1, $t1, 4
	add $t0, $t0, $t1
	li $t1, 0
	LineClearILoop:
		lw $t2, 0($t0)
		beqz $t2, ExitLineClearFunction
		addi $t0, $t0, 4
		addi $t1, $t1, 1
		bne $t1, 10, LineClearILoop
	jal DropFixedPiece
	lw $t0, TickSpeed
	li $t1, 10000
	slt $t1, $t1, $t0
	bnez $t1, ExitLineClearFunction
	addi $t0, $t0, -500
	la $t1, TickSpeed
	sw $t0, 0($t1)
	
	ExitLineClearFunction:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra


#Desce a peça atual para seu limite
HardDrop:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	HardDropLoop:
		jal FixPieceCondition
		bnez $a0, QuitHardDropLoop
		jal DropPiece
		j HardDropLoop	
	QuitHardDropLoop:
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	

#Move todas as peças móveis para a esquerda
LeftMove:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	la $t0, PieceArray
	li $t1, 0
	LeftMoveILoop:
		lw $t2, 4($t0)
		sw $t2, 0($t0)
		addi $t0, $t0, 4
		addi $t1, $t1, 1
		bne $t1, 219, LeftMoveILoop
	li $a0, 9
	li $a1, 21
	li $a2, 0
	jal SetValueToPieceArray
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

#Move todas as peças móveis para a direita
RightMove:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	la $t0, PieceArray
	li $t1, 0
	lw $t2, 0($t0)
	sw $zero, 0($t0)
	addi $t0, $t0, 4
	RightMoveILoop:
		lw $t3, 0($t0)
		sw $t2, 0($t0)
		move $t2, $t3
		addi $t0, $t0, 4
		addi $t1, $t1, 1
		bne $t1, 219, RightMoveILoop
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

#Move todas as peças móveis para baixo a partir de um Y dado
#$a0: Y base
DropFixedPiece:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	li $t0, 0
	move $t1, $a0
	DropFixedPieceILoop:
		addi $sp, $sp, -4
		sw $t1, 0($sp)
		DropFixedPieceJLoop:
			
			move $a0, $t0
			addi $a1, $t1, -1
			addi $sp, $sp, -4
			sw $t0, 0($sp)
			addi $sp, $sp, -4
			sw $t1, 0($sp)
			jal GetFixedArrayElement
			lw $t1, 0($sp)
			addi $sp, $sp, 4
			lw $t0, 0($sp)
			addi $sp, $sp, 4
			move $a2, $a0
			move $a0, $t0
			move $a1, $t1
			addi $sp, $sp, -4
			sw $t0, 0($sp)
			addi $sp, $sp, -4
			sw $t1, 0($sp)
			jal SetValueToFixedArray
			lw $t1, 0($sp)
			addi $sp, $sp, 4
			lw $t0, 0($sp)
			addi $sp, $sp, 4
				
			addi $t1, $t1, -1
			bne $t1, 0, DropFixedPieceJLoop
		
		lw $t1, 0($sp)
		addi $sp, $sp, 4
		addi $t0, $t0, 1
		bne $t0, 10, DropFixedPieceILoop	
		
			
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
#Move todas as peças móveis para baixo
DropPiece:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	li $t0, 0
	
	DropPieceILoop:
		li $t1, 21
		DropPieceJLoop:
			
			move $a0, $t0
			addi $a1, $t1, -1
			addi $sp, $sp, -4
			sw $t0, 0($sp)
			addi $sp, $sp, -4
			sw $t1, 0($sp)
			jal GetPieceArrayElement
			lw $t1, 0($sp)
			addi $sp, $sp, 4
			lw $t0, 0($sp)
			addi $sp, $sp, 4
			move $a2, $a0
			move $a0, $t0
			move $a1, $t1
			addi $sp, $sp, -4
			sw $t0, 0($sp)
			addi $sp, $sp, -4
			sw $t1, 0($sp)
			jal SetValueToPieceArray
			lw $t1, 0($sp)
			addi $sp, $sp, 4
			lw $t0, 0($sp)
			addi $sp, $sp, 4
				
			addi $t1, $t1, -1
			bne $t1, -1, DropPieceJLoop

		addi $t0, $t0, 1
		bne $t0, 10, DropPieceILoop	
		
			
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
	
#Checa se a condição de derrota foi alcançada
#$a0 retorna 1 se Sim ou 0 se Não
LoseCondition:
	addi $sp, $sp -4
	sw $ra, 0($sp)
	la $t0, FixedArray
	li $t1, 0
	li $a0, 0
	LoseConditionILoop:
		
		lw $t3, 0($t0)
		bnez $t3, GameOver
		addi $t0, $t0, 4
		addi $t1, $t1, 1
		bne $t1, 20, LoseConditionILoop
	
	j ExitLoseConditionFunction
	GameOver:
	li $a0, 1
	
	ExitLoseConditionFunction:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
	
#Checa se está em condição para transformar a peça móvel em fixa
#$a0 retorna 1 se Sim ou 0 se Não
FixPieceCondition:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	li $t0, 0
	PieceConditionILoop:
		li $t1, 0
		PieceConditionJLoop:
			addi $sp, $sp, -4
			sw $t0, 0($sp)
			addi $sp, $sp, -4
			sw $t1, 0($sp)
			move $a0, $t0
			move $a1, $t1
			jal GetPieceArrayElement
			lw $t1, 0($sp)
			addi $sp, $sp, 4
			lw $t0, 0($sp)
			addi $sp, $sp, 4
			
			addi $sp, $sp, -4
			sw $t0, 0($sp)
			addi $sp, $sp, -4
			sw $t1, 0($sp)
			addi $sp, $sp, -4
			sw $a0, 0($sp)
			
			
			move $a1, $t1
			add $a1, $a1, 1
			move $a0, $t0
			jal GetFixedArrayElement
			move $t3, $a0
			
			lw $t2, 0($sp)
			addi $sp, $sp, 4
			lw $t1, 0($sp)
			addi $sp, $sp, 4
			lw $t0, 0($sp)
			addi $sp, $sp, 4
			
			beqz $t3, BlockingPieceNotFound
			beqz $t2, BlockingPieceNotFound
			li $a0, 1
			j ExitPieceConditionFunction
			
			BlockingPieceNotFound:
			addi $t1, $t1, 1
			bne $t1, 22, PieceConditionJLoop
			
		
		addi $t0, $t0, 1
		bne $t0, 10, PieceConditionILoop
		
	li $a0, 0
	
	ExitPieceConditionFunction:
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
	
	
#Checa há alguma peça fixa impedindo o movimento para a esquerda
#$a0 retorna 1 se Sim ou 0 se Não
CheckLeftBoundary:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	li $t0, 0
	LeftBoundaryILoop:
		li $t1, 0
		LeftBoundaryJLoop:
			addi $sp, $sp, -4
			sw $t0, 0($sp)
			addi $sp, $sp, -4
			sw $t1, 0($sp)
			move $a0, $t0
			move $a1, $t1
			jal GetPieceArrayElement
			lw $t1, 0($sp)
			addi $sp, $sp, 4
			lw $t0, 0($sp)
			addi $sp, $sp, 4
			
			addi $sp, $sp, -4
			sw $t0, 0($sp)
			addi $sp, $sp, -4
			sw $t1, 0($sp)
			addi $sp, $sp, -4
			sw $a0, 0($sp)
			
			
			move $a1, $t1
			move $a0, $t0
			addi $a0, $a0, -1
			jal GetFixedArrayElement
			move $t3, $a0
			
			lw $t2, 0($sp)
			addi $sp, $sp, 4
			lw $t1, 0($sp)
			addi $sp, $sp, 4
			lw $t0, 0($sp)
			addi $sp, $sp, 4
			
			beqz $t3, LeftBlockingPieceNotFound
			beqz $t2, LeftBlockingPieceNotFound
			li $a0, 1
			j ExitLeftBoundaryFunction
			
			LeftBlockingPieceNotFound:
			addi $t1, $t1, 1
			bne $t1, 22, LeftBoundaryJLoop
			
		
		addi $t0, $t0, 1
		bne $t0, 10, LeftBoundaryILoop
		
	li $a0, 0
	
	ExitLeftBoundaryFunction:
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

#Checa há alguma peça fixa impedindo o movimento para a direta
#$a0 retorna 1 se Sim ou 0 se Não
CheckRightBoundary:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	li $t0, 0
	RightBoundaryILoop:
		li $t1, 0
		RightBoundaryJLoop:
			addi $sp, $sp, -4
			sw $t0, 0($sp)
			addi $sp, $sp, -4
			sw $t1, 0($sp)
			move $a0, $t0
			move $a1, $t1
			jal GetPieceArrayElement
			lw $t1, 0($sp)
			addi $sp, $sp, 4
			lw $t0, 0($sp)
			addi $sp, $sp, 4
			
			addi $sp, $sp, -4
			sw $t0, 0($sp)
			addi $sp, $sp, -4
			sw $t1, 0($sp)
			addi $sp, $sp, -4
			sw $a0, 0($sp)
			
			
			move $a1, $t1
			move $a0, $t0
			addi $a0, $a0, 1
			jal GetFixedArrayElement
			move $t3, $a0
			
			lw $t2, 0($sp)
			addi $sp, $sp, 4
			lw $t1, 0($sp)
			addi $sp, $sp, 4
			lw $t0, 0($sp)
			addi $sp, $sp, 4
			
			beqz $t3, RightBlockingPieceNotFound
			beqz $t2, RightBlockingPieceNotFound
			li $a0, 1
			j ExitRightBoundaryFunction
			
			RightBlockingPieceNotFound:
			addi $t1, $t1, 1
			bne $t1, 22, RightBoundaryJLoop
			
		
		addi $t0, $t0, 1
		bne $t0, 10, RightBoundaryILoop
		
	li $a0, 0
	
	ExitRightBoundaryFunction:
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra



#Coloca elemento na posição (x,y) da Matriz de Peças Móveis
#$a0: Coordenada x
#$a1: Coordenada y
#$a2: Cor
SetValueToPieceArray:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	slti $t0, $a0, 10
	beqz $t0, ExitValuePieceArrayFunction
	slti $t0, $a1, 22
	beqz $t0, ExitValuePieceArrayFunction
	slti $t0, $a0, 0
	bnez $t0, ExitValuePieceArrayFunction
	slti $t0, $a1, 0
	bnez $t0, ExitValuePieceArrayFunction
	
	la $t0, PieceArray
	mul $t1, $a1, 10
	mul $t1, $t1, 4
	add $t0, $t0, $t1
	mul $t2, $a0, 4
	add $t0, $t0, $t2
	sw $a2, 0($t0)
	
	
	ExitValuePieceArrayFunction:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
#Coloca elemento na posição (x,y) da Matriz de Peças Fixas
#$a0: Coordenada x
#$a1: Coordenada y
#$a2: Cor
SetValueToFixedArray:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	la $t0, FixedArray
	mul $t1, $a1, 10
	mul $t1, $t1, 4
	add $t0, $t0, $t1
	mul $t2, $a0, 4
	add $t0, $t0, $t2
	sw $a2, 0($t0)
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	

#Retorna o elemento que está na posição (x,y) da Matriz de Peças móveis no registrador $a0
#$a0: Coordenada x
#$a1; Coordenada y
GetPieceArrayElement:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	slti $t0, $a0, 10
	beqz $t0, PieceArrayElementAlreadyPicked
	slti $t0, $a1, 22
	beqz $t0, PieceArrayElementAlreadyPicked
	slti $t0, $a0, 0
	bnez $t0, PieceArrayElementAlreadyPicked
	slti $t0, $a1, 0
	bnez $t0, PieceArrayElementAlreadyPicked
	la $t0, PieceArray
	mul $t1, $a1, 10
	mul $t1, $t1, 4
	add $t0, $t0, $t1
	mul $t2, $a0, 4
	add $t0, $t0, $t2
	lw $a0, 0($t0)
	j ExitPieceArrayFunction
	
	PieceArrayElementAlreadyPicked:
	li $a0, 0
	
	ExitPieceArrayFunction:
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
#Retorna o elemento que está na posição (x,y) da Matriz de peças fixas no registrador $a0
#$a0: Coordenada x
#$a1; Coordenada y
GetFixedArrayElement:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	slti $t0, $a0, 10
	beqz $t0, FixedArrayElementAlreadyPicked
	slti $t0, $a1, 22
	beqz $t0, FixedArrayElementAlreadyPicked
	slti $t0, $a0, 0
	bnez $t0, FixedArrayElementAlreadyPicked
	slti $t0, $a1, 0
	bnez $t0, FixedArrayElementAlreadyPicked
	la $t0, FixedArray
	mul $t1, $a1, 10
	mul $t1, $t1, 4
	add $t0, $t0, $t1
	mul $t2, $a0, 4
	add $t0, $t0, $t2
	lw $a0, 0($t0)
	j ExitFixedArrayFunction
	
	FixedArrayElementAlreadyPicked:
	li $a0, 1
	
	ExitFixedArrayFunction:
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

##########################################################
# Funções Gráficas e Auxiliares				 #
##########################################################

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

		#li $a0, 500	#
		#li $v0, 32	# pause for 250 milisec
		#syscall		#

		j SelectMode    # Jump back to the top of the wait loop

	ComecaJogo:
		jal ZeraBotoes
		jal TelaPreta
		jal TelaJogo
		jal RandomColor
		jal ResetPieceArray
		jal ResetFixedArray
		sw $zero, Tick
		li $t0, 25000
		sw $t0, TickSpeed
		
		
		addi $sp, $sp, -4
		sw $a0, 0($sp)
		jal GetElementFromBag
		sw $a0, CurrentPiece
		lw $a1, 0($sp)
		addi $sp, $sp, 4
		jal SelectNewSpawnPiece
		lw $a0, CurrentPiece
		jal InitialRotationPos
		sw $a0, XRotation
		sw $a1, YRotation
		
		jal Spawn
		jal CopiaMemoria
		jal RandomColor
		addi $sp, $sp, -4
		sw $a0, 0($sp)
		jal GetElementFromBag
		sw $a0, NextPiece
		lw $a1, 0($sp)
		addi $sp, $sp, 4
		jal SelectNewSpawnPiece
		jal CopiaMemoriaProximaPeca
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		jr $ra

#Spawna uma peça no Grid e troca a peça no Spawn Grid
SpawnNewPiece:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	lw $a0, NextPiece
	sw $a0, CurrentPiece
	jal InitialRotationPos
	sw $a0, XRotation
	sw $a1, YRotation
	jal Spawn
	
	jal RandomColor
	addi $sp, $sp, -4
	sw $a0, 0($sp)
	jal GetElementFromBag
	sw $a0, NextPiece
	lw $a1, 0($sp)
	addi $sp, $sp, 4
	jal SelectNewSpawnPiece
	jal CopiaMemoriaProximaPeca
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

#Passado em $a0 o ID da peça devolve As coordenadas X e Y de centro de rotação inicial da peça
#$a0: Coordenada X
#$a1: Coordenada Y
InitialRotationPos:
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	beq $a0, 0, SwitchRotate0
	beq $a0, 1, SwitchRotate1
	beq $a0, 2, SwitchRotate2
	beq $a0, 3, SwitchRotate3
	beq $a0, 4, SwitchRotate4
	beq $a0, 5, SwitchRotate5
	beq $a0, 6, SwitchRotate6

	SwitchRotate0:
		li $a0, -1
		li $a1, -1
		j ExitSwitchRotate
	SwitchRotate1:
		li $a0, 5
		li $a1, 0
		j ExitSwitchRotate
	SwitchRotate2:
		li $a0, 4
		li $a1, 0
		j ExitSwitchRotate
	SwitchRotate3:
		li $a0, 4
		li $a1, 0
		j ExitSwitchRotate
	SwitchRotate4:
		li $a0, 4
		li $a1, 0
		j ExitSwitchRotate
	SwitchRotate5:
		li $a0, 4
		li $a1, 0
		j ExitSwitchRotate
	SwitchRotate6:
		li $a0, 4
		li $a1, 0
		j ExitSwitchRotate
	ExitSwitchRotate:

	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

#Devolve uma cor Aleatória em $a0
RandomColor:
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	li $v0, 42
	li $a0, 498465463
	li $a1, 7
	syscall
	beq $a0, 0, CaseColor0
	beq $a0, 1, CaseColor1
	beq $a0, 2, CaseColor2
	beq $a0, 3, CaseColor3
	beq $a0, 4, CaseColor4
	beq $a0, 5, CaseColor5
	beq $a0, 6, CaseColor6

	CaseColor0:
		lw $a0, corblocoI
		j ExitSwitchColor
	CaseColor1:
		lw $a0, corblocoJ
		j ExitSwitchColor
	CaseColor2:
		lw $a0, corblocoL
		j ExitSwitchColor
	CaseColor3:
		lw $a0, corblocoO
		j ExitSwitchColor
	CaseColor4:
		lw $a0, corblocoS
		j ExitSwitchColor
	CaseColor5:
		lw $a0, corblocoT
		j ExitSwitchColor
	CaseColor6:
		lw $a0, corblocoZ
		j ExitSwitchColor


	ExitSwitchColor:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra


#Copia peças móveis para a Matriz de peças fixas
CopyPieceToFixed:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	la $t1, PieceArray
	la $t2, FixedArray
	li $t0, 0
	CopyPieceToFixedILoop:
		
		lw $t3, 0($t1)
		beqz $t3, NotAPiece
		sw $t3, 0($t2)
		
		NotAPiece:
		
		addi $t1, $t1, 4
		addi $t2, $t2, 4
		addi $t0, $t0, 1
		bne $t0, 220 CopyPieceToFixedILoop
		
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

ResetPieceArray:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	la $t1, PieceArray
	li $t0, 0
	ResetPieceILoop:	
		sw $zero, 0($t1)
		addi $t1, $t1, 4
		addi $t0, $t0, 1
		bne $t0, 220, ResetPieceILoop
	
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
	
	
ResetFixedArray:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	la $t1, FixedArray
	li $t0, 0
	ResetFixedPieceILoop:	
		sw $zero, 0($t1)
		addi $t1, $t1, 4
		addi $t0, $t0, 1
		bne $t0, 220, ResetFixedPieceILoop
	
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
#Decodifica peça passada em $a0 para a memória de Spawn e $a1 sendo a cor da peça
SelectNewSpawnPiece:
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	jal SpawnClear
	la $t0, SpawnArray
	beq $a0, 0, Piece0
	beq $a0, 1, Piece1
	beq $a0, 2, Piece2
	beq $a0, 3, Piece3
	beq $a0, 4, Piece4
	beq $a0, 5, Piece5
	beq $a0, 6, Piece6


	Piece0: #Peça O
		sw $a1, 4($t0)
		sw $a1, 8($t0)
		sw $a1, 20($t0)
		sw $a1, 24($t0)
		j ExitSwitch
	Piece1: #Peça I
		sw $a1, 0($t0)
		sw $a1, 4($t0)
		sw $a1, 8($t0)
		sw $a1, 12($t0)
		j ExitSwitch
	Piece2: #Peça T
		sw $a1, 0($t0)
		sw $a1, 4($t0)
		sw $a1, 8($t0)
		sw $a1, 20($t0)
		j ExitSwitch
	Piece3: #Peça L
		sw $a1, 0($t0)
		sw $a1, 4($t0)
		sw $a1, 8($t0)
		sw $a1, 16($t0)
		j ExitSwitch
	Piece4: #Peça J
		sw $a1, 0($t0)
		sw $a1, 4($t0)
		sw $a1, 8($t0)
		sw $a1, 24($t0)
		j ExitSwitch
	Piece5: #Peça S
		sw $a1, 4($t0)
		sw $a1, 8($t0)
		sw $a1, 16($t0)
		sw $a1, 20($t0)
		j ExitSwitch
	Piece6: #Peça Z
		sw $a1, 0($t0)
		sw $a1, 4($t0)
		sw $a1, 20($t0)
		sw $a1, 24($t0)
		j ExitSwitch
	ExitSwitch:


	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

SpawnClear:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	la $t0, SpawnArray
	lw $t1, corFundo
	sw, $t1, 0($t0)
	sw, $t1, 4($t0)
	sw, $t1, 8($t0)
	sw, $t1, 12($t0)
	sw, $t1, 16($t0)
	sw, $t1, 20($t0)
	sw, $t1, 24($t0)
	sw, $t1, 28($t0)

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
		
		

		#Desenhando Espaço de Score
		#X Absoluto Base: 45
		#Y Abosuluto Base: 10
		li $a0, 41 #Comeco de x
		li $a1 40 #Comeco de Y
		lw $a2, corFundo
		li $a3, 57 #Limite de x
		jal DrawHorizontalLine

		li $a0, 41
		li $a1 41
		lw $a2, corFundo
		li $a3, 57
		jal DrawHorizontalLine

		li $a0, 41
		li $a1 42
		lw $a2, corFundo
		li $a3, 57
		jal DrawHorizontalLine

		li $a0, 41
		li $a1 43
		lw $a2, corFundo
		li $a3, 57
		jal DrawHorizontalLine

		li $a0, 41
		li $a1 44
		lw $a2, corFundo
		li $a3, 57
		jal DrawHorizontalLine
		
		#jal AtualizaScore

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
		sw $zero, 0xFFFF0004		# clear the button pushed bit
		jr $ra



#Retorna uma peca aleatória da Bag
#Retorno da Peça está no $a0
GetElementFromBag:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	lw $t0, BagLength
	bnez $t0, PickElement
	jal CreateNewBag
	PickElement:
	lw $t1, BagLength
	la $t2, RandomBag
	addi $t1, $t1, -1
	sw $t1, BagLength
	mul $t1, $t1, 4
	add $t2, $t2, $t1
	lw $a0, 0($t2)
	li $t0, -1
	sw $t0, 0($t2)

	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

#Cria uma nova Bag caso ela esteja vazia
CreateNewBag:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	li $t0, 0

	NewBagILoop:
		li $v0, 42
		li $a0, 485498564
		li $a1, 7
		syscall
		la $t2, RandomBag
		mul $a0, $a0, 4
		add $t3, $t2, $a0
		lw $t4, 0($t3)
		bne $t4, -1, NewBagJLoop
		sw $t0, 0($t3)
		j AlreadyInserted
			NewBagJLoop:
				lw $t3, 0($t2)
				bne $t3, -1, EmptySpaceNotFound
				sw  $t0, 0($t2)
				j AlreadyInserted
				EmptySpaceNotFound:
				addi $t2, $t2, 4
				j NewBagJLoop
		AlreadyInserted:
		addi $t0, $t0, 1
		bne $t0, 7, NewBagILoop
	li $t1, 7
	sw $t1, BagLength
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

#Spawna a nova peça
Spawn:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	sw $zero, PieceState
	la $t0, PieceArray
	#addi $t0, $t0, 80 #Comando de Teste para spawnar no espaço visível. Não utilizado no Jogo final
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


CopiaMemoriaFixa:
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	la $t0, FixedArray
	addi $t0, $t0, 80 #Pula os 20 primeiros espaços do Array, pois as duas primeiras linhas não aparecem na tela
	li $t2, 0
	FixCopyILoop:
		li $t1, 0
		FixCopyJLoop:
			move $a0, $t1
			move $a1, $t2
			lw $a2, 0($t0)
			beqz $a2, BlackBlockNotDrawn #Não Desenha Bloco vazio (Preto), pois isso é função do CopiaMemoria
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
			BlackBlockNotDrawn:
			addi $t1, $t1, 1
			addi $t0, $t0, 4
			bne $t1, 10, FixCopyJLoop
		addi $t2, $t2, 1
		bne $t2, 20, FixCopyILoop
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

#Atualiza o Score com +1, deve ser chamado quando o jogo tem uma linha excluida.
AtualizaScore:
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	#add $t0, $s0, 1
	
	lw $t2, Score

	addi $t2, $t0, 1
	
	sw $t2, Score
	jal LimpaScore
	
	jal PegaDigito1
	jal VerificaDigito1
	
	jal PegaDigito2
	jal VerificaDigito2
	
	jal PegaDigito3
	jal VerificaDigito3
	

	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

#Pega o primeiro digito do numero para poder imprimir no score.
PegaDigito1:
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	sw $zero, AuxModulus
	sw $zero, AuxModulus2
	li $t5, 1

	add $t0, $s0, 10
	add $t1, $s0, 1
	
	for:
		beq $t1, $zero, result			#while(n>=1)
		mul $t2, $t2, $t0			#x=*x
		
		sub $t1, $t1, $t5			#n--
		j for

		result:
			lw $t7, Score
			div $t3, $t7, $t2

			addi $t6, $t3, 0
			sw $t6, AuxModulus
			#addi AuxModuluz, $zero, $t3
			
			CalculaMod:
					addi $sp, $sp, -4
					sw $ra, 0($sp)

					lw $t6, AuxModulus
					addi $t0, $t6, 0
					addi $t1, $zero, 10
					addi $t2, $zero, 0
					addi $t3, $zero, 2

					L1:
						beq $t0, $t1, L2    # while i < 9, compute
						div $t0, $t3        # i mod 2
						mfhi $t6            # temp for the mod
						beq $t6, 0, Lmod    # if mod == 0, jump over to Lmod and increment
						add $t2, $t2, $t0   # k = k + i
						
					Lmod:
						add $t0, $t0, 1     # i++
						j L1                # repeat the while loop

					L2:
						sw $t2, AuxModulus2


					lw $ra, 0($sp)
					addi $sp, $sp, 4
					jr $ra

	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

#Pega o segundo digito do numero para poder imprimir no score.
PegaDigito2:
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	li $t5, 1
	sw $zero, AuxModulus
	sw $zero, AuxModulus2

	add $t0, $s0, 10
	add $t1, $s0, 2
		
	for1:
		beq $t1, $zero, result1			#while(n>=1)
		
		mul $t2, $t2, $t0			#x=*x
		sub $t1, $t1, $t5			#n--

		j for1

		result1:
			lw $t7, Score
			div $t3, $t7, $t2

			addi $t6, $t3, 0
			sw $t6, AuxModulus
			#addi AuxModuluz, $zero, $t3
			
			CalculaMod1:
					addi $sp, $sp, -4
					sw $ra, 0($sp)

					lw $t6, AuxModulus
					addi $t0, $t6, 0
					addi $t1, $zero, 10
					addi $t2, $zero, 0
					addi $t3, $zero, 2

					L11:
						beq $t0, $t1, L2    # while i < 9, compute
						div $t0, $t3        # i mod 2
						mfhi $t6            # temp for the mod
						beq $t6, 0, Lmod    # if mod == 0, jump over to Lmod and increment
						add $t2, $t2, $t0   # k = k + i
					Lmod1:
						add $t0, $t0, 1     # i++
						j L1                # repeat the while loop

					L21:
						sw $t2, AuxModulus2


					lw $ra, 0($sp)
					addi $sp, $sp, 4
					jr $ra

	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

#Pega o terceiro digito do numero para poder imprimir no score.
PegaDigito3:
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	li $t5, 1
	sw $zero, AuxModulus
	sw $zero, AuxModulus2

	add $t0, $s0, 10
	add $t1, $s0, 3
	
	for2:
		beq $t1, $zero, result2				#while(n>=1)

		mul $t2, $t2, $t0				#x=*x
		sub $t1, $t1, $t5				#n--

		j for2

		result2:
			lw $t7, Score
			div $t3, $t7, $t2
			addi $t6, $t3, 0
			sw $t6, AuxModulus
			#addi AuxModuluz, $zero, $t3
			
			CalculaMod2:
					addi $sp, $sp, -4
					sw $ra, 0($sp)

					lw $t6, AuxModulus
					addi $t0, $t6, 0
					addi $t1, $zero, 10
					addi $t2, $zero, 0
					addi $t3, $zero, 2

					L12:
						beq $t0, $t1, L2    # while i < 9, compute
						div $t0, $t3        # i mod 2
						mfhi $t6            # temp for the mod
						beq $t6, 0, Lmod    # if mod == 0, jump over to Lmod and increment
						add $t2, $t2, $t0   # k = k + i
					Lmod2:
						add $t0, $t0, 1     # i++
						j L1                # repeat the while loop

					L22:
						sw $t2, AuxModulus2


					lw $ra, 0($sp)
					addi $sp, $sp, 4
					jr $ra

	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
#Descobre que numero do digito 1 e chama a funcao para imprimir o digito 1.
VerificaDigito1:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	lw $t0, AuxModulus2
	
	li $a0, 42 #x
	li $a1 40 #y
	lw $a2, corMargem
	li $a3, 42 #x
	
	beq $t0, 0, Desenha0
	beq $t0, 1, Desenha1
	beq $t0, 2, Desenha2
	beq $t0, 3, Desenha3
	beq $t0, 5, Desenha5
	beq $t0, 6, Desenha6
	beq $t0, 7, Desenha7
	beq $t0, 8, Desenha8
	beq $t0, 9, Desenha9
	
	
	
	
	addi $sp, $sp, 4
	jr $ra

#Descobre que numero do digito 2 e chama a funcao para imprimir o digito 2.
VerificaDigito2:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	lw $t0, AuxModulus2
	
	li $a0, 47 #x
	li $a1 40 #y
	lw $a2, corMargem
	li $a3, 47 #x
	
	beq $t0, 0, Desenha0
	beq $t0, 1, Desenha1
	beq $t0, 2, Desenha2
	beq $t0, 3, Desenha3
	beq $t0, 5, Desenha5
	beq $t0, 6, Desenha6
	beq $t0, 7, Desenha7
	beq $t0, 8, Desenha8
	beq $t0, 9, Desenha9
	
	addi $sp, $sp, 4
	jr $ra

#Descobre que numero do digito 3 e chama a funcao para imprimir o digito 3.	
VerificaDigito3:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	lw $t0, AuxModulus2
	
	li $a0, 52 #x
	li $a1 40	#y
	lw $a2, corMargem
	li $a3, 52 #x
	
	beq $t0, 0, Desenha0
	beq $t0, 1, Desenha1
	beq $t0, 2, Desenha2
	beq $t0, 3, Desenha3
	beq $t0, 5, Desenha5
	beq $t0, 6, Desenha6
	beq $t0, 7, Desenha7
	beq $t0, 8, Desenha8
	beq $t0, 9, Desenha9
	
	addi $sp, $sp, 4
	jr $ra

#Imprime o digito 0 conforme as cordenadas estabelecidas.
Desenha0:
	addi $a0, $a0, 1
	addi $a3, $a3, 2
	jal DrawHorizontalLine
	subi $a0, $a0, 1#Volta
	subi $a3, $a3, 2#Volta
	
	addi $a1, $a1, 1
	jal DrawHorizontalLine
	addi $a0, $a0, 2
	addi $a3, $a3, 3
	jal DrawHorizontalLine
	subi $a0, $a0, 2
	subi $a3, $a3, 3
	
	addi $a1, $a1, 1
	addi $a3, $a3, 3
	jal DrawHorizontalLine
	subi $a3, $a3, 3
	
	addi $a1, $a1, 1
	addi $a3, $a3, 1
	jal DrawHorizontalLine
	addi $a0, $a0, 3
	addi $a3, $a3, 2
	jal DrawHorizontalLine
	subi $a3, $a3, 3
	subi $a0, $a0, 3
	
	addi $a1, $a1, 1
	addi $a3, $a3, 2
	addi $a0, $a0, 1
	jal DrawHorizontalLine
	subi $a3, $a3, 2
	subi $a0, $a0, 1
	
	jr $ra
	
#Imprime o digito 1 conforme as cordenadas estabelecidas.
Desenha1:
	addi $a0, $a0, 3
	addi $a3, $a3, 3
	jal DrawHorizontalLine
	addi $a1, $a1, 1
	subi $a0, $a0, 1
	jal DrawHorizontalLine
	
	addi $a1, $a1, 1
	jal DrawHorizontalLine
	
	addi $a1, $a1, 1
	jal DrawHorizontalLine
	
	addi $a1, $a1, 1
	jal DrawHorizontalLine
	
	addi $a1, $a1, 1
	jal DrawHorizontalLine
	
	jr $ra
	
#Imprime o digito 2 conforme as cordenadas estabelecidas.
Desenha2:
	addi $a3, $a3, 3
	jal DrawHorizontalLine
	addi $a0, $a0, 3
	addi $a1, $a1, 1
	jal DrawHorizontalLine
	subi $a0, $a0, 3
	addi $a1, $a1, 1
	jal DrawHorizontalLine
	subi $a3, $a3, 3
	addi $a1, $a1, 1
	jal DrawHorizontalLine
	addi $a1, $a1, 1
	addi $a3, $a3, 3
	jal DrawHorizontalLine
	
	jr $ra
			
#Imprime o digito 3 conforme as cordenadas estabelecidas.
Desenha3:
	addi $a3, $a3, 3
	jal DrawHorizontalLine
	addi $a0, $a0, 3
	addi $a1, $a1, 1
	jal DrawHorizontalLine
	subi $a0, $a0, 2
	addi $a1, $a1, 1
	jal DrawHorizontalLine
	addi $a0, $a0, 2
	addi $a1, $a1, 1
	jal DrawHorizontalLine
	subi $a0, $a0, 3
	addi $a1, $a1, 1
	jal DrawHorizontalLine
	
	jr $ra
	
#Imprime o digito 4 conforme as cordenadas estabelecidas.
Desenha4:
	jal DrawHorizontalLine
	addi $a1, $a1, 1
	jal DrawHorizontalLine
	addi $a3, $a3, 2
	addi $a0, $a0, 2
	jal DrawHorizontalLine
	addi $a1, $a1, 1
	subi $a3, $a3, 2
	subi $a0, $a0, 2
	addi $a3, $a3, 3
	jal DrawHorizontalLine
	addi $a1, $a1, 1
	addi $a0, $a0, 2
	subi $a3, $a3, 1
	jal DrawHorizontalLine
	addi $a1, $a1, 1
	jal DrawHorizontalLine
	
	jr $ra
	
#Imprime o digito 5 conforme as cordenadas estabelecidas.
Desenha5:
	addi $a3, $a3, 3
	jal DrawHorizontalLine
	subi $a3, $a3, 3
	addi $a1, $a1, 1
	jal DrawHorizontalLine
	addi $a3, $a3, 3
	addi $a1, $a1, 1
	jal DrawHorizontalLine
	addi $a0, $a0, 3
	addi $a1, $a1, 1
	jal DrawHorizontalLine
	subi $a0, $a0, 3
	addi $a1, $a1, 1
	jal DrawHorizontalLine
	
	jr $ra
	
#Imprime o digito 6 conforme as cordenadas estabelecidas.
Desenha6:
	addi $a3, $a3, 3
	jal DrawHorizontalLine
	subi $a3, $a3, 3
	addi $a1, $a1, 1
	jal DrawHorizontalLine
	addi $a3, $a3, 3
	addi $a1, $a1, 1
	jal DrawHorizontalLine
	subi $a3, $a3, 3
	addi $a1, $a1, 1
	jal DrawHorizontalLine
	addi $a3, $a3, 3
	addi $a0, $a0, 3
	addi $a1, $a1, 1
	jal DrawHorizontalLine
	subi $a0, $a0, 3
	addi $a1, $a1, 1
	jal DrawHorizontalLine
	
	jr $ra

#Imprime o digito 7 conforme as cordenadas estabelecidas.
Desenha7:
	addi $a3, $a3, 3
	jal DrawHorizontalLine
	addi $a0, $a0, 3
	addi $a1, $a1, 1
	jal DrawHorizontalLine
	addi $a1, $a1, 1
	jal DrawHorizontalLine
	addi $a1, $a1, 1
	jal DrawHorizontalLine
	addi $a1, $a1, 1
	jal DrawHorizontalLine
	
	jr $ra
	
#Imprime o digito 8 conforme as cordenadas estabelecidas.
Desenha8:
	addi $a3, $a3, 3
	jal DrawHorizontalLine
	subi $a3, $a3, 3
	addi $a1, $a1, 1
	jal DrawHorizontalLine
	addi $a3, $a3, 3
	addi $a0, $a0, 3
	jal DrawHorizontalLine
	subi $a0, $a0, 3
	addi $a1, $a1, 1
	jal DrawHorizontalLine
	subi $a3, $a3, 3
	addi $a1, $a1, 1
	jal DrawHorizontalLine
	addi $a3, $a3, 3
	addi $a0, $a0, 3
	jal DrawHorizontalLine
	addi $a1, $a1, 1
	subi $a0, $a0, 3
	jal DrawHorizontalLine
	
	jr $ra
	
#Imprime o digito 9 conforme as cordenadas estabelecidas.
Desenha9:
	addi $a3, $a3, 3
	jal DrawHorizontalLine
	subi $a3, $a3, 3
	addi $a1, $a1, 1
	jal DrawHorizontalLine
	addi $a3, $a3, 3
	addi $a0, $a0, 3
	jal DrawHorizontalLine
	subi $a0, $a0, 3
	addi $a1, $a1, 1
	jal DrawHorizontalLine
	addi $a1, $a1, 1
	addi $a0, $a0, 3
	jal DrawHorizontalLine
	addi $a1, $a1, 1
	subi $a0, $a0, 3
	jal DrawHorizontalLine
	
	jr $ra

#Limpa toda a area de Score(pinta tudo de preto)
LimpaScore:	
	li $a0, 41 #Comeco de x
	li $a1 40 #Comeco de Y
	lw $a2, corFundo
	li $a3, 57 #Limite de x
	jal DrawHorizontalLine

	li $a0, 41
	li $a1 41
	lw $a2, corFundo
	li $a3, 57
	jal DrawHorizontalLine

	li $a0, 41
	li $a1 42
	lw $a2, corFundo
	li $a3, 57
	jal DrawHorizontalLine

	li $a0, 41
	li $a1 43
	lw $a2, corFundo
	li $a3, 57
	jal DrawHorizontalLine

	li $a0, 41
	li $a1 44
	lw $a2, corFundo
	li $a3, 57
	jal DrawHorizontalLine
	
	jr $ra
