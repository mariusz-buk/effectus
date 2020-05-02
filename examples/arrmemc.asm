 org $2200

 icl 'c:\atari\effectus\lib\common.asm'

 .var var19750412_eff_ .word
 .var i_eff_ .byte
 .var mem_eff_ .word
ARR_eff_ = $8000 .array [1000] .word
 .var array_buffer_ARR_eff_ .word
 .var array_index_ARR_eff_ .byte

; Effectus example:
; CARD ARRAY usage demonstration using
; direct memory assignment
MAIN_reff_
 Put #125
 mwa #14 arr_eff_[0]
 mwa #230 arr_eff_[1]
 mwa #5100 arr_eff_[2]
 mwa #63000 arr_eff_[3]
 PutE
 jsr printf
 dta c'Array values:',0
 PutE
 mva #0 I_eff_
 mva #0 array_index_ARR_eff_
for_loop19
 ldy array_index_ARR_eff_
 lda ARR_eff_,y
 sta array_buffer_ARR_eff_
 inc array_index_ARR_eff_
 ldy array_index_ARR_eff_
 lda ARR_eff_,y
 sta array_buffer_ARR_eff_+1
 jsr printf
 dta c'%',$9b,0
 dta a(array_buffer_ARR_eff_)
 ldx I_eff_
 cpx #3
 inc I_eff_
 inc array_index_ARR_eff_
 jcc for_loop19
 PutE
 jsr printf
 dta c'Array values in descending order:',0
 PutE
 PeekC $8006
 mwa $A0 mem_eff_
 jsr printf
 dta c'%',$9b,0
 dta a(mem_eff_)
 PeekC $8004
 mwa $A0 mem_eff_
 jsr printf
 dta c'%',$9b,0
 dta a(mem_eff_)
 PeekC $8002
 mwa $A0 mem_eff_
 jsr printf
 dta c'%',$9b,0
 dta a(mem_eff_)
 PeekC $8000
 mwa $A0 mem_eff_
 jsr printf
 dta c'%',$9b,0
 dta a(mem_eff_)
 jmp *

 .link 'c:\atari\effectus\lib\runtime.obx'
 .link 'c:\atari\effectus\lib\printf.obx'

 run Main_reff_
