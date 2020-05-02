 org $2200

 icl 'c:\atari\effectus\lib\common.asm'

; Handling TYPE variables
 .var struct_ptr_var .word

 .var var19750412_eff_ .word
 .var ENTRY_ptr_eff_ .word
 .struct rec_eff_
NUM1_eff_ .byte
NUM2_eff_ .word
NUM3_eff_ .word
 .ends
 .array DATA_eff_ [16] .byte = $ff
 .end

; Effectus example:
; Record ARRAY demonstration
MAIN_reff_
 Put #125
 jsr printf
 dta c'Effectus example:',$9b,0
 jsr printf
 dta c'Record ARRAY demonstration',$9b,0
 PutE
;ENTRY=DATA+(0*5)
 mva #10 ENTRY_sv_eff_[0].NUM1_eff_
 mwa #100 ENTRY_sv_eff_[0].NUM2_eff_
 mwa #1000 ENTRY_sv_eff_[0].NUM3_eff_
 mva #20 ENTRY_sv_eff_[1].NUM1_eff_
 mwa #200 ENTRY_sv_eff_[1].NUM2_eff_
 mwa #2000 ENTRY_sv_eff_[1].NUM3_eff_
 mva #30 ENTRY_sv_eff_[2].NUM1_eff_
 mwa #200 ENTRY_sv_eff_[2].NUM2_eff_
 mwa #3000 ENTRY_sv_eff_[2].NUM3_eff_
 jsr printf
 dta c'Some data retrieved from the records',$9b,0
 PutE
 jsr printf
 dta c'entry.num1 = ',0
 mva ENTRY_sv_eff_[0].NUM1_eff_ struct_ptr_var
 jsr printf
 dta c'%',$9b,0
 dta a(struct_ptr_var)
 jsr printf
 dta c'entry.num2 = ',0
 mwa ENTRY_sv_eff_[1].NUM2_eff_ struct_ptr_var
 jsr printf
 dta c'%',$9b,0
 dta a(struct_ptr_var)
 jsr printf
 dta c'entry.num3 = ',0
 mwa ENTRY_sv_eff_[2].NUM3_eff_ struct_ptr_var
 jsr printf
 dta c'%',$9b,0
 dta a(struct_ptr_var)
 PutE
 PutE
 jsr printf
 dta c'---------------------',$9b,0
 jmp *

 .link 'c:\atari\effectus\lib\runtime.obx'
 .link 'c:\atari\effectus\lib\printf.obx'
ENTRY_sv_eff_ dta rec_eff_ [2]

 run MAIN_reff_
