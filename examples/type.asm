 org $2200

 icl 'c:\atari\effectus\lib\common.asm'

; Handling TYPE variables
 .var struct_ptr_var .word

 .var var19750412_eff_ .word
 .var i_eff_ .word
 .var j_eff_ .word
 .struct rec_eff_
x_eff_ .word
y_eff_ .word
z_eff_ .word
b_eff_ .byte
 .ends

; Effectus example:
; TYPE declaration demonstration
MAIN_reff_
 Put #125
 jsr printf
 dta c'Effectus example:',$9b,0
 jsr printf
 dta c'TYPE declaration demonstration',$9b,0
 PutE
 mwa #50 temp_eff_.x_eff_
 mwa #120 temp_eff_.y_eff_
 mwa #3700 temp_eff_.z_eff_
 mva #200 temp_eff_.b_eff_
 mwa #7 i_eff_
 mwa i_eff_ temp_eff_.x_eff_
 mwa temp_eff_.z_eff_ j_eff_
 jsr printf
 dta c'Members of variable temp of type rec  have these values:',$9b,0
 PutE
 jsr printf
 dta c'temp.x=',0
 jsr printf
 dta c'%',$9b,0
 dta a(temp_eff_.x_eff_)
 jsr printf
 dta c'temp.y=',0
 jsr printf
 dta c'%',$9b,0
 dta a(temp_eff_.y_eff_)
 jsr printf
 dta c'temp.z=',0
 jsr printf
 dta c'%',$9b,0
 dta a(j_eff_)
 jsr printf
 dta c'temp.b=',0
 jsr printf
 dta c'%',$9b,0
 dta a(temp_eff_.b_eff_)
 PutE
 PutE
 jsr printf
 dta c'End of program',$9b,0
 jmp *

 .link 'c:\atari\effectus\lib\runtime.obx'
 .link 'c:\atari\effectus\lib\printf.obx'
temp_eff_ rec_eff_

 run Main_reff_
