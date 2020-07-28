// Effectus auto-generated Mad Pascal source code listing
program includePrg;

uses
  Crt, Graph;

// Effectus example
// ----------------
// INCLUDE demo
// Effectus example
// ----------------
// User library for INCLUDE demo
var
  CH : byte absolute 764;

procedure WAITFORKEYProc;
begin  // 1
  CH := 255;
 WHILE CH=255 do begin
  end;
end;

procedure PRINTTEXTProc;
begin  // 6
  Writeln('Hello world');
end;

procedure CHANGECOLORProc;
begin  // 6
  Poke(710, 50);
  Poke(712, 160);
end;

procedure MAINProc;
begin  // 6
  Write(Chr(125));
  Writeln('Effectus example:');
  Writeln('INCLUDE demonstration');
  Writeln('');
  Writeln('Press any key and see my greetings!');
  WAITFORKEYProc;
  Writeln('');
  PRINTTEXTProc;
  Writeln('');
  Writeln('Press any key to change color!');
  WAITFORKEYProc;
  CHANGECOLORProc;
  WAITFORKEYProc;
end;

begin
  MAINProc;
end.
