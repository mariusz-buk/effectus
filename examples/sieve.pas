// Effectus auto-generated Mad Pascal source code listing
program sievePrg;

uses
  Crt, SySutils, CIO;

var
  strBuffer : string;
// Effectus example
// ----------------
// SIEVE benchmark test
var
  RTCLOK : byte absolute 20;
  SDMCTL : byte absolute 559;
  FLAGS : array[0..8190] of byte;
  COUNT : word;
  I : word;
  K : word;
  PRIME : word;
  TIME : word;
  key : byte;

procedure SIEVEProc;
begin  // 1
  SDMCTL := 0;
  RTCLOK := 0;
  COUNT := 0;
 FOR I:=0 TO 8190 do begin
  FLAGS[I] := 84;
  end;
 FOR I:=0 TO 8190 do begin
  if  FLAGS[I]=84  then begin
  PRIME := I+I+3;
  K := I+PRIME;
 WHILE K<=8190 do begin
  FLAGS[K] := 70;
  Inc(K, PRIME);
  end;
  Inc(COUNT);
  end;  // if
  end;
  TIME := RTCLOK;
  SDMCTL := 34;
  Write('', eol, ' ', COUNT, ' PRIMES IN');
  Write('', eol, ' ', TIME, ' JIFFIES');
  key := Get(7);
  ReadKey;
end;

begin
  SIEVEProc;
end.
