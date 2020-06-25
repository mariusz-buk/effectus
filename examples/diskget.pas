// Effectus auto-generated Mad Pascal source code listing
program diskgetPrg;

uses
  Crt, SySutils, CIO;


var
  strBuffer : string;
// Effectus example
// -------------------------------------
// Device I/O demo using GetD and EOF
// routines
// Sample file: H1:TESTNUM.TXT
var
  n : byte;
  i : byte;
  KEY : byte;

procedure MAINProc;
begin  // 1
  Write(Chr(125));
  Write('GetD and EOF example', eol, '', eol, '');
  Cls(1);
  Opn(1, 4, 0, 'H1:TESTNUM.TXT');
  for  i:=1 to 15 do begin
  n := Get(1);
  Write(Chr(n));
  end;  // for
  Cls(1);
  Write('', eol, 'All numbers read!', eol, '', eol, '');
// PRINTE("Read numbers again:")
// OPEN(1,"H1:TESTNUM.TXT",4,0)
// DO
// n=GetD(1) Put(n)
// UNTIL EOF(1)
// OD
// CLOSE(1)
// PRINTF("%E%EAll numbers are read again!%E")
  KEY := Get(7);
  ReadKey;
end;  // 4

begin
  MAINProc;
end.
