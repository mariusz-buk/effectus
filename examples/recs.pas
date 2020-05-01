// Effectus auto-generated Mad Pascal source code listing
program recsPrg;

uses
  SySutils, Crt;

// Effectus example:
// Record ARRAY demonstration
type
  rec = record
  NUM1 : byte;
  NUM2 : integer;
  NUM3 : integer;
  end;
var
  DATA : array[0..15] of byte;
  ENTRY : ^rec;
  KEY : char;

procedure MAINProc;
begin
  Write(Chr(125));
  Writeln('Effectus example:');
  Writeln('Record ARRAY demonstration');
  Writeln('');
  ENTRY := pointer(word(@DATA));
Inc(ENTRY, 0);
// ENTRY=DATA+(0*SIZE)
  ENTRY^.NUM1 := 10;
  ENTRY^.NUM2 := 100;
  ENTRY^.NUM3 := 1000;
  ENTRY := pointer(word(@DATA));
Inc(ENTRY, 5);
  ENTRY^.NUM1 := 20;
  ENTRY^.NUM2 := 200;
  ENTRY^.NUM3 := 2000;
  ENTRY := pointer(word(@DATA));
Inc(ENTRY, 10);
  ENTRY^.NUM1 := 30;
  ENTRY^.NUM2 := 200;
  ENTRY^.NUM3 := 3000;
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
  KEY := ReadKey;
end;

begin
  MAINProc;
end.
