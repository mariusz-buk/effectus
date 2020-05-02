;
; Effectus / MADS game controller library
;
; Source code assembled with Mads 2.0.8 build 31 (8 Jan 19)

  icl 'equates.asm'

  .reloc

  .public Stick, Strig, Paddle, Ptrig

; Stick - Joystick movement status routine
;
; Parameters:
; .byte a (8-bit value): Joystick port (0 or 1)
;
; Result:
; STORE1 (8-bit value): Joystick movement status
;
Stick .proc (.byte a) .reg

  sta $A1
  #if .byte $A1 = #0
    lda STICK0  ; Stick 0 status
    sta $A0
  #end
  #if .byte $A1 = #1
    lda STICK1  ; Stick 1 status
    sta $A0
  #end
  rts

  .endp

; Strig - Joystick trigger status routine
;
; Parameters:
; .byte a (8-bit value): Joystick port (0 or 1)
;
; Result:
; STORE1 (8-bit value): Joystick trigger status
;
Strig .proc (.byte a) .reg

  sta $A1
  #if .byte $A1 = #0
    mva STRIG0 $A0  ; Stick 0 trigger status
  #end
  #if .byte $A1 = #1
    mva STRIG1 $A0  ; Stick 1 trigger status
  #end  
  rts
 
  .endp 

; Paddle - Paddle movement status routine
;
; Parameters:
; .byte a (8-bit value): Paddle (0 or 3)
;
; Result:
; STORE1 (8-bit value): Paddle movement status
;
Paddle  .proc (.byte a) .reg

  sta $A1
  #if .byte $A1 = #0
    mva PADDL0 $A0  ; Paddle 0 status
  #end
  #if .byte $A1 = #1
    mva PADDL1 $A0  ; Paddle 1 status
  #end
  #if .byte $A1 = #2
    mva PADDL2 $A0  ; Paddle 2 status
  #end
  #if .byte $A1 = #3
    mva PADDL3 $A0  ; Paddle 3 status
  #end
  rts
 
  .endp

; Ptrig - Paddle trigger status routine
;
; Parameters:
; .byte a (8-bit value): Paddle (0 or 3)
;
; Result:
; STORE1 (8-bit value): Paddle trigger status
;
Ptrig .proc (.byte a) .reg

  sta $A1
  #if .byte $A1 = #0
    mva PTRIG0 $A0  ; Paddle 0 trigger status
  #end
  #if .byte $A1 = #1
    mva PTRIG1 $A0  ; Paddle 1 trigger status
  #end
  #if .byte $A1 = #2
    mva PTRIG2 $A0  ; Paddle 2 trigger status
  #end
  #if .byte $A1 = #3
    mva PTRIG3 $A0  ; Paddle 3 trigger status
  #end
  rts
 
  .endp
