// Effectus auto-generated Mad Pascal source code listing
program pmgdemoPrg;

uses
  SySutils, Crt, Graph;

// Effectus example
// -------------------------------------
// Player/Missile graphics demo

procedure MAINProc;
// REGISTER VARIABLES
// PLAYER 0 BITMAP
var
  key : char;
  PMBASE : byte absolute $D407;
  SDMCTL : byte absolute $22F;
  GRACTL : byte absolute $D01D;
  SIZEP0 : byte absolute $D008;
  PCOLR0 : byte absolute $2C0;
  HPOSP0 : byte absolute $D000;
  RAMTOP : byte absolute $6A;
// P/M memory storage
var
  P0 : array[0..14] of byte = (0, 0, 28, 28, 8, 28, 58, 89, 24, 40, 76, 68, 68, 0, 0);
  PGMMEM : word;
begin  // 1
// TURN OFF P/M GRAPHICS
  GRACTL := 0;
// GRAPHICS MODE 0
  InitGraph(0);
// SET SAFE PLACE FOR OUR PLAYER
  PGMMEM := RAMTOP-16;
// BASE ADDRESS (MSB)
  PMBASE := PGMMEM;
// STARTING ADDRESS OF P/M GRAPHICS
  PGMMEM := PGMMEM * 256;
// P/M DOUBLE RESOLUTION
  SDMCTL := 46;
// PLAYER 0 NORMAL SIZE
  SIZEP0 := 0;
// CLEAR SPACE FOR PLAYER 0
  FillChar(pointer(PGMMEM+512), 128, 0);
// COPY IMAGE DATA TO P/M MEMORY
  Move(P0, pointer(PGMMEM+512+60),  14);
// TURN ON P/M GRAPHICS
  GRACTL := 3;
  PCOLR0 := 50;
  HPOSP0 := 120;
  key := ReadKey;
// TURN OFF P/M GRAPHICS
  GRACTL := 0;
end;  // 4

begin
  MAINProc;
end.
