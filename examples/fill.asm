 org $2200

 icl 'c:\atari\effectus\lib\common.asm'

 .var var19750412_eff_ .word

; Effectus example:
; Graphics Fill demonstration
MAIN_reff_
 Graphics #7
 jsr printf
 dta c'FILL TEST',$9b,0
 SetColor #4, #0, #15
 Color #2
 Plot #20, #3
 DrawTo #120, #3
 DrawTo #120, #20
 DrawTo #20, #20
 DrawTo #20, #3
 Poke 765, #3
 Fill #50, #30
 Color #3
 Plot #50, #35
 DrawTo #146, #35
 DrawTo #146, #70
 DrawTo #50, #70
 DrawTo #50, #35
 Poke 765, #1
 Fill #65, #50
 Put #125
 jsr printf
 dta c'FILL TEST',$9b,0
 Put #125
 jsr printf
 dta c'FILL TEST',$9b,0
loop35 jmp loop35
 jmp *

 .link 'c:\atari\effectus\lib\runtime.obx'
 .link 'c:\atari\effectus\lib\graphics.obx'
 .link 'c:\atari\effectus\lib\printf.obx'

 run MAIN_reff_
