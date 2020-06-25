// Effectus auto-generated Mad Pascal source code listing
program inpnumPrg;

uses
  Crt, SySutils, CIO;


var
  strBuffer : string;
// Effectus example
// -------------------------------------
// Input numeric values
// using InputB, InputI and InputC

procedure MAINProc;
var
  key : byte;
  n1 : byte;
  n2 : integer;
  n3 : word;
begin  // 2
  Write(Chr(125));
  Writeln('');
  Writeln('Enter BYTE value: ');
  Readln(n1);
  Writeln('Enter INT value: ');
  Readln(n2);
  Writeln('Enter CARD value: ');
  Readln(n3);
// PrintF("%E%EAnd data entered is:%E%E")
  Writeln(n1);
  Writeln(n2);
  Writeln(n3);
  key := Get(7);
  ReadKey;
end;  // 4

begin
  MAINProc;
end.
