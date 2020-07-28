// Effectus auto-generated Mad Pascal source code listing
program chrdefPrg;

uses
  Crt, SySutils, Graph, CIO;

var
  strBuffer : string;
// Effectus example
// ----------------
// Character set redefinition demo
// NEW CHARACTER DATA
var
  CH : byte absolute $2FC;
  RAMTOP : byte absolute $6A;
  CHBAS : byte absolute $2F4;
  TOPMEM : word;
  key : byte;
var
  CHECK : array[0..7] of byte = (0, 1, 3, 6, 140, 216, 112, 32);
  SMILEY : array[0..7] of byte = (60, 66, 165, 129, 165, 153, 66, 60);

procedure MAINProc;
// TEXT MODE 2
begin  // 6
  InitGraph(2);
// RESERVE MEMORY FOR NEW CHARACTER SET
  TOPMEM := RAMTOP-8;
  CHBAS := TOPMEM;
  TOPMEM := TOPMEM * 256;
// CLEAR RESERVED MEMORY
// SETBLOCK(TOPMEM,1023,0)
// VECTOR TO PAGE ADDRESS OF NEW SET
  CHBAS := TOPMEM div 256;
// COPY ATARI CHARACTERS
  Move(pointer(57344), pointer(TOPMEM),  1023);
// REDEFINE SOME CHARACTERS
  Move(CHECK, pointer(TOPMEM+28*8),  8);
  Move(SMILEY, pointer(TOPMEM+30*8),  8);
// DEMO
  GotoXY(2 + 1,  2 + 1);
  strBuffer := Concat('>', #$9b);
  BPut(6, @strBuffer[1], Length(strBuffer));
  strBuffer := Concat('""', #$9b);
  BPut(6, @strBuffer[1], Length(strBuffer));
  strBuffer :=  'CHECKED <';
  BPut(6, @strBuffer[1], Length(strBuffer));
  Writeln('PRESS <SPACE> KEY TO EXIT!');
// CHECK FOR SPACE KEY PRESSED
  CH := 255;
  repeat
 UNTIL CH=33;
  CH := 255;
  key := Get(7);
  ReadKey;
end;

begin
  MAINProc;
end.
