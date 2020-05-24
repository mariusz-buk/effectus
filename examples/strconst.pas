// Effectus auto-generated Mad Pascal source code listing
program strconstPrg;

uses
  SySutils, Crt;

// Effectus example
// -------------------------------------
// String manipulation demo
// 
// SBYTE ARRAY as temporary substitution
// for string assignment (not original
// Action! command)

procedure MAINProc;
var
  key : char;
  A : string = 'THIS IS A STRING CONSTANT';
  B : string = 'N1';
begin  // 2
  Writeln(A);
  B := A;
  Writeln(B);
  key := ReadKey;
end;  // 4

begin
  MAINProc;
end.
