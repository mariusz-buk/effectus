 org $2200

 icl 'c:\atari\effectus\lib\common.asm'

 .var var19750412_eff_ .word
 .array str_buffer1_eff_ [256] .byte = $ff
 .end

;
; Effectus example:
;
; Device Input/Output demonstration
; using InputSD procedure for reading
; text file
; Sample file: TEST.TXT
;
MAIN_reff_
 Put #125
 jsr printf
 dta c'Effectus example:',$9b,0
 PutE
 jsr printf
 dta c'Device Input/Output demonstration',$9b,0
 jsr printf
 dta c'using InputSD procedure for reading',$9b,0
 jsr printf
 dta c'text file',$9b,0
 jsr printf
 dta c'---------------------',$9b,0
 jsr printf
 dta c'Sample file: TEST.TXT',$9b,0
 PutE
 Close #16
 Open #16, #4, #_str_buffer_27
 jmi stop1
 jsr printf
 dta c'InputSD example:',$9b,0
 PutE
 Read #16, #5, #str_buffer1_eff_, #255
 jsr printf
 dta c'#',$9b,0
 dta a(str_buffer1_eff_)
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
_str_buffer_27 .byte 'D1:TEST.TXT', $9b

 run Main_reff_
