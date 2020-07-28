// Effectus auto-generated Mad Pascal source code listing
program rainbowPrg;

uses
  Crt, Graph;

// Effectus example
// ----------------
// Rainbow graphics demo
// **********************************************************************
// *                                                                    *
// * PhoeniX SoftCrew  ACTION! Programme                                *
// **********************************************************************
// Programmname    :Rainbow
// Filename        :RAINBOW.ACT
// von             :Carsten Strotmann
// letzte Aenderung:12.10.91
// Bemerkung       :fuer M.Heinzig

procedure RAINBOWProc;
var
  vcount : byte absolute $D40B;
  wsync : byte absolute $D40A;
  rtclok : byte absolute $14;
  getcolor : byte absolute $D018;
  u : byte absolute $7;
  ch : byte absolute 764;
begin  // 2
  ch := $FF;
  repeat
  wsync := u;
  getcolor := vcount+rtclok;
 UNTIL ch<>$FF;
end;

begin
  RAINBOWProc;
end.
