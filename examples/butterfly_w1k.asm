 org $2200

 icl 'c:\atari\effectus\lib\common.asm'

 .var var19750412_eff_ .word
 .var A_eff_ .word
 .var B_eff_ .word
 .var C_eff_ .word
 .var D_eff_ .word
 .var X_eff_ .word
 .var Y_eff_ .word
 .var J_eff_ .word
 .var K_eff_ .word
 .var COL_eff_ .word
 .var I_eff_ .word
 .var Q_eff_ .word
CH_eff_ equ 764

; Effectus example:
;
; Butterfly by michael mitchell
; 01/20/85
;
; Example provided by w1k from Atariage
;
; Modified by Gury to work correctly
; with random numbers in PC emulation
; software
DEMO2_reff_
 Put #125
 PutE
 jsr printf
 dta c'Butterfly',$9b,0
 PutE
 jsr printf
 dta c'Press any key to start graphics demo!',$9b,0
 mva #255 CH_eff_
 #while .byte ch_eff_=#255
 #end
 Graphics #11
 Poke 710, #0
 Color #0
 mwa #1 A_eff_
 mwa #1 B_eff_
 mwa #1 C_eff_
 mwa #1 D_eff_
 Rand #70
 adw $A0 #1 x_eff_
 Rand #190
 adw $A0 #1 y_eff_
 Rand #50
 adw $A0 #1 j_eff_
 Rand #190
 adw $A0 #1 k_eff_
 mwa #1 I_eff_
 mwa #9400 $A2
for_loop42
 Plot X_eff_, Y_eff_
 DrawTo J_eff_, K_eff_
 Plot J_eff_, Y_eff_
 DrawTo X_eff_, K_eff_
 adw x_eff_ a_eff_
 adw y_eff_ b_eff_
 adw j_eff_ c_eff_
 adw k_eff_ d_eff_
 Rand #50
 mwa $A0 Q_eff_
 #if .word q_eff_>#40
 inw col_eff_
 #end
 #if .word col_eff_>#14
 mwa #1 COL_eff_
 #end
 Color COL_eff_
 #if .word x_eff_>=#79
 sub16 #65535 A_eff_
 mwa $A0 A_eff_
 inw A_eff_
 adw x_eff_ a_eff_
 #end
 #if .word j_eff_>=#79
 sub16 #65535 C_eff_
 mwa $A0 C_eff_
 inw C_eff_
 adw j_eff_ c_eff_
 #end
 #if .word j_eff_<=#0
 sub16 #65535 C_eff_
 mwa $A0 C_eff_
 inw C_eff_
 adw j_eff_ c_eff_
 #end
 #if .word x_eff_<=#0
 sub16 #65535 A_eff_
 mwa $A0 A_eff_
 inw A_eff_
 adw x_eff_ a_eff_
 #end
 #if .word y_eff_>=#191
 sub16 #65535 B_eff_
 mwa $A0 B_eff_
 inw B_eff_
 adw y_eff_ b_eff_
 #end
 #if .word k_eff_>=#191
 sub16 #65535 D_eff_
 mwa $A0 D_eff_
 inw D_eff_
 adw k_eff_ d_eff_
 #end
 #if .word k_eff_<=#0
 sub16 #65535 D_eff_
 mwa $A0 D_eff_
 inw D_eff_
 adw k_eff_ d_eff_
 #end
 #if .word y_eff_<=#0
 sub16 #65535 B_eff_
 mwa $A0 B_eff_
 inw B_eff_
 adw y_eff_ b_eff_
 #end
 lda I_eff_
 cmp $A2
 lda I_eff_+1
 sbc $A3
 inw I_eff_
 jcc for_loop42
 jmp *

 .link 'c:\atari\effectus\lib\runtime.obx'
 .link 'c:\atari\effectus\lib\graphics.obx'
 .link 'c:\atari\effectus\lib\printf.obx'
 .link 'c:\atari\effectus\lib\math.obx'

 run DEMO2_reff_
