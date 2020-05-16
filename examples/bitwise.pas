// Effectus auto-generated Mad Pascal source code listing
program bitwisePrg;

uses
  SySutils, Crt;

// Effectus example
// -------------------------------------
// Logical (bitwise) manipulation demo
var
  key : char;
  n : byte;
  a : byte;
  b : byte;

procedure MAINProc;
begin  // 1
  Write(Chr(125));
  Writeln('Logical(bitwise) operators demo');
  Writeln('');
  Write('n=');
  n := 2;
  n := n+2;
  Writeln(n);
  Writeln('');
  Write('n==&2 Result: ');
  n := n AND 2;
  Writeln(n);
  Writeln('');
  Write('n=n&40 Result: ');
  n := n AND 40;
  Writeln(n);
  Writeln('');
  Write('n=');
  n := 2;
  Writeln(n);
  Writeln('');
  Write('n==!2 Result: ');
  n := n XOR 2;
  Writeln(n);
  Writeln('');
  Write('n==XOR 2 Result: ');
  n := n XOR 2;
  Writeln(n);
  Writeln('');
  Write('n==!n Result: ');
  n := n XOR n;
  Writeln(n);
  Writeln('');
  Writeln('a=40');
  Write('b=a LSH 1 Result: ');
  a := 40;
  b := a SHL 1;
  Writeln(b);
  Writeln('');
  Write('b=a RSH 1 Result: ');
  b := a SHR 1;
  Writeln(b);
  key := ReadKey;
end;  // 4

begin
  MAINProc;
end.
