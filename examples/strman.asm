 org $2200

 icl 'c:\atari\effectus\lib\common.asm'

 .var var19750412_eff_ .word
 .var n1_eff_ .byte
 .var n2_eff_ .byte
 .array str1_eff_ [16] .byte = $ff
 .end
 .array str2_eff_ [16] .byte = $ff
 .end
 .array str3_eff_ [16] .byte = $ff
 .end
 .array str4_eff_ [9] .byte = $ff
 .end
 .array str5_eff_ [6] .byte = $ff
 .end
 .array STRA_eff_ [16] .byte = $ff
 [0] = 'Old text',$9b
 .end

; Effectus example:
; SCopy, SCopyS, SAssign demonstration
MAIN_reff_
 Put #125
 jsr printf
 dta c'Effectus example:',$9b,0
 jsr printf
 dta c'SCopy demonstration',$9b,0
 PutE
 ldx #0
loop_16
 mva _str_buffer_16,x str1_eff_,x
 inx
 cpx #5
 jcc loop_16
 jsr printf
 dta c'str1 = ',0
 jsr printf
 dta c'#',$9b,0
 dta a(str1_eff_)
 ldx #0
loop_19
 mva _str_buffer_19,x str2_eff_,x
 inx
 cpx #13
 jcc loop_19
 jsr printf
 dta c'str2 = ',0
 jsr printf
 dta c'#',$9b,0
 dta a(str2_eff_)
 ldx #0
loop_22
 mva _str_buffer_22,x str3_eff_,x
 inx
 cpx #12
 jcc loop_22
 jsr printf
 dta c'str3 = ',0
 jsr printf
 dta c'#',$9b,0
 dta a(str3_eff_)
 PutE
 jsr printf
 dta c'Variable str2 = str1',$9b,0
 ldx #0
loop_27
 mva str1_eff_,x str2_eff_,x
 inx
 cpx #15
 jcc loop_27
 jsr printf
 dta c'#',$9b,0
 dta a(str2_eff_)
 PutE
 jsr printf
 dta c'SCopyS demonstration',$9b,0
 PutE
 jsr printf
 dta c'Original string: LATARIAN',$9b,0
 ldy #2
 dey
 ldx #0
loop_34
 lda _str_buffer_34,y
 sta str4_eff_,x
 iny
 inx
 cpx #5
 jcc loop_34
 mva #2 n1_eff_
 mva #5 n2_eff_
 mva n2_eff_ b_param1
 dec b_param1
 ldy n1_eff_
 dey
 ldx #0
loop_37
 lda str4_eff_,y
 sta str5_eff_,x
 iny
 inx
 cpx b_param1
 jcc loop_37
 PutE
 jsr printf
 dta c'Extracted strings:',$9b,0
 jsr printf
 dta c'#',$9b,0
 dta a(str4_eff_)
 jsr printf
 dta c'#',$9b,0
 dta a(str5_eff_)
 PutE
 jsr printf
 dta c'SAssign demonstration',$9b,0
 PutE
 jsr printf
 dta c'strA=',0
 jsr printf
 dta c'#',$9b,0
 dta a(strA_eff_)
 ldx #0
loop_48
 mva _str_buffer_48,x str2_eff_,x
 inx
 cpx #8
 jcc loop_48
 jsr printf
 dta c'str2=',0
 jsr printf
 dta c'#',$9b,0
 dta a(str2_eff_)
 ldy #1
 dey
 ldx #0
loop_51
 lda strA_eff_,y
 sta Str2_eff_,x
 iny
 inx
 cpx #5
 jcc loop_51
 jsr printf
 dta c'New str2=',0
 jsr printf
 dta c'#',$9b,0
 dta a(str2_eff_)
 ldy #6
 dey
 ldx #0
loop_54
 lda _str_buffer_54,y
 sta Str2_eff_,x
 iny
 inx
 cpx #10
 jcc loop_54
 jsr printf
 dta c'New str2=',0
 jsr printf
 dta c'#',$9b,0
 dta a(str2_eff_)
 jmp *

 .link 'c:\atari\effectus\lib\runtime.obx'
 .link 'c:\atari\effectus\lib\printf.obx'
_str_buffer_16 .byte 'Atari', $9b
_str_buffer_19 .byte 'Second string', $9b
_str_buffer_22 .byte 'Third string', $9b
_str_buffer_34 .byte 'LATARIAN', $9b
_str_buffer_48 .byte 'Baracuda', $9b
_str_buffer_54 .byte 'Test again', $9b

 run Main_reff_
