// Effectus auto-generated Mad Pascal source code listing
program strvalPrg;

uses
  SySutils, Crt;

// Effectus example
// -------------------------------------
// Number to string conversion using
// StrB, StrI and StrC procedures
// 
// String to number conversion by using
// ValB, ValI and ValC functions
var
  key : char;
  num1 : byte;
  num2 : integer;
  num3 : word;
  strnum1 : string[6];
  strnum2 : string[6];
  strnum3 : string[6];

procedure MAINProc;
begin  // 1
  Write(Chr(125));
  Writeln('Effectus example:');
  Writeln('');
  Writeln('Number to string conversion using');
  Writeln('StrB,StrI and StrC procedures');
  Writeln('');
  strnum1 := IntToStr(65000);
  strnum2 := IntToStr(3200);
  strnum3 := IntToStr(178);
  Write('strnum1=');
  Writeln(strnum1);
  Write('strnum2=');
  Writeln(strnum2);
  Write('strnum3=');
  Writeln(strnum3);
  Writeln('');
  Writeln('String to number conversion by using');
  Writeln('ValB,ValI and ValC');
  Writeln('');
  num1 := StrToInt('100');
  Write('num1=');
  Writeln(num1);
  num2 := StrToInt('1500');
  Write('num2=');
  Writeln(num2);
  num3 := StrToInt('44611');
  Write('num3=');
  Writeln(num3);
  key := ReadKey;
end;  // 4

begin
  MAINProc;
end.
