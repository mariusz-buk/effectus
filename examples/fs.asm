 org $2200

 icl 'c:\atari\effectus\lib\common.asm'

 .var var19750412_eff_ .word
 .var j_eff_=0 .word
 .var k_eff_=0 .word
hsc_eff_ equ 54276
 .var tmpl_eff_ .byte
 .var tmph_eff_ .byte
 .var tmp_eff_ .byte
 .var i_eff_ .word
sav_eff_ equ 88
clock_eff_ equ $14
nmi_eff_ equ $D40E
dlist_eff_ equ 560
vvblkd_eff_ equ $0224
col0_eff_ equ 708
col1_eff_ equ 709
 .array ndl_eff_ .byte = $ff
 112, 112, 112, 66, 64, 156, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 86, 216, 159, 65, 32, 156
 .end

; Effectus example:
;
; Finescroll by greblus
CHNDL_reff_ .proc
; (1)
 mva NDL_eff_[28] tmp_eff_
 #if .byte tmp_eff_<#2
; (2)
 mva #255 ndl_eff_[28]
; (3)
 sbb ndl_eff_[29] #1 tmp_eff_
; (4)
 mva TMP_eff_ ndl_eff_[29]
 #else
; (5)
 sbb ndl_eff_[28] #2 tmp_eff_
; (6)
 mva TMP_eff_ ndl_eff_[28]
 #end
from_else15
 rts

 .endp
SCROL_reff_ .proc
 mva J_eff_ hsc_eff_
 inw j_eff_
 #if .word j_eff_=#17
 chndl_reff_ 
 mwa #0 j_eff_
 inw k_eff_
 #end
 #if .word k_eff_=#14
 mva TMPL_eff_ ndl_eff_[28]
 mva TMPH_eff_ ndl_eff_[29]
 mwa #0 k_eff_
 #end
 .he  4C 62 E4
 rts

 .endp
MAIN_reff_
 Graphics #0
 mwa #NDL_eff_ dlist_eff_
 mwa #40000 sav_eff_
 mva #14 col0_eff_
 mva #14 col1_eff_
 mwa #1 I_eff_
 mwa #23 $A2
for_loop57
 jsr printf
 dta c'line: ',0
 jsr printf
 dta c'%',0
 dta a(i_eff_)
 PutE
 lda I_eff_
 cmp $A2
 lda I_eff_+1
 sbc $A3
 inw I_eff_
 jcc for_loop57
 jsr printf
 dta c'Action!',0
 mva NDL_eff_[28] tmpl_eff_
 mva NDL_eff_[29] tmph_eff_
 mwa CLOCK_eff_ i_eff_
 #while .byte clock_eff_=i_eff_
 #end
 mva #0 nmi_eff_
 mwa #SCROL_reff_ vvblkd_eff_
 mva #$40 nmi_eff_
loop71 jmp loop71
 jmp *

 .link 'c:\atari\effectus\lib\runtime.obx'
 .link 'c:\atari\effectus\lib\graphics.obx'
 .link 'c:\atari\effectus\lib\printf.obx'
 .link 'c:\atari\effectus\lib\math.obx'

 run main_reff_
