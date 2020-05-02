 org $2200

 icl 'c:\atari\effectus\lib\common.asm'

 .var var19750412_eff_ .word
 .var n_eff_ .byte
 .var a_eff_ .byte
 .var b_eff_ .byte
 .array arr_eff_ [6] .byte = $ff
 .end

; Effectus example:
; ASCII manipulation demonstration
MAIN_reff_
 Put #125
 jsr printf
 dta c'ASCII manipulation demonstration',$9b,0
 PutE
 PutE
 jsr printf
 dta c'Character Put test',$9b,0
 Put #'J'
 Put #' '
 Put #'d'
 PutE
 PutE
 jsr printf
 dta c'Some math',$9b,0
 mva #65 a_eff_
 mva #66 b_eff_
 jsr printf
 dta c'a=65, b=66, a+b=',0
 adb a_eff_ b_eff_ n_eff_
 mva n_eff_ $c0
 jsr printf
 dta c'%',$9b,0
 dta a($c0)
 PutE
 jsr printf
 dta c'Array test',$9b,0
 mva #65 arr_eff_[1]
 ldx #1
 mva arr_eff_,x $c0
 jsr printf
 dta c'%',0
 dta a($c0)
 mva #50 arr_eff_[2]
 mva #67 arr_eff_[3]
 mva #52 arr_eff_[4]
 mva #2 N_eff_
for_loop37
 Put #44
 ldx N_eff_
 mva ARR_eff_,x $c0
 jsr printf
 dta c'%',0
 dta a($c0)
 ldx N_eff_
 cpx #4
 inc N_eff_
 jcc for_loop37
 jmp *

 .link 'c:\atari\effectus\lib\runtime.obx'
 .link 'c:\atari\effectus\lib\printf.obx'
 .link 'c:\atari\effectus\lib\math.obx'

 run MAIN_reff_
