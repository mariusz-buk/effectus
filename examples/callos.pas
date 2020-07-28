// Effectus auto-generated Mad Pascal source code listing
program callosPrg;

uses
  Crt, SySutils, CIO;

var
  strBuffer : string;
// Effectus example
// ----------------
// Calling OS routines by using PROC
// memory assignment

procedure TEXTProc;
begin  // 6
  Writeln('Press two keys to scroll up!');
end;

// Scroll screen
procedure SCROLLProc;
begin
  asm {
    jsr $F7F7
    rts
  };
end;
// Keyclick sound
procedure CLICKProc;
begin
  asm {
    jsr $F983
    rts
  };
end;
// Read key
procedure KBGETProc;
begin
  asm {
    jsr $F302
    rts
  };
end;
// Cassette-beep sound
procedure BEEPWAITProc(times : byte);
begin
  asm {
    jsr $FDFC
    rts
  };
end;
procedure MAINProc;
var
  N : byte;
  key : byte;
begin  // 2
  Write(Chr(125));
  GotoXY(2 + 1,  18 + 1);
  TEXTProc;
  BEEPWAITProc(1);
  KBGETProc;
 FOR N:=1 TO 20 do begin
  CLICKProc;
  SCROLLProc;
  end;
  key := Get(7);
  ReadKey;
end;

begin
  MAINProc;
end.
