// Effectus auto-generated Mad Pascal source code listing
program loop_exitPrg;

uses
  Crt, SySutils, CIO;


var
  strBuffer : string;
// Effectus example
// -------------------------------------
// Using EXIT command in loop statements

procedure MAINProc;
var
  key : byte;
  n : byte;
begin  // 2
  Write(Chr(125));
  Writeln('Effectus example:');
  Writeln('Using EXIT command in loop statements FOR,WHILE and UNTIL');
  Writeln('');
  Writeln('Counting from 1 to 10...');
  Writeln('');
  for  n:=1 to 10 do begin
  Write(n);
  Write(Chr(44));
  if n=7 then begin
  break;
  end;  // if
  end;  // for
  Writeln('');
  Writeln('Escaped from FOR loop!');
  Writeln('');
  Writeln('Counting from 1 to 20...');
  Writeln('');
  n := 1;
  n := n+1;
 WHILE n<21 do begin
  Write(n);
  Write(Chr(44));
  if n=14 then begin
  break;
  end;  // if
  n := n+1;
  end;  // while
  Writeln('');
  Writeln('Escaped from WHILE loop!');
  Writeln('');
  Writeln('Counting from 1 to 6...');
  Writeln('');
  n := 0;
  repeat
  Inc(n);
  Write(n);
  Write(Chr(44));
  break;
  until  n=6;
  Writeln('');
  Writeln('Escaped from UNTIL loop!');
  key := Get(7);
  ReadKey;
end;  // 4

begin
  MAINProc;
end.
