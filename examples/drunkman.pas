// Effectus auto-generated Mad Pascal source code listing
program drunkmanPrg;

uses
  Crt, SySutils, Graph, Joystick;

// Effectus example
// ----------------
// Player/missile graphics demo
// COLLISION DETECTION FLAG
// P0PL ($D00C) - PLAYER 0 TO PLAYER COLLISION STATUS
// P1PL ($D00D) - PLAYER 1 TO PLAYER COLLISION STATUS
// PLAYER POSITION STORAGE
// MISSILE DISTANCE RANGE POSITION
// PLAYER DATA
var
  CH : byte absolute $2FC;
  RAMTOP : byte absolute $6A;
  GPRIOR : byte absolute $26F;
  PMBASE : byte absolute $D407;
  SDMCTL : byte absolute $22F;
  GRACTL : byte absolute $D01D;
  HITCLR : byte absolute $D01E;
  COLLISION : byte;
  P0 : byte;
  P1 : byte;
  P3 : byte;
  M3R : byte;
  PGMMEM : word;
  PCOLR : array[0..3] of byte absolute $2C0;
  HPOSP : array[0..3] of byte absolute $D000;
  HPOSM : array[0..3] of byte absolute $D004;
  SIZEP : array[0..3] of byte absolute $D008;
// IN P/M DOUBLE RESOLUTION, MISSILES
// START AT OFFSET OF 384 OF PMBASE
// 1 BYTE FOR ALL MISSILES
// (2 BITS PER MISSILE)
// 
// MISSILE0 (BITS 0 1)
// MISSILE1 (BITS 2 3)
// MISSILE2 (BITS 4 5)
// MISSILE3 (BITS 6 7)
// MISSILE3 DATA
// SIMPLE DELAY ROUTINE
var
  P0_DATA : array[0..7] of byte = (56, 68, 124, 124, 124, 124, 124, 56);
  P1_DATA : array[0..10] of byte = (28, 34, 62, 62, 28, 8, 8, 8, 8, 28, 62);
  P2_DATA : array[0..14] of byte = (24, 24, 24, 60, 126, 126, 126, 126, 66, 90, 66, 126, 66, 126, 126);
  P3_DATA : array[0..14] of byte = (36, 149, 85, 62, 66, 129, 129, 165, 129, 153, 129, 165, 153, 66, 60);
  M3_DATA : array[0..10] of byte = (128, 128, 255, 64, 64, 255, 128, 128, 255, 64, 64);

procedure DELAYProc(LIMIT : integer);
var
  I : integer;
begin  // 1
 FOR I:=1 TO LIMIT do begin
  end;
end;

// BULLET MOVE ROUTINE
function BULLET_PROCFunc(MOVE : integer; NUM : byte; POS : byte) : byte;
begin  // 1
  Inc(POS, MOVE);
  HPOSP[NUM] := POS;
  result := POS;
end;
// MAIN PROGRAM
procedure MAINProc;
// TURN OFF P/M GRAPHICS
begin  // 6
  GRACTL := 0;
// GRAPHICS MODE 0
  InitGraph(0);
// HIDE CURSOR
  Poke(752, 1);
// PUT SOME TEXT ON SCREEN
  Write('DRUNK MAN SHooTING NiGhTmAre', eol, '', eol, '');
  Writeln('Hik! Shoot glasses by pressing Hik!');
  Write('joystick fire button! Hik!');
  GotoXY(1 + 1,  23 + 1);
  Write('PRESS ESCAPE KEY TO WAKE UP');
// SET SAFE PLACE FOR OUR PLAYER
  PGMMEM := RAMTOP-12;
// BASE ADDRESS (MSB)
  PMBASE := PGMMEM;
// STARTING ADDRESS OF P/M GRAPHICS
  PGMMEM := PGMMEM * 256;
// P/M DOUBLE RESOLUTION
  SDMCTL := 46;
