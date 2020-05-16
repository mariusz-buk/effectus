// Effectus auto-generated Mad Pascal source code listing
program writenumPrg;

uses
  SySutils, Crt;


var
  intValue : integer;
  f : file;
  strBuffer : string;
// Effectus example
// --------------------------------------
// Device I/O demo using PrintBD routine
// Sample file: H1:TESTNUM.TXT

procedure MAINProc;
var
  I : byte;
  key : char;
begin  // 2
  Write(Chr(125));
  Write('PrintBD example', eol, '', eol, '');
  Assign(f,  'H1:TESTNUM.TXT');
  Rewrite(f, 1);
  Writeln('Write numbers to disk...');
  for  I:=1 TO 12 do begin
  strBuffer := IntToStr( I);
  Blockwrite(f, strBuffer[1], Length(strBuffer));
  end;  // for
  Close(f);
  Writeln('Done!(file H1:TESTNUM.TXT)');
  Write('', eol, '', eol, 'Press any key to continue!');
  key := ReadKey;
end;  // 4

begin
  MAINProc;
  Close(f);
end.
