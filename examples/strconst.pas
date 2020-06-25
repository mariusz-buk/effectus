// Effectus auto-generated Mad Pascal source code listing
program strconstPrg;

uses
  Crt, SySutils, CIO;


var
  strBuffer : string;
// Effectus example
// -------------------------------------
// String manipulation demo
// 
// SBYTE ARRAY as temporary substitution
// for string assignment (not original
// Action! command)

procedure MAINProc;
var
  key : byte;
  A : string = 'THIS IS A STRING CONSTANT';
  B : string = 'N1';
begin  // 2
  Writeln(A);
  B := A;
  Writeln(B);
  key := Get(7);
  ReadKey;
end;  // 4

begin
  MAINProc;
end.
