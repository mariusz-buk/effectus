 org $2200

 icl 'c:\atari\effectus\lib\common.asm'

 .var var19750412_eff_ .word
 .var N_eff_ .byte

; Effectus example:
; Calling OS routines demonstration
TEXT_reff_ .proc
 jsr printf
 dta c'Press two keys to scroll up!',$9b,0
 rts

 .endp
; Scroll screen
SCROLL_reff_ .proc
 jsr $F7F7
 rts

 .endp
; Keyclick sound
CLICK_reff_ .proc
 jsr $F983
 rts

 .endp
; Read key
KBGET_reff_ .proc
 jsr $F302
 rts

 .endp
; Casette-beep sound
BEEPWAIT_reff_ .proc ( .byte a) .reg
 jsr $FDFC
 rts

 .endp
; Routines currently can't take the
; same name like equates in the library,
; so they must be renamed
CIOV_reff_ .proc ( .byte a, x) .reg
 jsr $E4DF
 rts

 .endp
MAIN_reff_
 Put #125
 Position #2, #18
 Text_reff_ 
 BEEPWAIT_reff_ #1
 KBGET_reff_ 
 mva #1 N_eff_
for_loop36
 CLICK_reff_ 
 SCROLL_reff_ 
 ldx N_eff_
 cpx #20
 inc N_eff_
 jcc for_loop36
 jsr printf
 dta c'End of program',$9b,0
 jmp *

 .link 'c:\atari\effectus\lib\runtime.obx'
 .link 'c:\atari\effectus\lib\graphics.obx'
 .link 'c:\atari\effectus\lib\printf.obx'

 run MAIN_reff_
