// Effectus auto-generated Mad Pascal source code listing
program atasciiPrg;

uses
  SySutils, Crt;

// Effectus example
// -------------------------------------
// Printing ATASCII characters

procedure MAINProc;
var
  key : char;
  n : byte;
  a : byte;
  b : byte;
  arr : array[0..5] of byte;
begin
  Write(Chr(125));
  Writeln('ASCII manipulation demonstration');
  Writeln('');
  Writeln('Character Put test');
  Write('A');  // test put
  Write('T');  // test put
  Write('a');  // test put
  Write(Chr(82));
  Write(Chr($49));
  Writeln('');
  Writeln('Some math');
  a := 65;
  b := 66;
  Write('a=65,b=66,a+b=');
  n := a+b;
  Writeln(n);
  Writeln('');
  Writeln('Array test');
  arr[1] := 65;
  Write(arr[1]);
  arr[2] := 50;
  arr[3] := 67;
  arr[4] := 52;
  n := 2;
  for  n:=2 TO 4 do begin
  Write(Chr(44));
  Write(ARR[N]);
  end;
  key := ReadKey;
end;

begin
  MAINProc;
end.
