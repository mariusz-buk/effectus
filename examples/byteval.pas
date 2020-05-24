// Effectus auto-generated Mad Pascal source code listing
program bytevalPrg;

uses
  SySutils, Crt;

// Effectus example
// -------------------------------------
// Variable manipulation demo

procedure MAINProc;
var
  N1 : byte absolute 764;
  N2 : byte;
  N3 : byte = 12;
begin  // 2
  Write(Chr(125));
  N2 := 14;
  Write('Value of 764 is ');
  Writeln(N1);
  Write('Value of N2 is ');
  Writeln(N2);
  Write('Predeclared value of N3 is ');
  Writeln(N3);
  N1 := 255;
  N1 := 255;
 WHILE N1=255 do begin
  end;  // while
  N1 := 255;
end;  // 4

begin
  MAINProc;
end.
