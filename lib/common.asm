;
; Effectus / MADS runtime library
;
; Source code assembled with Mads 2.0.8 build 31 (8 Jan 19)

 icl 'equates.asm'

 device #0

 .var b_param1, b_param2, b_param3, b_param4, b_param5 .byte
 .var w_param1, w_param2, w_param3, w_param4, w_param5 .word
 .var loop_var .byte

 .array hex_num [4] .byte = $ff
 .end

 .var a_reg, x_reg, y_reg, a3_par, a4_par, a5_par, a6_par, a7_par, a8_par .byte
 .var a9_par, aA_par, aB_par, aC_par, aD_par, aE_par, aF_par .byte
 ;.var var19750412_eff_ .word

; POKE / DPOKE procedures
;
; Original source:
; Mad-Assembler (MADS)
; Hyperlink: http://mads.atari8.info/
;
/*
  POKE:
  POKE address,value

  Examples:
            poke 712,12
*/

Poke .macro

 lda :2
 sta :1

.endm

/*
  PokeC:
  POKE address,<value
  POKE address+1,>value

  Examples:
            PokeC $a000,1024
*/

PokeC .macro

 lda <:2
 sta :1

 lda >:2
 sta :1+1

 .endm

Peek .macro

 lda :1
 sta $A0
 lda #$00
 sta $A1
 
 .endm

PeekC .macro

 lda :1
 sta $A0
 lda :1+1
 sta $A1

 .endm

; MACRO:  @CH
;
; Loads IOCB number (parameter 1) into X register.
;
; If parameter value is 0 to 7, immediate channel number
;   is assumed.
;
; If parameter value is > 7 then a memory location
;   is assumed to contain the channel number.
;
; Original code by Pecus (Atari.Area forum) 

     .MACRO @CH
     .IF :1>7
       LDA %1
       ASL @
       ASL @
       ASL @
       ASL @
       TAX
       .ELSE
       LDX #:1*16
       .ENDIF
     .ENDM

 ; MACRO:  @CV
 ;
 ; Loads Constant or Value into accumultor (A-register)
 ;
 ; If value of parameter 1 is 0-255, @CV
 ; assumes it's an (immediate) constant.
 ;
 ; Otherwise the value is assumed to
 ; be a memory location (non-zero page).
 ;
 ; Original code by Pecus (Atari.Area forum)
 ;
     .MACRO @CV
     
     .IF :1<256
       LDA %1
     .ELSE
       LDA :1
     .ENDIF
       
     .ENDM

 ; MACRO:  @FL
 ;
 ; @FL is used to establish a filespec (file name)
 ;
 ; If a literal string is passed, @FL will
 ; generate the string in line, jump
 ; around it, and place its address
 ; in the IOCB pointed to by the X-register.
 ;
 ; If a non-zero page label is passed
 ; the MACRO assumes it to be the label
 ; of a valid filespec and uses it instead.
 ;
 ; Original code by Pecus (Atari.Area forum)
 ;
     .MACRO @FL
     
    .IF :1<256
       JMP *+:1+4
@F  .BYTE :1,0
       LDA #<@F
       STA ICBLL,X
       LDA #>@F
       STA ICBLH,X
       .ELSE
       LDA #<:1
       STA ICBLL,X
       LDA #>:1
       STA ICBLH,X
       .ENDIF
       
     .ENDM

 ; MACRO:  XIO
 ; FORM:  XIO ch,cmd[,aux1,aux2][,filespec]
 ;
 ; Original code by Pecus (Atari.Area forum)
 ;
 ; Action! procedure call:
 ; PROC XIO(BYTE channel, 0, command, aux1, aux2, fileString)
 ;
 ; ch is given as in the @CH macro
 ; cmd, aux1, aux2 are given as in the @CV macro
 ; filespec is given as in the @FL macro
 ;
 ; performs familiar XIO operations with/for OS/A+
 ;
 ; If aux1 is given, aux2 must also be given
 ; If aux1 and aux2 are omitted, they are set to zero
 ; If the filespec is omitted, "S:" is assumed
 ;
     .MACRO XIO
     
     IFT :0<2 .OR :0>5
       ERT "XIO: wrong number of arguments"
       ELS
        @CH  :1
        @CV  :2
       STA ICCOM,X ; COMMAND
       IFT %0>=4
         @CV  :3
         STA ICAX1,X
         @CV  :4
         STA ICAX2,X
         ELS
         LDA #0
         STA ICAX1,X
         STA ICAX2,X
         EIF
       IFT :0=2 .OR :0=4
          @FL  "S:"
         ELS
          @FL  :0
         EIF
       JSR CIOV
       EIF
       
     .ENDM

