// Effectus auto-generated Mad Pascal source code listing
program gr9Prg;

uses
  SySutils, Crt, Graph;

// Effectus example
// -------------------------------------
// Graphics mode 9 demo
var
  key : char;
  i : byte;

procedure MAINProc;
begin
  InitGraph(9);
  Poke(708 + 4,  8*16 +  0);
  i := 0;
  for  i:=0 TO 79 do begin
  SetColor(i);
  PutPixel(i, i);
  MoveTo(i, i);
  LineTo(i, 191);
  end;
  key := ReadKey;
end;

begin
  MAINProc;
end.
