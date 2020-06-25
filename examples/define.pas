// Effectus auto-generated Mad Pascal source code listing
program definePrg;

uses
  Crt, SySutils, CIO;


var
  strBuffer : string;
// --------------------------------------
// Effectus example
// --------------------------------------
var
  key : byte;

procedure DEFINE_TESTProc;
var
  n : byte;
begin  // 1
  Write(Chr(125));
  Poke(710, 0);
  Poke(712, 60);
  Writeln('');
  Writeln('');
  Writeln('DEFINE statement test');
  Writeln('');
  Writeln('');
  Writeln('Cls,Newline');
  Writeln('');
  Writeln('Count from 1 to max');
  for  n:=1 to 3 do begin
  Writeln(n);
  end;  // for
  key := Get(7);
  ReadKey;
end;  // 4

begin
  DEFINE_TESTProc;
end.
