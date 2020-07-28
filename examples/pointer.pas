// Effectus auto-generated Mad Pascal source code listing
program pointerPrg;

uses
  Crt, SySutils, CIO;

var
  strBuffer : string;
// Effectus example
// ----------------
// Using pointer
var
  key : byte;
  ptr : ^word;
  i : integer;

procedure MAINProc;
begin  // 1
  Write(Chr(125));
  Writeln('Effectus example:');
  Writeln('POINT=ER variable demonstration');
  Writeln('');
  i := 70;
  Writeln('Current value of variable i: ');
  Writeln(I);
  ptr := @I;
  Writeln('Memory address of variable i: ');
  Writeln(word(ptr));
  Writeln('New value of variable ptr and i: ');
  ptr^ := 251;
  Write(ptr^);
  Write('=');
  Writeln(i);
  key := Get(7);
  ReadKey;
end;

begin
  MAINProc;
end.
