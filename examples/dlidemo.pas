// Effectus auto-generated Mad Pascal source code listing
program dlidemoPrg;

uses
  Crt, Graph;

// Effectus example
// - - - - - - - - - - - - - - - - - -
// Display list interrupt (DLI) demo
var
  DL : array[0..21] of byte = ($70, $70, $70, $42, $00, $40, $2, $2, $2, $2, $F0, $2, $2, $2, $2, $2, $70, $70, $70, $41, $00, $20);
// 48        PHA
// A9 DE     LDA #$DE
// 8D 0A D4  STA $D40A
// 8D 18 D0  STA $D018
// 68        PLA
// 40        RTI
var
  DLI : array[0..10] of byte = ($48, $A9, $DE, $8D, $0A, $D4, $8D, $18, $D0, $68, $40);
  CH : byte absolute $2FC;
  NMIEN : byte absolute $D40E;
  VDSLST : word absolute $200;
  SDLSTL : word absolute $230;

procedure MAINProc;
begin  // 1
  SDLSTL := word(@DL);
  VDSLST := word(@DLI);
  NMIEN := $C0;
 WHILE CH=$FF do begin
  end;  // while
  InitGraph(0);
end;  // 4

begin
  MAINProc;
end.
