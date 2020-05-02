 org $2200

 icl 'c:\atari\effectus\lib\common.asm'

 .var var19750412_eff_ .word
 .var n_eff_ .byte
 .var i_eff_ .word
 .array items_eff_ [13] .word = $ff
 .end
 .var array_buffer_items_eff_ .word
 .var array_index_items_eff_ .byte
 .array STR1_eff_ .byte = $ff
 [0] = 'First text',$9b
 .end
 .var array_buffer_STR1_eff_ .word
 .var array_index_STR1_eff_ .byte
 .array STR2_eff_ [21] .byte = $ff
 [0] = 'Second text',$9b
 .end
 .var array_buffer_STR2_eff_ .word
 .var array_index_STR2_eff_ .byte
 .array bytes_eff_ [5] .byte = $ff
 .end
 .var array_buffer_bytes_eff_ .word
 .var array_index_bytes_eff_ .byte

; Effectus example:
; ARRAY elements demonstration 02
MAIN_reff_
 Put #125
 jsr printf
 dta c'Effectus example:',$9b,0
 jsr printf
 dta c'ARRAY usage demonstration',$9b,0
 PutE
 mwa #21 items_eff_[0]
 mwa #1024 items_eff_[1]
 mwa #40678 items_eff_[2]
 mva #1 N_eff_
 mva #2 array_index_items_eff_
for_loop25
 mva N_eff_ $c0
 ldx n_eff_
 mva $c0 bytes_eff_,x
 ldx N_eff_
 cpx #4
 inc N_eff_
 inc array_index_items_eff_
 jcc for_loop25
 jsr printf
 dta c'CARD ARRAY items:',$9b,0
 PutE
 jsr printf
 dta c'items(0)=',0
 mva #0*2 array_index_items_eff_
 ldy array_index_items_eff_
 lda items_eff_,y
 sta array_buffer_items_eff_
 inc array_index_items_eff_
 ldy array_index_items_eff_
 lda items_eff_,y
 sta array_buffer_items_eff_+1
 jsr printf
 dta c'%',$9b,0
 dta a(array_buffer_items_eff_)
 mwa ITEMS_eff_[1] i_eff_
 jsr printf
 dta c'items(1)=',0
 jsr printf
 dta c'%',$9b,0
 dta a(i_eff_)
 jsr printf
 dta c'items(2)=',0
 mva #2*2 array_index_items_eff_
 ldy array_index_items_eff_
 lda items_eff_,y
 sta array_buffer_items_eff_
 inc array_index_items_eff_
 ldy array_index_items_eff_
 lda items_eff_,y
 sta array_buffer_items_eff_+1
 jsr printf
 dta c'%',$9b,0
 dta a(array_buffer_items_eff_)
 jsr printf
 dta c'items(4)=',0
 jsr printf
 dta c'#',$9b,0
 dta a(items_eff_array_str_4)
 jsr printf
 dta c'items(11)=',0
 jsr printf
 dta c'#',$9b,0
 dta a(items_eff_array_str_11)
 jsr printf
 dta c'items(3)=',0
 jsr printf
 dta c'#',$9b,0
 dta a(items_eff_array_str_3)
 PutE
 jsr printf
 dta c'Byte count: ',$9b,0
 mva #1 N_eff_
 mva #2 array_index_items_eff_
for_loop49
 ldx n_eff_
 mva bytes_eff_,x $c0
 jsr printf
 dta c'%',0
 dta a($c0)
 jsr printf
 dta c',',0
 ldx N_eff_
 cpx #4
 inc N_eff_
 inc array_index_items_eff_
 jcc for_loop49
 PutE
 PutE
 jsr printf
 dta c'String examples:',$9b,0
 jsr printf
 dta c'#',$9b,0
 dta a(Str1_eff_)
 jsr printf
 dta c'#',$9b,0
 dta a(Str2_eff_)
 PutE
 PutE
 jsr printf
 dta c'End of program',$9b,0
 jmp *

 .link 'c:\atari\effectus\lib\runtime.obx'
 .link 'c:\atari\effectus\lib\printf.obx'
items_eff_array_str_3 .byte 'ATARI FOREVER',$9b
items_eff_array_str_4 .byte 'FUJI',$9b
items_eff_array_str_11 .byte 'DUMMY STRING',$9b

 run Main_reff_
