 org $2200

 icl 'c:\atari\effectus\lib\common.asm'

 .var var19750412_eff_ .word
 .var i_eff_ .byte
CH_eff_ equ 764
COL_eff_ equ 710

; Effectus example:
; Sound demonstration
WAITFORKEY_reff_ .proc
 #while .byte ch_eff_=#255
 #end
 mva #255 CH_eff_
 rts

 .endp
SPACEKEY_reff_ .proc
 #while .byte ch_eff_<>#33
 #end
 mva #255 CH_eff_
 rts

 .endp
MAIN_reff_
 Put #125
 Poke 82, #0
 SetColor #2, #0, #0
 jsr printf
 dta c'Effectus example:',$9b,0
 jsr printf
 dta c'Sound demonstration',$9b,0
 PutE
 jsr printf
 dta c'Press space for first s. channel!',$9b,0
 SpaceKey_reff_ 
 mva #50 COL_eff_
 Sound #0, #100, #10, #10
 jsr printf
 dta c'Press space for second s. channel!',$9b,0
 SpaceKey_reff_ 
 mva #100 COL_eff_
 Sound #1, #140, #12, #12
 jsr printf
 dta c'Press space for third s. channel!',$9b,0
 SpaceKey_reff_ 
 mva #150 COL_eff_
 Sound #2, #200, #14, #6
 jsr printf
 dta c'Press space for fourth s. channel!',$9b,0
 SpaceKey_reff_ 
 mva #180 COL_eff_
 Sound #3, #70, #10, #4
 PutE
 jsr printf
 dta c'**************+*********************',$9b,0
 jsr printf
 dta c'Press any key to shut off the sound!',$9b,0
 jsr printf
 dta c'***************+********************',$9b,0
 WaitForKey_reff_ 
 mva #240 COL_eff_
; Reset all four sound channels
 SndRst
 PutE
 PutE
 jsr printf
 dta c'End of program',$9b,0
 jmp *

 .link 'c:\atari\effectus\lib\runtime.obx'
 .link 'c:\atari\effectus\lib\graphics.obx'
 .link 'c:\atari\effectus\lib\sound.obx'
 .link 'c:\atari\effectus\lib\printf.obx'

 run Main_reff_
