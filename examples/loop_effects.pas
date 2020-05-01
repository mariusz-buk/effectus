// Effectus auto-generated Mad Pascal source code listing
program loop_effectsPrg;

uses
  SySutils, Crt, Graph;


var
  f : file;
  strBuffer : string;
// Effectus example
// -------------------------------------
// Loop effects by ascrnet
// http://www.atariage.com/forums/topic/112501-effectus-new-atari-cross-compiler-alpha-stage/page__st__25
// Demo Effectus

procedure MAINProc;
var
  i : byte;
begin
  assign(f, 'S:'); rewrite(f, 1);
  InitGraph(2);
  repeat
  GotoXY(7 + 1,  5 + 1);
  i := Random(255);
  strBuffer := IntToStr( i);
  Blockwrite(f, strBuffer[1], Length(strBuffer));
  Poke(710, i);
  until 0 = 1;
end;

begin
  MAINProc;
  Close(f);
end.
