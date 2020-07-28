// Effectus auto-generated Mad Pascal source code listing
program vscrollPrg;

uses
  Crt, Graph;

// Effectus example
// ----------------
// Vertical scrolling demo
var
  TEXT : string = 'NNNeffectus@rulezNNN';
  DL : array[0..9] of byte = ($70, $70, $70, $70, $67, $1, $20, $41, $0, $0);
  CH : byte absolute $2FC;
  VSCROL : byte absolute $D405;
  SDLSTL : word absolute $230;

procedure WAITProc(F : byte); assembler;
  asm
  {
  lda F
    .by $18 $65 $14 $C5 $14 $D0 $FC $60 
  };
end;
procedure MAINProc;
var
  I : byte absolute $E0;
begin  // 1
  I := $F;
  SDLSTL := word(@DL);
 WHILE CH=$FF do begin
 WHILE I > 0 do begin
  Dec(I);
  VSCROL := I;
  WAITProc(3);
  end;
  WAITProc(50);
 WHILE I<$F do begin
  Inc(I);
  VSCROL := I;
  WAITProc(2);
  end;
  end;
  InitGraph(0);
end;

begin
  MAINProc;
end.
