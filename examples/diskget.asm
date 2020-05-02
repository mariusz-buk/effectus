 org $2200

 icl 'c:\atari\effectus\lib\common.asm'

 .var var19750412_eff_ .word
 .var n_eff_ .byte
 .var i_eff_ .byte

; Effectus example:
;
; Device Input/Output demonstration
; using GetD and Put routines
; Sample file: TEST2.TXT
MAIN_reff_
 Put #125
 jsr printf
 dta c'Effectus example:',$9b,0
 PutE
 jsr printf
 dta c'Device Input/Output demonstration',$9b,0
 jsr printf
 dta c'using GetD and Put procedures',$9b,0
 jsr printf
 dta c'----------------------',$9b,0
 jsr printf
 dta c'Sample file: TEST2.TXT',$9b,0
 PutE
 Close #16
 Open #16, #4, #_str_buffer_22
 jmi stop1
 jsr printf
 dta c'GetD example:',$9b,0
 PutE
 mva #1 I_eff_
for_loop27
 GetD #16
 mva $A0 n_eff_
 Put n_eff_
 ldx I_eff_
 cpx #12
 inc I_eff_
 jcc for_loop27
 Close #16
 PutE
 PutE
 jsr printf
 dta c'----------------------',$9b,0

stop1
 close #$10

 jmp *

 .link 'c:\atari\effectus\lib\runtime.obx'
 .link 'c:\atari\effectus\lib\printf.obx'
 .link 'c:\atari\effectus\lib\io.obx'
_str_buffer_22 .byte 'D:TEST2.TXT', $9b

 run Main_reff_
