// Effectus auto-generated Mad Pascal source code listing
program loop_exitPrg;

uses
  SySutils, Crt;

// Effectus example
// -------------------------------------
// Using EXIT command in loop statements

procedure MAINProc;
var
  key : char;
  n : byte;
begin
  Write(Chr(125));
  Writeln('Effectus example:');
  Writeln('Using EXIT command in loop statements FOR,WHILE and UNTIL');
  Writeln('');
  Writeln('Counting from 1 to 10...');
  Writeln('');
  n := 1;
  for  n:=1 to 10 do begin
  Write(n);
  Write(Chr(44));
  if n=7 then begin
  break;
  end;
  end;
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
  end;
  n := n+1;
  end;
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
  n := 6;
  until  n=6;
  Writeln('');
  Writeln('Escaped from UNTIL loop!');
  key := ReadKey;
end;

begin
  MAINProc;
end.
