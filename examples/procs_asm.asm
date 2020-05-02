 org $2200

 icl 'c:\atari\effectus\lib\common.asm'

 .var var19750412_eff_ .word
CH_eff_ equ 764

; Effectus example:
; Use of inline machine language in
; PROCedures and in the body of the
; program
POKECOLOR1_reff_ .proc
 .he A9 30 8D C6 02 0 60
 rts

 .endp

POKECOLOR2_reff_ .proc
 .he  A9 60 8D C6 02 0 60
 rts

 .endp

POKECOLOR3_reff_ .proc
 .he  A9 90 8D C6 02 0 60 
 rts

 .endp

PARAM_reff_ .proc ( .byte a) .reg
 .he  8D C6 02 0 60
 rts

 .endp

MAIN_reff_
 Put #125
 jsr printf
 dta c'Effectus example:',$9b,0
 jsr printf
 dta c'Inline machine language usage in',$9b,0
 jsr printf
 dta c'PROCedures',$9b,0
 PutE
 PokeColor1_reff_ 
 PokeColor2_reff_ 
 Param_reff_ #120
 PokeColor3_reff_ 
 jsr printf
 dta c'Press any key to change color! (1)',$9b,0
 mva #255 CH_eff_
 #while .byte ch_eff_=#255
 #end
 .he  A9 50 8D C6 02 0 60
 jsr printf
 dta c'Press any key to change color! (2)',$9b,0
 mva #255 CH_eff_
 #while .byte ch_eff_=#255
 #end
 .he  A9 90 3E C6 02 0 60 
 PutE
 PutE
 jsr printf
 dta c'End of program',$9b,0
 jmp *

 .link 'c:\atari\effectus\lib\runtime.obx'
 .link 'c:\atari\effectus\lib\printf.obx'

 run Main_reff_
