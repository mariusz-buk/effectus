 org $2200

 icl 'c:\atari\effectus\lib\common.asm'

 .var var19750412_eff_ .word
 .var X1_eff_ .byte
 .var NUM_eff_ .word

; CODE BLOCK WITH PARAMETERS EXAMPLE
TEST_reff_ .proc ( .byte a_reg, x_reg, y_reg, a3_par, a4_par, a5_par) .var
 mva a3_par $a3
 mva a4_par $a4
 mva a5_par $a5
 lda a_reg
 ldx x_reg
 ldy y_reg
; BACKGROUND COLOR
; BORDER COLOR
; CURSOR VISIBILITY
; CHARACTERS UPSIDE DOWN?
; COLUMN FOR TEXT
; ROW FOR TEXT
 .he 8E C6 02 8C C8 02 8D F0 02 A5 A5 8D F3 02 A5 A3 8D 55 00 00 00 A5 A4 8D 54 00 00 00  60
 rts

 .endp
ADD8_reff_ .proc ( .byte a, x) .reg
; CLD
; CLC
; STX $B1
; ADC $B1
; STA $A0
; RTS
 .he   D8  18 86 B1 65 B1 85 A0  60
 rts

 .endp
ADD16_reff_ .proc ( .word add1_eff_, add2_eff_) .var
 .var ADD1_eff_ .word
 .var ADD2_eff_ .word
 lda a_reg
 ldx x_reg
 ldy y_reg
 lda a_reg
 ldx x_reg
 lda ADD1_eff_
 pha
 ldx ADD1_eff_+1
 ldy ADD2_eff_
 mva ADD2_eff_+1 $A3
 pla
; CLD
; CLC
; STX $B1
; STY $B2
; ADC $B2
; STA $A0
; LDA $B1
; ADC $A3
; STA $A1
; RTS
 .he   D8  18 86 B1 84 B2 65 B2 85 A0 A5 B1 65 A3 85 A1  60
 rts

 .endp
MAIN_reff_
 Put #125
 TEST_reff_ #1, #20, #30, #8, #8, #4
 jsr printf
 dta c'LOOK, I AM UPSIDE DOWN!',$9b,0
 PutE
 PutE
 ADD8_reff_ #100, #50
 mva $A0 X1_eff_
 jsr printf
 dta c'ADD8(100,50) = ',0
 mva X1_eff_ $c0
 jsr printf
 dta c'%',$9b,0
 dta a($c0)
 ADD16_reff_ #1100, #34900
 mwa $A0 NUM_eff_
 jsr printf
 dta c'ADD16(1100,34900) = ',0
 jsr printf
 dta c'%',$9b,0
 dta a(NUM_eff_)
 jmp *

 .link 'c:\atari\effectus\lib\runtime.obx'
 .link 'c:\atari\effectus\lib\printf.obx'

 run MAIN_reff_
