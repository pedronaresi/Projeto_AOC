
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
	mode:			.word 0
.text

######################################################
# Deixa a tela preta
######################################################

NewGame:
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

ZeraBotoes:
		sw $zero, 0xFFFF0000		# clear the button pushed bit
		jr $ra

TelaJogo:
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

		jr $ra

	# $a0 the x starting coordinate
	# $a1 the y coordinate
	# $a2 the color
	# $a3 the x ending coordinate

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
