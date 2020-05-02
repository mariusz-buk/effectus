 org $2200

 icl 'c:\atari\effectus\lib\common.asm'

 .var var19750412_eff_ .word
CH_eff_ equ 764
 .var i_eff_ .byte

; Effectus example:
; Joystick manipulation demonstration
MAIN_reff_
 Put #125
 jsr printf
 dta c'Effectus example:',$9b,0
 jsr printf
 dta c'Joystick manipulation demonstration',$9b,0
 PutE
 jsr printf
 dta c'Move your joystick to see destination',$9b,0
 jsr printf
 dta c'numbers or press trigger to fire!',$9b,0
 PutE
 jsr printf
 dta c'Press any key to exit!',$9b,0
 mva #255 CH_eff_
 #while .byte ch_eff_=#255
 Stick #0
 mva $A0 i_eff_
 #if .byte i_eff_<>#15
 mva i_eff_ $c0
 jsr printf
 dta c'%',$9b,0
 dta a($c0)
 #end
 Strig #0
 mva $A0 i_eff_
 #if .byte i_eff_=#0
 jsr printf
 dta c'Fire!',$9b,0
 #end
 #end
jump_from_while_18
 mva #255 CH_eff_
 PutE
 jsr printf
 dta c'All done!',$9b,0
 PutE
 PutE
 jsr printf
 dta c'End of program',$9b,0
 jmp *

 .link 'c:\atari\effectus\lib\runtime.obx'
 .link 'c:\atari\effectus\lib\printf.obx'
 .link 'c:\atari\effectus\lib\controllers.obx'

 run Main_reff_
