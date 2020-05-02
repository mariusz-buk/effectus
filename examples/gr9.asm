 org $2200

 icl 'c:\atari\effectus\lib\common.asm'

 .var var19750412_eff_ .word
 .var i_eff_ .byte

; Effectus example:
; Graphics demonstration
MAIN_reff_
 Graphics #9
 SetColor #4, #8, #0
 mva #0 I_eff_
for_loop11
 Color i_eff_
 Plot i_eff_, i_eff_
 DrawTo i_eff_, #191
 ldx I_eff_
 cpx #79
 inc I_eff_
 jcc for_loop11
loop18 jmp loop18
 jmp *

 .link 'c:\atari\effectus\lib\runtime.obx'
 .link 'c:\atari\effectus\lib\graphics.obx'

 run Main_reff_
