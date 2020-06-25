// Effectus auto-generated Mad Pascal source code listing
program fillPrg;

uses
  Crt, Graph;

// Effectus example
// -------------------------------------
// Graphics demo
// (using Fill procedure)

procedure MAINProc;
begin  // 6
  InitGraph(7);
  Writeln('FILL TEST');
  Poke(708 + 4,  0*16 +  15);
  SetColor(2);
  PutPixel(20, 3);
  MoveTo(20, 3);
  LineTo(120, 3);
  LineTo(120, 20);
  LineTo(20, 20);
  LineTo(20, 3);
  Poke(765, 3);
  FloodFill(50, 30, 2);
  SetColor(3);
  PutPixel(50, 35);
  MoveTo(50, 35);
  LineTo(146, 35);
  LineTo(146, 70);
  LineTo(50, 70);
  LineTo(50, 35);
  Poke(765, 1);
  FloodFill(65, 50, 3);
  Write(Chr(125));
  Writeln('FILL TEST');
  repeat
  until 0 = 1;
end;  // 4

begin
  MAINProc;
end.
