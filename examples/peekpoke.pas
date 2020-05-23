// Effectus auto-generated Mad Pascal source code listing
program peekpokePrg;

uses
  SySutils, Crt, Graph;

// Effectus example
// -------------------------------------
// PEEK and POKE demo
var
  n : byte;
  CH : byte absolute 764;
  COL : byte absolute 710;

procedure WAITFORKEYProc;
begin  // 1
  CH := 255;
 WHILE CH=255 do begin
  end;  // while
  CH := 255;
end;  // 4

procedure MAINProc;
begin  // 6
  Write(Chr(125));
  Writeln('Effectus example:');
  Writeln('PEEK demonstration');
  Writeln('');
  n := CH;
  Writeln('Shadow register 764 currently holds:');
  Writeln('');
  Writeln(n);
  Writeln('');
  n := COL;
  Writeln('Shadow register 710 currently holds:');
  Writeln('');
  Writeln(n);
  Writeln('');
  n := Peek(559);
  Writeln('Shadow register 559 currently holds:');
  Writeln('');
  Writeln(n);
  Writeln('');
  Writeln('');
  Writeln('POKE demonstration');
  Writeln('Press any key to change color!');
  WAITFORKEYProc;
  COL := 0;
  Writeln('Press any key to change color again!');
  WAITFORKEYProc;
  Poke(710, 230);
  Writeln('And again!');
  WAITFORKEYProc;
  n := 65;
  Poke(710, n);
  Writeln('Last time!');
  WAITFORKEYProc;
  n := 184;
  Poke(COL, n);
  WAITFORKEYProc;
end;  // 4

begin
  MAINProc;
end.
