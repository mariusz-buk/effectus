// Effectus auto-generated Mad Pascal source code listing
program fsPrg;

uses
  Crt, SySutils, Graph, CIO;


var
  strBuffer : string;
// Effectus example
// -------------------------------------
// Finescroll by greblus
// Modification by Gury (keypress check)
var
  key : byte;
  j : integer = 0;
  k : integer = 0;
  hsc : byte absolute 54276;
  tmpl : byte;
  tmph : byte;
  tmp : byte;
var
  ndl : array[0..32] of byte = (112, 112, 112, 66, 64, 156, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 86, 216, 159, 65, 32, 156);

procedure CHNDLProc;
begin  // 6
  tmp := ndl[28];
  if tmp<2 then begin
  ndl[28] := 255;
  tmp := ndl[29]-1;
  ndl[29] := tmp;
  end
  else begin
  tmp := ndl[28]-2;
  ndl[28] := tmp;
  end;  // if
end;  // 4

procedure SCROLProc;
begin  // 6
  hsc := j;
  j := j+1;
  if j=17 then begin
  CHNDLProc;
  j := 0;
  k := k+1;
  end;  // if
  if k=14 then begin
  ndl[28] := tmpl;
  ndl[29] := tmph;
  k := 0;
  end;  // if
  asm
  {
    .by $4C $62 $E4 
  };
end;  // 4

procedure MAINProc;
var
  i : integer;
  sav : word absolute 88;
  clock : byte absolute $14;
  nmi : byte absolute $D40E;
  dlist : word absolute 560;
  vvblkd : word absolute $0224;
  col0 : byte absolute 708;
  col1 : byte absolute 709;
begin  // 1
  InitGraph(0);
  dlist := word(@ndl);
  sav := 40000;
  col0 := 14;
  col1 := 14;
  for  i:=1 to 23 do begin
  Write('line:', i, '', eol, '');
  end;  // for
  Write('Action!');
  tmpl := ndl[28];
  tmph := ndl[29];
  i := clock;
 while clock=i do begin
  end;  // while
  nmi := 0;
  vvblkd := word(@SCROLProc);
  nmi := $40;
  key := Get(7);
  ReadKey;
end;  // 4

begin
  MAINProc;
end.
