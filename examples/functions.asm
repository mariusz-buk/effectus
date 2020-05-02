 org $2200

 icl 'c:\atari\effectus\lib\common.asm'

 .var var19750412_eff_ .word
 .var i_eff_ .byte
 .var j_eff_ .byte
 .var z_eff_ .word
 .var result_eff_ .word
 .var n1_eff_ .word
 .var n2_eff_ .word
 .var n3_eff_ .word

; Effectus example:
; Using local functions (FUNC) with
; some examples using inline machine
; code mnemonics
SUM_reff_ .proc ( .word nn1_eff_, nn2_eff_) .var
 .var NN1_eff_ .word
 .var NN2_eff_ .word
 adw nn1_eff_ nn2_eff_ result_eff_
 mwa result_eff_ $A0
 rts

 .endp
MULTIPLYB_reff_ .proc ( .byte a, x) .reg
 .he  85 E0 86 E1 A9 00 85 A0 A2 08 46 E0 90 03 18 65 E1 6A 66 A0 CA D0 F3 85 A1  60
 rts

 .endp

POKETEST_reff_ .proc ( .byte a) .reg
 .he  8D C6 02  60 
 rts

 .endp

MAIN_reff_
 Put #125
 jsr printf
 dta c'Effectus example:',$9b,0
 jsr printf
 dta c'Using local functions (FUNC)',$9b,0
 PutE
 mwa #30 n1_eff_
 mwa #120 n2_eff_
 jsr printf
 dta c'Custom function Sum',$9b,0
 PutE
 jsr printf
 dta c'n1=30, n2=120, with sum of n3=',0
 Sum_reff_ n1_eff_, n2_eff_
 mwa $A0 n3_eff_
 jsr printf
 dta c'%',$9b,0
 dta a(n3_eff_)
 mwa #255 n1_eff_
 Sum_reff_ n1_eff_, #255
 mwa $A0 n3_eff_
 jsr printf
 dta c'n1=255 with 255 added is ',0
 jsr printf
 dta c'%',$9b,0
 dta a(n3_eff_)
 PutE
 jsr printf
 dta c'Custom machine language functions:',$9b,0
 jsr printf
 dta c'MultiplyB, PokeTest',$9b,0
; Poke background with color
 PokeTest_reff_ #210
; Multiply two numbers
 mva #20 i_eff_
 mva #30 j_eff_
 MultiplyB_reff_ i_eff_, #30
 mwa $A0 z_eff_
 PutE
 jsr printf
 dta c'Result of assembler multiplication routine with parameters 20, 30 is ',0
 jsr printf
 dta c'%',0
 dta a(z_eff_)
 PutE
 PutE
 jsr printf
 dta c'-----------------------------------',$9b,0
 PutE
 jsr printf
 dta c'Press trigger',$9b,0
 strig #0
 mwa $A0 var19750412_eff_

 #while .word var19750412_eff_=#1
 strig #0
 mwa $A0 var19750412_eff_

 #end
 jsr printf
 dta c'Trigger pressed',$9b,0
 jsr printf
 dta c'Program finished!',$9b,0
 jmp *

 .link 'c:\atari\effectus\lib\runtime.obx'
 .link 'c:\atari\effectus\lib\printf.obx'
 .link 'c:\atari\effectus\lib\math.obx'
 .link 'c:\atari\effectus\lib\controllers.obx'

 run Main_reff_
