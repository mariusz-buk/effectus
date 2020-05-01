// Effectus auto-generated Mad Pascal source code listing
program scope02Prg;

uses
  SySutils, Crt;

// Effectus example
// -------------------------------------
// PROCedure and variable scope
var
  key : char;
  cvar : word;

procedure TEST01Proc;
begin
  Writeln('Hello there 01');
end;

procedure Test02Proc(n : byte);
var
  ii : integer;
begin
  Writeln('Hello there 02');
  Write(Chr(n));
  Writeln('ello there 03');
  ii := -1230;
  Writeln(ii);
end;

procedure Test03Proc(n : byte; cc : word);
begin
  Writeln(n);
  Writeln(cc);
  cvar := 65000;
  n := 10;
  cc := 50000;
  Writeln(n);
  Writeln(cc);
end;

procedure MAINProc;
var
  X : word;
  Y : word;
begin
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
  key := ReadKey;
end;

begin
  MAINProc;
end.
