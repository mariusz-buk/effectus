// Effectus auto-generated Mad Pascal source code listing
program printePrg;

uses
  Crt, SySutils, CIO;

var
  strBuffer : string;
// Effectus example
// ----------------
// PrintE demo

procedure MAINProc;
var
  key : byte;
begin  // 2
  Writeln('HELLO WORLD');
  Writeln('');
  Writeln('NEW LINE');
  Writeln('');
  Writeln('ANOTHER NEW LINE');
  key := Get(7);
  ReadKey;
end;

begin
  MAINProc;
end.
