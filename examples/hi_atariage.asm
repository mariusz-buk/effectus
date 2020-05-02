 org $2200

 icl 'c:\atari\effectus\lib\common.asm'

 .var var19750412_eff_ .word
 .var i_eff_ .word

;
; Effectus example:
; Graphics demonstration
;
; Hi, AtariAge by ascrnet
; http://www.atariage.com/forums/topic/112501-effectus-new-atari-cross-compiler-alpha-stage/page__st__25
;
; Demo Effectus
MAIN_reff_
 Graphics #2
 Position #5, #5
 Read #$60, #9, #_str_buffer_15_eff_, #12
 mwa #0 I_eff_
 mwa #2 $A2
for_loop16
 jsr printf
 dta c'hi, AtariAge........',$9b,0
 lda I_eff_
 cmp $A2
 lda I_eff_+1
 sbc $A3
 inw I_eff_
 jcc for_loop16
 jmp *

 .link 'c:\atari\effectus\lib\runtime.obx'
 .link 'c:\atari\effectus\lib\graphics.obx'
 .link 'c:\atari\effectus\lib\printf.obx'
 .link 'c:\atari\effectus\lib\io.obx'
_str_buffer_15_eff_ .byte 'hi, atariage'

 run Main_reff_
