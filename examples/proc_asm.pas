// Effectus auto-generated Mad Pascal source code listing
program proc_asmPrg;

uses
  Crt, SySutils, Graph, CIO;


var
  strBuffer : string;
// Effectus example
// -------------------------------------
// Using local PROCedures using machine
// language
var
  KEY : byte;

procedure PokeTestProc(d : byte); assembler;
  asm
  {
  lda d
    .by $8D $C6 $02 $60 
  };
end;  // 2
procedure TESTProc(CURSOR : byte; BACK : byte; BORDER : byte; X : byte; Y : byte; UPDOWN : byte); assembler;
  asm
  {
  lda CURSOR
  ldx BACK
  ldy BORDER
  mva X $a3
  mva Y $a4
  mva UPDOWN $a5
    .by $8E $C6 $02 $8C $C8 $02 $8D $F0 $02 $A5 $A5 $8D $F3 $02 $A5 $A3 $8D $55 $00 $A5 $A4 $8D $54 $00 $60 
  };
end;  // 2
procedure MAINProc;
var
  n1 : word;
  n2 : word;
  n3 : word;
begin  // 1
  Write(Chr(125));
  Write('', eol, 'Press any key to see some effect!', eol, '');
  KEY := Get(7);
  ReadKey;
  TESTProc(1, 20, 30, 8, 8, 4);
  Write('LOOK,I AM UPSIDE DOWN!', eol, '');
  Writeln('Press any key again!');
  KEY := Get(7);
  ReadKey;
  POKETESTProc(144);
  KEY := Get(7);
  ReadKey;
end;  // 4

begin
  MAINProc;
end.
