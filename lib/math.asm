;
; Effectus / MADS math runtime library
;
; Source code assembled with Mads 2.0.8 build 31 (8 Jan 19)

  icl 'equates.asm'

  .reloc

  .public Mul8, Div8, Mod8, Mul16, Div16, Sub16

  .var p1_math, p2_math .byte
  .var wp1_math, wp2_math, wp3_math .word

/*
  Add8 - 8-bit addition routine
  
  Original source:
  Book Atari Roots (Chapter Ten - Assembly Language Math)
  Hyperlink: http://www.atariarchives.org/roots/chapter_10.php
  
  Parameters:
  .byte p1_math (8-bit value): First operand
  .byte p2_math (8-bit value): Second operand
  
  Result: (sum up to 510)
  STORE1: Low byte of 16-bit number
  STORE2: High byte of 16-bit number

Add8  .proc (.byte p1_math, p2_math) .var

  cld
  clc
  lda p1_math
  adc p2_math
  php
  sta $A0
  pla
  and #1
  sta $A1
  rts

  .endp
*/

/*
  Sub8 - 8-bit subtraction routine
  
  Parameters:
  .byte p1_math (8-bit value): First operand
  .byte p2_math (8-bit value): Second operand
  
  Result:
  STORE1 (8-bit value): Resulting number

Sub8  .proc (.byte p1_math, p2_math) .var

  cld
  sec
  lda p1_math
  sbc p2_math
  sta $A0
  rts

  .endp
*/

/*
  Mul8 - 8-bit multiplication routine
  
  Original source:
  Book Atari Roots (Chapter Ten - Assembly Language Math)
  Hyperlink: http://www.atariarchives.org/roots/chapter_10.php
  
  Parameters:
  .byte p1_math (8-bit value): First multiplicant
  .byte p2_math (8-bit value): Second multiplicant
  
  Result:
  STORE1: Low byte of 16-bit number
  STORE2: High byte of 16-bit number
*/
Mul8  .proc (.byte p1_math, p2_math) .var

  lda #0
  sta $A0
  ldx #8
loop  lsr p1_math
  bcc noadd
  clc
  adc p2_math
noadd ror @
  ror $A0
  dex
  bne loop
  sta $A1
  rts

  .endp

/*
  Div8 - 8-bit division routine
 
  Original source:
  Book Atari Roots (Chapter Ten - Assembly Language Math)
  Hyperlink: http://www.atariarchives.org/roots/chapter_10.php
 
  Parameters:
  .word wp1_math: 16-bit dividend
  .byte p1_math:  8-bit divisor
 
  Result:
  STORE1: 8-bit quotient
  STORE2: 8-bit remainder
*/
Div8  .proc (.word wp1_math .byte p1_math) .var

  lda wp1_math+1
  ldx #08  ; For an 8-bit divisor 
  sec 
  sbc p1_math
dloop php  ; The loop that divides 
  rol $A0
  asl wp1_math
  rol @
  plp
  bcc addit
  sbc p1_math
  jmp next
addit adc p1_math
next  dex
  bne dloop
  bcs fini
  adc p1_math
  clc
fini  rol $A0
  sta $A1
  rts
 
  .endp

/*
  Div8 - 8-bit modulus routine
  
  Parameters:
  .byte p1_math: 8-bit dividend
  .byte p2_math: 8-bit divisor
    
  Result:
  STORE1: 8-bit remainder
*/
Mod8  .proc (.byte p1_math .byte p2_math) .var

 mva #0 dvdh
 mva p1_math dvdl
 mva p2_math divs
 LDA DVDH ;ACCUMULATOR WILL HOLD DVDH 
 LDX #08 ;FOR AN 8-BIT DIVISOR 
 SEC 
 SBC DIVS 
DLOOP PHP ;THE LOOP THAT DIVIDES 
 ROL QUOT 
 ASL DVDL 
 ROL @
 PLP 
 BCC ADOIT 
 SBC DIVS 
 JMP NEXT 
ADOIT ADC DIVS 
NEXT DEX 
 BNE DLOOP 
 BCS FINI 
 ADC DIVS 
 CLC 
FINI ROL QUOT 
 STA $A0
 rts

  .endp

/*
  Add16 - 16-bit addition routine
  
  Original source:
  Book Atari Roots (Chapter Ten - Assembly Language Math)
  Hyperlink: http://www.atariarchives.org/roots/chapter_10.php
  
  Parameters:
  .word wp1_math (16-bit value): First operand
  .word wp2_math (16-bit value): Second operand
  
  Result: (sum up to 65535)
  STORE1: Low byte of 16-bit number
  STORE2: High byte of 16-bit number

Add16  .proc (.word wp1_math, wp2_math) .var

  cld
  clc
  lda wp1_math
  adc wp2_math
  sta $A0
  lda wp1_math+1
  adc wp2_math+1
  sta $A1
  rts

  .endp
*/

/*
  Sub16 - 16-bit subtraction routine
  
  Parameters:
  .word wp1_math (16-bit value): First operand
  .word wp2_math (16-bit value): Second operand
  
  Result:
  STORE1 (16-bit value): Resulting number
*/
Sub16  .proc (.word wp1_math, wp2_math) .var

  cld
  sec ; Set carry
  lda wp1_math ;LOW HALF OF 16-BIT NUMBER IN wp1_math 
  sbc wp2_math ;LOW HALF OF 16-BIT NUMBER IN wp2_math 
  sta $A0 
  lda wp1_math+1 ;HIGH HALF OF 16-BIT NUMBER IN wp1_math 
  sbc wp2_math+1 ;HIGH HALF OF 16-BIT NUMBER IN wp2_math 
  sta $A1 
  rts

  .endp

/*
  Mul16 - 16-bit multiplication routine
  
  Original source:
  MADS (\examples\math\mul_div16.asm)

 16 bit multiply and divide routines.
 Three 16 bit (two-byte) locations
 ACC, AUX and EXT must be set up,
 preferably on zero page.

  Parameters:
  .word wp1_math (16-bit value): Multiplicator
  .word wp2_math (16-bit value): Multiplicand
  
  Result: 16-bit value in STORE1
*/

.proc Mul16 (.word wp1_math, wp2_math) .var

	LDA #0
	STA wp3_math+1
	LDY #$11
	CLC
LOOP	ROR wp3_math+1
	ROR @
	ROR wp1_math+1
	ROR wp1_math
	BCC MUL2
	CLC
	ADC wp2_math
	PHA
	LDA wp2_math+1
	ADC wp3_math+1
	STA wp3_math+1
	PLA
MUL2	DEY
	BNE LOOP
	STA wp3_math
	mwa wp1_math $A0
	RTS

.endp

/*
  Div16 - 16-bit divide routine
  
  Original source:
  MADS (\examples\math\mul_div16.asm)

 ACC/AUX -> ACC, remainder in EXT

  Parameters:
  .word wp1_math (16-bit value): Divisor
  .word wp2_math (16-bit value): Divident
  
  Result: 16-bit value in STORE1
*/

.proc Div16 (.word wp1_math, wp2_math) .var

	LDA #0
	STA wp3_math+1
	LDY #$10
LOOP	ASL wp1_math
	ROL wp1_math+1
	ROL @
	ROL wp3_math+1
	PHA
	CMP wp2_math
	LDA wp3_math+1
	SBC wp2_math+1
	BCC DIV2
	STA wp3_math+1
	PLA
	SBC wp2_math
	PHA
	INC wp1_math
DIV2	PLA
	DEY
	BNE LOOP
	STA wp3_math
	mwa wp1_math $A0
	RTS

.endp
