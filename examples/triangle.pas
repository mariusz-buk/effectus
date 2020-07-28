// Effectus auto-generated Mad Pascal source code listing
program trianglePrg;

uses
  Crt, SySutils, Graph, CIO;

var
  strBuffer : string;
// Effectus example
// ----------------
// Graphics triangle demo
var
  x : byte;
  y : byte;
  r : byte;
  key : byte;

procedure MAINProc;
begin  // 1
  InitGraph(7);
  x := 80;
  y := 10;
  r := 60;
  SetColor(1);
  PutPixel(x, y);
  MoveTo(x, y);
  LineTo(x+r-10, y+r);
  SetColor(2);
  LineTo(x-r+10, y+r);
  SetColor(3);
  LineTo(x, y);
  x := 80;
  y := 14;
  r := 54;
  PutPixel(x, y);
  MoveTo(x, y);
  LineTo(x+r-y, y+r);
  SetColor(2);
  LineTo(x-r+y, y+r);
  SetColor(3);
  LineTo(x, y);
  Writeln('Triangle');
  key := Get(7);
  ReadKey;
end;

begin
  MAINProc;
end.
