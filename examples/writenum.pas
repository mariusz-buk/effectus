// Effectus auto-generated Mad Pascal source code listing
program writenumPrg;

uses
  Crt, SySutils, CIO;


var
  strBuffer : string;
// Effectus example
// --------------------------------------
// Device I/O demo using PrintBD routine
// Sample file: H1:TESTNUM.TXT

procedure MAINProc;
var
  I : byte;
  key : byte;
begin  // 2
  Write(Chr(125));
  Write('PrintBD example', eol, '', eol, '');
  Cls(1);
  Opn(1, 8, 0, 'H1:TESTNUM.TXT');
  Writeln('Write numbers to disk...');
  for  I:=1 TO 12 do begin
  strBuffer := IntToStr( I);
  BPut(1, @strBuffer[1], Length(strBuffer));
  end;  // for
  Cls(1);
  Writeln('Done!(file H1:TESTNUM.TXT)');
  Write('', eol, '', eol, 'Press any key to continue!');
  key := Get(7);
  ReadKey;
end;  // 4

begin
  MAINProc;
end.
