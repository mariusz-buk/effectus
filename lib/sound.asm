;
; Effectus / MADS sound runtime library
;
; Source code assembled with Mads 2.0.8 build 31 (8 Jan 19)

  icl 'equates.asm'	

  .reloc

  .public Sound SndRst

  STORE2 equ $CC   ; Temporary 8-bit variable

/*
  Sound - Sound routine
  Modified by Tebe
 
  Parameters:
  .byte voice (8-bit value): voice channel
  .byte freq (8-bit value): frequency
  .byte dist (8-bit value): distortion
  .byte volume (8-bit value): volume
*/
Sound .proc (.byte voice+1, freq+1, dist+1, volume+1) .var

voice LDX #0 ; set voice
freq  LDA #0
  STA STORE2+1 ; set and store frequency
dist  LDA #0 ; set distortion
  PHA ; store distortion
  TXA ; double voice value
volume  LDY #0 ; set volume
  ASL @ ; for offset to
  TAX ; voice control
store2  LDA #0 ; frequency into
  STA AUDF1,X ; right channel
  LDA #0 ; to initialize the
  STA AUDCTL ; POKEY chip
  LDA #3 ; set these as
  STA SKCTL ; indicated
  PLA ; retrieve distortion
  ASL @ ; now multiply by
  ASL @ ; 16 to get the
  ASL @ ; distortion into
  ASL @ ; the high nibble
  CLC ; setup for add
  ADC STORE2+1 ; add the volume
  STA AUDC1,X ; into right voice
  RTS
 
  .endp

/*
  SndRst - Sound reset routine
*/
SndRst  .proc

  Sound #0, #0, #0, #0
  Sound #1, #0, #0, #0
  Sound #2, #0, #0, #0
  Sound #3, #0, #0, #0
  rts

  .endp
