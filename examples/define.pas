// Effectus auto-generated Mad Pascal source code listing
program definePrg;

uses
  SySutils, Crt;

// Effectus example
// -------------------------------------
// DEFINE declaration demo
var
  key : char;

procedure DEFINE_TESTProc;
var
  n : byte;
begin
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
  n := 1;
  for  n:=1 to 3 do begin
  Writeln(n);
  end;
  key := ReadKey;
end;

begin
  DEFINE_TESTProc;
end.
