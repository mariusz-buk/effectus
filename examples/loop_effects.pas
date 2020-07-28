// Effectus auto-generated Mad Pascal source code listing
program loop_effectsPrg;

uses
  Crt, SySutils, Graph, CIO;

var
  strBuffer : string;
// Effectus example
// ----------------
// Loop effects by ascrnet
// http://www.atariage.com/forums/topic/112501-effectus-new-atari-cross-compiler-alpha-stage/page__st__25
// Demo Effectus

procedure MAINProc;
var
  i : byte;
begin  // 2
  InitGraph(2);
  repeat
  GotoXY(7 + 1,  5 + 1);
  i := Random(255);
  strBuffer := IntToStr( i);
  BPut(6, @strBuffer[1], Length(strBuffer));
  Poke(710, i);
  until false;
end;

begin
  MAINProc;
end.
