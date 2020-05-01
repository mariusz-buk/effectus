// Effectus auto-generated Mad Pascal source code listing
program butterflyPrg;

uses
  SySutils, Crt, Graph;

// Effectus example
// -------------------------------------
// Graphics mode 9 demo
// Butterfly  by michael mitchell
// Original date: 01/20/85

procedure DEMO2Proc;
var
  A : word;
  B : word;
  C : word;
  D : word;
  X : word;
  Y : word;
  J : word;
  K : word;
  COL : word;
  I : word;
  Q : word;
begin
  InitGraph(11);
  Poke(710, 0);
  SetColor(0);
  A := 1;
  B := 1;
  C := 1;
  D := 1;
  X := Random(70);
  Y := Random(190);
  J := Random(50);
  K := Random(190);
  I := 1;
  for  I:=1 TO 9400 do begin
  PutPixel(X, Y);
  MoveTo(X, Y);
  LineTo(J, K);
  PutPixel(J, Y);
  MoveTo(J, Y);
  LineTo(X, K);
  Inc(X, A);
  Inc(Y, B);
  Inc(J, C);
  Inc(K, D);
  Q := Random(50);
  if Q>40 then begin
  Inc(COL);
  end;
  if COL>14 then begin
  COL := 1;
  end;
  SetColor(COL);
  if X>=79 then begin
  A := -A;
  Inc(X, A);
  end;
  if J>=79 then begin
  C := -C;
  Inc(J, C);
  end;
  if J<=0 then begin
  C := -C;
  Inc(J, C);
  end;
  if X<=0 then begin
  A := -A;
  Inc(X, A);
  end;
  if Y>=191 then begin
  B := -B;
  Inc(Y, B);
  end;
  if K>=191 then begin
  D := -D;
  Inc(K, D);
  end;
  if K<=0 then begin
  D := -D;
  Inc(K, D);
  end;
  if Y<=0 then begin
  B := -B;
  Inc(Y, B);
  end;
  end;
end;

begin
  DEMO2Proc;
end.
