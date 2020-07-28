// Effectus auto-generated Mad Pascal source code listing
program scope01Prg;

uses
  Crt, SySutils, CIO;

var
  strBuffer : string;
// Effectus example
// ----------------
// Variable assignment and its scope
var
  key : byte;
  n1 : byte = 14;

procedure CHANGEProc;
begin  // 1
  n1 := 10;
  Writeln(n1);
end;

procedure MAINProc;
begin  // 6
  Writeln(n1);
  CHANGEProc;
  key := Get(7);
  ReadKey;
end;

begin
  MAINProc;
end.
