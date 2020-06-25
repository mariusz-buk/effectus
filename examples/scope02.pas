// Effectus auto-generated Mad Pascal source code listing
program scope02Prg;

uses
  Crt, SySutils, CIO;


var
  strBuffer : string;
// Effectus example
// -------------------------------------
// PROCedure and variable scope
var
  key : byte;
  cvar : word;

procedure TEST01Proc;
begin  // 1
  Writeln('Hello there 01');
end;  // 4

procedure Test02Proc(n : byte);
var
  ii : integer;
begin  // 1
  Writeln('Hello there 02');
  Write(Chr(n));
  Writeln('ello there 03');
  ii := -1230;
  Writeln(ii);
end;  // 4

procedure Test03Proc(n : byte; cc : word);
begin  // 6
  Writeln(n);
  Writeln(cc);
  cvar := 65000;
  n := 10;
  cc := 50000;
  Writeln(n);
  Writeln(cc);
end;  // 4

procedure MAINProc;
var
  X : word;
  Y : word;
begin  // 1
  Write(Chr(125));
  Writeln('Hello world');
  X := 30;
  Y := 50;
  X := X * 20;
  Writeln(X);
  X := X * Y;
  Writeln(X);
  TEST01Proc;
  TEST02Proc(72);
  TEST03Proc(7, 2355);
  key := Get(7);
  ReadKey;
end;  // 4

begin
  MAINProc;
end.
