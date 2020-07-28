// Effectus auto-generated Mad Pascal source code listing
program arraysetPrg;

uses
  Crt, SySutils, CIO;

var
  strBuffer : string;
// Effectus example
// ----------------
// Using ARRAY predeclared values with
// BYTE ARRAY and CARD ARRAY
var
  key : byte;
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
 FOR I:=0 TO 3 do begin
  Write(BYTES[I]);
  if  I<3  then begin
  Write(',');
  end;  // if
  end;
  Writeln('');
  Writeln('');
  Writeln('CARD ARRAY VALUES:');
 FOR I:=0 TO 3 do begin
  Write(CARDS[I]);
  if  I<3  then begin
  Write(',');
  end;  // if
  end;
  key := Get(7);
  ReadKey;
end;

begin
  MAINProc;
end.
