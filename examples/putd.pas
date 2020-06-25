// Effectus auto-generated Mad Pascal source code listing
program putdPrg;

uses
  Crt, SySutils, Graph, CIO;


var
  strBuffer : string;
// Effectus example
// - - - - - - - - - - - - - - - - - -
// PutD and PutDE demo
// Print character codes to the screen

procedure PUTD_TESTProc;
var
  CH : byte absolute 764;
begin  // 2
  InitGraph(1+16);
  Put(6,  65);
  Put(6,  66);
  Put(6,  67);
  Put(6, $9b);
  Put(6,  68);
  Put(6,  69);
  Put(6,  70);
// PRESS ANY KEY TO EXIT
  CH := 255;
  repeat
  until  CH<>255;
end;  // 4

begin
  PUTD_TESTProc;
end.
