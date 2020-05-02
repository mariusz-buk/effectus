 org $2200

 icl 'c:\atari\effectus\lib\common.asm'

 .var var19750412_eff_ .word
 .var ptr_ptr_eff_ .word
 .var i_eff_ .word

; Effectus example:
; POINTER variable demonstration
MAIN_reff_
 Put #125
 jsr printf
 dta c'Effectus example:',$9b,0
 jsr printf
 dta c'POINTER variable demonstration',$9b,0
 PutE
 mwa #70 i_eff_
 jsr printf
 dta c'Current value of variable i: ',$9b,0
 jsr printf
 dta c'%',$9b,0
 dta a(I_eff_)
 lda #<i_eff_
 sta $c0
 lda #>i_eff_
 sta $c1

 mwa $c0 ptr_ptr_eff_

 jsr printf
 dta c'Memory address of variable i: ',$9b,0
 jsr printf
 dta c'%',$9b,0
 dta a(ptr_ptr_eff_)
 jsr printf
 dta c'PrintE(" ")',$9b,0
 jsr printf
 dta c'New value of variable ptr and i: ',$9b,0
 mwa #251 ptr_ptr_eff_
 lda ptr_ptr_eff_
 ldy #0
 sta ($c0),y
 jsr printf
 dta c'%',0
 dta a(ptr_ptr_eff_)
 jsr printf
 dta c', ',0
 jsr printf
 dta c'%',$9b,0
 dta a(i_eff_)
 PutE
 PutE
 jsr printf
 dta c'End of program',$9b,0
 jmp *

 .link 'c:\atari\effectus\lib\runtime.obx'
 .link 'c:\atari\effectus\lib\printf.obx'

 run Main_reff_