;-------------------------------------
;
; MoveBlock dest_addr, source_addr, length
;
; Original code by Pecus and Pirx (Atari.Area forum)
; Modified by me to accomodate the Action! procedure paramater order
;
; Action! command call:
; PROC MoveBlock(BYTE POINTER target, source, CARD size)
;
; Moves 'length' bytes long block of bytes beginning from 'source_addr' to 
; 'dest_addr'
; The macro tries to create the optimal code for given data CAUTION! Blocks
; shouldn't overlap! Macro is self-modyfying!
;
         .MACRO MoveBlock

         .IF %3<$0100
           LDX #%3-1
@MC        LDA %2,X
           STA %1,X
           DEX
           .IF %3>$7F
             CPX #$FF
             BNE @MC
             .ELSE
             BPL @MC
             .ENDIF
           .ENDIF
         .IF %3&$FF<>$00
           .IF %3>$0100
             LDA #$00
             STA ?LI
             STA ?LI+1
?MO          LDA %2
?MO1         STA %1
             INC ?MO+1
             BNE ?MO2
             INC ?MO+2
?MO2         INC ?MO1+1
             BNE ?MO3
             INC ?MO1+2
?MO3         INC ?LI
             BNE ?MO4
             INC ?LI+1
?MO4         LDA ?LI+1
             CMP # >%3
             BNE ?MO
             LDA ?LI
             CMP # <%3
             BNE ?MO
             BEQ ?MO5
?LI           .WORD 0
?MO5
             .ENDIF
           .ELSE
           LDX # >%3
           LDY #$00
?MO        LDA %2,Y
?MO1       STA %1,Y
           INY
           BNE ?MO
           INC ?MO+2
           INC ?MO1+2
           DEX
           BNE ?MO
           .ENDIF
           
         .ENDM

ShowHex .proc ( .byte a) .reg
   
 ldx #0   
 cmp #16
 bcs jump3  ; Greater or equal to 16
 cmp #10
 bcs jump1  ; Greater or equal to 10
 
; No. Just print out number from 0 to 9
 ldx #1  
 adc #48
 sta hex_num,x
 jmp jump2 

; Greater or equal to 16
jump3
 ldx #1  
 lda #70
 sta hex_num,x
 jmp jump2 
 
; Convert to hexadecimal notation
jump1          
 sta $A2
 lsr @
 lsr @
 lsr @
 lsr @
 tay
 lda nmbrs,y
 sta hex_num,x
 inx
 lda $A2
 and #$F
 tay
 lda nmbrs,y
 sta hex_num,x
 inx
jump2
 
 rts

nmbrs dta d'0123456789abcdef'

 .endp

ShowHex2 .proc ( .byte a) .reg

HEX16    PHA         ;  LO-Byte retten
         TXA         ;  HI-Byte zuerst ausgeben
         JSR HEX8
         PLA         ;  dann LO-Byte

HEX8     PHA         ;  Wert retten
         LSR         ;  erst HI-Nibble
         LSR
         LSR
         LSR
         JSR HEX     ;  ausgeben
         PLA         ;  dann
         AND #$F     ;  LO-Nibble

HEX      CMP #10     ;  Zahl>=10
         BCC ff      ;  Nein\^_\^_\^_
         CLC         ;  +7 fuer "A"-"F"
         ADC #7
ff       ADC #$30    ;  +ASCII "0"

  ;ldx #0
  sta hex_num,x
  
  sta $c0
 
 rts
 
 .endp
 
SCompare .macro

 ldx #0
for_loop_equal
 lda :1,x
 ldy :2,x
 inx
 sty $A0
 cmp $A0
 bne exit_equal
 cpx #5
 jcc for_loop_equal
 mva #0 $A0
; jsr printf
; dta c'The strings are equal',$9b,0
 jmp exit_rtn
  
exit_equal
 ldx #0
 lda :1,x
 ldy :2,x
 sty $A0
 
 cmp $A0
 bcs go_on
 mva #255 $A0 
; jsr printf
; dta c'Str1 less than Str2',$9b,0
 jmp exit_rtn
 
go_on bne go_on2
go_on2
 mva #1 $A0
; jsr printf
; dta c'Str1 greater than Str2',$9b,0
 
exit_rtn

 .endm
