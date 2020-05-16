// Effectus auto-generated Mad Pascal source code listing
program diskgetPrg;

uses
  SySutils, Crt;


var
  intValue : integer;
  f : file;
  strBuffer : string;
// Effectus example
// -------------------------------------
// Device I/O demo using GetD and EOF
// routines
// Sample file: H1:TESTNUM.TXT
var
  n : byte;
  i : byte;
  KEY : char;

procedure MAINProc;
begin  // 1
  Write(Chr(125));
  Write('GetD and EOF example', eol, '', eol, '');
  Assign(f,  'H1:TESTNUM.TXT');
  Reset(f, 1);
  for  i:=1 to 15 do begin
  BlockRead(f, n, 1);
  Write(Chr(n));
  end;  // for
  Close(f);
  Write('', eol, 'All numbers read!', eol, '', eol, '');
  Writeln('Read numbers again:');
  Assign(f,  'H1:TESTNUM.TXT');
  Reset(f, 1);
  repeat
  BlockRead(f, n, 1);
  Write(Chr(n));
  until  eof(f);
  Close(f);
  Write('', eol, '', eol, 'All numbers are read again!', eol, '');
  KEY := ReadKey;
end;  // 4

begin
  MAINProc;
  Close(f);
end.
