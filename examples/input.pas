// Effectus auto-generated Mad Pascal source code listing
program inputPrg;

uses
  SySutils, Crt;

// Effectus example
// -------------------------------------
// String input demo
// (using InputS procedure)
var
  key : char;
  name : string[13];
  surname : string[21];

procedure MAINProc;
begin  // 1
  Write(Chr(125));
  Writeln('Effectus example:');
  Writeln('String input demonstration');
  Writeln('using InputS procedure');
  Writeln('');
  Writeln('Whats your name?');
  Readln(name);
  Writeln('');
  Writeln('Whats your surname?');
  Readln(surname);
  Writeln('');
  Write('Thank you,');
  Write(name);
  Write(Chr(32));
  Writeln(surname);
  Writeln('');
  key := ReadKey;
end;  // 4

begin
  MAINProc;
end.
