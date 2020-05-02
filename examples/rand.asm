 org $2200

 icl 'c:\atari\effectus\lib\common.asm'

 .var var19750412_eff_ .word
 .var i_eff_ .byte
CH_eff_ equ 764

; Effectus example:
; Random number generator demonstration
; (function Rand)
MAIN_reff_
 Put #125
 jsr printf
 dta c'Effectus example:',$9b,0
 jsr printf
 dta c'Random number generator demonstration',$9b,0
 jsr printf
 dta c'(function Rand)',$9b,0
 PutE
 jsr printf
 dta c'Press any key to see random numbers!',$9b,0
 mva #255 CH_eff_
 #while .byte ch_eff_=#255
 #end
 mva #255 CH_eff_
 PutE
 jsr printf
 dta c'Selected number between 0 and 100',$9b,0
 Rand #100
 mva $A0 i_eff_
 mva i_eff_ $c0
 jsr printf
 dta c'%',$9b,0
 dta a($c0)
 PutE
 jsr printf
 dta c'Selected number between 0 and 255',$9b,0
 Rand #255
 mva $A0 i_eff_
 mva i_eff_ $c0
 jsr printf
 dta c'%',$9b,0
 dta a($c0)
 PutE
 jsr printf
 dta c'Selected number between 0 and 3',$9b,0
 Rand #3
 mva $A0 i_eff_
 mva i_eff_ $c0
 jsr printf
 dta c'%',$9b,0
 dta a($c0)
 PutE
 PutE
 jsr printf
 dta c'End of program',$9b,0
 jmp *

 .link 'c:\atari\effectus\lib\runtime.obx'
 .link 'c:\atari\effectus\lib\printf.obx'

 run Main_reff_
