 org $2200

 icl 'c:\atari\effectus\lib\common.asm'

 .var var19750412_eff_ .word
 .var n1_eff_ .word
 .var n2_eff_ .word
 .var i_eff_ .word

; Effectus example:
; Arithmetics demonstration
MAIN_reff_
 Put #125
 jsr printf
 dta c'Effectus example:',$9b,0
 jsr printf
 dta c'Arithmetics demonstration',$9b,0
 PutE
 mwa #4 n2_eff_
; Addition example
 mwa #7 n1_eff_
 adw n1_eff_ #2
 jsr printf
 dta c'%',$9b,0
 dta a(n1_eff_)
; Subtraction example
 mwa #240 n1_eff_
 sbw n1_eff_ #40
 jsr printf
 dta c'%',$9b,0
 dta a(n1_eff_)
; Multiplication example
 mwa #8 n1_eff_
 Mul16 n1_eff_, #10
 mwa  $A0 n1_eff_
 jsr printf
 dta c'%',$9b,0
 dta a(n1_eff_)
; Division example
 mwa #210 n1_eff_
 Div16 n1_eff_, #70
 mwa  $A0 n1_eff_
 jsr printf
 dta c'%',$9b,0
 dta a(n1_eff_)
 dew n1_eff_
 jsr printf
 dta c'%',$9b,0
 dta a(n1_eff_)
 mwa #8 n1_eff_
 Mul16 n1_eff_, n2_eff_
 mwa  $A0 n1_eff_
 jsr printf
 dta c'%',$9b,0
 dta a(n1_eff_)
 Div16 n1_eff_, n2_eff_
 mwa  $A0 n1_eff_
 jsr printf
 dta c'%',$9b,0
 dta a(n1_eff_)
; MOD examples
 jsr printf
 dta c'n1 = 10 MOD 4',$9b,0
 jsr printf
 dta c'n1 = ',0
 Mod8 #10, #4
 mwa  $A0 n1_eff_
 jsr printf
 dta c'%',$9b,0
 dta a(n1_eff_)
 PutE
 jsr printf
 dta c'i = 255 MOD 10',$9b,0
 jsr printf
 dta c'i = ',0
 Mod8 #255, #10
 mwa  $A0 i_eff_
 jsr printf
 dta c'%',$9b,0
 dta a(i_eff_)
 PutE
 PutE
 jsr printf
 dta c'End of program',$9b,0
 jmp *

 .link 'c:\atari\effectus\lib\runtime.obx'
 .link 'c:\atari\effectus\lib\printf.obx'
 .link 'c:\atari\effectus\lib\math.obx'

 run Main_reff_
