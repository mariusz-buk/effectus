// Effectus auto-generated Mad Pascal source code listing
program valbciPrg;

uses
  SySutils, Crt;

// Effectus example
// -------------------------------------
// String to number conversion demo
// using ValB, ValC and ValI functions

procedure MAINProc;
var
  key : char;
  B : byte;
  C : word;
  I : integer;
begin  // 2
  B := StrToInt('120');
  C := StrToInt('65000');
  I := StrToInt('-3400');
  Writeln(B);
  Writeln(C);
  Writeln(I);
  key := ReadKey;
end;  // 4

begin
  MAINProc;
end.
