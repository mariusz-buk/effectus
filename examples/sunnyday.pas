// Effectus auto-generated Mad Pascal source code listing
program sunnydayPrg;

uses
  Crt, SySutils, Graph, CIO;

var
  strBuffer : string;
// Effectus example
// ----------------
// Draw a picture in graphics mode 3
// Picture data
// Color data
var
  picData : array[0..239] of byte = (0, 0, 0, 0, 0, 0, 0, 48, 3, 0, 0, 0, 0, 0, 0, 0, 0, 12, 12, 0, 0, 0, 0, 0, 0, 0, 3, 3, 240, 48, 0, 2, 170, 0, 0, 0, 0, 207, 252, 192, 0, 10, 170, 128, 0, 0, 0, 60, 207, 0, 0, 42, 102, 96, 0, 0, 3, 255, 255, 240, 0, 169, 170, 168, 0, 0, 0, 51, 243, 0, 0, 169, 169, 168, 0, 0, 0, 204, 12, 192, 0, 170, 153, 104, 0, 0, 3, 3, 240, 48, 0, 166, 170, 104, 0, 0, 0, 12, 12, 0, 0, 169, 166, 168, 0, 0, 0, 48, 3, 0, 0, 42, 166, 96, 0, 0, 0, 0, 0, 0, 0, 10, 154, 128, 0, 0, 0, 0, 0, 0, 0, 2, 170, 0, 0, 0, 0, 0, 0, 0, 0, 0, 84, 0, 0, 0, 0, 0, 0, 0, 0, 0, 84, 0, 0, 0, 0, 0, 0, 0, 0, 0, 84, 0, 0, 0, 0, 0, 0, 0, 0, 0, 84, 0, 0, 0, 0, 0, 0, 0, 0, 0, 84, 0, 0, 0, 0, 0, 0, 0, 0, 0, 84, 0, 0, 0, 0, 0, 0, 0, 0, 0, 84, 0, 0, 0, 0, 0, 0, 0, 0, 1, 85, 0, 0, 0, 0, 0, 0, 0, 0, 5, 85, 64, 0, 0, 0, 0, 0, 0, 170, 170, 170, 170, 170, 170, 170, 170, 170, 170);
// Screen memory address
var
  colors : array[0..3] of byte = (148, 224, 192, 236);
  SCREEN : word absolute 88;
var
  ch : byte;

procedure MAINProc;
begin  // 1
  InitGraph(3+16);
  Move(picData, pointer(SCREEN),  240);
  Poke(712, colors[0]);
  Poke(708, colors[1]);
  Poke(709, colors[2]);
  Poke(710, colors[3]);
// Press any key to exit
  ch := Get(7);
  ReadKey;
end;

begin
  MAINProc;
end.
