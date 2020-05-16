// Effectus auto-generated Mad Pascal source code listing
program callosPrg;

uses
  SySutils, Crt;

// Effectus example
// -------------------------------------
// Calling OS routines by using PROC
// memory assignment

procedure TEXTProc;
begin  // 6
  Writeln('Press two keys to scroll up!');
end;  // 4

// Scroll screen
procedure SCROLLProc;
begin
  asm {
    jsr $F7F7
    rts
  };
end;  // 5
// Keyclick sound
procedure CLICKProc;
begin
  asm {
    jsr $F983
    rts
  };
end;  // 5
// Read key
procedure KBGETProc;
begin
  asm {
    jsr $F302
    rts
  };
end;  // 5
// Cassette-beep sound
procedure BEEPWAITProc(times : byte);
begin
  asm {
    jsr $FDFC
    rts
  };
end;  // 6
procedure MAINProc;
var
  N : byte;
  key : char;
begin  // 2
  Write(Chr(125));
  GotoXY(2 + 1,  18 + 1);
  TEXTProc;
  BEEPWAITProc(1);
  KBGETProc;
  for  N:=1 TO 20 do begin
  CLICKProc;
  SCROLLProc;
  end;  // for
  key := ReadKey;
end;  // 4

begin
  MAINProc;
end.
