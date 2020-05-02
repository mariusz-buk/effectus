 org $2200

 icl 'c:\atari\effectus\lib\common.asm'

 .var var19750412_eff_ .word
 .var m1_eff_ .word
 .var m2_eff_ .word
 .var total1_eff_ .byte
 .var total2_eff_ .word

; Effectus example:
; Using local procedures (PROC)
PRINTTEXT_reff_ .proc
 PutE
 jsr printf
 dta c'Hello from PROC',0
 PutE
 PutE
 rts

 .endp
SHOWNUM_reff_ .proc ( .byte n_eff_) .var
 .var N_eff_ .byte
 mva n_eff_ $c0
 jsr printf
 dta c'%',$9b,0
 dta a($c0)
 rts

 .endp
; Calculate the sum of two 8-bit
; numbers and print the result to the
; screen
SUMCALC1_reff_ .proc ( .byte n1_eff_, n2_eff_) .var
 .var N1_eff_ .byte
 .var N2_eff_ .byte
 adb n1_eff_ n2_eff_ total1_eff_
 jsr printf
 dta c'Result: ',0
 mva total1_eff_ $c0
 jsr printf
 dta c'%',$9b,0
 dta a($c0)
 rts

 .endp
; Calculate the sum of two 16-bit
; numbers and print the result to the
; screen
SUMCALC2_reff_ .proc ( .word c1_eff_, c2_eff_) .var
 .var C1_eff_ .word
 .var C2_eff_ .word
 adw c1_eff_ c2_eff_ total2_eff_
 jsr printf
 dta c'Result: ',0
 jsr printf
 dta c'%',$9b,0
 dta a(total2_eff_)
 rts

 .endp
NUMBERS_reff_ .proc ( .word e1_eff_, e2_eff_ .byte e3_eff_ .word e4_eff_, e5_eff_) .var
 .var E1_eff_ .word
 .var E2_eff_ .word
 .var E3_eff_ .byte
 .var E4_eff_ .word
 .var E5_eff_ .word
 PutE
 jsr printf
 dta c'e1=',0
 jsr printf
 dta c'%',0
 dta a(e1_eff_)
 jsr printf
 dta c', e2=',0
 jsr printf
 dta c'%',0
 dta a(e2_eff_)
 PutE
 jsr printf
 dta c'e3=',0
 mva e3_eff_ $c0
 jsr printf
 dta c'%',0
 dta a($c0)
 PutE
 jsr printf
 dta c'e4=',0
 jsr printf
 dta c'%',0
 dta a(e4_eff_)
 jsr printf
 dta c', e5=',0
 jsr printf
 dta c'%',0
 dta a(e5_eff_)
 PutE
 PutE
 PutE
 rts

 .endp
MAIN_reff_
 Put #125
 jsr printf
 dta c'Effectus example:',$9b,0
 jsr printf
 dta c'Using local procedures (PROC)',$9b,0
 PrintText_reff_ 
 jsr printf
 dta c'Variable n holds value ',0
 ShowNum_reff_ #21
 PutE
 jsr printf
 dta c'Input parameters: 10 and 240',$9b,0
 SumCalc1_reff_ #10, #240
 PutE
 mwa #2100 m1_eff_
 mwa #62000 m2_eff_
 jsr printf
 dta c'Input parameters: ',0
 jsr printf
 dta c'%',0
 dta a(m1_eff_)
 jsr printf
 dta c' and ',0
 jsr printf
 dta c'%',$9b,0
 dta a(m2_eff_)
 jsr printf
 dta c'held in variables m1 and m2',$9b,0
 SumCalc2_reff_ m1_eff_, m2_eff_
 Numbers_reff_ #10000, #65200, #201, #32000, #4651
 jsr printf
 dta c'End of program',$9b,0
 jmp *

 .link 'c:\atari\effectus\lib\runtime.obx'
 .link 'c:\atari\effectus\lib\printf.obx'
 .link 'c:\atari\effectus\lib\math.obx'

 run Main_reff_
