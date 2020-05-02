; Effectus example:
; INCLUDE demonstration
; User library
WAITFORKEY_reff_ .proc
 mva #255 CH_eff_
 #while .byte ch_eff_=#255
 #end
 rts

 .endp
PRINTTEXT_reff_ .proc
 jsr printf
 dta c'Hello world',$9b,0
 rts

 .endp
CHANGECOLOR_reff_ .proc
 Poke 710, #14
 Poke 712, #182
 rts

 .endp
DUMMY_reff_ .proc
 jsr printf
 dta c'Don''t know why there must be one more procedure...',$9b,0
 rts

 .endp
