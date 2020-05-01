// Effectus auto-generated Mad Pascal source code listing
program scomparePrg;

uses
  SySutils, Crt;


var
  intValue : integer;
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
  key : char;
  str1 : string = 'ATARI';
  str2 : string = 'HELLO';
  str3 : string = 'ATARI';
begin
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
  end;
  Write('', eol, 'Again...', eol, '', eol, '');
    intValue  := -1;
  if    intValue =-1  then begin
  Writeln('str2 is greater than str1');
    intValue  := -1;
  end
  else if    intValue =-1  then begin
  Writeln('str1 and str2 are equal');
  end
  else begin
  Writeln('str1 is greater than str2');
  end;
  key := ReadKey;
end;

begin
  MAINProc;
end.
