;
; Effectus / MADS runtime library
;
; Source code assembled with Mads 2.0.8 build 31 (8 Jan 19)

  icl 'equates.asm'

  .reloc

  .public device, device.devscr
  .public GetLine, SetColor, Put, PutE, Rand, SetBlock, Zero

  // Action! code block variables
//  .var a_reg, x_reg, y_reg, a3_par, a4_par, a5_par, a6_par, a7_par, a8_par .byte
//  .var a9_par, aA_par, aB_par, aC_par, aD_par, aE_par, aF_par .byte

; temporary BYTE variable
  .var b_prm01 .byte

; temporary WORD variables
  .var w_prm01, w_prm02 .word

; device - Global variable representing current device enabled
;
; Parameters:
; .byte x (8-bit value): current device 
;
; Result:
; devscr (8-bit value): current device (a variable used inside any file)
;
device  .proc (.byte x) .reg

  stx devscr
  rts

devscr  brk

  .endp

; GetLine - Input string from device 0 (editor)
;
; Original source:
; Mad-Assembler (MADS)
; Hyperlink: http://mads.atari8.info/
;
; Parameters:
; .word ya (16-bit value): Buffer for inputted string
;
; Result:
; ICBAL,x (low byte of 16-bit value): Buffer for inputted string on device 0
; ICBAL+1,x (high byte of 16-bit value): Buffer for inputted string on device 0
;
GetLine .proc (.word ya)  .reg

  ldx device.devscr
  sta ICBAL,x
  tya
  sta ICBAL+1,x

  mwa #120 ICBLL,x	; maximum size of inputted text

  mva #$05  iccom,x
  jmp CIOV

  .endp

; Setcolor - Set color of specific color register
;
; Parameters:
; .byte x (8-bit value): Color register
; .byte a (8-bit value): Color hue
; .byte y (8-bit value): Color luminance
;
; Result:
; COLOR0,X (8-bit value): Actual color register affected
; STORE1 (8-bit value)
;
SetColor  .proc (.byte x .byte a .byte y) .reg

  asl @         ; need to multiply
  asl @         ; hue by 16, and
  asl @         ; add it to lum.
  asl @         ; now hue is *16
  sta $A0    ; temporarily
  tya           ; so we can add
  clc           ; before adding
  adc $A0    ; now have sum
  sta COLORO,x  ; actual SETCOLOR
  rts

  .endp

; Rand - Random routine
;
; Parameters:
; .byte a (8-bit value): A value between 0 and 255
;
; Result:
; STORE1 (8-bit value): Random number between 0 and 255
; 
Rand  .proc (.byte a) .reg

  sta $A2
Loop
  lda RANDOM
  sta $A0
  #if .byte $A0>$A2
    jmp Loop
  #end
  rts

  .endp

; Put - Put a character to device 0 (editor)
;
; Parameters:
; .byte a (8-bit value): ATASCII value of character to be written to device 0
;
Put .proc (.byte a) .reg

  ldx device.devscr
  tay
  lda ICPTL+1,x
  pha
  lda ICPTL,x
  pha
  tya
  rts

  .endp

; PutE - Put a carriage return character to device 0 (editor)
;
PutE  .proc

  Put #$9b
  rts
 
  .endp

; ANTIC VOL. 1, NO. 2 / JUNE 1982 / PAGE 15
;PROC SetBlock (BYTE POINTER adr,CARD size,BYTE value)
SetBlock  .proc (.word w_prm01, w_prm02 .byte b_prm01) .var

  LDA #>w_prm01       ; save lo-byte of dest addr
  STA  $CC
  LDA #<w_prm01       ; save hi-byte of dest addr
  STA  $CB
  LDA #>w_prm02       ; save total to be moved
  STA  $CE       ; *
  LDA #<w_prm02       ; save total to be moved
  STA  $CD       ; *
  LDX  $CE       ; count of bytes to move
  LDY  #0        ; init index
  LDA  b_prm01   ; init character to be moved
MOV STA ($CB),Y    ; move data
  DEY            ; decrement index
  BNE  MOV       ; go move next character
  INC  $CC       ; incr dest addr lo-byte
  DEX            ; decr lo-byte count to move
  BMI  EXIT
  BNE  MOV       ; go move next character
  LDY  $CD       ; hi-byte of count to move
  BNE  MOV       ; go move next character
EXIT  DEC  $CC       ; decr lo-byte dest addr
  LDY  #0
  STA  ($CD),Y
  rts

  .endp

Zero  .proc (.word w_prm01, w_prm02) .var
;PROC Zero (BYTE POINTER adr,CARD size)

  SetBlock w_prm01, w_prm02, #0
  rts

  .endp
