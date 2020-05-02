;
; Effectus / MADS graphics runtime library
;
; Source code assembled with Mads 2.0.8 build 31 (8 Jan 19)

  icl 'equates.asm'

  .extrn device.devscr .proc

  .reloc

  .public Graphics color Plot DrawTo Fill Position Locate

  .var temp_x .word
  .var temp_y .byte

; Position - Cursor position routine
; 
; Original source:
; Mad-Assembler (MADS)
; Hyperlink: http://mads.atari8.info/
;
; Parameters:
; .word ax: 16-bit value representing x position (applies also to graphics mode 8)
; .byte y:  8-bit value representing y position
;------------------------;
Position  .proc (.word ax .byte y) .reg

  sty ROWCRS
  stx COLCRS
  and #1
  sta COLCRS+1
  rts

  .endp

; Locate - Locate value beneath cursor at specific location
; 
; Parameters:
; .word ax: 16-bit value representing x position (applies also to graphics mode 8)
; .byte y (8-bit value): y position
;
; Result:
; STORE1 (8-bit value): Value beneath cursor at specific location
;------------------------;
Locate  .proc (.word ax .byte y) .reg

  jsr Position
  mwa COLCRS temp_x
  mva ROWCRS temp_y
  ldx device.devscr
  mva	#7 ICHID+2,x  ; CIO command
  mwa	#0 ICHID+8,x	; length
  jsr	CIOV
  sta $A0

  Position temp_x, temp_y
  ldx device.devscr
  lda $A0
  tay
  lda ICPTL+1,x
  pha
  lda ICPTL,x
  pha
  tya
  rts

  .endp

; Graphics - Set graphics mode routine
; 
; Original source:
; Mad-Assembler (MADS)
; Hyperlink: http://mads.atari8.info/
;
; Parameters:
; .byte y (8-bit value): graphics mode of choice
;
;------------------------;
; Ustaw tryb ekranu      ;
;------------------------;
;We:.X-numer kanalu      ;
;      (normalnie 0)     ;
;   .Y-numer trybu (O.S.);
;   .A-Ustawiony bit nr :;
;     5-Nie kasowanie    ;
;       pamieci ekranu   ;
;     4-Obecnosc okna    ;
;       tekstowego       ;
;     2-Odczyt z ekranu  ;
;------------------------;
;Wy:SCRCHN-numer kanalu  ;
;  .Y-numer bledu (1-OK) ;
;   f(N)=1 wystapil blad ;
;------------------------;
Graphics  .proc (.byte y) .reg

  sty byte2
  #if .byte byte2 > #15 
    mva #%00100000 byte1
;    jmp skip
  #else
    mva #%00010000 byte1 
  #end
;skip
  mvx #$60 scrchn
  lda #close0		; zamknij kanal
  sta ICCOM,x
  jsr ciov
  lda byte1		; =opcje
  ora #8		; +zapis na ekranie
  sta ICAX1,x
  lda byte2		;=nr.trybu
  sta ICAX2,x
  lda #open0    	; otworz kanal dla S:
  sta ICCOM,x
  lda <scrnam
  sta ICBAL,x
  lda >scrnam
  sta ICBAL+1,x
  jmp ciov

scrnam  dta c'S:',b(eol)
scrchn  dta b(0)

  .endp

; color - Global variable representing color of hue
; 
; Original source:
; Mad-Assembler (MADS)
; Hyperlink: http://mads.atari8.info/
; 
; Parameters:
; .byte x (8-bit value): Color of current hue
;
; Result:
; color.colscr (8-bit value): Color of current hue
;
;------------------------;
;Ustaw kolor dla operacji;
;graf. (PLOT,DRAW,itd.)  ;
;------------------------;
;We:.X  -numer koloru    ;
;------------------------;
color .proc (.byte x) .reg

  stx colscr
  rts

colscr  brk

  .endp

; Plot - Plot a pixel at specific location
; 
; Original source:
; Mad-Assembler (MADS)
; Hyperlink: http://mads.atari8.info/
; 
; Parameters:
; .word ax (16-bit value): x position of the pixel to be drawn
; .byte y (8-bit value): y position of the pixel to be drawn
;
;------------------------;
;Rysuj punkt             ;
;------------------------;
;We:.Y  -wspolrzedna y   ;
;   .X.A-wspolrzedna x   ;
;------------------------;
;Wy:.Y-numer bledu (1-OK);
;   f(N)=1-wystapil blad ;
;------------------------;
Plot  .proc (.word ax .byte y) .reg

  jsr Position
  ldx #$60
  lda #plotc
  sta ICCOM,x
  lda color.colscr
  sta atachr
  jmp ciov

  .endp

; DrawTo - Draw a line from one to another point
; 
; Original source:
; Mad-Assembler (MADS)
; Hyperlink: http://mads.atari8.info/
; 
; Parameters:
; .word ax (16-bit value): x position of the line to be drawn
; .byte y (8-bit value): y position of the line to be drawn
;
;------------------------;
;Narysuj linie o podanych;
;wsp. konca              ;
;------------------------;
;We:.Y  -wspolrzedna y   ;
;   .X.A-wspolrzedna x   ;
;------------------------;
;Wy:.Y-numer bledu (1-OK);
;   f(N)=1-wystapil blad ;
;------------------------;
DrawTo  .proc (.word ax .byte y) .reg

  jsr Position
  ldx #$60
  lda #drawc
  sta ICCOM,x
  lda color.colscr
  sta atachr
  jmp ciov

  .endp

; Fill - Fill an area
; 
; Original source:
; Mad-Assembler (MADS)
; Hyperlink: http://mads.atari8.info/
; 
; Parameters:
; .word ax (16-bit value): x position of location in the chosen area
; .byte y (8-bit value): y position of location in the chosen area
;------------------------;
Fill  .proc (.word ax .byte y) .reg

  jsr Position
  lda color.colscr ; get COLOR 
  sta ATACHR       ; keep CIO happy
  ldx #$60         ; the screen again
  lda #$12         ; for FILL
  sta ICCOM,x      ; command byte
  lda #$C          ; as in XIO
  sta ICAX1,x      ; auxiliary 1
  lda #0           ; clear
  sta ICAX2,x      ; auxiliary 2
  jsr CIOV         ; FILL the area

  .endp
