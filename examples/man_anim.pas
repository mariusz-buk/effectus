// Effectus auto-generated Mad Pascal source code listing
program man_animPrg;

uses
  Crt, Graph;

// Effectus example
// ----------------
// Player animation demo
// Colors for players
// Player 0 data
var
  p0Color : array[0..3] of byte = (26, 26, 26, 26);
  p1Color : array[0..3] of byte = (36, 36, 36, 36);
// Player 1 data
var
  p0Frame1 : array[0..29] of byte = (0, 0, 12, 8, 28, 28, 28, 24, 24, 16, 25, 61, 127, 127, 94, 220, 220, 156, 156, 160, 188, 28, 44, 52, 116, 96, 96, 0, 0, 0);
  p0Frame2 : array[0..29] of byte = (0, 0, 12, 8, 28, 28, 28, 24, 24, 16, 24, 56, 60, 124, 94, 94, 94, 126, 124, 32, 60, 60, 60, 52, 52, 48, 48, 0, 0, 0);
  p0Frame3 : array[0..29] of byte = (0, 0, 0, 12, 8, 28, 28, 28, 24, 24, 16, 56, 60, 60, 92, 92, 94, 102, 124, 124, 32, 60, 58, 54, 54, 6, 6, 6, 0, 0);
  p0Frame4 : array[0..29] of byte = (0, 0, 12, 8, 28, 28, 28, 24, 24, 16, 24, 56, 60, 124, 94, 94, 94, 126, 124, 32, 60, 60, 60, 52, 52, 48, 48, 0, 0, 0);
var
  p1Frame1 : array[0..29] of byte = (28, 28, 60, 60, 60, 60, 60, 56, 24, 8, 1, 1, 0, 0, 32, 32, 32, 32, 32, 156, 128, 33, 19, 11, 3, 3, 128, 192, 224, 96);
  p1Frame2 : array[0..29] of byte = (28, 28, 60, 60, 60, 60, 60, 56, 24, 8, 0, 0, 0, 0, 32, 32, 34, 34, 96, 60, 0, 0, 0, 8, 8, 14, 14, 62, 56, 24);
  p1Frame3 : array[0..29] of byte = (0, 28, 28, 60, 60, 60, 60, 60, 56, 24, 8, 0, 0, 0, 32, 32, 38, 30, 0, 0, 28, 0, 4, 200, 192, 240, 128, 128, 7, 7);
  p1Frame4 : array[0..29] of byte = (28, 28, 60, 60, 60, 60, 60, 56, 24, 8, 0, 0, 0, 0, 32, 32, 34, 34, 96, 60, 0, 0, 0, 8, 8, 14, 14, 62, 56, 24);
  PMBASE : byte absolute $D407;
var
  SDMCTL : byte absolute $22F;
  GRACTL : byte absolute $D01D;
  RAMTOP : byte absolute $6A;
  PRIOR : byte absolute 623;
  CH : byte absolute $2FC;
  PMGMEM : word;
  PCOLR : array[0..1] of byte absolute $2C0;
  HPOSP : array[0..1] of byte absolute $D000;
  SIZEP : array[0..1] of byte absolute $D008;
  PCOLR33 : array[0..1] of word;
  px0 : byte = 40;
  px1 : byte = 40;
  py0 : byte = 46;
  height : byte = 30;
  frame : byte = 1;
  delay : integer;

procedure NEXTFRAMEProc;
begin  // 1
  if  frame=1  then begin
  Move(p0Frame1, pointer(PMGMEM+512+py0),  height);
  Move(p1Frame1, pointer(PMGMEM+640+py0),  height);
  end
  else if  frame=2  then begin
  Move(p0Frame2, pointer(PMGMEM+512+py0),  height);
  Move(p1Frame2, pointer(PMGMEM+640+py0),  height);
  end
  else if  frame=3  then begin
  Move(p0Frame3, pointer(PMGMEM+512+py0),  height);
  Move(p1Frame3, pointer(PMGMEM+640+py0),  height);
  end
  else if  frame=4  then begin
  Move(p0Frame4, pointer(PMGMEM+512+py0),  height);
  Move(p1Frame4, pointer(PMGMEM+640+py0),  height);
  end;  // if
end;

procedure PLAYGROUNDProc;
var
  i : byte;
begin  // 1
  Poke(708 + 0,  11*16 +  8);
  Poke(708 + 1,  0*16 +  6);
  Poke(708 + 2,  11*16 +  10);
 FOR i:=26 to 42 do begin
  SetColor(i);
  PutPixel(0, i);
  MoveTo(0, i);
  LineTo(159, i);
  end;
  SetColor(1);
  PutPixel(0, 54);
  MoveTo(0, 54);
  LineTo(159, 54);
  PutPixel(0, 64);
  MoveTo(0, 64);
  LineTo(159, 64);
  SetColor(2);
 FOR i:=55 to 63 do begin
  PutPixel(0, i);
  MoveTo(0, i);
  LineTo(159, i);
  end;
end;

procedure MAINProc;
// Set environment
begin  // 6
  InitGraph(7);
  Poke(710, 0);
  Poke(712, 0);
  Poke(752, 1);
  PLAYGROUNDProc;
// Set P/M graphics
  GRACTL := 0;
  PMGMEM := RAMTOP-24;
  PMBASE := PMGMEM;
  PMGMEM := PMGMEM * 256;
// P/M graphics double resolution
  SDMCTL := 46;
// Clear player memory
  FillChar(pointer(PMGMEM+384), 511+128, 0);
// Enable third color
  PRIOR := 33;
// Player normal size
  FillChar(pointer(@SIZEP), 2, 0);
// Turn on P/M graphics
  GRACTL := 3;
  Write('Man running on the street');
  HPOSP[0] := px0;
  HPOSP[1] := px1;
  CH := 255;
 WHILE CH=255 do begin
  NEXTFRAMEProc;
  PCOLR[0] := p0Color[0];
  PCOLR[1] := p1Color[0];
  HPOSP[0] := PX0;
  HPOSP[1] := PX1;
  Inc(px0, 2);
  Inc(px1, 2);
  if  px0  >  210  then begin
  px0 := 40;
  px1 := 40;
  end;  // if
 FOR delay:=0 TO 1500 do begin
  end;
  Inc(frame);
  if  frame  >  4  then begin
  frame := 1;
  end;  // if
  end;
  CH := 255;
// TURN OFF P/M GRAPHICS
  GRACTL := 0;
end;

begin
  MAINProc;
end.
