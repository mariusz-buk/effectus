;
; Effectus / MADS graphics runtime library
;
; Original source:
; Mad-Assembler (MADS)
; Hyperlink: http://mads.atari8.info/
;
; Source code assembled with Mads 2.0.8 build 31 (8 Jan 19)

  icl 'equates.asm'

?off	=	$15
?strv	=	$32
?vecv	=	$34
?dtav	=	$36
?soff	=	$38
?aux	=	$39

	.reloc

	.public	printfd

//	.var chnx .byte

printfd	.proc (.byte chn+1) .var	

	clc
	pla
	adc #$01
	sta ?strv
	pla
	adc #$00
	sta ?strv+1

	ldy #$FF
?cnt	iny
	lda (?strv),Y
	bne ?cnt

	tya
	adc ?strv
	sta ?vecv
	lda #$00
	tay
	adc ?strv+1
	sta ?vecv+1

?prt	lda (?strv),Y
	beq ?ext
	iny
	sty ?off
	cmp #'%'
	beq ?spc
	cmp #'@'
	beq _float
	cmp #'#'
	beq _string
	jsr putchr
?nxt	ldy ?off
	bne ?prt

?ext	lda ?vecv+1
	pha
	lda ?vecv
	pha
	rts

_float	jmp float
_string	jmp string


?spc	
	jsr _word

	lda (?dtav),Y
	sta fr0
	iny
	lda (?dtav),Y
	sta fr0+1
	jsr IFP
	jsr FASC

insert
	ldy #$00

?pnd	lda (INBUFF),y
	bmi ?chr
	sty ?aux
	jsr putchr
	inc ?aux
	ldy ?aux
	bne ?pnd
?chr	and #$7F
	jsr putchr
	bpl ?nxt

putchr	
  tay

chn	ldx	#0       ; IOCB channel
		
	lda ICPTL+1,x	; put character routine high address
	pha
	lda ICPTL,x	  ; put character routine low address
	pha
	tya
	rts

	.endp


float	.proc	

	jsr	_word

	ldx	?dtav
	ldy	?dtav+1
	jsr	fld0r
	jsr	FASC

	jmp	printfd.insert

	.endp


string	.proc	

	jsr	_word

	ldy	#$ff
_lp	iny
	lda	(?dtav),y
	sta	lbuff,y
	bpl	_lp

	mwa	#lbuff	INBUFF

	jmp	printfd.insert

	.endp


_word
	ldy	#$02
?lp1	lda	(?vecv),Y
	sta	?vecv+1,Y
	dey
	bne	?lp1

	ldy	#$02
?lp2	inw	?vecv
	dey
	bne	?lp2
	rts
