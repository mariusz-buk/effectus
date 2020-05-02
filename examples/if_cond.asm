 org $2200

 icl 'c:\atari\effectus\lib\common.asm'

 .var else_flag .byte
 .var var19750412_eff_ .word
SCRX_eff_ equ 82
 .var res1_eff_ .byte
 .var res2_eff_ .word
 .var x1_eff_ .byte
 .var x2_eff_ .word
 .var y1_eff_ .word
 .var y2_eff_ .word
 .var A_eff_=1 .byte
 .var B_eff_=2 .byte
 .var i_eff_ .word
 .var j_eff_ .word
 .var x_eff_=5 .byte

; Effectus example:
; IF condition statement demonstration
MULT_reff_ .proc ( .byte n_eff_) .var
 .var N_eff_ .byte
 Mul8 n_eff_, #2
 mva  $A0 res1_eff_
 mwa res1_eff_ $A0
 rts

 .endp
MULT2_reff_ .proc ( .word n1_eff_, n2_eff_) .var
 .var N1_eff_ .word
 .var N2_eff_ .word
 Mul16 n1_eff_, n2_eff_
 mwa  $A0 res2_eff_
 mwa res2_eff_ $A0
 rts

 .endp
MAIN_reff_
 Put #125
 jsr printf
 dta c'IF condition statement demonstration',$9b,0
 mva #0 SCRX_eff_
 PutE
 mva #1 x1_eff_
 jsr printf
 dta c'x1=1',$9b,0
 mva #0 else_flag
 #if .byte x1_eff_<>#2
 mva #1 else_flag
 jsr printf
 dta c'This is line is shown because x1 <> 2!',$9b,0
 #end
; BYTE type function in IF condition
 PutE
 Mult_reff_ #3
 mva $A0 x1_eff_
 mva x1_eff_ $c0
 jsr printf
 dta c'%',$9b,0
 dta a($c0)
 Mult_reff_ #3
 mwa $A0 var19750412_eff_

 mva #0 else_flag
 #if .word var19750412_eff_=#6
 mva #1 else_flag
 jsr printf
 dta c'TRUE: 3 * 2 = 6',$9b,0
 #else
 #if .byte else_flag=#1
 jmp from_else36
 #end
 jsr printf
 dta c'FALSE: 3 * 2 NOT 6?',$9b,0
 #end
from_else36
; CARD type function in IF condition
 PutE
 mwa #500 y1_eff_
 mwa #70 y2_eff_
 Mult2_reff_ y1_eff_, y2_eff_
 mwa $A0 x2_eff_
 jsr printf
 dta c'%',$9b,0
 dta a(x2_eff_)
 Mult2_reff_ y1_eff_, y2_eff_
 mwa $A0 var19750412_eff_

 mva #0 else_flag
 #if .word var19750412_eff_<x2_eff_
 mva #1 else_flag
 jsr printf
 dta c'FALSE: 130 * 55 IS NOT 35000',$9b,0
 #else
 #if .byte else_flag=#1
 jmp from_else48
 #end
 jsr printf
 dta c'TRUE: 500 * 70 = 35000',$9b,0
 #end
from_else48
 PutE
 mva #0 else_flag
 #if .byte a_eff_=#1
 mva #1 else_flag
 jsr printf
 dta c'A=1 (first condition)',$9b,0
 mva #0 else_flag
 #if .byte b_eff_=#2
 mva #1 else_flag
 jsr printf
 dta c'B=2 (nested condition)',$9b,0
 #end
 #end
; IF multi-conditional operators demonstration
 PutE
 mwa #10 i_eff_
 mwa #21 j_eff_
 jsr printf
 dta c'Variable values:',$9b,0
 jsr printf
 dta c'i=',0
 jsr printf
 dta c'%',0
 dta a(i_eff_)
 jsr printf
 dta c' and j=',0
 jsr printf
 dta c'%',0
 dta a(j_eff_)
 PutE
 PutE
 mva #0 else_flag
 #if .word i_eff_>#1 .and.word j_eff_<#21
 mva #1 else_flag
 jsr printf
 dta c'i > 1 and j < 21',$9b,0
 #end
 mva #0 else_flag
 #if .word i_eff_>#1 .and.word j_eff_>#20
 mva #1 else_flag
 jsr printf
 dta c'i > 1 and j > 20',$9b,0
 #end
 mva #0 else_flag
 #if .word i_eff_<#9 .or.word j_eff_=#21
 mva #1 else_flag
 jsr printf
 dta c'i < 9 or j = 21',$9b,0
 #end
 mva #0 else_flag
 #if .word i_eff_<#9 .or.word j_eff_<#21
 mva #1 else_flag
 jsr printf
 dta c'i < 9 or j < 21',$9b,0
 #end
 mva #0 else_flag
 #if .word j_eff_>=#21
 mva #1 else_flag
 jsr printf
 dta c'j >= 21',$9b,0
 #end
; ELSEIF demonstration
 PutE
 jsr printf
 dta c'x is assigned to ',0
 mva x_eff_ $c0
 jsr printf
 dta c'%',0
 dta a($c0)
 jsr printf
 dta c' and the result is: ',$9b,0
 mva #0 else_flag
 #if .byte x_eff_=#1
 mva #1 else_flag
 jsr printf
 dta c'x=1',0
 #end
 #if .byte x_eff_=#5
 mva #1 else_flag
 jsr printf
 dta c'x=5',0
 #end
 #if .byte x_eff_=#6
 mva #1 else_flag
 jsr printf
 dta c'x=6',0
 #else
 #if .byte else_flag=#1
 jmp from_else89
 #end
 jsr printf
 dta c'x=?',0
 #end
from_else89
 jmp *

 .link 'c:\atari\effectus\lib\runtime.obx'
 .link 'c:\atari\effectus\lib\printf.obx'
 .link 'c:\atari\effectus\lib\math.obx'

 run MAIN_reff_
