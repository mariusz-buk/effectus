 org $2200

 icl 'c:\atari\effectus\lib\common.asm'

 .var var19750412_eff_ .word
 .var x_eff_ .byte
 .var y_eff_ .word
 .var z_eff_ .word

; Effectus example:
; PrintF demonstration
MAIN_reff_
 Put #125
 jsr printf
 dta c'Effectus example:',$9b,0
 jsr printf
 dta c'PrintF demonstration',$9b,0
 PutE
 mva #120 x_eff_
 mwa #3200 y_eff_
 mwa #65001 z_eff_
 jsr printf
 dta c'The numbers are:',0
 PutE
 jsr printf
 dta c'x=',0
 mva x_eff_ $c0
 jsr printf
 dta c'%',0
 dta a($c0)
 jsr printf
 dta c', y=',0
 jsr printf
 dta c'%',0
 dta a(y_eff_)
 jsr printf
 dta c', z=',0
 jsr printf
 dta c'%',0
 dta a(z_eff_)
 jsr printf
 dta c'.',0
 PutE
 PutE
 jsr printf
 dta c'Procent sign: ',0
 put #'%'
 mva #155 X_eff_
 PutE
 PutE
 jsr printf
 dta c'HEX (x) ',0
 mva X_eff_ $c0
 jsr printf
 dta c'%',0
 dta a($c0)
 jsr printf
 dta c'=',0
 ShowHex X_eff_
 jsr printf
 dta c'$000',0
 jsr printf
 dta c'#',0
 dta a(hex_num+1)
 mva #4 X_eff_
 PutE
 jsr printf
 dta c'HEX (x) ',0
 mva X_eff_ $c0
 jsr printf
 dta c'%',0
 dta a($c0)
 jsr printf
 dta c'=',0
 ShowHex X_eff_
 jsr printf
 dta c'$000',0
 jsr printf
 dta c'#',0
 dta a(hex_num+1)
 mva #11 X_eff_
 PutE
 jsr printf
 dta c'HEX (x) ',0
 mva X_eff_ $c0
 jsr printf
 dta c'%',0
 dta a($c0)
 jsr printf
 dta c'=',0
 ShowHex X_eff_
 jsr printf
 dta c'$000',0
 jsr printf
 dta c'#',0
 dta a(hex_num+1)
 PutE
 PutE
 jsr printf
 dta c'First character: ',0
 Put #65
 PutE
 jsr printf
 dta c'Number one: ',0
 Put #49
 PutE
 PutE
 PutE
 jsr printf
 dta c'End of program',0
 PutE
 jmp *

 .link 'c:\atari\effectus\lib\runtime.obx'
 .link 'c:\atari\effectus\lib\printf.obx'

 run Main_reff_
