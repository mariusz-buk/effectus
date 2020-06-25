// Effectus auto-generated Mad Pascal source code listing
program arrmemcPrg;

uses
  Crt, SySutils, CIO;


var
  strBuffer : string;
// Effectus example
// -------------------------------------
// Using CARD ARRAY as direct memory
// assignment

procedure MAINProc;
var
  key : byte;
  i : byte;
  mem : word;
  arr : array[0..255] of word absolute $8000;
begin  // 2
  Write(Chr(125));
  arr[0] := 14;
  arr[1] := 230;
  arr[2] := 5100;
  arr[3] := 63000;
  Write('', eol, 'Array values:', eol, '');
  for  i:=0 to 3 do begin
  Writeln(arr[i]);
  end;  // for
  Write('', eol, 'Array values in descending order:', eol, '');
  mem := DPeek($8006);
  Writeln(mem);
  mem := DPeek($8004);
  Writeln(mem);
  mem := DPeek($8002);
  Writeln(mem);
  mem := DPeek($8000);
  Writeln(mem);
  key := Get(7);
  ReadKey;
end;  // 4

begin
  MAINProc;
end.