// CLEAR SPACE FOR P/M GRAPHICS
  FillChar(pointer(PGMMEM+384), 768, 0);
// COPY PLAYER DATA TO P/M MEMORY
  Move(P0_DATA, pointer(PGMMEM+512+46),  8);
  Move(P1_DATA, pointer(PGMMEM+640+40),  11);
  Move(P2_DATA, pointer(PGMMEM+768+40),  15);
  Move(P3_DATA, pointer(PGMMEM+896+85),  15);
// TURN ON P/M GRAPHICS
  GRACTL := 3;
// PLAYERS 0 TO 2 - NORMAL SIZE
// SIZEP(0)=0 SIZEP(1)=0 SIZEP(2)=0
// PLAYER 3 - DOUBLE SIZE
  SIZEP[3] := 1;
// PLAYER COLORS
  PCOLR[0] := 152;
  PCOLR[1] := 8;
  PCOLR[2] := 228;
  PCOLR[3] := 248;
// PLAYER HORIZONTAL INITIAL POSITIONS
  P3 := 90;
  P0 := 70;
  P1 := 170;
  HPOSP[0] := P0;
  HPOSP[1] := P1;
  HPOSP[2] := 120;
  HPOSP[3] := P3;
// NO KEY PRESSED YET
  CH := 255;
  repeat
// MOVE DRUNK MAN LEFT
  if  STICK[0]=11  then begin
  Dec(P3);
  if  P3<50  then begin
  P3 := 50;
  end;  // if
  HPOSP[3] := P3;
  DELAYProc(320);
// MOVE DRUNK MAN RIGHT
  end
  else if  STICK[0]=7  then begin
  Inc(P3);
  if  P3>190  then begin
  P3 := 190;
  end;  // if
  HPOSP[3] := P3;
  DELAYProc(320);
  end;  // if
// JOYSTICK TRIGGER WAS PRESSED
// THE GAME BEGINS... :)
  if  STRIG[0]=0  then begin
// CLEAR ALL P/M GRAPHICS COLLISION REGISTERS
  HITCLR := 1;
  HPOSM[3] := P3;
// SHOOT BOTTLE AND GLASSES
// MISSILE3 IS A BULLET
  M3R := 70;
// BULLET DISTANCE RANGE CHECK
 WHILE M3R>30 do begin
  DELAYProc(320);
// DRAW BULLET
  FillChar(pointer(PGMMEM+384), 128, 0);
  Move(M3_DATA, pointer(PGMMEM+384+M3R),  10);
// PLAYER0 IS HIT (LEFT GLASS)
  if  (SIZEP[3]=1)  AND (P0=70)  then begin
  FillChar(pointer(PGMMEM+384), 128, 0);
  repeat
  P0 := BULLET_PROCFunc(1,0,P0);
  COLLISION := Peek($D00C);
 UNTIL COLLISION>=4;
// PLAYER1 IS HIT (RIGHT GLASS)
  end
  else if  (SIZEP[3]=2)  AND (P1=170)  then begin
  FillChar(pointer(PGMMEM+384), 128, 0);
  repeat
  P1 := BULLET_PROCFunc(-1,1,P1);
  COLLISION := Peek($D00D);
 UNTIL COLLISION>=4;
// PLAYER2 IS HIT (BOTTLE)
  end
  else if  SIZEP[3]=4  then begin
  FillChar(pointer(PGMMEM+384), 128, 0);
  if  P0<>70  then begin
  repeat
  P0 := BULLET_PROCFunc(-1,0,P0);
 UNTIL P0=70;
  end;  // if
  if  P1<>170  then begin
  repeat
  P1 := BULLET_PROCFunc(1,1,P1);
 UNTIL P1=170;
  end;  // if
  end;  // if
  Dec(M3R);
  end;
  FillChar(pointer(PGMMEM+384), 128, 0);
  end;  // if
 UNTIL CH=28;
// TURN OFF P/M GRAPHICS
  GRACTL := 0;
end;

begin
  MAINProc;
end.
