// Effectus auto-generated Mad Pascal source code listing
program soundsPrg;

uses
  Crt, Graph;

// Effectus example
// -------------------------------------
// Sound demo
// (using Sound and SndRst procedures)
var
  CH : byte absolute 764;
  COL : byte absolute 710;

procedure WAITFORKEYProc;
begin  // 1
 WHILE CH=255 do begin
  end;  // while
  CH := 255;
end;  // 4

procedure SPACEKEYProc;
begin  // 6
 WHILE CH<>33 do begin
  end;  // while
  CH := 255;
end;  // 4

procedure MAINProc;
begin  // 6
  Write(Chr(125));
  Poke(82, 0);
  Poke(708 + 2,  0*16 +  0);
  Writeln('Effectus example:');
  Writeln('Sound demonstration');
  Writeln('');
  Writeln('Press space for first s. channel!');
  SPACEKEYProc;
  COL := 50;
  Sound(0, 100, 10, 10);
  Writeln('Press space for second s. channel!');
  SPACEKEYProc;
  COL := 100;
  Sound(1, 140, 12, 12);
  Writeln('Press space for third s. channel!');
  SPACEKEYProc;
  COL := 150;
  Sound(2, 200, 14, 6);
  Writeln('Press space for fourth s. channel!');
  SPACEKEYProc;
  COL := 180;
  Sound(3, 70, 10, 4);
  Writeln('');
  Writeln('**************+*********************');
  Writeln('Press any key to shut off the sound!');
  Writeln('***************+********************');
  WAITFORKEYProc;
  COL := 240;
  Sound(0, 0, 0, 0);
  Sound(1, 0, 0, 0);
  Sound(2, 0, 0, 0);
  Sound(3, 0, 0, 0);
end;  // 4

begin
  MAINProc;
end.
