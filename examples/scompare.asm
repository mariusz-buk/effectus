 org $2200

 icl 'c:\atari\effectus\lib\common.asm'

 .var else_flag .byte
 .var var19750412_eff_ .word
 .var value_eff_ .word
 .array STR1_eff_ .byte = $ff
 [0] = 'ATARI',$9b
 .end
 .array STR2_eff_ .byte = $ff
 [0] = 'HELLO',$9b
 .end
 .array STR3_eff_ .byte = $ff
 [0] = 'ATARI',$9b
 .end

; Effectus example:
; SCompare function demonstration
MAIN_reff_
 PutE
 jsr printf
 dta c'str1=',0
 jsr printf
 dta c'#',$9b,0
 dta a(str1_eff_)
 jsr printf
 dta c'str2=',0
 jsr printf
 dta c'#',$9b,0
 dta a(str2_eff_)
 jsr printf
 dta c'str3=',0
 jsr printf
 dta c'#',$9b,0
 dta a(str3_eff_)
 SCompare str1_eff_, str2_eff_
 mva $A0 value_eff_
 PutE
; value 255 evaluates as signed number
; below zero in this example, because
; currently Effectus does not support
; signed numbers. SCompare results to
; value<0 for this particular case.
 mva #0 else_flag
 #if .word value_eff_=#255
 mva #1 else_flag
;IF value<0 THEN
 jsr printf
 dta c'str2 is greater than str1',$9b,0
 #end
 #if .word value_eff_=#0
 mva #1 else_flag
 jsr printf
 dta c'str1 and str2 are equal',$9b,0
 #else
 #if .byte else_flag=#1
 jmp from_else28
 #end
 jsr printf
 dta c'str1 is greater than str2',$9b,0
 #end
from_else28
;ELSEIF THEN
;  PRINTE("C")
;FI
;IF SCOMPARE(STR1,STR2)>0 THEN
;  PRINTE("A")
;ELSEIF SCOMPARE(STR1,STR2)=0 THEN
;  PRINTE("B")
;ELSEIF SCOMPARE(STR1,STR2)<0 THEN
;  PRINTE("C")
;FI
 jmp *

 .link 'c:\atari\effectus\lib\runtime.obx'
 .link 'c:\atari\effectus\lib\printf.obx'

 run Main_reff_
