 org $2200

 icl 'c:\atari\effectus\lib\common.asm'

 .var var19750412_eff_ .word
 .var x_eff_ .byte
 .var y_eff_ .byte
 .var r_eff_ .byte

; Effectus example:
; Demonstration of using parameters
; with multiple operands
TEST_reff_
 mva #80 x_eff_
 mva #10 y_eff_
 mva #60 r_eff_
 Graphics #7
 Color #1
 Plot x_eff_, y_eff_
 adb x_eff_ r_eff_ b_param1
 sbb b_param1 #10
 adb y_eff_ r_eff_ b_param2
 DrawTo b_param1, b_param2
 Color #2
 sbb x_eff_ r_eff_ b_param1
 adb b_param1 #10
 adb y_eff_ r_eff_ b_param2
 DrawTo b_param1, b_param2
 Color #3
 DrawTo x_eff_, y_eff_
 mva #80 x_eff_
 mva #14 y_eff_
 mva #54 r_eff_
 Plot x_eff_, y_eff_
 adb x_eff_ r_eff_ b_param1
 sbb b_param1 y_eff_
 adb y_eff_ r_eff_ b_param2
 DrawTo b_param1, b_param2
 Color #2
 sbb x_eff_ r_eff_ b_param1
 adb b_param1 y_eff_
 adb y_eff_ r_eff_ b_param2
 DrawTo b_param1, b_param2
 Color #3
 DrawTo x_eff_, y_eff_
 jsr printf
 dta c'Triangle',$9b,0
 jmp *

 .link 'c:\atari\effectus\lib\runtime.obx'
 .link 'c:\atari\effectus\lib\graphics.obx'
 .link 'c:\atari\effectus\lib\printf.obx'
 .link 'c:\atari\effectus\lib\math.obx'

 run Test_reff_
