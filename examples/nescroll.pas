// Effectus auto-generated Mad Pascal source code listing
program nescrollPrg;

uses
  Crt;

// Effectus example
// ----------------
// Horizontal scrolling demo
var
  DL : array[0..14] of byte = ($70, $70, $70, $52, $00, $40, $52, $60, $40, $52, $C0, $40, $41, $00, $20);
  HSCROL : byte absolute $D404;
  RANDOM : byte absolute $D20A;
  SDLSTL : word absolute $230;
  SCREENI : word = $4000;

procedure WAITProc(F : byte); assembler;
  asm
  {
  lda F
    .by $18 $65 $14 $C5 $14 $D0 $FC $60 
  };
end;
procedure MAINProc;
var
  HSCROLI : byte absolute $CA;
  A : byte;
  B : byte;
  C : byte;
begin  // 1
  SDLSTL := word(@DL);
  HSCROLI := $F;
  repeat
  if  HSCROLI=$B  then begin
  A := (RANDOM AND 15)+33;
  B := (RANDOM AND 15)+33;
  C := (RANDOM AND 15)+33;
  Poke(SCREENI, A);
  Poke(SCREENI+$60, B);
  Poke(SCREENI+$C0, C);
  Poke(SCREENI+$30, A);
  Poke(SCREENI+$30+$60, B);
  Poke(SCREENI+$30+$C0, C);
  Inc(DL[4]);
  Inc(DL[7]);
  Inc(DL[$A]);
  Inc(SCREENI);
  if  DL[4]=$30  then begin
  DL[4] := 0;
  DL[7] := $60;
  DL[$A] := $C0;
  SCREENI := $4000;
  end;  // if
  HSCROLI := $F;
  end;  // if
  HSCROL := HSCROLI;
  Dec(HSCROLI);
  WAITProc(1);
  until false;
end;

begin
  MAINProc;
end.
