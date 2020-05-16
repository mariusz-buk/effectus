// Effectus auto-generated Mad Pascal source code listing
program arraysetPrg;

uses
  SySutils, Crt;

// Effectus example
// -------------------------------------
// Using ARRAY predeclared values with
// BYTE ARRAY and CARD ARRAY
var
  key : char;
  I : byte;
var
  BYTES : array[0..3] of byte = (10, 20, 30, 40);
var
  CARDS : array[0..3] of word = (540, 1300, 26800, 65300);

procedure MAINProc;
begin  // 6
  Write(Chr(125));
  Writeln('EFFECTUS EXAMPLE:');
  Writeln('ARRAYS DEMONSTRATION');
  Writeln('');
  Writeln('BYTE ARRAY VALUES:');
  for  I:=0 TO 3 do begin
  Write(BYTES[I]);
  if I<3 then begin
  Write(',');
  end;  // if
  end;  // for
  Writeln('');
  Writeln('');
  Writeln('CARD ARRAY VALUES:');
  for  I:=0 TO 3 do begin
  Write(CARDS[I]);
  if I<3 then begin
  Write(',');
  end;  // if
  end;  // for
  key := ReadKey;
end;  // 4

begin
  MAINProc;
end.
