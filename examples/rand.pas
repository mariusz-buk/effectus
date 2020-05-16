// Effectus auto-generated Mad Pascal source code listing
program randPrg;

uses
  SySutils, Crt;

// Effectus example
// -------------------------------------
// Random number generator demo
// (Rand function)
var
  i : byte;
  key : char;

procedure MAINProc;
begin  // 1
  Write(Chr(125));
  Writeln('Effectus example:');
  Writeln('Random number generator demonstration');
  Writeln('(function Rand)');
  Writeln('');
  Writeln('Press any key to see random numbers!');
  key := ReadKey;
  Writeln('');
  Writeln('Selected number between 0 and 100');
  i := Random(100);
  Writeln(i);
  Writeln('');
  Writeln('Selected number between 0 and 255');
  i := Random(255);
  Writeln(i);
  Writeln('');
  Writeln('Selected number between 0 and 3');
  i := Random(3);
  Writeln(i);
  key := ReadKey;
end;  // 4

begin
  MAINProc;
end.
