 org $2200

 icl 'c:\atari\effectus\lib\common.asm'

 .var var19750412_eff_ .word
 .var n_eff_ .byte
 .var a_eff_ .byte
 .var b_eff_ .byte

; Effectus example:
; Logical (bitwise) operators demo
MAIN_reff_
 Put #125
 jsr printf
 dta c'Logical (bitwise) operators demo',$9b,0
 PutE
 jsr printf
 dta c'n=',0
 mva #2 n_eff_
 mva n_eff_ $c0
 jsr printf
 dta c'%',$9b,0
 dta a($c0)
 PutE
 jsr printf
 dta c'n==&2  Result: ',0
 lda n_eff_
 and #2
 sta $A0
 mva  $A0 n_eff_
 mva n_eff_ $c0
 jsr printf
 dta c'%',$9b,0
 dta a($c0)
 PutE
 jsr printf
 dta c'n=n&40  Result: ',0
 lda n_eff_
 and #40
 sta $A0
 mva  $A0 n_eff_
 mva n_eff_ $c0
 jsr printf
 dta c'%',$9b,0
 dta a($c0)
 PutE
 jsr printf
 dta c'n=',0
 mva #2 n_eff_
 mva n_eff_ $c0
 jsr printf
 dta c'%',$9b,0
 dta a($c0)
 PutE
 jsr printf
 dta c'n==!2  Result: ',0
 lda n_eff_
 eor #2
 sta $A0
 mva  $A0 n_eff_
 mva n_eff_ $c0
 jsr printf
 dta c'%',$9b,0
 dta a($c0)
 PutE
 jsr printf
 dta c'n==XOR 2  Result: ',0
 lda n_eff_
 eor #2
 sta $A0
 mva  $A0 n_eff_
 mva n_eff_ $c0
 jsr printf
 dta c'%',$9b,0
 dta a($c0)
 PutE
 jsr printf
 dta c'n==!n  Result: ',0
 lda n_eff_
 eor n_eff_
 sta $A0
 mva  $A0 n_eff_
 mva n_eff_ $c0
 jsr printf
 dta c'%',$9b,0
 dta a($c0)
 PutE
 jsr printf
 dta c'a=40',$9b,0
 jsr printf
 dta c'b=a LSH 1  Result: ',0
 mva #40 a_eff_
 lda a_eff_
 asl @
 sta $A0
 mva  $A0 b_eff_
 mva b_eff_ $c0
 jsr printf
 dta c'%',$9b,0
 dta a($c0)
 PutE
 jsr printf
 dta c'b=a RSH 1  Result: ',0
 lda a_eff_
 lsr @
 sta $A0
 mva  $A0 b_eff_
 mva b_eff_ $c0
 jsr printf
 dta c'%',$9b,0
 dta a($c0)
 PutE
 jsr printf
 dta c'---------------------',0
 jmp *

 .link 'c:\atari\effectus\lib\runtime.obx'
 .link 'c:\atari\effectus\lib\printf.obx'
 .link 'c:\atari\effectus\lib\math.obx'

 run Main_reff_
