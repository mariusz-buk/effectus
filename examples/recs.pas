// Effectus auto-generated Mad Pascal source code listing
program recsPrg;

uses
  Crt, SySutils, CIO;

var
  strBuffer : string;
// Effectus example
// ----------------
// Record ARRAY demonstration
type
  rec = record
  NUM1 : byte;
  NUM2 : word;
  NUM3 : word;
  end;  // type
var
  DATA : array[0..15] of byte;
  ENTRY : ^rec;
  KEY : byte;

procedure MAINProc;
begin  // 1
  Write(Chr(125));
  Writeln('Effectus example:');
  Writeln('Record ARRAY demonstration');
  Writeln('');
  ENTRY := pointer(word(@DATA));
  Inc(ENTRY, 0);
// ENTRY=DATA+(0*5)
  ENTRY^.NUM1 := 10;
  ENTRY^.NUM2 := 1000;
  ENTRY^.NUM3 := 10000;
  ENTRY := pointer(word(@DATA));
  Inc(ENTRY, (1*5));
  ENTRY^.NUM1 := 20;
  ENTRY^.NUM2 := 2000;
  ENTRY^.NUM3 := 20000;
  ENTRY := pointer(word(@DATA));
  Inc(ENTRY, (2*5));
  ENTRY^.NUM1 := 30;
  ENTRY^.NUM2 := 3000;
  ENTRY^.NUM3 := 30000;
  Writeln('Some data retrieved from the records');
  Writeln('');
  ENTRY := pointer(word(@DATA));
  Inc(ENTRY, 0);
  Write('entry.num1=');
  Writeln(ENTRY.NUM1);
  ENTRY := pointer(word(@DATA));
  Inc(ENTRY, 5);
  Write('entry.num2=');
  Writeln(ENTRY.NUM2);
  ENTRY := pointer(word(@DATA));
  Inc(ENTRY, 10);
  Write('entry.num3=');
  Writeln(ENTRY.NUM3);
  Write('', eol, '---------------------');
  KEY := Get(7);
  ReadKey;
end;

begin
  MAINProc;
end.
