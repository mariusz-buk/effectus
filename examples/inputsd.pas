// Effectus auto-generated Mad Pascal source code listing
program inputsdPrg;

uses
  SySutils, Crt;


var
  intValue : integer;
  f : file;
  strBuffer : string;
// Effectus example
// -------------------------------------
// Device I/O demo using InputSD and
// InputMD procedures to read text file
// 
// Sample file on H1: device: TEST.TXT
var
  key : char;
  str_buffer1 : string[255];

procedure MAINProc;
begin  // 1
  Write(Chr(125));
  Writeln('Device I/O demo');
  Writeln('using InputSD and InputMD procedures');
  Writeln('to read text file');
  Writeln('');
  Writeln('Sample file: TEST.TXT');
  Assign(f,  'H1:TEST.TXT');
  Reset(f, 1);
  Write('', eol, 'InputSD example:', eol, '');
  BlockRead(f,  str_buffer1, 255);
  Writeln(str_buffer1);
  Close(f);
  Assign(f,  'H1:TEST.TXT');
  Reset(f, 1);
  Write('', eol, 'InputMD example:', eol, '');
  BlockRead(f,  str_buffer1,  255);
  Writeln(str_buffer1);
  Close(f);
  key := ReadKey;
end;  // 4

begin
  MAINProc;
  Close(f);
end.
