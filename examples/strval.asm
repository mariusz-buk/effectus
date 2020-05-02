 org $2200

 icl 'c:\atari\effectus\lib\common.asm'

 .var var19750412_eff_ .word
 .var num1_eff_ .byte
 .var num2_eff_ .word
 .var num3_eff_ .word
 .array strnum1_eff_ [7] .byte = $ff
 .end
 .array strnum2_eff_ [7] .byte = $ff
 .end
 .array strnum3_eff_ [7] .byte = $ff
 .end

; Effectus example:
;- Number to string conversion using
;  StrB, StrI and StrC procedures
;- String to number conversion by using
;  ValB, ValI and ValC
MAIN_reff_
 Put #125
 jsr printf
 dta c'Effectus example:',$9b,0
 PutE
 jsr printf
 dta c'Number to string conversion using',$9b,0
 jsr printf
 dta c'StrB, StrI and StrC procedures',$9b,0
 PutE
 ldy #0
 mva #'6' strnum1_eff_,y
 iny
 mva #'5' strnum1_eff_,y
 iny
 mva #'0' strnum1_eff_,y
 iny
 mva #'0' strnum1_eff_,y
 iny
 mva #'0' strnum1_eff_,y
 ldy #0
 mva #'3' strnum2_eff_,y
 iny
 mva #'2' strnum2_eff_,y
 iny
 mva #'0' strnum2_eff_,y
 iny
 mva #'0' strnum2_eff_,y
 ldy #0
 mva #'1' strnum3_eff_,y
 iny
 mva #'7' strnum3_eff_,y
 iny
 mva #'8' strnum3_eff_,y
 jsr printf
 dta c'strnum1 = ',0
 jsr printf
 dta c'#',$9b,0
 dta a(strnum1_eff_)
 jsr printf
 dta c'strnum2 = ',0
 jsr printf
 dta c'#',$9b,0
 dta a(strnum2_eff_)
 jsr printf
 dta c'strnum3 = ',0
 jsr printf
 dta c'#',$9b,0
 dta a(strnum3_eff_)
 PutE
 jsr printf
 dta c'String to number conversion by using',$9b,0
 jsr printf
 dta c'ValB, ValI and ValC',$9b,0
 PutE
 mva _strval_38_ $A0
 mva $A0 num1_eff_
 jsr printf
 dta c'num1=',0
 mva num1_eff_ $c0
 jsr printf
 dta c'%',$9b,0
 dta a($c0)
 mwa _strval_42_ $A0
 mwa $A0 num2_eff_
 jsr printf
 dta c'num2=',0
 jsr printf
 dta c'%',$9b,0
 dta a(num2_eff_)
 mwa _strval_46_ $A0
 mwa $A0 num3_eff_
 jsr printf
 dta c'num3=',0
 jsr printf
 dta c'%',$9b,0
 dta a(num3_eff_)
 PutE
 PutE
 jsr printf
 dta c'.....................................',$9b,0
 jmp *

 .link 'c:\atari\effectus\lib\runtime.obx'
 .link 'c:\atari\effectus\lib\printf.obx'
_strval_38_ dta a(100)
_strval_42_ dta a(1500)
_strval_46_ dta a(44611)

 run Main_reff_
