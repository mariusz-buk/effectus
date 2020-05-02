 org $2200

 icl 'c:\atari\effectus\lib\common.asm'

 .var else_flag .byte
 .var var19750412_eff_ .word
 .var n_eff_=4 .byte
 .var i_eff_ .byte
CH_eff_ equ 764

; Effectus example:
; Random Number game
MAIN_reff_
 Put #125
 jsr printf
 dta c'Effectus example:',$9b,0
 jsr printf
 dta c'Random Number game',$9b,0
 PutE
 PutE
 jsr printf
 dta c'Select a number between 0 and 3',$9b,0
 jsr printf
 dta c'by pressing corresponding key!',$9b,0
 PutE
 mva #255 CH_eff_
 #while .byte ch_eff_=#255
 #end
 Rand #3
 mva $A0 i_eff_
 mva #0 else_flag
 #if .byte ch_eff_=#50
 mva #1 else_flag
 mva #0 n_eff_
 #end
 #if .byte ch_eff_=#31
 mva #1 else_flag
 mva #1 n_eff_
 #end
 #if .byte ch_eff_=#30
 mva #1 else_flag
 mva #2 n_eff_
 #end
 #if .byte ch_eff_=#26
 mva #1 else_flag
 mva #3 n_eff_
 #end
 mva #255 CH_eff_
 PutE
 jsr printf
 dta c'You pressed ',0
 mva #0 else_flag
 #if .byte n_eff_>#3
 mva #1 else_flag
 jsr printf
 dta c'the wrong',0
 #else
 #if .byte else_flag=#1
 jmp from_else42
 #end
 mva n_eff_ $c0
 jsr printf
 dta c'%',0
 dta a($c0)
 #end
from_else42
 jsr printf
 dta c' key!',0
 mva #0 else_flag
 #if .byte i_eff_=n_eff_
 mva #1 else_flag
 jsr printf
 dta c' You won!!!',$9b,0
 #else
 #if .byte else_flag=#1
 jmp from_else50
 #end
 jsr printf
 dta c' You lost, the number is ',0
 mva i_eff_ $c0
 jsr printf
 dta c'%',0
 dta a($c0)
 jsr printf
 dta c'!',$9b,0
 #end
from_else50
 PutE
 PutE
 jsr printf
 dta c'End of game',$9b,0
 jmp *

 .link 'c:\atari\effectus\lib\runtime.obx'
 .link 'c:\atari\effectus\lib\printf.obx'

 run Main_reff_
