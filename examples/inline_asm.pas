// Effectus auto-generated Mad Pascal source code listing
program inline_asmPrg;

uses
  Crt, SySutils, Graph, CIO;


var
  strBuffer : string;
// Effectus example
// -------------------------------------
// Inline machine language demo

procedure MAINProc;
var
  key : byte;
begin  // 2
  Write(Chr(125));
  Writeln('Effectus example:');
  Writeln('Using inline machine language');
  Writeln('');
  asm
  {
    .by $A9 $21 $8D $C6 $02 $00 $60 
  };
  Writeln('Press any key to change color!(1)');
  key := Get(7);
  ReadKey;
  asm
  {
    .by $A9 $90 $3E $C6 $02 $0 $60 
  };
  Writeln('Press any key to change color!(2)');
  key := Get(7);
  ReadKey;
  asm
  {
    .by $A9 $60 $8D $C6 $02 $0 $60 
  };
  Writeln('Press any key to change color!(3)');
  key := Get(7);
  ReadKey;
  asm
  {
    .by $A9 $76 $8D $C6 $02 $0 $60 
  };
  Writeln('Press any key to change color!(4)');
  key := Get(7);
  ReadKey;
  asm
  {
    .by $A9 $13 $8D $C6 $02 $0 $60 
  };
  key := Get(7);
  ReadKey;
end;  // 4

begin
  MAINProc;
end.
