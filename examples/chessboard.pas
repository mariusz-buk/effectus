// Effectus auto-generated Mad Pascal source code listing
program chessboardPrg;

uses
  Crt, Graph;

// Effectus example
// ----------------
// Graphics demo with benchmark test
// using iterations
var
  ch : byte absolute 764;
  RTCLOCK : byte absolute 20;
  SAVMSC : word absolute 88;
  col1 : byte absolute 709;
  col2 : byte absolute 710;
  colB : byte absolute 712;
  stop : byte;

procedure DRAWBOARDProc;
var
  i1b : byte;
  i2b : byte;
  i3b : byte;
  SCREEN : PByte;
begin  // 1
  SCREEN := pointer(SAVMSC);
 FOR i3b:=1 TO 8 do begin
 FOR i2b:=1 TO 24 do begin
 FOR i1b:=1 TO 4 do begin
  SCREEN[0] := 255;
  SCREEN[1] := 255;
  SCREEN[2] := 255;
  Inc(SCREEN, 6);
  end;
  Inc(SCREEN, 16);
  end;
  if  (i3b AND 1)=0  then begin
  Dec(SCREEN, 3);
  end
  else begin
  Inc(SCREEN, 3);
  end;  // if
  end;
end;

procedure MAINProc;
var
  I : byte = 0;
begin  // 1
  InitGraph(8+16);
  col1 := 1;
  col2 := 11;
  colB := 12;
  RTCLOCK := 0;
 WHILE RTCLOCK<150 do begin
  DRAWBOARDProc;
  Inc(I);
  end;
  stop := RTCLOCK;
  InitGraph(0);
  Write('', eol, ' ', I, ' iterations');
 WHILE ch=255 do begin
  end;
end;

begin
  MAINProc;
end.
