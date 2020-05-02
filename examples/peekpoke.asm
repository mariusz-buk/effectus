 org $2200

 icl 'c:\atari\effectus\lib\common.asm'

 .var var19750412_eff_ .word
 .var num_eff_ .word
 .var n_eff_ .byte
CH_eff_ equ 764
COL_eff_ equ 710

; Effectus example:
; PEEK and POKE demonstration
WAITFORKEY_reff_ .proc
 #while .byte ch_eff_=#255
 #end
 mva #255 CH_eff_
 rts

 .endp
MAIN_reff_
 Put #125
 jsr printf
 dta c'Effectus example:',$9b,0
 jsr printf
 dta c'PEEK demonstration',$9b,0
 PutE
 Peek CH_eff_
 mva $A0 n_eff_
 jsr printf
 dta c'Shadow register 764 currently holds:',$9b,0
 PutE
 mva n_eff_ $c0
 jsr printf
 dta c'%',$9b,0
 dta a($c0)
 PutE
 Peek COL_eff_
 mva $A0 n_eff_
 jsr printf
 dta c'Shadow register 710 currently holds:',$9b,0
 PutE
 mva n_eff_ $c0
 jsr printf
 dta c'%',$9b,0
 dta a($c0)
 PutE
 Peek 559
 mva $A0 n_eff_
 jsr printf
 dta c'Shadow register 559 currently holds:',$9b,0
 PutE
 mva n_eff_ $c0
 jsr printf
 dta c'%',$9b,0
 dta a($c0)
 PutE
 PutE
 jsr printf
 dta c'POKE demonstration',$9b,0
 jsr printf
 dta c'Press any key to change color!',$9b,0
 WaitForKey_reff_ 
 mva #0 COL_eff_
 jsr printf
 dta c'Press any key to change color again!',$9b,0
 WaitForKey_reff_ 
 Poke 710, #230
 jsr printf
 dta c'And again!',$9b,0
 WaitForKey_reff_ 
 mva #65 n_eff_
 Poke 710, n_eff_
 jsr printf
 dta c'Last time!',$9b,0
 WaitForKey_reff_ 
 mva #184 n_eff_
 Poke COL_eff_, n_eff_
 PutE
 jsr printf
 dta c'Thank you!',$9b,0
 PutE
 PutE
 jsr printf
 dta c'End of program',$9b,0
 jmp *

 .link 'c:\atari\effectus\lib\runtime.obx'
 .link 'c:\atari\effectus\lib\printf.obx'

 run Main_reff_
