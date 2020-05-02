 org $2200

 icl 'c:\atari\effectus\lib\common.asm'

 .var var19750412_eff_ .word
 .var n1_eff_ .byte
 .var n2_eff_ .word
 .var n3_eff_ .word
 .var n4_eff_ .word
 .var n5_eff_ .word
 .var a_eff_ .word
 .var b_eff_ .word
 .var c_eff_ .word
 .var d_eff_ .word
 .var n_eff_ .word

; Effectus example:
; Arithmetics demonstration
MAIN_reff_
 Put #125
 jsr printf
 dta c'Effectus example:',$9b,0
 jsr printf
 dta c'Arithmetics demonstration',$9b,0
 PutE
; 8-bit addition
 mwa #10 $A0
 adb $A0 #30 n1_eff_
 jsr printf
 dta c'10+30=',0
 mva n1_eff_ $c0
 jsr printf
 dta c'%',0
 dta a($c0)
 jsr printf
 dta c'.',0
 PutE
 mwa #1255 n2_eff_
 mwa #30000 n3_eff_
 adw n2_eff_ n3_eff_ n4_eff_
 PutE
 jsr printf
 dta c'n2=',0
 jsr printf
 dta c'%',0
 dta a(n2_eff_)
 jsr printf
 dta c', n3=',0
 jsr printf
 dta c'%',0
 dta a(n3_eff_)
 jsr printf
 dta c'.',0
 PutE
 jsr printf
 dta c'%',0
 dta a(n2_eff_)
 jsr printf
 dta c'+',0
 jsr printf
 dta c'%',0
 dta a(n3_eff_)
 jsr printf
 dta c'=',0
 jsr printf
 dta c'%',0
 dta a(n4_eff_)
 PutE
; 8-bit substraction
 mwa #250 $A0
 sbw $A0 #80 n3_eff_
 PutE
 jsr printf
 dta c'250-80=',0
 jsr printf
 dta c'%',0
 dta a(n3_eff_)
 jsr printf
 dta c'.',0
 PutE
 mwa #25500 n2_eff_
 mwa #1100 n3_eff_
 sbw n2_eff_ n3_eff_ n4_eff_
 PutE
 jsr printf
 dta c'n2=',0
 jsr printf
 dta c'%',0
 dta a(n2_eff_)
 jsr printf
 dta c', n3=',0
 jsr printf
 dta c'%',0
 dta a(n3_eff_)
 jsr printf
 dta c'.',0
 PutE
 jsr printf
 dta c'%',0
 dta a(n2_eff_)
 jsr printf
 dta c'-',0
 jsr printf
 dta c'%',0
 dta a(n3_eff_)
 jsr printf
 dta c'=',0
 jsr printf
 dta c'%',0
 dta a(n4_eff_)
 PutE
; 8-bit multiplication
 Mul16 #10, #255
 mwa  $A0 n3_eff_
 PutE
 jsr printf
 dta c'10*255=',0
 jsr printf
 dta c'%',0
 dta a(n3_eff_)
 jsr printf
 dta c'.',0
 PutE
 mva #255 n1_eff_
 mwa #210 n2_eff_
 Mul16 n1_eff_, n2_eff_
 mwa  $A0 n3_eff_
 PutE
 jsr printf
 dta c'n1=',0
 mva n1_eff_ $c0
 jsr printf
 dta c'%',0
 dta a($c0)
 jsr printf
 dta c', n2=',0
 jsr printf
 dta c'%',0
 dta a(n2_eff_)
 jsr printf
 dta c'.',0
 PutE
 mva n1_eff_ $c0
 jsr printf
 dta c'%',0
 dta a($c0)
 jsr printf
 dta c'*',0
 jsr printf
 dta c'%',0
 dta a(n2_eff_)
 jsr printf
 dta c'=',0
 jsr printf
 dta c'%',0
 dta a(n3_eff_)
 PutE
; 8-bit division
 Div16 #200, #40
 mwa  $A0 n3_eff_
 PutE
 jsr printf
 dta c'200/40=',0
 jsr printf
 dta c'%',0
 dta a(n3_eff_)
 jsr printf
 dta c'.',0
 PutE
 mwa #1000 n5_eff_
 mwa #4 n2_eff_
 Div16 n5_eff_, n2_eff_
 mwa  $A0 n3_eff_
 PutE
 jsr printf
 dta c'n5=',0
 jsr printf
 dta c'%',0
 dta a(n5_eff_)
 jsr printf
 dta c', n2=',0
 jsr printf
 dta c'%',0
 dta a(n2_eff_)
 jsr printf
 dta c'.',0
 PutE
 jsr printf
 dta c'%',0
 dta a(n5_eff_)
 jsr printf
 dta c'/',0
 jsr printf
 dta c'%',0
 dta a(n2_eff_)
 jsr printf
 dta c'=',0
 jsr printf
 dta c'%',0
 dta a(n3_eff_)
 PutE
 mwa #10 a_eff_
 mwa #20 b_eff_
 mwa #30 c_eff_
 mwa #40 d_eff_
 mwa #4 $A0
 adw $A0 a_eff_ n_eff_
 adw n_eff_ b_eff_
 adw n_eff_ c_eff_
 adw n_eff_ #2100
 adw n_eff_ d_eff_
 jsr printf
 dta c'%',$9b,0
 dta a(n_eff_)
 adw a_eff_ b_eff_ n_eff_
 adw n_eff_ c_eff_
 adw n_eff_ #20
 jsr printf
 dta c'%',$9b,0
 dta a(n_eff_)
 sbw d_eff_ a_eff_ n_eff_
 sbw n_eff_ b_eff_
 mwa A_eff_ n_eff_
 inw n_eff_
 jsr printf
 dta c'%',$9b,0
 dta a(n_eff_)
 mwa #20000 $A0
 sbw $A0 #1000 n_eff_
 sbw n_eff_ #10000
 jsr printf
 dta c'%',$9b,0
 dta a(n_eff_)
 PutE
 jsr printf
 dta c'End of program',$9b,0
 jmp *

 .link 'c:\atari\effectus\lib\runtime.obx'
 .link 'c:\atari\effectus\lib\printf.obx'
 .link 'c:\atari\effectus\lib\math.obx'

 run Main_reff_
