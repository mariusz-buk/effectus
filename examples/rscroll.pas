// Effectus auto-generated Mad Pascal source code listing
program rscrollPrg;

uses
  Crt;

// ------------------------------------
// Effectus example
// Scroll
// ------------------------------------

procedure MAINProc;
var
  i : word;
  scrloc : word absolute 88;
  screen : PByte;
var
  new_dir : array[0..7] of byte = ($D7, $D8, $D9, $FF, 1, 39, 40, 41);
  ch : byte;
  dir : byte;
begin  // 1
  dir := 1;
  screen := pointer(SCRLOC);
  repeat
  for  i:=0 TO 959 do begin
  screen[i] := ch+i;
  end;  // for
  if  Random(10) = 0  then begin
  dir := new_dir[Random(8)];
  end;  // if
  ch := ch+dir;
  until 0 = 1;
end;  // 4

begin
  MAINProc;
end.
