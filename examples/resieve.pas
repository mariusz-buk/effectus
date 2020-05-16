// Effectus auto-generated Mad Pascal source code listing
program resievePrg;

uses
  SySutils, Crt;

var
  ch : byte absolute 764;
  RTCLOCK : byte absolute 20;
  FLAGS : array[0..8191] of byte;

procedure SIEVEProc;
var
  SQRCOUNT : byte = 91;
  FRAME : byte = 0;
  N : word;
  K : word;
begin  // 1
  FRAME := RTCLOCK;
 WHILE FRAME=RTCLOCK do begin
  end;  // while
  FillChar(FLAGS, 8190, 1);
  for  N:=2 TO SQRCOUNT do begin
  if FLAGS[N]=1 then begin
  K := N*2;
 WHILE K<=8191 do begin
  FLAGS[K] := 0;
  Inc(K, N);
  end;  // for
  end;  // if
  end;  // while
end;  // 4

procedure MAINProc;
var
  N : word;
  COUNT : word = 0;
begin  // 1
  RTCLOCK := 0;
  SIEVEProc;
  Write('Effectus 0.4');
  Write('', eol, ' ', RTCLOCK, ' JIFFIES');
  for  N:=2 TO 8191 do begin
  if FLAGS[N]=1 then begin
  Inc(COUNT);
  end;  // if
  end;  // for
  Write('', eol, ' ', COUNT, ' PRIMES');
  ch := 255;
 WHILE ch=255 do begin
  end;  // while
end;  // 4

begin
  MAINProc;
end.
