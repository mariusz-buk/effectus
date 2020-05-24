// Effectus auto-generated Mad Pascal source code listing
program scope01Prg;

uses
  SySutils, Crt;

// Effectus example
// -------------------------------------
// Variable assignment and its scope
var
  key : char;
  n1 : byte = 14;

procedure CHANGEProc;
begin  // 1
  n1 := 10;
  Writeln(n1);
end;  // 4

procedure MAINProc;
begin  // 6
  Writeln(n1);
  CHANGEProc;
  key := ReadKey;
end;  // 4

begin
  MAINProc;
end.
