 org $2200

 icl 'c:\atari\effectus\lib\common.asm'

 .var var19750412_eff_ .word
 .var key_eff_ .byte

; Effectus example:
; Device Input/Output demonstration
MAIN_reff_
 Put #125
 jsr printf
 dta c'Effectus example:',$9b,0
 jsr printf
 dta c'Device Input/Output demonstration',$9b,0
 PutE
 jsr printf
 dta c'Press any key to play with and',$9b,0
 jsr printf
 dta c'exit program by typing E key!',$9b,0
 PutE
 Close #16
 Open #16, #4, #_str_buffer_17
 jmi stop1
 #while .byte key_eff_<>#69
 GetD #16
 mva $A0 key_eff_
 Put key_eff_
 #end
jump_from_while_19
 Close #16
 PutE
 PutE
 jsr printf
 dta c'End of program',0

stop1
 close #$10

 jmp *

 .link 'c:\atari\effectus\lib\runtime.obx'
 .link 'c:\atari\effectus\lib\printf.obx'
 .link 'c:\atari\effectus\lib\io.obx'
_str_buffer_17 .byte 'K:', $9b

 run Main_reff_
