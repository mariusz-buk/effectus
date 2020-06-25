// Effectus auto-generated Mad Pascal source code listing
program inputsdPrg;

uses
  Crt, SySutils, CIO;


var
  strBuffer : string;
// Effectus example
// -------------------------------------
// Device I/O demo using InputSD and
// InputMD procedures to read text file
// 
// Sample file on H1: device: TEST.TXT
var
  key : byte;
  str_buffer1 : string[255];

procedure MAINProc;
begin  // 1
  Write(Chr(125));
  Writeln('Device I/O demo');
  Writeln('using InputSD and InputMD procedures');
  Writeln('to read text file');
  Writeln('');
  Writeln('Sample file: TEST.TXT');
  Cls(1);
  Opn(1, 4, 0, 'H1:TEST.TXT');
  Write('', eol, 'InputSD example:', eol, '');
  BGet(1,  str_buffer1, SizeOf( str_buffer1));
  Writeln(str_buffer1);
  Cls(1);
  Opn(1, 4, 0, 'H1:TEST.TXT');
  Write('', eol, 'InputMD example:', eol, '');
  BGet(1,  str_buffer1,  255);
  Writeln(str_buffer1);
  Cls(1);
  key := Get(7);
  ReadKey;
end;  // 4

begin
  MAINProc;
end.
