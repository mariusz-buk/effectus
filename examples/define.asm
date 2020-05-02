 org $2200

 icl 'c:\atari\effectus\lib\common.asm'

 .var var19750412_eff_ .word
 .var n_eff_ .byte

; Effectus example:
; DEFINE statement demonstration
 Put #125
DEFINE_TEST_reff_
 PutE
 Put #125
 PutE
 PutE
 jsr printf
 dta c'DEFINE statement test',$9b,0
 PutE
 PutE
 jsr printf
 dta c'Cls, Newline',$9b,0
 PutE
 jsr printf
 dta c'Count from 1 to max',$9b,0
 mva #1 N_eff_
for_loop23
 mva N_eff_ $c0
 jsr printf
 dta c'%',$9b,0
 dta a($c0)
 ldx N_eff_
 cpx #3
 inc N_eff_
 jcc for_loop23
 jmp *

 .link 'c:\atari\effectus\lib\runtime.obx'
 .link 'c:\atari\effectus\lib\printf.obx'

 run DEFINE_TEST_reff_
