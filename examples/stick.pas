// Effectus auto-generated Mad Pascal source code listing
program stickPrg;

uses
  SySutils, Crt, Joystick;

// Effectus example
// -------------------------------------
// Joystick demo
// (using Stick and Strig functions)

procedure MAINProc;
var
  b : byte;
  fire : byte;
begin
  Write(Chr(125));
  fire := 1;
 WHILE fire>0 do begin
  B := stick[0];
  Writeln(B);
  fire := strig[0];
  end;
  Writeln('TRIGGER WAS PRESSED!');
end;

begin
  MAINProc;
end.
