// Effectus auto-generated Mad Pascal source code listing
program locate_gr0Prg;

uses
  Crt, SySutils, Graph, CIO;


var
  strBuffer : string;
// Effectus example
// -------------------------------------
// Using Locate in text mode 0

procedure MAINProc;
var
  key : byte;
  loc : byte;
begin  // 2
  InitGraph(0);
  GotoXY(3 + 1,  3 + 1);
  Write('HELLO,ATARIAN');
  GotoXY(3 + 1,  5 + 1);
  Write('AT RI');
  Write('', eol, '', eol, 'PRESS ANY KEY TO CONTINUE!');
  KEY := Get(7);
  ReadKey;
  LOC := GetPixel(10 + 1,  3);
  Write(LOC);
  GotoXY(5 + 1,  5 + 1);
  Write(Chr(LOC));
  key := Get(7);
  ReadKey;
end;  // 4

begin
  MAINProc;
end.
