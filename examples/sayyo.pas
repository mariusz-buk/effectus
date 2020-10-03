// Effectus auto-generated Mad Pascal source code listing
program sayyoPrg;

uses
  Crt, SySutils, CIO;

var
  isPasAsm : boolean;

var
  strBuffer : string;
// Effectus example
// ----------------
// Using Mad Pascal and Mad Assembler
// directly inside Effectus code listing
// with PAS {} and ASM {} code block

procedure SAYYOProc;
var
  rnd01 : byte;  // rnd01_byte_array
  rnd02 : byte;  // rnd02_byte_array
begin  // 2
  rnd01 := Random(255);
  rnd02 := Random(255);
  Write('YO! ');
  Poke(710, rnd01);
  Poke(712, rnd02);
end;

procedure MAINProc;
var
  ch : byte;  // ch_byte_array
  i : byte;  // i_byte_array
begin  // 1
  Writeln('Press any key for greetings!');
  asm {
  lda #0
  sta 710
  lda #42
  sta 712
  };
  repeat until keypressed;
  for i := 0 to 14 do begin
  SayYoProc;
  Sound(Random(3), 100, Random(10) + 8, 8);
  Delay(120);
  end;
  Poke(710, 80); Poke(712, 134);
  Sound(0, 0, 0, 0); Sound(1, 0, 0, 0);
  Sound(2, 0, 0, 0); Sound(3, 0, 0, 0);
  Writeln(#$9b#$9b'Press any key to exit!');
  ReadKey;
  //repeat until keypressed;
  ch := Get(7);
  ReadKey;
end;

begin
  MAINProc;
end.
