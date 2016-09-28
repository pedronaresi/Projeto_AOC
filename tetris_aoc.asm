
######################################################################
# 			     Tetris                                  #
######################################################################
#  Programado por: Pedro Naresi, Jaime Ossada, Bruno Ogata, Joao     #
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
	corblocoI:		.word 0x0000ffff		#Cor do bloco I: Azul claro
	corblocoJ:		.word 0x000000cd		#Cor do bloco J: Azul escuro
	corblocoL:		.word 0x00ffa500		#Cor do bloco L: Laranja
	corblocoO:		.word 0x00ffff00		#Cor do bloco O: Amarelo
	corblocoS:		.word 0x0000ff00		#Cor do bloco S: Verde
	corblocoT:		.word 0x009400d3		#Cor do bloco T: Roxo
	corblocoZ:		.word 0x00ff0000		#Cor do bloco Z: Vermelho
	corMargem:		.word 0x00ffffff		#Cor da Margem: Branco
	corFundo:		.word 0x00000000		#Cor do Fundo: Preto
.text

######################################################
# Deixa a tela preta
######################################################

NewGame:
	jal TelaPreta
	jal TETRIS
	
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

TETRIS:
		li $a0, 21
		li $a1, 13
		lw $a2, corblocoO
		li $a3, 18
		jal DrawHorizontalLine
		
		li $a0, 27
		jal DrawVerticalLine
		
		li $a0, 31
		jal DrawVerticalLine
		
		li $a0, 33
		jal DrawVerticalLine
		
		li $a0, 37
		jal DrawVerticalLine
		
		li $a0, 39
		jal DrawVerticalLine
		
		li $a0, 34 
		li $a1, 13
		li $a3, 14
		jal DrawVerticalLine
	
		li $a0, 35
		li $a1, 15
		li $a3, 16
		jal DrawVerticalLine
		
		li $a0, 25
		li $a1, 14
		jal DrawVerticalLine
		
		li $a0, 22
		li $a1, 16
		li $a3, 24
		#jal DrawHorizontalLine
	
		li $a0, 22
		li $a1, 16
		li $a3, 25
		#jal DrawHorizontalLine
	
		li $a1, 13
		#jal DrawHorizontalLine
		
		li $a0, 27
		li $a3, 30
		jal DrawHorizontalLine
	
		li $a1, 18
		jal DrawHorizontalLine
		
		li $a0, 40
		li $a3, 43
		jal DrawHorizontalLine
		
		li $a1, 13
		jal DrawHorizontalLine
		
		li $a0, 41
		li $a1, 16
		jal DrawHorizontalLine
		
		li $a0, 36
		li $a1, 17
		jal DrawPoint
		
		li $a0, 43
		jal DrawPoint
		
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