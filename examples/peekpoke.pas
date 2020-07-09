// Effectus auto-generated Mad Pascal source code listing
program peekpokePrg;

uses
  Crt, Graph;

// Effectus example
// PEEK and POKE demo
var
  n : byte;
  mem : word;
  CH : byte absolute 764;
  COL : byte absolute 710;

procedure WAITFORKEYProc;
begin  // 1
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
  n := Peek(CH);
  Writeln('Shadow register 764 currently holds:');
  Writeln('');
  Writeln(n);
  Writeln('');
  n := Peek(710);
  Writeln('Shadow register 710 currently holds:');
  Writeln('');
  Writeln(n);
  Writeln('');
  n := Peek(559);
  Writeln('Shadow register 559 currently holds:');
  Writeln('');
  Writeln(n);
  Writeln('');
  mem := DPeek($0230);
  Writeln('Display List Pointer(DLISTL/DLISTH)');
  Writeln('address:');
  Writeln('');
  Writeln(mem);
  Write('', eol, '', eol, 'POKE demonstration', eol, '');
  Writeln('Press any key to change color!');
  WAITFORKEYProc;
  COL := 0;
  Writeln('Press any key to change color again!');
  WAITFORKEYProc;
  Poke(710, 212);
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
