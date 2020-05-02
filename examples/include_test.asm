 org $2200

 icl 'c:\atari\effectus\lib\common.asm'

 .var var19750412_eff_ .word
CH_eff_ equ 764

 icl 'lib_test.asm'
; Effectus example:
; INCLUDE demonstration
MAIN_reff_
 Put #125
 jsr printf
 dta c'Effectus example:',$9b,0
 jsr printf
 dta c'INCLUDE demonstration',$9b,0
 PutE
 jsr printf
 dta c'Press any key!',$9b,0
 WaitForKey_reff_ 
 PutE
 jsr printf
 dta c'Press any key and see my greetings!',$9b,0
 WaitForKey_reff_ 
 PutE
 PrintText_reff_ 
 PutE
 jsr printf
 dta c'And press any key for new color!',$9b,0
 WaitForKey_reff_ 
 ChangeColor_reff_ 
 PutE
 PutE
 jsr printf
 dta c'End of program',$9b,0
 jmp *

 .link 'c:\atari\effectus\lib\runtime.obx'
 .link 'c:\atari\effectus\lib\graphics.obx'
 .link 'c:\atari\effectus\lib\printf.obx'

 run Main_reff_
