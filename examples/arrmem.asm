 org $2200

 icl 'c:\atari\effectus\lib\common.asm'

 .var var19750412_eff_ .word
 .var mem_eff_ .byte
ARRD_eff_ = 28000 .array [1000] .byte
ARRH_eff_ = $0600 .array [1000] .byte

; Effectus example:
; BYTE ARRAY usage demonstration using
; direct memory assignment
MAIN_reff_
 Put #125
 mva #10 arrD_eff_[0]
 mva #30 arrD_eff_[1]
 mva #60 arrD_eff_[2]
 mva #20 arrH_eff_[0]
 mva #40 arrH_eff_[1]
 mva #150 arrH_eff_[2]
 PutE
 jsr printf
 dta c'arrD array elements:',0
 PutE
 ldx #0
 mva arrD_eff_,x $c0
 jsr printf
 dta c'%',0
 dta a($c0)
 jsr printf
 dta c',',0
 ldx #1
 mva arrD_eff_,x $c0
 jsr printf
 dta c'%',0
 dta a($c0)
 jsr printf
 dta c',',0
 ldx #2
 mva arrD_eff_,x $c0
 jsr printf
 dta c'%',0
 dta a($c0)
 PutE
 jsr printf
 dta c'arrH array elements:',0
 PutE
 ldx #0
 mva arrH_eff_,x $c0
 jsr printf
 dta c'%',0
 dta a($c0)
 jsr printf
 dta c',',0
 ldx #1
 mva arrH_eff_,x $c0
 jsr printf
 dta c'%',0
 dta a($c0)
 jsr printf
 dta c',',0
 ldx #2
 mva arrH_eff_,x $c0
 jsr printf
 dta c'%',0
 dta a($c0)
 PutE
 jsr printf
 dta c'Peeked values:',0
 PutE
 Peek 28000
 mva $A0 mem_eff_
 mva mem_eff_ $c0
 jsr printf
 dta c'%',$9b,0
 dta a($c0)
 Peek $0600
 mva $A0 mem_eff_
 mva mem_eff_ $c0
 jsr printf
 dta c'%',$9b,0
 dta a($c0)
 Peek 28001
 mva $A0 mem_eff_
 mva mem_eff_ $c0
 jsr printf
 dta c'%',$9b,0
 dta a($c0)
 Peek $0601
 mva $A0 mem_eff_
 mva mem_eff_ $c0
 jsr printf
 dta c'%',$9b,0
 dta a($c0)
 jmp *

 .link 'c:\atari\effectus\lib\runtime.obx'
 .link 'c:\atari\effectus\lib\printf.obx'

 run Main_reff_
