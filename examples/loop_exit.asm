 org $2200

 icl 'c:\atari\effectus\lib\common.asm'

 .var var19750412_eff_ .word
 .var n_eff_ .byte

; Effectus example:
;Using EXIT command in loop statements
MAIN_reff_
 Put #125
 jsr printf
 dta c'Effectus example:',$9b,0
 jsr printf
 dta c'Using EXIT command in loop statements FOR, WHILE and UNTIL',$9b,0
 PutE
 jsr printf
 dta c'Counting from 1 to 10...',$9b,0
 PutE
 mva #1 N_eff_
for_loop16
 mva n_eff_ $c0
 jsr printf
 dta c'%',0
 dta a($c0)
 Put #44
 #if .byte n_eff_=#7
 jmp jump_from_for_loop16
 #end
 ldx N_eff_
 cpx #10
 inc N_eff_
 jcc for_loop16
jump_from_for_loop16
 PutE
 jsr printf
 dta c'Escaped from FOR loop!',$9b,0
 PutE
 jsr printf
 dta c'Counting from 1 to 20...',$9b,0
 PutE
 mva #1 n_eff_
 #while .byte n_eff_<#21
 mva n_eff_ $c0
 jsr printf
 dta c'%',0
 dta a($c0)
 Put #44
 #if .byte n_eff_=#14
 jmp jump_from_while_34
 #end
 inc n_eff_
 #end
jump_from_while_34
 PutE
 jsr printf
 dta c'Escaped from WHILE loop!',$9b,0
 PutE
 jsr printf
 dta c'Counting from 1 to 6...',$9b,0
 PutE
 mva #0 n_eff_
 mva #1 loop_var
loop55
LabelUntil55
 inc n_eff_
 mva n_eff_ $c0
 jsr printf
 dta c'%',0
 dta a($c0)
 Put #44
 jmp loop_jump55
 lda N_eff_
 cmp #6
 beq loop_jump55
 jmp LabelUntil55
loop_jump55
 PutE
 jsr printf
 dta c'Escaped from UNTIL loop!',$9b,0
 PutE
 PutE
 jsr printf
 dta c'End of program',$9b,0
 jmp *

 .link 'c:\atari\effectus\lib\runtime.obx'
 .link 'c:\atari\effectus\lib\printf.obx'
 .link 'c:\atari\effectus\lib\math.obx'

 run Main_reff_
