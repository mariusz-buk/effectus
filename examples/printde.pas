// Effectus auto-generated Mad Pascal source code listing
program printdePrg;

uses
  SySutils, Crt;


var
  intValue : integer;
  f : file;
  strBuffer : string;
// EFFECTUS EXAMPLE:
// DEVICE INPUT/OUTPUT DEMONSTRATION

procedure MAINProc;
var
  TEXT_BUF : string[10];
  KEY : char;
begin  // 2
  Assign(f,  'S:');
  Rewrite(f, 1);
  Writeln('PRINTING STRING VALUES TO CHANNEL 1');
  Writeln('ON S: DEVICE');
  Writeln('');
  strBuffer := Concat('TEST1', #$9b);
  Blockwrite(f, strBuffer[1], Length(strBuffer));
  TEXT_BUF :=  'TEST2';
  strBuffer := Concat(TEXT_BUF, #$9b);
  Blockwrite(f, strBuffer[1], Length(strBuffer));
  strBuffer := 'TEST3';
  Blockwrite(f, strBuffer[1], Length(strBuffer));
  strBuffer := IntToStr( 10);
  Blockwrite(f, strBuffer[1], Length(strBuffer));
  Writeln('');
  strBuffer := Concat(IntToStr( 20), #$9b);
  Blockwrite(f, strBuffer[1], Length(strBuffer));
  strBuffer := IntToStr( 2000);
  Blockwrite(f, strBuffer[1], Length(strBuffer));
  Writeln('');
  strBuffer := Concat(IntToStr( 10000), #$9b);
  Blockwrite(f, strBuffer[1], Length(strBuffer));
  strBuffer := IntToStr( 6230);
  Blockwrite(f, strBuffer[1], Length(strBuffer));
  Writeln('');
  strBuffer := Concat(IntToStr( 65334), #$9b);
  Blockwrite(f, strBuffer[1], Length(strBuffer));
  Writeln('');
  Close(f);
  KEY := ReadKey;
end;  // 4

begin
  MAINProc;
  Close(f);
end.
