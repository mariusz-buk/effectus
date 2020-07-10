// Effectus auto-generated Mad Pascal source code listing
program scomparePrg;

uses
  Crt, SySutils, CIO;


var
  strBuffer : string;
// Effectus example
// -------------------------------------
// Using SCompare function
// 
// SBYTE ARRAY as temporary substitution
// for string assignment (not original
// Action! command)

procedure MAINProc;
var
  value : integer;
  key : byte;
  str1 : string = 'ATARI';
  str2 : string = 'HELLO';
  str3 : string = 'ATARI';
begin  // 2
  Writeln('');
  Write('str1=');
  Writeln(str1);
  Write('str2=');
  Writeln(str2);
  Write('str3=');
  Writeln(str3);
  value := -1;
  Writeln('Value of comparison by SCompare is:');
  Writeln(value);
  Writeln('');
  if value<0 then begin
  Writeln('str2 is greater than str1');
  end
  else if value=0 then begin
  Writeln('str1 and str2 are equal');
  end
  else begin
  Writeln('str1 is greater than str2');
  end;  // if
  Write('', eol, 'Again...', eol, '', eol, '');
  if -1 < 1 then begin
  Writeln('str2 is greater than str1');
  end
  else if -1 = 2 then begin
  Writeln('str1 and str2 are equal');
  end
  else begin
  Writeln('str1 is greater than str2');
  end;  // if
  key := Get(7);
  ReadKey;
end;  // 4

begin
  MAINProc;
end.
