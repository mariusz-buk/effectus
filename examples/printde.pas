// Effectus auto-generated Mad Pascal source code listing
program printdePrg;

uses
  Crt, SySutils, CIO;

var
  strBuffer : string;
// EFFECTUS EXAMPLE
// ----------------
// DEVICE INPUT/OUTPUT DEMONSTRATION

procedure MAINProc;
var
  TEXT_BUF : string[10];
  KEY : byte;
begin  // 2
  Cls(1);
  Opn(1, 8, 0, 'S:');
  Writeln('PRINTING STRING VALUES TO CHANNEL 1');
  Writeln('ON S: DEVICE');
  Writeln('');
  strBuffer := Concat('TEST1', #$9b);
  BPut(1, @strBuffer[1], Length(strBuffer));
  TEXT_BUF :=  'TEST2';
  strBuffer := Concat(TEXT_BUF, #$9b);
  BPut(1, @strBuffer[1], Length(strBuffer));
  strBuffer :=  'TEST3';
  BPut(1, @strBuffer[1], Length(strBuffer));
  strBuffer := IntToStr( 10);
  BPut(1, @strBuffer[1], Length(strBuffer));
  Writeln('');
  strBuffer := Concat(IntToStr( 20), #$9b);
  BPut(1, @strBuffer[1], Length(strBuffer));
  strBuffer := IntToStr( 2000);
  BPut(1, @strBuffer[1], Length(strBuffer));
  Writeln('');
  strBuffer := Concat(IntToStr( 10000), #$9b);
  BPut(1, @strBuffer[1], Length(strBuffer));
  strBuffer := IntToStr( 6230);
  BPut(1, @strBuffer[1], Length(strBuffer));
  Writeln('');
  strBuffer := Concat(IntToStr( 65334), #$9b);
  BPut(1, @strBuffer[1], Length(strBuffer));
  Writeln('');
  Cls(1);
  KEY := Get(7);
  ReadKey;
end;

begin
  MAINProc;
end.
