// Effectus auto-generated Mad Pascal source code listing
program arrmemPrg;

uses
  SySutils, Crt;

// Effectus example
// -------------------------------------
// Using BYTE ARRAY as direct memory
// assignment
var
  key : char;
  mem : byte;
  arrD : array[0..255] of byte absolute 28000;
  arrH : array[0..255] of byte absolute $0600;
  COL : array[0..255] of byte absolute 708;

procedure MAINProc;
begin  // 1
  Write(Chr(125));
  COL[0] := 154;
  COL[1] := 40;
  COL[2] := 78;
  COL[4] := 228;
  arrD[0] := 10;
  arrD[1] := 30+arrD[0]-12*3*3;
  arrD[2] := 60;
  arrH[0] := 20;
  arrH[1] := 40;
  arrH[2] := 150;
// PrintF("%EarrD array elements:%E")
// PrintB(arrD(0))
// Print(",")
// PrintB(arrD(1))
// Print(",")
// PrintB(arrD(2))
  Write('', eol, 'arrD array elements:', eol, '', arrD[0], ',', arrD[1], ',', arrD[2], '');
  Write('', eol, '', eol, 'arrH array elements:', eol, '');
  Write(arrH[0]);
  Write(',');
  Write(arrH[1]);
  Write(',');
  Writeln(arrH[2]);
  Write('', eol, 'Peeked values:', eol, '');
  mem := Peek(28000);
  Writeln(mem);
  mem := Peek($0600);
  Writeln(mem);
  mem := Peek(28001);
  Writeln(mem);
  mem := Peek($0601);
  Writeln(mem);
  key := ReadKey;
end;  // 4

begin
  MAINProc;
end.
