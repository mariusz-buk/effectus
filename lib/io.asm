;
; Effectus / MADS runtime library
;
; Source code assembled with Mads 2.0.8 build 31 (8 Jan 19)
;

  icl 'equates.asm'

  .extrn printf .proc

  .reloc

  .public open, close, GetD, read, PutD, PutDE, Point, Note

* --- VARIABLES

  .var sector, offset .byte

/*
  OdPEN

  Command:
          $03 - OdPEN

  Example:
          odpen channel , #command(4 or 8) , #file_name
          odpen #$10 , #4 , #file_name

          file_name dta c'...',$9b
          channel = $10,$20,$30
*/
open .proc (.byte chn+1,com+1 .word fname) .var

chn ldx #0
  mva #3 ICHID+2,x  ; CIO command ; $03 - OPEN
  mwa fname ICHID+4,x ; file name
com mva #0 ICHID+$a,x ; $04 - READ ; $08 - WRITE
  jmp pciov

fname .word

  .endp

/*
  CLOSE

  Command:
          $0C - CLOSE

  Example:
          close channel
          close #$10

          channel = $10,$20,$30
*/
close	.proc (.byte x) .reg

  mva #$c ICHID+2,x  ; CIO command

  jmp pciov

  .endp

;
; GetD - Get a character from chosen device
;
; Parameters:
; .byte x (8-bit value): Chosen device number
;
; Result:
; STORE1 (8-bit value): A character read from chosen device
;
GetD  .proc (.byte x) .reg

  mva #7 ICHID+2,x  ; CIO command
  mwa #0 ICHID+8,x  ; length
  jsr CIOV
  sta $A0
  rts

  .endp

/*
  READ

  Command:
          $05 - GET RECORD
          $07 - GET CHARACTER
          $09 - PUT RECORD
          $0B - PUT CHARACTERS

  Example:
          read channel , #command , #buffer , #length
          read #$10 , command , buffer , length

          channel = $10,$20,$30 ...
*/

read .proc (.byte chn+1,com+1 .word buf,len) .var

chn ldx #0
com mva #0 ICHID+2,x  ; CIO command
  mwa buf ICHID+4,x   ; buffer address
  mwa len ICHID+8,x   ; length
  jmp pciov

buf .word
len .word

	.endp

/*
  PCIOV
  
  regY = status
*/
pciov	.proc

        jsr	ciov
 
        sty	status

        bmi	err
        rts

err	cpy	#136		; na b³¹d 136 nie reagujemy
	beq	quit

	printf
	dta 'I/O Error %',$9b,$00
	dta a(status)

quit	ldy	status
        rts

status	dta a(0)

	.endp

;
; PutD - Put a character on selected device
;
; Parameters:
; .byte x (8-bit value): A device number to be written to
; .byte a (8-bit value): A character to be written to selected device
;
PutD  .proc (.byte x .byte a) .reg

  tay
  lda ICPTL+1,x
  pha
  lda ICPTL,x
  pha
  tya
  rts

  .endp

;
; PutDE - Put a character on selected device with carriage return at the end
;
; Parameters:
; .byte x (8-bit value): A device number to be written to
; .byte a (8-bit value): A character to be written to selected device
;
;PutDE .proc (.byte chn+1 .byte chr+1) .var
PutDE  .proc (.byte x .byte a) .reg

;chn ldx #0
;chr lda #0
  jsr PutD
  lda #$9b
  jsr PutD
  rts

  .endp

Point .proc (.byte chn+1, sector+1, offset+1) .var

chn	ldx	#0
	mva	#$25 ICHID+2,x ; CIO command
sector	mwa	#0 ICHID+$C,x ; set sector
offset	mwa	#0 ICHID+$E,x ; set offset
	jmp	pciov
  
	.endp

Note .proc (.byte chn+1, sector, offset) .var
  
chn	ldx	#0
	mva	#$26 ICHID+2,x ; CIO command
	jmp	pciov
	mwa ICHID+$C,x sector ; get sector
	mwa	ICHID+$E,x offset ; get offset
;	jmp	pciov
  rts

	.endp
