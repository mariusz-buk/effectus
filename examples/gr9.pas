// Effectus auto-generated Mad Pascal source code listing
program gr9Prg;

uses
  Crt, SySutils, Graph, CIO;

var
  strBuffer : string;
// Effectus example
// ----------------
// Graphics mode 9 demo
var
  key : byte;
  i : byte;

procedure MAINProc;
begin  // 1
  InitGraph(9);
  Poke(708 + 4,  8*16 +  0);
 FOR i:=0 TO 79 do begin
  SetColor(i);
  PutPixel(i, i);
  MoveTo(i, i);
  LineTo(i, 191);
  end;
  key := Get(7);
  ReadKey;
end;

begin
  MAINProc;
end.
