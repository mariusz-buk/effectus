 org $2200

 icl 'c:\atari\effectus\lib\common.asm'

 .var var19750412_eff_ .word
 .array name_eff_ [14] .byte = $ff
 .end
 .array surname_eff_ [22] .byte = $ff
 .end

; Effectus example:
; String input demonstration
; using InputS procedure
MAIN_reff_
 Put #125
 jsr printf
 dta c'Effectus example:',$9b,0
 jsr printf
 dta c'String input demonstration',$9b,0
 jsr printf
 dta c'using InputS procedure',$9b,0
 PutE
 jsr printf
 dta c'What''s your name?',$9b,0
 getline #name_eff_
 PutE
 jsr printf
 dta c'What''s your surname?',$9b,0
 getline #surname_eff_
 PutE
 jsr printf
 dta c'Thank you, ',0
 jsr printf
 dta c'#',0
 dta a(name_eff_)
 Put #' '
 jsr printf
 dta c'#',$9b,0
 dta a(surname_eff_)
 PutE
 PutE
 PutE
 jsr printf
 dta c'End of program',$9b,0
 jmp *

 .link 'c:\atari\effectus\lib\runtime.obx'
 .link 'c:\atari\effectus\lib\printf.obx'

 run Main_reff_
