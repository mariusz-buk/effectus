 org $2200

 icl 'c:\atari\effectus\lib\common.asm'

 .var var19750412_eff_ .word
 .var I_eff_ .byte
 .var KLAVESA_eff_ .byte

;
; Effectus example:
; Graphics demonstration
;
; Graphics Program by w1k
; http://atarionline.pl/forum/comments.php?DiscussionID=207&page=1#Item_0
;
LINKA_reff_ .proc ( .byte x0_eff_, y0_eff_, x1_eff_, y1_eff_) .var
 .var X0_eff_ .byte
 .var Y0_eff_ .byte
 .var X1_eff_ .byte
 .var Y1_eff_ .byte
 Plot X0_eff_, Y0_eff_
 DrawTo X1_eff_, Y1_eff_
 rts

 .endp
; ***
DEMO_reff_ .proc
 mva #0 I_eff_
for_loop16
 LINKA_reff_ #0, #0, #159, I_eff_
 ldx I_eff_
 cpx #79
 inc I_eff_
 jcc for_loop16
 rts

 .endp
; ***
HLPROGRAM_reff_
 Graphics #7
 Color #1
 DEMO_reff_ 
 jsr printf
 dta c'STLAC',$9b,0
 GetD #112
 mva $A0 KLAVESA_eff_
 jmp *

 .link 'c:\atari\effectus\lib\runtime.obx'
 .link 'c:\atari\effectus\lib\graphics.obx'
 .link 'c:\atari\effectus\lib\printf.obx'
 .link 'c:\atari\effectus\lib\io.obx'

 run HLPROGRAM_reff_
