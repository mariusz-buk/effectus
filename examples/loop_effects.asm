 org $2200

 icl 'c:\atari\effectus\lib\common.asm'

 .var var19750412_eff_ .word
 .var i_eff_ .byte

; Effectus example
;
; Loop effects by ascrnet
; http://www.atariage.com/forums/topic/112501-effectus-new-atari-cross-compiler-alpha-stage/page__st__25
; Demo Effectus
MAIN_reff_
 Graphics #2
 mva #1 loop_var
loop11
 Position #7, #5
 Rand #255
 mva $A0 i_eff_
 printfd #96
 dta c'%',0
 dta a(i_eff_)
 Poke 710, i_eff_
 ldx #0
 cpx loop_var
 jcc loop11
 jmp *

 .link 'c:\atari\effectus\lib\runtime.obx'
 .link 'c:\atari\effectus\lib\graphics.obx'
 .link 'c:\atari\effectus\lib\printfd.obx'

 run Main_reff_
