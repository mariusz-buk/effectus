// Effectus auto-generated Mad Pascal source code listing
program procsPrg;

uses
  Crt, SySutils, CIO;


var
  strBuffer : string;
// Effectus example
// -------------------------------------
// Using local PROCedures
var
  m1 : word;
  m2 : word;
  key : byte;

procedure PRINTTEXTProc;
begin  // 1
  Write('', eol, 'Hello from PROC', eol, '', eol, '');
end;  // 4

procedure ShowNumProc(n : byte);
begin  // 6
  Write('Entered number is ');
  Writeln(n);
  if n<>20 then begin
  Writeln('It is not 20!');
  end;  // if
end;  // 4

// Calculate the sum of two 8-bit
// numbers and print the result to the
// screen
procedure SumBytesProc(n1 : byte; n2 : byte);
var
  total1 : byte;
begin  // 1
  total1 := n1+n2;
  Write('Result: ');
  Writeln(total1);
end;  // 4

// Calculate the sum of two 16-bit
// numbers and print the result to the
// screen
procedure SumCardsProc(c1 : word; c2 : word);
var
  total2 : word;
begin  // 1
  total2 := c1+c2;
  Write('Result: ');
  Writeln(total2);
end;  // 4

// Currently, mixed data types are not supported
procedure NumbersProc(e1 : word; e2 : word; e3 : byte; e4 : integer; e5 : integer);
begin  // 6
  Write('', eol, 'e1=', e1, ',e2=', e2, '');
  Write('', eol, 'e3=', e3, '');
  Write('', eol, 'e4=', e4, ',e5=', e5, '', eol, '');
end;  // 4

procedure MAINProc;
begin  // 6
  Write(Chr(125));
  Writeln('Effectus example:');
  Writeln('Using local PROCedures');
  PRINTTEXTProc;
  Write('Variable n holds value ');
  SHOWNUMProc(21);
  Writeln('');
  Writeln('Input parameters: 10 and 240');
  SUMBYTESProc(10, 240);
  Writeln('');
  m1 := 2100;
  m2 := 62000;
  Write('Input parameters: ');
  Write(m1);
  Write(' and ');
  Writeln(m2);
  Writeln('held in variables m1 and m2');
  SUMCARDSProc(m1, m2);
  NUMBERSProc(10000, 65200, 201, 32000, 4651);
  key := Get(7);
  ReadKey;
end;  // 4

begin
  MAINProc;
end.
