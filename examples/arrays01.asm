 org $2200

 icl 'c:\atari\effectus\lib\common.asm'

 .var var19750412_eff_ .word
 .var i_eff_ .byte
 .array num_eff_ [5] .byte = $ff
 .end
 .var array_buffer_num_eff_ .word
 .var array_index_num_eff_ .byte
 .array values_eff_ .word = $ff
 1, 2, 3, 100, 30000, 5
 .end
 .var array_buffer_values_eff_ .word
 .var array_index_values_eff_ .byte

; Effectus example:
; ARRAY elements demonstration 01
MAIN_reff_
 Put #125
 jsr printf
 dta c'Effectus example:',$9b,0
 jsr printf
 dta c'ARRAYs demonstration',$9b,0
 PutE
 jsr printf
 dta c'Array values:',$9b,0
 mva #0 I_eff_
 mva #0 array_index_values_eff_
for_loop17
 ldy array_index_values_eff_
 lda values_eff_,y
 sta array_buffer_values_eff_
 inc array_index_values_eff_
 ldy array_index_values_eff_
 lda values_eff_,y
 sta array_buffer_values_eff_+1
 jsr printf
 dta c'%',0
 dta a(array_buffer_values_eff_)
 #if .byte i_eff_<#8
 jsr printf
 dta c',',0
 #end
 ldx I_eff_
 cpx #8
 inc I_eff_
 inc array_index_values_eff_
 jcc for_loop17
 PutE
 PutE
 mva #10 num_eff_[1]
 mva #155 num_eff_[2]
 mva #246 num_eff_[3]
 jsr printf
 dta c'Show numbers using FOR statement:',$9b,0
 PutE
 mva #1 I_eff_
 mva #2 array_index_values_eff_
for_loop31
 jsr printf
 dta c'num(',0
 mva i_eff_ $c0
 jsr printf
 dta c'%',0
 dta a($c0)
 jsr printf
 dta c')=',0
 ldx i_eff_
 mva num_eff_,x $c0
 jsr printf
 dta c'%',$9b,0
 dta a($c0)
 ldx I_eff_
 cpx #3
 inc I_eff_
 inc array_index_values_eff_
 jcc for_loop31
 PutE
 jsr printf
 dta c'Show numbers using WHILE statement',$9b,0
 jsr printf
 dta c'IN DESCENDING ORDER:',$9b,0
 PutE
 mva #3 i_eff_
 mva #0 array_index_values_eff_
 #while .byte i_eff_>#0
 jsr printf
 dta c'num(',0
 mva i_eff_ $c0
 jsr printf
 dta c'%',0
 dta a($c0)
 jsr printf
 dta c')=',0
 ldx i_eff_
 mva num_eff_,x $c0
 jsr printf
 dta c'%',$9b,0
 dta a($c0)
 dec i_eff_
 inc array_index_values_eff_
 #end
 jmp *

 .link 'c:\atari\effectus\lib\runtime.obx'
 .link 'c:\atari\effectus\lib\printf.obx'
 .link 'c:\atari\effectus\lib\math.obx'

 run Main_reff_
