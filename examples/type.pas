// Effectus auto-generated Mad Pascal source code listing
program typePrg;

uses
  Crt, SySutils, CIO;


var
  strBuffer : string;
// --------------------------------------
// Effectus example
// TYPE declaration demo
// --------------------------------------
type
  REC = record
  day : byte;
  month : byte;
  year : word;
  height : byte;
  end;  // type
var
  data : REC;
  weightData : byte;
  key : byte;

procedure MAINProc;
begin  // 1
  Write(Chr(125));
  Writeln('Effectus example:');
  Writeln('TYPE declaration demonstration');
  Writeln('');
  data.day := 12;
  data.month := 4;
  data.year := 1975;
  data.height := 182;
  weightData := data.height;
  Writeln('Personal data');
  Writeln('-------------');
  Write('', eol, 'Birthday: ', data.day, '.', data.month, '.', data.year, '', eol, '');
  Write('Height: ');
  Writeln(weightData);
  key := Get(7);
  ReadKey;
end;  // 4

begin
  MAINProc;
end.
