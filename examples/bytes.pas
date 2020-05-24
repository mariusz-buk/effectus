// Effectus auto-generated Mad Pascal source code listing
program bytesPrg;

uses
  SySutils, Crt;

// Effectus example
// -------------------------------------
// BYTE ARRAY demo
var
  key : char;
  i : byte;
  num : array[0..4] of byte;

procedure MAINProc;
begin  // 1
  Write(Chr(125));
  Writeln('Effectus example:');
  Writeln('ARRAYs demonstration');
  Writeln('');
  num[0] := 35;
  num[1] := 10;
  num[2] := 155;
  num[3] := 246;
  num[4] := 170;
  for  i:=0 TO 4 do begin
  Write('Element ');
  Write(i);
  Write('=');
  Writeln(num[i]);
  end;  // for
  key := ReadKey;
end;  // 4

begin
  MAINProc;
end.
