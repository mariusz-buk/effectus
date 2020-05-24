// Effectus auto-generated Mad Pascal source code listing
program putdPrg;

uses
  SySutils, Crt, Graph;


var
  f : file;
  strBuffer : string;
// Effectus example
// - - - - - - - - - - - - - - - - - -
// PutD and PutDE demo
// Print character codes to the screen

procedure PUTD_TESTProc;
var
  CH : byte absolute 764;
begin  // 2
  assign(f, 'S:'); rewrite(f, 1);
  InitGraph(1+16);
  strBuffer := Concat(Concat(Chr( 65), ''), '');;
  Blockwrite(f, strBuffer[1], Length(strBuffer));
  strBuffer := Concat(Concat(Chr( 66), ''), '');;
  Blockwrite(f, strBuffer[1], Length(strBuffer));
  strBuffer := Concat(Concat(Chr( 67), ''), '');;
  Blockwrite(f, strBuffer[1], Length(strBuffer));
  strBuffer := Concat(#$9b, '');
  Blockwrite(f, strBuffer[1], Length(strBuffer));
  strBuffer := Concat(Concat(Chr( 68), ''), '');;
  Blockwrite(f, strBuffer[1], Length(strBuffer));
  strBuffer := Concat(Concat(Chr( 69), ''), '');;
  Blockwrite(f, strBuffer[1], Length(strBuffer));
  strBuffer := Concat(Concat(Chr( 70), ''), '');;
  Blockwrite(f, strBuffer[1], Length(strBuffer));
// PRESS ANY KEY TO EXIT
  CH := 255;
  repeat
  until  CH<>255;
end;  // 4

begin
  PUTD_TESTProc;
  Close(f);
end.
