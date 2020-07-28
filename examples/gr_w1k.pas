// Effectus auto-generated Mad Pascal source code listing
program gr_w1kPrg;

uses
  Crt, SySutils, Graph, CIO;

var
  strBuffer : string;
// Effectus example
// ----------------
// Graphics demonstration
// 
// Graphics Program by w1k
// http://atarionline.pl/forum/comments.php?DiscussionID=207&page=1#Item_0
var
  I : byte;
  KLAVESA : byte;

procedure LINKAProc(X0 : byte; Y0 : byte; X1 : byte; Y1 : byte);
begin  // 1
  PutPixel(X0, Y0);
  MoveTo(X0, Y0);
  LineTo(X1, Y1);
end;

procedure DEMOProc;
begin  // 6
 FOR i:=0 to 79 do begin
  LINKAProc(0, 0, 159, I);
  end;
end;

procedure HLPROGRAMProc;
begin  // 6
  InitGraph(7);
  SetColor(1);
  DEMOProc;
  Writeln('STLAC');
  KLAVESA := Get(7);
  ReadKey;
end;

begin
  HLPROGRAMProc;
end.
