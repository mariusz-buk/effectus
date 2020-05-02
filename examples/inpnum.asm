 org $2200

 icl 'c:\atari\effectus\lib\common.asm'

 .var var19750412_eff_ .word
 .var n1_eff_ .byte
 .var n2_eff_ .word
 .var n3_eff_ .word

; Effectus example:
; InputB, InputI and InputC function
; demonstration
MAIN_reff_
 Put #125
 PutE
 jsr printf
 dta c'Enter BYTE value: ',$9b,0
 getline #hex_num
 ldx #0
 lda hex_num,x
 sbc #48
 sta n1_eff_
 lda #10
 cmp n1_eff_
 bcc jfv14
 jmp skip14
jfv14 mva #0 n1_eff_
skip14
 jsr printf
 dta c'Enter INT value: ',$9b,0
 getline #hex_num
 ldx #0
 lda hex_num,x
 sbc #48
 sta n2_eff_
 lda #10
 cmp n2_eff_
 bcc jfv16
 jmp skip16
jfv16 mva #0 n2_eff_
skip16
 jsr printf
 dta c'Enter CARD value: ',$9b,0
 getline #hex_num
 ldx #0
 lda hex_num,x
 sbc #48
 sta n3_eff_
 lda #10
 cmp n3_eff_
 bcc jfv18
 jmp skip18
jfv18 mva #0 n3_eff_
skip18
 PutE
 PutE
 jsr printf
 dta c'And data entered is:',0
 PutE
 PutE
 mva n1_eff_ $c0
 jsr printf
 dta c'%',$9b,0
 dta a($c0)
 jsr printf
 dta c'%',$9b,0
 dta a(n2_eff_)
 jsr printf
 dta c'%',$9b,0
 dta a(n3_eff_)
 jmp *

 .link 'c:\atari\effectus\lib\runtime.obx'
 .link 'c:\atari\effectus\lib\printf.obx'

 run Main_reff_
