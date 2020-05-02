 org $2200

 icl 'c:\atari\effectus\lib\common.asm'

 .var var19750412_eff_ .word
 .var i_eff_ .byte
 .var m_eff_ .word
 .var n_eff_ .word
 .var j_eff_ .word

; Effectus example:
; FOR loop demonstration
MAIN_reff_
 Put #125
 jsr printf
 dta c'Effectus example:',$9b,0
 jsr printf
 dta c'FOR loop demonstration',$9b,0
 PutE
 jsr printf
 dta c'Count from 1 to 5:',$9b,0
 mva #1 I_eff_
for_loop15
 mva i_eff_ $c0
 jsr printf
 dta c'%',$9b,0
 dta a($c0)
 ldx I_eff_
 cpx #5
 inc I_eff_
 jcc for_loop15
 PutE
 jsr printf
 dta c'Count from 1 to 3 by using variables:',$9b,0
 mwa #1 m_eff_
 mwa #3 n_eff_
 mwa M_eff_ J_eff_
 mwa N_eff_ $A2
for_loop26
 jsr printf
 dta c'%',$9b,0
 dta a(j_eff_)
 lda J_eff_
 cmp $A2
 lda J_eff_+1
 sbc $A3
 inw J_eff_
 jcc for_loop26
 PutE
 jsr printf
 dta c'Iterate through numbers',$9b,0
 jsr printf
 dta c'from 1 to 10 with increment by 2',$9b,0
 PutE
 mwa #1 N_eff_
 mwa #10 $A2
for_loop36
 jsr printf
 dta c'%',0
 dta a(n_eff_)
 Put #'/'
 lda N_eff_
 cmp $A2
 lda N_eff_+1
 sbc $A3
 inw N_eff_
 inw N_eff_
 jcc for_loop36
 PutE
 PutE
 jsr printf
 dta c'Count to 25600: ',0
 mwa #0 m_eff_
 mwa #1 N_eff_
 mwa #25600 $A2
for_loop47
 inw m_eff_
 lda N_eff_
 cmp $A2
 lda N_eff_+1
 sbc $A3
 inw N_eff_
 jcc for_loop47
 jsr printf
 dta c'%',$9b,0
 dta a(m_eff_)
 PutE
 jsr printf
 dta c'End of program',$9b,0
 jmp *

 .link 'c:\atari\effectus\lib\runtime.obx'
 .link 'c:\atari\effectus\lib\printf.obx'
 .link 'c:\atari\effectus\lib\math.obx'

 run Main_reff_
