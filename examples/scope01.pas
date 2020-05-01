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
begin
  n1 := 10;
  Writeln(n1);
end;

procedure MAINProc;
begin
  Writeln(n1);
  CHANGEProc;
  key := ReadKey;
end;

begin
  MAINProc;
end.
