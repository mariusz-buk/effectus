 org $2200

 icl 'c:\atari\effectus\lib\common.asm'

 .var var19750412_eff_ .word
COL_eff_ equ 710
CH_eff_ equ 764
 .var i_eff_ .byte
 .var n_eff_ .word

; Effectus example:
; Loop demonstrations using
; WHILE, UNTIL, DO OD
WAITFORKEY_reff_ .proc
 #while .byte ch_eff_=#255
 #end
 mva #255 CH_eff_
 rts

 .endp
DELAY_reff_ .proc
 mwa #0 n_eff_
 #while .word n_eff_<#700
 inw n_eff_
 #end
 rts

 .endp
MAIN_reff_
 Put #125
 mva #0 COL_eff_
 jsr printf
 dta c'Loop demonstrations using',$9b,0
 jsr printf
 dta c'WHILE statement',$9b,0
 PutE
 jsr printf
 dta c'Press any key to cycle through colors!',$9b,0
 WaitForKey_reff_ 
 mva #0 i_eff_
 #while .byte i_eff_<#255
 mva I_eff_ COL_eff_
 Delay_reff_ 
 inc i_eff_
 #end
 Put #125
 mva #0 COL_eff_
 PutE
 jsr printf
 dta c'Loop demonstrations using',$9b,0
 jsr printf
 dta c'UNTIL statement',$9b,0
 PutE
 jsr printf
 dta c'Count from 1 to 7:',$9b,0
 mwa #0 n_eff_
 mva #1 loop_var
loop52
LabelUntil52
 inw n_eff_
 jsr printf
 dta c'%',$9b,0
 dta a(n_eff_)
 lda N_eff_
 cmp #7
 beq loop_jump52
 jmp LabelUntil52
loop_jump52
 PutE
 jsr printf
 dta c'Loop demonstrations using',$9b,0
 jsr printf
 dta c'DO-OD statement',$9b,0
 PutE
 jsr printf
 dta c'Counting from 1 to 3 in a loop...',$9b,0
 mva #0 i_eff_
 mva #1 loop_var
loop64
LabelUntil64
 inc i_eff_
 mva i_eff_ $c0
 jsr printf
 dta c'%',$9b,0
 dta a($c0)
 #if .byte i_eff_=#3
 jmp loop_jump64
 #end
 ldx #0
 cpx loop_var
 jcc loop64
loop_jump64
 jmp *

 .link 'c:\atari\effectus\lib\runtime.obx'
 .link 'c:\atari\effectus\lib\printf.obx'
 .link 'c:\atari\effectus\lib\math.obx'

 run Main_reff_
