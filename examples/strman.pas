// Effectus auto-generated Mad Pascal source code listing
program strmanPrg;

uses
  SySutils, Crt;

// Effectus example
// -------------------------------------
// Using string manipulation PROCedures
// SCopy, ScopyS and SAssign
// 
// SBYTE ARRAY as temporary substitution
// for string assignment (not original
// Action! command)

procedure MAINProc;
var
  key : char;
  STR01 : string[21];
  STR02 : string[15];
  STR03 : string[15];
begin
  Write(Chr(125));
  Writeln('');
  STR01 :=  'HELLO THERE: ATARIAN';
  STR02 := Copy( STR01, 1,  5 -  1 + 1);
  Write('STR01=');
  Writeln(STR01);
  Write('STR02=');
  Writeln(STR02);
  STR03 := Copy( STR01, 7,  11 -  7 + 1);
  Write('STR03=');
  Writeln(STR03);
  STR01 := Concat(Concat(Copy(STR01, 1,  7 - 1),  'ATARI'), Copy(STR01,  11 + 1, Length(STR01)));
  Write('STR01=');
  Writeln(STR01);
  key := ReadKey;
end;

begin
  MAINProc;
end.
