
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
		li $t1, 16136 # O Numero de pixels do Display
	StartCLoop:
		subi $t1, $t1, 4
		addu $t2, $t1, $gp
		sw $t0, ($t2)
		beqz $t1, EndCLoop
		j StartCLoop
	EndCLoop:
		jr $ra

TETRIS:
		li $a0, 4				# $a0 the x coordinate
		li $a1, 3				# $a1 the y starting coordinate
		lw $a2, corMargem			# $a2 the color
		li $a3, 59				# $a3 the x ending coordinate
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
		li $a0, 4		
		li $a1, 7
		lw $a2, corblocoZ
		li $a3, 12
		jal DrawHorizontalLine
		
		li $a1, 8
		jal DrawHorizontalLine
		
		li $a1, 9
		jal DrawHorizontalLine
		
		li $a0, 7
		li $a1, 10
		li $a3, 21
		jal DrawVerticalLine
		
		li $a0, 8
		jal DrawVerticalLine
		li $a0, 9
		jal DrawVerticalLine
		
		#Desenha "E"
		
		li $a0, 15
		li $a1, 7
		lw $a2, corblocoL
		jal DrawVerticalLine
		
		li $a0, 16
		jal DrawVerticalLine
		
		li $a0, 17
		jal DrawVerticalLine
		
		li $a0, 18
		li $a3 24
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
		li $a3, 21
		jal DrawHorizontalLine
		
		li $a1, 14
		jal DrawHorizontalLine
		
		li $a1, 15
		jal DrawHorizontalLine
		
		#Desenha "T"
		li $a0, 27	
		li $a1, 7
		lw $a2, corblocoO
		li $a3, 35
		jal DrawHorizontalLine
		
		li $a1, 8
		jal DrawHorizontalLine
		
		li $a1, 9
		jal DrawHorizontalLine
		
		li $a0, 30
		li $a1, 10
		li $a3, 21
		jal DrawVerticalLine
		
		li $a0, 31
		jal DrawVerticalLine
		li $a0, 32
		jal DrawVerticalLine
		
		#Desenha "R"
		li $a0, 39
		li $a1, 7
		lw $a2, corblocoS
		li $a3, 20
		jal DrawVerticalLine
		
		li $a0, 39
		jal DrawVerticalLine
		
		li $a0, 40
		jal DrawVerticalLine
		
		li $a0, 41
		li $a3, 45
		jal DrawHorizontalLine
		
		
		
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
