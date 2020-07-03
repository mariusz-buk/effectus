// Effectus auto-generated Mad Pascal source code listing
program stickPrg;

uses
  Crt, SySutils, Joystick;

// Effectus example
// -------------------------------------
// Joystick demo
// (using Stick and Strig functions)

procedure MAINProc;
var
  b : byte;
  fire : byte;
begin  // 2
  Write(Chr(125));
  fire := 1;
 WHILE fire>0 do begin
  B := stick[0];
  Writeln(B);
  fire := strig[0];
  end;  // while
  Writeln('TRIGGER WAS PRESSED!');
end;  // 4

begin
  MAINProc;
end.
