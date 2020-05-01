// Effectus auto-generated Mad Pascal source code listing
program hi_atariagePrg;

uses
  SySutils, Crt, Graph;


var
  intValue : integer;
  f : file;
  strBuffer : string;
// Effectus example
// -------------------------------------
// Printing on device #6 allowing to
// display text in gr. mode 1 and 2
// 
// Hi, AtariAge by ascrnet
// http://www.atariage.com/forums/topic/112501-effectus-new-atari-cross-compiler-alpha-stage/page__st__25
// 
// Demo Effectus
var
  key : char;

procedure MAINProc;
var
  i : integer;
begin
  assign(f, 'S:'); rewrite(f, 1);
  InitGraph(2);
  GotoXY(5 + 1,  5 + 1);
  strBuffer := Concat( 'hi atariage', #$9b);
  Blockwrite(f, strBuffer[1], Length(strBuffer));
  i := 0;
  for  i:=0 TO 2 do begin
  Writeln('hi,AtariAge........');
  end;
  key := ReadKey;
end;

begin
  MAINProc;
  Close(f);
end.
